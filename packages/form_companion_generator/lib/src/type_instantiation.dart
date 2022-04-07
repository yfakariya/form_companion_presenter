// See LICENCE file in the root.

import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'model.dart';

/// A context information holder of type instantiaion.
@sealed
class TypeInstantiationContext {
  static final _formFieldPattern = RegExp(RegExp.escape('FormField<'));

  final Map<String, String> _typeArgumentsMappings;

  TypeInstantiationContext._(
    this._typeArgumentsMappings,
  );

  /// Creates a new [TypeInstantiationContext] instance
  /// for the [PropertyDefinition].
  factory TypeInstantiationContext.create(
    PropertyDefinition property,
    InterfaceType formFieldType,
    Logger logger,
  ) {
    // We cannot use supertype.element here because it may lose generic argument
    // information in inheritance hierarchy, but origin should be
    // element.thisType to erase instantiated information.
    var currentType = formFieldType.element.thisType;
    while (!currentType
        .getDisplayString(withNullability: false)
        .startsWith(_formFieldPattern)) {
      currentType = currentType.superclass!;
    }

    // T, List<T>, or some type, which is specified as `T` of `FormField<T>`.
    // This is `ParameterizedType` if 1) the `formFieldType` is non generic or
    // 2) `T` is some generic type such as `List<E>`,
    // else 3) it is `TypeParameterType` for generic `formFieldType`.
    // Example of 1) is `TextFormField`, 2) is `FormBuilderCheckboxGroup`,
    // and 3) is `DropdownButtonFormField` respectively.
    final formFieldTypeArgument = currentType.typeArguments.single;

    // We use element here to erase generic argument information, which may be
    // specified via generic type argument of addWithField.
    if (formFieldType.element.typeParameters.isEmpty) {
      assert(
        formFieldTypeArgument.getDisplayString(withNullability: true) ==
            property.fieldType.getDisplayString(withNullability: true),
      );

      logger.finer("Form field type '$formFieldType' is not generic.");

      return TypeInstantiationContext._({});
    }

    final mapping = <String, String>{};
    _buildTypeArgumentMappings(
      formFieldTypeArgument,
      property.fieldType,
      mapping,
      property.name,
      formFieldType,
    );
    logger.finer(
      "Create type arguments mapping between field type argument '$formFieldTypeArgument' "
      "and specified field value type '${property.fieldType}': $mapping",
    );
    return TypeInstantiationContext._(mapping);
  }

  static void _buildTypeArgumentMappings(
    DartType parameter,
    GenericType argument,
    Map<String, String> mapping,
    String propertyName,
    DartType formFieldType,
  ) {
    if (parameter is TypeParameterType) {
      // Map `Foo` to `T` here.
      mapping[parameter.getDisplayString(withNullability: false)] =
          argument.getDisplayString(withNullability: false);
      return;
    }

    // Start generic type comparsion like `Foo<T> extends FormField<List<T>>`

    final parameterType = parameter.alias?.element.aliasedType ?? parameter;

    if (parameterType is ParameterizedType) {
      assert(argument.maybeAsInterfaceType != null);
      assert(parameterType.element!.name == argument.rawTypeName);
      assert(
        parameterType.typeArguments.length == argument.typeArguments.length,
      );

      if (parameterType.typeArguments.isNotEmpty) {
        final argumentTypeArguments = argument.typeArguments;
        for (var i = 0; i < parameterType.typeArguments.length; i++) {
          _buildTypeArgumentMappings(
            parameterType.typeArguments[i],
            argumentTypeArguments[i],
            mapping,
            propertyName,
            formFieldType,
          );
        }
      }

      return;
    }

    if (parameterType is FunctionType) {
      assert(argument is GenericFunctionType);
      assert(parameterType.parameters.length ==
          (argument as GenericFunctionType).rawFunctionType.parameters.length);

      if (parameterType.typeFormals.isNotEmpty &&
          parameterType.typeFormals.length ==
              (argument as GenericFunctionType)
                  .rawFunctionType
                  .typeFormals
                  .length) {
        late final List<String> argumentTypeArgumentNames;
        if (argument.typeArguments.isNotEmpty) {
          argumentTypeArgumentNames = argument.typeArguments
              .map((e) => e.getDisplayString(withNullability: false))
              .toList();
        } else {
          argumentTypeArgumentNames = argument.rawFunctionType.typeFormals
              .map((e) => e.getDisplayString(withNullability: false))
              .toList();
        }

        for (var i = 0; i < parameterType.typeFormals.length; i++) {
          // Map `Foo` to `T` here.
          mapping[parameterType.typeFormals[i].getDisplayString(
              withNullability: false)] = argumentTypeArgumentNames[i];
        }
      } else {
        _buildTypeArgumentMappings(
          parameterType.returnType,
          (argument as GenericFunctionType).returnType,
          mapping,
          propertyName,
          formFieldType,
        );

        final argumentParameterTypes = argument.parameterTypes.toList();
        for (var i = 0; i < parameterType.parameters.length; i++) {
          _buildTypeArgumentMappings(
            parameterType.parameters[i].type,
            argumentParameterTypes[i],
            mapping,
            propertyName,
            formFieldType,
          );
        }
      }
    }

    // Do nothing for NeverType, DynamicType, and VoidType.
  }

  /// Gets a mapped type string which was specified as type argument.
  /// If the [mayBeTypeParameter] is not a type parameter,
  /// then its value will be returned.
  ///
  /// This method is a core of type instantiation.
  String getMappedType(String mayBeTypeParameter) =>
      _typeArgumentsMappings[mayBeTypeParameter] ?? mayBeTypeParameter;

  /// Returns `true` if this instance can return a mapped type string
  /// which was specified as type argument.
  bool isMapped(String mayBeTypeParameter) =>
      _typeArgumentsMappings.containsKey(mayBeTypeParameter);
}
