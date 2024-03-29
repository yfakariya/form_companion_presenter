// See LICENCE file in the root.

import 'dart:async';
import 'dart:collection';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'arguments_handler.dart';
import 'dependency.dart';
import 'node_provider.dart';
import 'parser/parser_helpers.dart';
import 'type_instantiation.dart';
import 'utilities.dart';
import 'utilities.dart' as u;

class _FieldInfo {
  final TypeAnnotation? typeAnnotation;
  final DartType declaringType;
  _FieldInfo(this.typeAnnotation, this.declaringType);
}

class _FunctionTypedParameterDefaultValueInfo {
  final String defaultValueCode;
  final FunctionTypedParameterDefaultValueMethod? method;

  _FunctionTypedParameterDefaultValueInfo.withMethod(
    FunctionTypedParameterDefaultValueMethod method,
  )   : defaultValueCode = method.name,
        method = method;

  _FunctionTypedParameterDefaultValueInfo.withoutMethod(
    this.defaultValueCode,
  ) : method = null;
}

/// Represents a static method source to
/// build function typed parameter's default value.
class FunctionTypedParameterDefaultValueMethod {
  /// Gets a name of the static method.
  final String name;

  /// Gets a return value type of the static method.
  final TypeAnnotation returnType;

  /// Gets parameters of the static method.
  final FormalParameterList parameters;

  /// Gets a function body of the static method.
  final FunctionBody body;

  FunctionTypedParameterDefaultValueMethod._(
    this.name,
    this.returnType,
    this.parameters,
    this.body,
  );

  FunctionTypedParameterDefaultValueMethod._fromFunction(
    String name,
    FunctionDeclaration function,
  ) : this._(
          name,
          function.returnType!,
          function.functionExpression.parameters!,
          function.functionExpression.body,
        );

  FunctionTypedParameterDefaultValueMethod._fromMethod(
    String name,
    MethodDeclaration method,
  ) : this._(
          name,
          method.returnType!,
          method.parameters!,
          method.body,
        );
}

/// Represents a parameter.
@sealed
class ParameterInfo {
  /// Gets a name of this parameter.
  final String name;

  /// Gets a static [DartType] of this parameter.
  final DartType type;

  /// `true` if [type] is collection type (implements [Iterable]).
  final bool isCollectionType;

  /// Gets a [FormalParameter] which holds syntax information of this parameter.
  final FormalParameter node;

  /// Gets a name of type which declares this parameter.
  ///
  /// Normal, this is same as leaf type except super parameters.
  /// Superparameters can be chained to ancestor type, and eventually declared
  /// in the ancestor which might required difference generic type resolution.
  /// For example, when `SomeFormField<T> extends FormField<List<T>>` uses
  /// `super.onChanged`, the type paramter `T` of parameter type `ValueChanged<T>`
  /// which is declared in `FormField<T>` should be resolved `List<I>` instead of
  /// `I` where `I` is type argument for `SomeFormField<T>`.
  final String declaringTypeName;

  /// Gets a declared [TypeAnnotation] of this parameter.
  ///
  /// `null` if parameter is a function type formal parameter like `int foo(String bar)`.
  final TypeAnnotation? typeAnnotation;

  /// Gets a declared parameter as [FunctionTypedFormalParameter].
  ///
  /// `null` if parameter is not a function type formal parameter like `int foo(String bar)`.
  final FunctionTypedFormalParameter? functionTypedParameter;

  /// Gets a extra keyword like `final`.
  final String? keyword;

  /// Gets a requiability of this parameter.
  final ParameterRequirability requirability;

  /// Gets a default value of this parameter if exists.
  final String? defaultValue;

  /// Gets a method declaration if and only if the [defaultValue] is identifier
  /// of non public static method as default value of function typed parameter.
  final FunctionTypedParameterDefaultValueMethod? defaultTargetNonPublicMethod;

  /// Returns `true` if this parameter has default value.
  bool get hasDefaultValue => defaultValue != null;

  /// Initializes a new [ParameterInfo] instance.
  ParameterInfo._(
    this.node,
    this.name,
    this.type,
    this.typeAnnotation,
    this.functionTypedParameter,
    this.declaringTypeName,
    this.keyword,
    this.defaultValue,
    this.defaultTargetNonPublicMethod,
    this.requirability, {
    required this.isCollectionType,
  });

  /// Creates a new [ParameterInfo] isntance from specified [FormalParameter].
  static FutureOr<ParameterInfo> fromNodeAsync(
    NodeProvider nodeProvider,
    FormalParameter node,
  ) async {
    if (node is DefaultFormalParameter) {
      // Parse left side with recursive call.
      final base =
          await ParameterInfo.fromNodeAsync(nodeProvider, node.parameter);

      final defaultValueType = node.parameter.declaredElement?.type;
      late final String? defaultValueCode;
      late final FunctionTypedParameterDefaultValueMethod?
          defaultTargetNonPublicMethod;

      if (base.defaultValue != null &&
          base.defaultValue != 'null' &&
          defaultValueType is FunctionType) {
        final lookupResult = await _lookupDefaultTargetNonPublicMethodAsync(
          nodeProvider,
          node,
        );
        defaultTargetNonPublicMethod = lookupResult.method;
        defaultValueCode = lookupResult.defaultValueCode;
      } else {
        defaultTargetNonPublicMethod = null;
        defaultValueCode = base.defaultValue;
      }

      return ParameterInfo._(
        // Use original DefaultFormalParameter for `node` for DependencyCollector.
        node,
        base.name,
        base.type,
        base.typeAnnotation,
        base.functionTypedParameter,
        base.declaringTypeName,
        base.keyword,
        defaultValueCode,
        defaultTargetNonPublicMethod,
        // Existence of the default value is not considered here
        // because the requirability always be considered in named parameters
        // context.
        base.requirability,
        isCollectionType: base.isCollectionType,
      );
    }

    if (node is SimpleFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo._(
        node,
        node.name!.lexeme,
        element.type,
        node.type,
        null,
        // Empty string for top-level functions (abnormal, but it is useful in unit testing)
        node.thisOrAncestorOfType<ClassDeclaration>()?.name.lexeme ?? '',
        node.keyword?.stringValue,
        element.defaultValueCode,
        null,
        element.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.notRequired,
        isCollectionType: u.isCollectionType(element.type, element),
      );
    }

    if (node is FieldFormalParameter) {
      final parameterElement = node.declaredElement!;
      final fieldType = await _getThisFieldTypeAnnotationAsync(
        nodeProvider,
        node,
        parameterElement,
      );
      return ParameterInfo._(
        node,
        node.name.lexeme,
        parameterElement.type,
        fieldType.typeAnnotation,
        null,
        node.thisOrAncestorOfType<ClassDeclaration>()!.name.lexeme,
        node.keyword?.stringValue,
        parameterElement.defaultValueCode,
        null,
        parameterElement.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.notRequired,
        isCollectionType: u.isCollectionType(
          parameterElement.type,
          parameterElement,
        ),
      );
    }

    if (node is FunctionTypedFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo._(
        node,
        node.name.lexeme,
        element.type,
        null,
        node,
        node.thisOrAncestorOfType<ClassDeclaration>()!.name.lexeme,
        null,
        element.defaultValueCode,
        null,
        element.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.notRequired,
        isCollectionType: u.isCollectionType(element.type, element),
      );
    }

    if (node is SuperFormalParameter) {
      final parameterElement = node.declaredElement!;
      final fieldInfo = await _getSuperFieldTypeAnnotationAsync(
        nodeProvider,
        node,
        parameterElement,
      );
      return ParameterInfo._(
        node,
        node.name.lexeme,
        parameterElement.type,
        fieldInfo.typeAnnotation,
        null,
        fieldInfo.declaringType.element?.name ??
            fieldInfo.declaringType.getDisplayString(withNullability: false),
        node.keyword?.stringValue,
        parameterElement.defaultValueCode,
        null,
        parameterElement.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.notRequired,
        isCollectionType: u.isCollectionType(
          parameterElement.type,
          parameterElement,
        ),
      );
    }

    // coverage:ignore-start
    assert(
      false,
      "Failed to parse complex parameter '$node' (${node.runtimeType}) "
      'at ${getNodeLocation(node, node.declaredElement!)} ',
    );
    throwError(
      message:
          "Failed to parse complex parameter '$node' (${node.runtimeType}) at ${getNodeLocation(node, node.declaredElement!)} ",
      element: node.declaredElement,
    );
    // coverage:ignore-end
  }

  static FutureOr<_FunctionTypedParameterDefaultValueInfo>
      _lookupDefaultTargetNonPublicMethodAsync(
    NodeProvider nodeProvider,
    DefaultFormalParameter parameter,
  ) async {
    FutureOr<_FunctionTypedParameterDefaultValueInfo> buildAsync(
      String name,
      ExecutableElement element,
    ) async {
      final node = await nodeProvider.getElementDeclarationAsync(element);
      if (node is MethodDeclaration) {
        return _FunctionTypedParameterDefaultValueInfo.withMethod(
          FunctionTypedParameterDefaultValueMethod._fromMethod(
            name,
            node,
          ),
        );
      } else {
        assert(
          node is FunctionDeclaration,
          // coverage:ignore-start
          "'$node' (${node.runtimeType}) is unknown AstNode for element "
          "'$element'(${element.runtimeType}).",
          // coverage:ignore-end
        );
        return _FunctionTypedParameterDefaultValueInfo.withMethod(
          FunctionTypedParameterDefaultValueMethod._fromFunction(
            name,
            node as FunctionDeclaration,
          ),
        );
      }
    }

    final parameterElement = parameter.declaredElement!;
    late final Expression defaultValue;
    if (parameter.defaultValue != null) {
      defaultValue = parameter.defaultValue!;
    } else {
      // from left
      // Caller should call when base.defaultValue is not null.
      assert(parameter.parameter.declaredElement?.defaultValueCode != null);

      // When the super parameter has default value which is declared in
      // the super class, parameter.defaultValue is null
      // but parameter.parameter.declaredElement?.defaultValueCode is not null.
      // We can get the default value expression from AstNode for
      // element.superConstructorParameter element here.
      assert(
        parameter.parameter.declaredElement is SuperFormalParameterElement,
      );
      final superElement =
          parameter.parameter.declaredElement! as SuperFormalParameterElement;
      assert(
        superElement.superConstructorParameter != null,
        '$superElement in ${parameter.parent} does not have superConstructorParameter.', // coverage:ignore-line
      );
      final leftNode =
          await nodeProvider.getElementDeclarationAsync<DefaultFormalParameter>(
        superElement.superConstructorParameter!,
      );
      defaultValue = leftNode.defaultValue!;
    }

    if (defaultValue is SimpleIdentifier) {
      final declaringClass =
          parameterElement.thisOrAncestorOfType<InterfaceElement>()!;
      final maybeThisMethod = declaringClass.lookUpMethod(
        defaultValue.name,
        parameterElement.library!,
      );
      if (!defaultValue.name.startsWith('_')) {
        // public method or function
        return _FunctionTypedParameterDefaultValueInfo.withoutMethod(
          maybeThisMethod != null
              // The building field factory is not "declaringClass",
              // so class name prefix is required.
              ? '${declaringClass.name}.${defaultValue.name}'
              // Top level function, so prefix does not exist.
              : defaultValue.name,
        );
      } else {
        return await buildAsync(
          maybeThisMethod == null
              ? defaultValue.name
              : '_default_${declaringClass.name}_${defaultValue.name}',
          maybeThisMethod ??
              lookupMethod(
                parameterElement,
                null,
                defaultValue.name,
                defaultValue,
              ),
        );
      }
    }

    if (defaultValue is PrefixedIdentifier) {
      final prefix = defaultValue.prefix;
      final identifier = defaultValue.identifier;
      if (!prefix.name.startsWith('_') && !identifier.name.startsWith('_')) {
        // public method
        return _FunctionTypedParameterDefaultValueInfo.withoutMethod(
          defaultValue.name,
        );
      } else {
        return await buildAsync(
          '_default_${prefix.name}_${identifier.name}',
          lookupMethod(
            parameterElement,
            parameterElement.library!.scope.lookup(prefix.name).getter!
                as InterfaceElement,
            identifier.name,
            defaultValue,
          ),
        );
      }
    }

    // coverage:ignore-start
    assert(
      false,
      "Unexpected default value type of '$defaultValue': ${defaultValue.runtimeType}",
    );
    throwNotSupportedYet(node: parameter, contextElement: parameterElement);
    // coverage:ignore-end
  }

  /// Returns a copy of this instance clearing [defaultValue] and setting
  /// [ParameterRequirability.forciblyOptional].
  ParameterInfo asForciblyOptional() => ParameterInfo._(
        node,
        name,
        type,
        typeAnnotation,
        functionTypedParameter,
        declaringTypeName,
        keyword,
        null,
        null,
        ParameterRequirability.forciblyOptional,
        isCollectionType: isCollectionType,
      );

  static FutureOr<_FieldInfo> _getThisFieldTypeAnnotationAsync(
    NodeProvider nodeProvider,
    FieldFormalParameter node,
    ParameterElement parameterElement,
  ) async {
    final classElement = parameterElement.thisOrAncestorOfType<ClassElement>()!;
    final fieldElement = classElement.lookUpGetter(
      node.name.lexeme,
      parameterElement.library!,
    )!;
    return _getFieldTypeAnnotationCoreAsync(
      nodeProvider,
      parameterElement.thisOrAncestorOfType<ClassElement>()!,
      node,
      parameterElement,
      fieldElement,
    );
  }

  static FutureOr<_FieldInfo> _getSuperFieldTypeAnnotationAsync(
    NodeProvider nodeProvider,
    SuperFormalParameter node,
    ParameterElement parameterElement,
  ) async {
    final targetClass = parameterElement.thisOrAncestorOfType<ClassElement>();
    assert(
      targetClass != null,
      'Failed to find class declaration of $parameterElement', // coverage:ignore-line
    );

    final superClass = targetClass!.supertype?.element;
    assert(
      superClass != null,
      'Failed to find super class of $targetClass', // coverage:ignore-line
    );

    final superConstructor =
        superClass!.constructors.singleWhereOrNull((c) => c.name.isEmpty);
    assert(
      superConstructor != null,
      'Failed to find constructor of $superClass for $node', // coverage:ignore-line
    );

    final parameterOnSuperConstructor = superConstructor!.parameters
        .singleWhereOrNull((p) => p.name == parameterElement.name);
    assert(
      parameterOnSuperConstructor != null,
      // coverage:ignore-start
      "Failed to find parameter '${parameterElement.name}' in constructor of "
      '$superClass',
      // coverage:ignore-end
    );

    return _getConstructorParameterTypeAnnotationAsync(
      nodeProvider,
      superClass,
      await nodeProvider.getElementDeclarationAsync<FormalParameter>(
        parameterOnSuperConstructor!,
      ),
      parameterOnSuperConstructor,
    );
  }

  static FutureOr<_FieldInfo> _getConstructorParameterTypeAnnotationAsync(
    NodeProvider nodeProvider,
    InterfaceElement declaringClass,
    FormalParameter parameterNode,
    ParameterElement parameterElement,
  ) async {
    if (parameterNode is SimpleFormalParameter) {
      return _FieldInfo(parameterNode.type, declaringClass.thisType);
    }

    if (parameterNode is FieldFormalParameter) {
      return await _getFieldTypeAnnotationCoreAsync(
        nodeProvider,
        declaringClass,
        parameterNode,
        parameterElement,
        declaringClass.lookUpGetter(
          parameterNode.name.lexeme,
          parameterElement.library!,
        )!,
      );
    }

    if (parameterNode is SuperFormalParameter) {
      return await _getSuperFieldTypeAnnotationAsync(
        nodeProvider,
        parameterNode,
        parameterElement,
      );
    }

    if (parameterNode is DefaultFormalParameter) {
      return await _getConstructorParameterTypeAnnotationAsync(
        nodeProvider,
        declaringClass,
        parameterNode.parameter,
        parameterNode.parameter.declaredElement!,
      );
    }

    assert(
      parameterNode is FunctionTypedFormalParameter,
      'Unknown parameter type of $parameterNode: ${parameterNode.runtimeType}', // coverage:ignore-line
    );

    return _FieldInfo(null, declaringClass.thisType);
  }

  static FutureOr<_FieldInfo> _getFieldTypeAnnotationCoreAsync(
    NodeProvider nodeProvider,
    InterfaceElement classElement,
    FormalParameter node,
    ParameterElement parameterElement,
    Element fieldElement,
  ) async {
    final fieldNode = await nodeProvider
        .getElementDeclarationAsync(fieldElement.nonSynthetic);
    // Always become VariableDeclaration which is retrieved from FieldFormalParameter.
    assert(fieldNode is VariableDeclaration);
    return _FieldInfo(
      (fieldNode.parent! as VariableDeclarationList).type,
      classElement.thisType,
    );
  }
}

/// Represents 'requirability' of the parameter.
enum ParameterRequirability {
  /// Parameter is required in its declaration.
  required,

  /// Parameter is not required in its declaration.
  ///
  /// Note that positional parameters requirability should be determined with
  /// their type, so all positional parameters should be [notRequired].
  notRequired,

  /// Paramter shoul
  /// d be treated as nullable and optional regardless its declaration.
  forciblyOptional,
}

/// Represents target presenter data.
class PresenterDefinition {
  /// A class name of this presenter.
  final String name;

  /// A value this presenter is `FormBuilderCompanionMixin` or not.
  final bool isFormBuilder;

  /// A defined properties and their `FormField`s information.
  /// Key is a name of each properties.
  /// This list is mutable.
  final List<PropertyAndFormFieldDefinition> properties;

  /// A unordered list of [LibraryImport] which represents prefixed library
  /// imports and restricted library imports.
  final List<LibraryImport> imports;

  /// Gets a presenter-wide warnings generated by parser.
  /// This list is unmodifiable.
  final List<String> warnings;

  // NOTE: Form.autoValidateMode is rarely speified.
  //       If the value is set to AutovalidateMode.onUserInteraction,
  //       all fields are validated at once, and the default is
  //       AutovalidateMode.disabled which is preferred one because individual
  //       fields will be validated on each user interaction.

  /// An autoValidateMode value for each fields.
  /// This value is derrived from the annotation.
  final String? fieldAutovalidateMode;

  /// Initializes a new instance from specified values generated by parser.
  PresenterDefinition({
    required this.name,
    required this.isFormBuilder,
    required bool doAutovalidate,
    required List<String> warnings,
    required this.imports,
    required List<PropertyAndFormFieldDefinition> properties,
  })  : warnings = List.unmodifiable(warnings),
        properties = List.unmodifiable(properties),
        fieldAutovalidateMode =
            doAutovalidate ? 'AutovalidateMode.onUserInteraction' : null;
}

const _annotationLibrary =
    'package:form_companion_presenter/src/form_companion_annotation.dart';

/// Determines that specified [ElementAnnotation] is `FormCompanion` or not.
bool isFormCompanionAnnotation(ElementAnnotation annotation) {
  // We use hand written logic instead of GeneratorForAnnotation to avoid
  // dependency to `form_presenter_companion` which causes a lot of error
  // related to flutter SDK because the SDK prohibits reflection (dart:mirrors)
  // but test tool chain of build_runner depends reflection.
  final element = annotation.element;
  if (element is PropertyAccessorElement) {
    return element.library.identifier == _annotationLibrary &&
        element.name == 'formCompanion';
  } else if (element is ConstructorElement) {
    return element.library.identifier == _annotationLibrary &&
        element.enclosingElement.name == 'FormCompanion';
  }

  return false;
}

/// A convinient accessor for a constant evaluated `FormCompanion` annotation.
@sealed
class FormCompanionAnnotation {
  final ConstantReader _annotation;

  /// Whether the presenter prefers autovalidate or not.
  bool? get autovalidate {
    final value = _annotation.read('autovalidate');
    if (value.isNull) {
      return null;
    } else {
      return value.boolValue;
    }
  }

  /// Initializes a new instance which wraps specified [ConstantReader] for a `FormCompanion` annotation.
  FormCompanionAnnotation(this._annotation);

  /// Returns [FormCompanionAnnotation] for given class.
  ///
  /// If [ClassElement] is not quailified with `FormCompanion` annotation,
  /// this method returns `null`.
  static FormCompanionAnnotation? forClass(ClassElement classElement) {
    final annotationReader = classElement.metadata
        .where(isFormCompanionAnnotation)
        .whereType<ElementAnnotation?>()
        .firstWhere((_) => true, orElse: () => null)
        ?.computeConstantValue();

    if (annotationReader == null) {
      return null;
    }

    return FormCompanionAnnotation(ConstantReader(annotationReader));
  }
}

/// Represents mix-in type of presenter.
enum MixinType {
  /// `FormCompanionMixin`
  formCompanionMixin,

  /// `FormBuilderCompanionMixin`
  formBuilderCompanionMixin,
}

/// Represents interface type as transparent structured object.
abstract class GenericType {
  /// Raw type part of generic type.
  ///
  /// This can be instantiated generic type.
  DartType get rawType;

  /// Type arguments part of generic type.
  ///
  /// This value will be empty when the type is non-generic types and [rawType]
  /// is instantiated generic type.
  List<GenericType> get typeArguments;

  /// Gets a [rawType] as [InterfaceType] or `null` when [rawType] is not an
  /// [InterfaceType].
  InterfaceType? get maybeAsInterfaceType;

  /// Gets a [GenericType] which represents type of each items in this collection
  /// type. `null` when this type is not a collection type.
  ///
  /// Note that collection type means that this type can assign to [Iterable],
  /// and the value of this property should be single generic type argument of
  /// casted [Iterable].
  GenericType? get collectionItemType;

  /// Whether this type is enum or not.
  bool get isEnumType => false;

  /// Whether this type is [bool] or not.
  bool get isBoolType => false;

  /// Whether this type is [String] or not.
  bool get isStringType => false;

  /// Whether this type is nullable or not.
  bool get isNullable;

  /// Whether this type contains any non-instantiated generic type parameters or not.
  bool get hasTypeParameter;

  /// Returns a new [GenericType] instance.
  factory GenericType.generic(
    DartType rawType,
    List<GenericType> typeArguments,
    Element contextElement,
  ) {
    if (rawType is InterfaceType && typeArguments.isNotEmpty) {
      return _InstantiatedGenericInterfaceType(
        rawType,
        _toRawInterfaceType(rawType),
        typeArguments,
      );
    } else if (rawType is FunctionType) {
      return _InstantiatedGenericFunctionType(
        rawType,
        _toRawFunctionType(rawType),
        typeArguments,
        _buildFunctionTypeGenericArguments(
          rawType,
          typeArguments,
          contextElement,
        ),
        contextElement,
      );
    } else {
      return _NonGenericType(rawType, contextElement);
    }
  }

  /// Initializes a new [GenericType] instance from [DartType].
  factory GenericType.fromDartType(DartType type, Element contextElement) {
    // NOTE: currenty, `type` never be non-instantiated generic type.

    if (type is InterfaceType) {
      if (type.typeArguments.isNotEmpty) {
        // recursively parse it.
        return GenericType.generic(
          type,
          type.typeArguments
              .map(
                (t) => GenericType.fromDartType(t, contextElement),
              )
              .toList(),
          contextElement,
        );
      }

      // else: fall-through to _NonGenericType().
    } else if (type is FunctionType) {
      final alias = type.alias;
      if (alias == null) {
        final typeArgumentsMap = LinkedHashMap<String, DartType?>();
        final typeFormals = {for (final f in type.typeFormals) f.name: f};
        for (final typeFormal in type.typeFormals) {
          typeArgumentsMap[typeFormal.name] = null;
        }

        if (type.returnType is TypeParameterType) {
          typeArgumentsMap.update(
            type.returnType.element!.name!,
            (_) => type.returnType,
          );
        }

        type.parameters.where((p) => p.type is TypeParameterType).forEach(
              (p) => typeArgumentsMap.update(
                p.type.element!.name!,
                (_) => p.type,
              ),
            );

        assert(
          typeArgumentsMap.values.every((v) => v != null),
          // coverage:ignore-start
          "Unmapped type formals of '$type': "
          "[${typeArgumentsMap.entries.where((e) => e.value == null).map((e) => e.key).join(', ')}]",
          // coverage:ignore-end
        );

        final typeArguments = typeArgumentsMap.entries
            .map(
              (e) => GenericType.fromDartType(e.value!, typeFormals[e.key]!),
            )
            .toList();
        return _InstantiatedGenericFunctionType(
          type,
          _toRawFunctionType(type),
          typeArguments,
          _buildFunctionTypeGenericArguments(
            type,
            typeArguments,
            contextElement,
          ),
          contextElement,
        );
      } else {
        final typeArguments = alias.typeArguments
            .map((t) => GenericType.fromDartType(t, contextElement))
            .toList();
        return _InstantiatedGenericFunctionType(
          type,
          _toRawFunctionType(type),
          typeArguments,
          _buildFunctionTypeGenericArguments(
            type,
            typeArguments,
            contextElement,
          ),
          contextElement,
        );
      }
    }

    return _NonGenericType(type, contextElement);
  }

  GenericType._();

  static InterfaceType _toRawInterfaceType(InterfaceType type) =>
      type.element.thisType;

  static FunctionType _toRawFunctionType(FunctionType type) =>
      (type.element?.nonSynthetic as FunctionTypedElement?)?.type ?? type;

  @override
  @nonVirtual
  String toString() => getDisplayString(withNullability: true);

  /// Returns a [String] to display this type.
  ///
  /// This method simulates [DartType.getDisplayString].
  @nonVirtual
  String getDisplayString({
    required bool withNullability,
  }) {
    final sink = StringBuffer();
    writeTo(sink, withNullability: withNullability);
    return sink.toString();
  }

  /// Writes [getDisplayString] result to the specified [sink].
  void writeTo(
    StringSink sink, {
    required bool withNullability,
  });
}

/// Represents non generic type.
@sealed
class _NonGenericType extends GenericType {
  final Element _contextElement;

  /// Gets a wrapped [DartType].
  final DartType type;

  @override
  DartType get rawType {
    final element = type.element;
    if (element is ClassElement) {
      return element.thisType;
    }

    return type;
  }

  @override
  InterfaceType? get maybeAsInterfaceType {
    final type = this.type;
    if (type is InterfaceType) {
      return type;
    } else {
      return null;
    }
  }

  @override
  GenericType? get collectionItemType {
    final itemType = getCollectionElementType(type, _contextElement);
    return itemType == null
        ? null
        : GenericType.fromDartType(itemType, _contextElement);
  }

  @override
  bool get isEnumType => u.isEnumType(type, _contextElement);

  @override
  bool get isBoolType =>
      _contextElement.library?.typeSystem
          .promoteToNonNull(type)
          .isDartCoreBool ??
      false;

  @override
  bool get isStringType =>
      _contextElement.library?.typeSystem
          .promoteToNonNull(type)
          .isDartCoreString ??
      false;

  @override
  bool get isNullable => type.nullabilitySuffix != NullabilitySuffix.none;

  @override
  bool get hasTypeParameter => false;

  @override
  List<GenericType> get typeArguments {
    final type = this.type;
    return type is InterfaceType
        ? type.typeArguments
            .map((t) => GenericType.fromDartType(t, _contextElement))
            .toList()
        : [];
  }

  _NonGenericType(this.type, this._contextElement)
      : assert(type is! FunctionType),
        super._();

  @override
  void writeTo(
    StringSink sink, {
    required bool withNullability,
  }) =>
      _writeTypeTo(type, sink, withNullability: withNullability);
}

void _writeTypeTo(
  DartType type,
  StringSink sink, {
  required bool withNullability,
}) {
  final alias = type.alias;
  if (alias == null) {
    sink.write(type.getDisplayString(withNullability: withNullability));
  } else {
    _writeAliasTo(
      alias,
      {},
      type.nullabilitySuffix,
      sink,
      withNullability: withNullability,
    );
  }
}

void _writeAliasTo(
  InstantiatedTypeAliasElement alias,
  Map<String, GenericType> typeParameterMap,
  NullabilitySuffix nullabilitySuffix,
  StringSink sink, {
  required bool withNullability,
}) {
  sink.write(alias.element.name);

  if (alias.typeArguments.isNotEmpty) {
    sink.write('<');
    var isFirst = true;
    for (final t in alias.typeArguments) {
      if (isFirst) {
        isFirst = false;
      } else {
        sink.write(', ');
      }

      if (t is TypeParameterType) {
        final actual = typeParameterMap[t.element.name];
        if (actual != null) {
          actual.writeTo(sink, withNullability: withNullability);
          continue;
        }
      }

      _writeTypeTo(t, sink, withNullability: withNullability);
    }
    sink.write('>');
  }

  if (withNullability && nullabilitySuffix != NullabilitySuffix.none) {
    sink.write('?');
  }
}

/// Represents generic interface type with type arguments.
@sealed
class _InstantiatedGenericInterfaceType extends GenericType {
  final InterfaceType _interfaceType;
  final InterfaceType _rawType;

  @override
  DartType get rawType => _rawType;

  @override
  final List<GenericType> typeArguments;

  @override
  InterfaceType? get maybeAsInterfaceType => _interfaceType;

  @override
  GenericType? get collectionItemType {
    final typeSystem = _interfaceType.element.library.typeSystem;
    final typeProvider = _interfaceType.element.library.typeProvider;
    if (!typeSystem.isAssignableTo(
      typeSystem.promoteToNonNull(_interfaceType),
      typeProvider.iterableDynamicType,
    )) {
      return null;
    }

    return typeArguments.single;
  }

  @override
  bool get isNullable =>
      _interfaceType.nullabilitySuffix != NullabilitySuffix.none;

  @override
  bool get hasTypeParameter => typeArguments
      .any((t) => t.rawType is TypeParameterType || t.hasTypeParameter);

  _InstantiatedGenericInterfaceType(
    this._interfaceType,
    this._rawType,
    this.typeArguments,
  )   : assert(
          _rawType.typeArguments.whereType<TypeParameterType>().length ==
              typeArguments.length,
          "Arity mismatch between '$_rawType' and type arguments [${typeArguments.join(', ')}]", // coverage:ignore-line
        ),
        super._();

  @override
  void writeTo(
    StringSink sink, {
    required bool withNullability,
  }) {
    final alias = _interfaceType.alias;
    if (alias == null) {
      sink.write(_interfaceType.element.name);
    } else {
      sink.write(alias.element.name);
    }

    _writeTypeArgumentsTo(
      sink,
      typeArguments,
      withNullability: withNullability,
    );
    if (withNullability &&
        _interfaceType.nullabilitySuffix != NullabilitySuffix.none) {
      sink.write('?');
    }
  }

  void _writeTypeArgumentsTo(
    StringSink sink,
    List<GenericType> typeArguments, {
    required bool withNullability,
  }) {
    sink.write('<');
    var isFirst = true;
    for (final typeArgument in typeArguments) {
      if (isFirst) {
        isFirst = false;
      } else {
        sink.write(', ');
      }

      typeArgument.writeTo(
        sink,
        withNullability: withNullability,
      );
    }
    sink.write('>');
  }
}

/// Represents generic function type.
abstract class GenericFunctionType extends GenericType {
  /// Gets an underlying [FunctionType].
  final FunctionType functionType;
  final FunctionType _rawType;

  @override
  @nonVirtual
  DartType get rawType => _rawType;

  @override
  @nonVirtual
  InterfaceType? get maybeAsInterfaceType => null;

  @override
  bool get isNullable =>
      functionType.nullabilitySuffix != NullabilitySuffix.none;

  /// Gets a return type of the function type.
  GenericType get returnType;

  /// Gets a list of parameter types of the function type.
  Iterable<GenericType> get parameterTypes;

  GenericFunctionType._(this.functionType, this._rawType) : super._();
}

/// Represents generic function type with type arguments.
@sealed
class _InstantiatedGenericFunctionType extends GenericFunctionType {
  final Element _contextElement;
  final Map<String, GenericType> _genericArguments;

  @override
  List<GenericType> typeArguments;

  @override
  GenericType get returnType => _instantiate(functionType.returnType);

  @override
  Iterable<GenericType> get parameterTypes =>
      functionType.parameters.map((p) => _instantiate(p.type));

  @override
  GenericType? get collectionItemType => null;

  @override
  bool get hasTypeParameter => typeArguments
      .any((t) => t.rawType is TypeParameterType || t.hasTypeParameter);

  _InstantiatedGenericFunctionType(
    FunctionType functionType,
    FunctionType rawFunctionType,
    this.typeArguments,
    this._genericArguments,
    this._contextElement,
  ) : super._(functionType, rawFunctionType);

  GenericType _instantiate(DartType mayBeTypeParameter) =>
      ((mayBeTypeParameter is TypeParameterType)
          ? _genericArguments[
              mayBeTypeParameter.getDisplayString(withNullability: false)]
          : null) ??
      GenericType.fromDartType(
        mayBeTypeParameter,
        _contextElement,
      );

  @override
  void writeTo(StringSink sink, {required bool withNullability}) {
    final alias = functionType.alias;
    if (alias != null) {
      _writeAliasTo(
        alias,
        _genericArguments,
        functionType.nullabilitySuffix,
        sink,
        withNullability: withNullability,
      );
      return;
    }

    sink
      ..write(returnType.getDisplayString(withNullability: withNullability))
      ..write(' Function');

    if (hasTypeParameter) {
      var isFirst = true;
      sink.write('<');
      for (final typeArgument
          in typeArguments.where((t) => t.rawType is TypeParameterType)) {
        if (isFirst) {
          isFirst = false;
        } else {
          sink.write(', ');
        }

        sink.write(
          typeArgument.getDisplayString(withNullability: withNullability),
        );
      }
      sink.write('>');
    }

    sink.write('(');
    {
      var isFirst = true;
      var isRequiredPositional = true;
      var isNamed = false;
      final parameterTypes = this.parameterTypes.toList();
      for (var i = 0; i < functionType.parameters.length; i++) {
        final parameter = functionType.parameters[i];
        if (isFirst) {
          isFirst = false;
        } else {
          sink.write(', ');
        }

        if (!parameter.isRequiredPositional && isRequiredPositional) {
          isRequiredPositional = false;
          if (parameter.isNamed) {
            isNamed = true;
          } else {}

          sink.write(isNamed ? '{' : '[');
        }

        if (parameter.isRequiredNamed) {
          sink.write('required ');
        }

        sink.write(
          parameterTypes[i].getDisplayString(withNullability: withNullability),
        );

        if (parameter.isNamed) {
          sink
            ..write(' ')
            ..write(parameter.name);
        }
      }

      if (!isRequiredPositional) {
        sink.write(isNamed ? '}' : ']');
      }
    }

    sink.write(')');

    if (withNullability &&
        functionType.nullabilitySuffix != NullabilitySuffix.none) {
      sink.write('?');
    }
  }
}

Map<String, GenericType> _buildFunctionTypeGenericArguments(
  FunctionType type,
  List<GenericType> typeArguments,
  Element contextElement,
) {
  if (typeArguments.isEmpty) {
    return {};
  }

  if (type.typeFormals.isNotEmpty) {
    if (type.typeFormals.length != typeArguments.length) {
      throwError(
        message: "Complex function type '$type' is not supported.",
        todo: 'Do not use complex function type which has type formals and '
            'uses any type parameters other than type formals. '
            'For example, `S Function<T>(T)` is not allowed, '
            'but `T Function<T>(T)` is allowed.',
        element: contextElement,
      );
    }

    final result = <String, GenericType>{};
    for (var i = 0; i < typeArguments.length; i++) {
      result[type.typeFormals[i].name] = typeArguments[i];
    }

    return result;
  } else {
    if (typeArguments.length == 1) {
      late final FunctionType actualType;
      final alias = type.alias;
      if (alias != null) {
        actualType = alias.element.aliasedType as FunctionType;
      } else {
        actualType = type;
      }

      final typeParameters = <String>{};
      if (actualType.returnType is TypeParameterType) {
        typeParameters.add(
          actualType.returnType.getDisplayString(withNullability: false),
        );
      }

      typeParameters.addAll(
        actualType.parameters
            .map((e) => e.type)
            .whereType<TypeParameterType>()
            .map((t) => t.getDisplayString(withNullability: false)),
      );

      if (typeParameters.length == 1) {
        return {typeParameters.first: typeArguments.first};
      }
    }

    throwError(
      message: "Complex function type '$type' is not supported.",
      todo: 'Do not use complex function type which has more than one type '
          'parameters. '
          'For example, `S Function(T)` is not allowed, '
          'but `T Function(T)` is allowed.',
      element: contextElement,
    );
  }
}

/// Represents definition of a property.
@sealed
class PropertyDefinition {
  /// A name of the property.
  final String name;

  /// A type of the property.
  /// This may not be equal to the type of `FormField`'s value.
  final GenericType propertyType;

  /// A type of the value of the form field.
  /// This may not be equal to the type of property's value.
  final GenericType fieldType;

  /// Preferred type of `FormField`, which is specified as type arguments
  /// of `addWithField` extension method.
  final GenericType? preferredFormFieldType;

  /// Gets a property specific warnings generated by parser.
  final List<String> warnings;

  /// Initializes a new instance from parsed property data.
  PropertyDefinition({
    required this.name,
    required this.propertyType,
    required this.fieldType,
    required this.preferredFormFieldType,
    required this.warnings,
  });
}

/// A pair of [PropertyDefinition] and its source [MethodInvocation].
@sealed
class PropertyDefinitionWithSource {
  /// [PropertyDefinition] created by [source].
  final PropertyDefinition property;

  /// Source [MethodInvocation] for reporting.
  final MethodInvocation source;

  /// Initializes a new [PropertyDefinitionWithSource] instance.
  PropertyDefinitionWithSource(this.property, this.source);
}

/// A property definition with resolved `FormField` information.
@sealed
class PropertyAndFormFieldDefinition {
  final PropertyDefinition _property;

  /// A name of the property.
  String get name => _property.name;

  /// A type of the property.
  /// This may not be equal to the type of `FormField`'s value.
  GenericType get propertyValueType => _property.propertyType;

  /// A type of the value of the form field.
  /// This may not be equal to the type of property's value.
  GenericType get fieldValueType => _property.fieldType;

  /// A type name of `FormField`.
  /// Note that this field should not include generic type parameters.
  ///
  /// This field is intended for error reporting.
  final String formFieldTypeName;

  /// A type of `FormField`.
  ///
  /// This property will be `null` when failed to find target `FormField`.
  ///
  /// This type may have generic type argument if this was specified as type
  /// argument of `addWithField`, otherwise this type does not have type
  /// argument.
  final InterfaceType? formFieldType;

  /// A [List] of [FormFieldConstructorDefinition] of [formFieldType].
  ///
  /// This property will be empty when [formFieldType] is `null`.
  final List<FormFieldConstructorDefinition> formFieldConstructors;

  /// Property specific warnings generated by parser.
  List<String> get warnings => _property.warnings;

  /// A [TypeInstantiationContext] for [formFieldType] constructor.
  ///
  /// This property will be `null` when failed to determine target `FormField`
  /// constructor, [formFieldType] is `null`, or failed to resolve their dependency.
  final TypeInstantiationContext? instantiationContext;

  /// Wheter [formFieldType] declares only one public anonymous (default)
  /// constructor.
  ///
  /// Note that the constructor can be generative constructor
  /// or factory constructor, and there are some private constructors.
  bool get isSimpleFormField =>
      formFieldConstructors.length == 1 &&
      formFieldConstructors[0].constructor.name == null;

  /// Initializes a new [PropertyAndFormFieldDefinition] instance.
  PropertyAndFormFieldDefinition({
    required PropertyDefinition property,
    required this.formFieldType,
    required this.formFieldTypeName,
    required this.formFieldConstructors,
    required this.instantiationContext,
  }) : _property = property;
}

/// `FormField` constructor and related objects.
@sealed
class FormFieldConstructorDefinition {
  /// A [ConstructorDeclaration] of this constructor to be called.
  final ConstructorDeclaration constructor;

  /// [ArgumentsHandler] to handle arguments for this constructor
  /// and a form field factory which wraps the constructor.
  final ArgumentsHandler argumentsHandler;

  /// Initializes a new [FormFieldConstructorDefinition] object.
  FormFieldConstructorDefinition(this.constructor, this.argumentsHandler);
}

/// Defines eventual methods of `PropertyDescriptorsBuilder` to define a new
/// property.
@sealed
class PropertyDescriptorsBuilderMethods {
  /// `add<F, P>(...)`.
  static const add = 'add';

  /// `addWithField<F, P, TField>(...)`.
  static const addWithField = 'addWithField';
}
