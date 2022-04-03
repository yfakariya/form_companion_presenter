// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'arguments_handler.dart';
import 'dependency.dart';
import 'node_provider.dart';
import 'type_instantiation.dart';
import 'utilities.dart';

/// Represents a parameter.
@sealed
class ParameterInfo {
  /// Gets a name of this parameter.
  final String name;

  /// Gets a static [DartType] of this parameter.
  final DartType type;

  /// Gets a [FormalParameter] which holds syntax information of this parameter.
  final FormalParameter node;

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

  /// Returns `true` if this parameter has default value.
  bool get hasDefaultValue => defaultValue != null;

  /// Initializes a new [ParameterInfo] instance.
  ParameterInfo._(
    this.node,
    this.name,
    this.type,
    this.typeAnnotation,
    this.functionTypedParameter,
    this.keyword,
    this.defaultValue,
    this.requirability,
  );

  /// Creates a new [ParameterInfo] isntance from specified [FormalParameter].
  static FutureOr<ParameterInfo> fromNodeAsync(
    NodeProvider nodeProvider,
    FormalParameter node,
  ) async {
    if (node is DefaultFormalParameter) {
      // Parse left side with recursive call.
      final base =
          await ParameterInfo.fromNodeAsync(nodeProvider, node.parameter);
      // But, use original DefaultFormatlParameter for node for DependencyCollector.
      return ParameterInfo._(
        node,
        base.name,
        base.type,
        base.typeAnnotation,
        base.functionTypedParameter,
        base.keyword,
        base.defaultValue,
        base.requirability,
      );
    }

    if (node is SimpleFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo._(
        node,
        node.identifier!.name,
        element.type,
        node.type,
        null,
        node.keyword?.stringValue,
        element.defaultValueCode,
        element.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.optional,
      );
    }

    if (node is FieldFormalParameter) {
      final parameterElement = node.declaredElement!;
      final fieldType = await _getFieldTypeAnnotationAsync(
        nodeProvider,
        node,
        parameterElement,
      );
      return ParameterInfo._(
        node,
        node.identifier.name,
        parameterElement.type,
        fieldType,
        null,
        node.keyword?.stringValue,
        parameterElement.defaultValueCode,
        parameterElement.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.optional,
      );
    }

    if (node is FunctionTypedFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo._(
        node,
        node.identifier.name,
        element.type,
        null,
        node,
        null,
        element.defaultValueCode,
        element.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.optional,
      );
    }

    throwError(
      message:
          "Failed to parse complex parameter '$node' (${node.runtimeType}) at ${getNodeLocation(node, node.declaredElement!)} ",
      element: node.declaredElement,
    );
  }

  /// Returns a copy of this instance clearing [defaultValue] and setting
  /// [ParameterRequirability.forciblyOptional].
  ParameterInfo asForciblyOptional() => ParameterInfo._(
        node,
        name,
        type,
        typeAnnotation,
        functionTypedParameter,
        keyword,
        null,
        ParameterRequirability.forciblyOptional,
      );
}

FutureOr<TypeAnnotation> _getFieldTypeAnnotationAsync(
  NodeProvider nodeProvider,
  FieldFormalParameter node,
  ParameterElement parameterElement,
) async {
  final classElement = parameterElement.thisOrAncestorOfType<ClassElement>()!;
  final fieldElement = classElement.lookUpGetter(
    node.identifier.name,
    parameterElement.library!,
  )!;

  final fieldNode =
      await nodeProvider.getElementDeclarationAsync(fieldElement.nonSynthetic);
  late final TypeAnnotation fieldType;
  if (fieldNode is VariableDeclaration) {
    fieldType = (fieldNode.parent! as VariableDeclarationList).type!;
  } else {
    fieldType = (fieldNode as FieldDeclaration).fields.type!;
  }
  return fieldType;
}

/// Represents 'requirability' of the parameter.
enum ParameterRequirability {
  /// Parameter is required in its declaration.
  required,

  /// Parameter is optional in its declaration.
  optional,

  /// Paramter should be treated as nullable and optional regardless its declaration.
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
}

/// Represents mix-in type of presenter.
enum MixinType {
  /// `FormCompanionMixin`
  formCompanionMixin,

  /// `FormBuilderCompanionMixin`
  formBuilderCompanionMixin,
}

/// Represents generic interface type as transparent structured object.
@sealed
class GenericInterfaceType {
  /// Raw type part of generic type.
  ///
  /// This can be instantiated generic type.
  final DartType rawType;

  /// Type arguments part of generic type.
  ///
  /// This value will be empty when the type is non-generic types and [rawType]
  /// is instantiated generic type.
  final List<GenericInterfaceType> typeArguments;

  /// Gets a [rawType] as [InterfaceType] or `null` when [rawType] is not an
  /// [InterfaceType].
  InterfaceType? get maybeAsInterfaceType {
    final type = rawType;
    if (type is InterfaceType) {
      return type;
    } else {
      return null;
    }
  }

  /// Gets a raw type name without generic type parameters and arguments of
  /// [rawType].
  String get rawTypeName {
    final type = rawType;
    if (type is InterfaceType) {
      return type.element.name;
    } else {
      return type.getDisplayString(withNullability: false);
    }
  }

  /// Initializes a new [GenericInterfaceType] instance.
  GenericInterfaceType(
    this.rawType,
    this.typeArguments,
  );

  @override
  String toString() => getDisplayString(withNullability: true);

  /// Returns a [String] to display this type.
  ///
  /// This method simulates [DartType.getDisplayString].
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
  }) {
    final type = rawType;
    if (type is InterfaceType) {
      sink.write(type.element.name);
      _writeTypeArgumentsTo(sink, withNullability: withNullability);
      if (withNullability && type.nullabilitySuffix != NullabilitySuffix.none) {
        sink.write('?');
      }

      return;
    } else {
      sink.write(type.getDisplayString(withNullability: withNullability));
    }
  }

  void _writeTypeArgumentsTo(
    StringSink sink, {
    required bool withNullability,
  }) {
    if (typeArguments.isNotEmpty) {
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
      return;
    }

    final type = rawType;
    if (type is! InterfaceType) {
      return;
    }

    if (type.typeArguments.isNotEmpty &&
        !type.typeArguments.any((e) => e is TypeParameterType)) {
      sink.write('<');
      var isFirst = true;
      for (final typeArgument in type.typeArguments) {
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
  }
}

/// Represents definition of a property.
@sealed
class PropertyDefinition {
  /// A name of the property.
  final String name;

  /// A type of the property.
  /// This may not be equal to the type of `FormField`'s value.
  final GenericInterfaceType propertyType;

  /// A type of the value of the form field.
  /// This may not be equal to the type of property's value.
  final GenericInterfaceType fieldType;

  // TODO(yfakariya): can be InterfaceType
  /// Preferred type of `FormField`, which is specified as type arguments
  /// of `addWithField` extension method.
  final GenericInterfaceType? preferredFormFieldType;

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
class PropertyDefinitionAndSource {
  /// [PropertyDefinition] created by [source].
  final PropertyDefinition property;

  /// Source [MethodInvocation] for reporting.
  final MethodInvocation source;

  /// Initializes a new [PropertyDefinitionAndSource] instance.
  PropertyDefinitionAndSource(this.property, this.source);
}

/// A property definition with resolved `FormField` information.
@sealed
class PropertyAndFormFieldDefinition {
  final PropertyDefinition _property;

  /// A name of the property.
  String get name => _property.name;

  /// A type of the property.
  /// This may not be equal to the type of `FormField`'s value.
  GenericInterfaceType get propertyValueType => _property.propertyType;

  /// A type of the value of the form field.
  /// This may not be equal to the type of property's value.
  GenericInterfaceType get fieldValueType => _property.fieldType;

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
  /// A [ConstructorElement] of this constructor to be called.
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

  PropertyDescriptorsBuilderMethods._();
}
