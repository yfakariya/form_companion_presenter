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
    GenericInterfaceType argument,
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

    final argumentType = argument.rawType;

    if (parameter is ParameterizedType) {
      assert(argumentType is ParameterizedType);
      assert(parameter.element!.name == argumentType.element!.name);
      assert(
        parameter.typeArguments.length ==
            (argumentType as ParameterizedType).typeArguments.length,
      );

      if (parameter.typeArguments.isNotEmpty) {
        late final List<GenericInterfaceType> argumentTypeArguments;
        if (argument.typeArguments.isNotEmpty) {
          argumentTypeArguments = argument.typeArguments;
        } else {
          argumentTypeArguments = (argumentType as ParameterizedType)
              .typeArguments
              .map((e) => GenericInterfaceType(e, []))
              .toList();
        }

        for (var i = 0; i < parameter.typeArguments.length; i++) {
          _buildTypeArgumentMappings(
            parameter.typeArguments[i],
            argumentTypeArguments[i],
            mapping,
            propertyName,
            formFieldType,
          );
        }
      }

      return;
    }

    if (parameter is FunctionType) {
      assert(argumentType is FunctionType);
      assert(parameter.returnType == (argumentType as FunctionType).returnType);

      // We believe that we cannot declare generic function type
      // like `Foo<T> extends Bar<T Function<S>(S)>`...
      assert(parameter.typeFormals.isEmpty);
      assert(parameter.parameters.length ==
          (argumentType as FunctionType).parameters.length);

      _buildTypeArgumentMappings(
        parameter.returnType,
        GenericInterfaceType((argumentType as FunctionType).returnType, []),
        mapping,
        propertyName,
        formFieldType,
      );

      for (var i = 0; i < parameter.parameters.length; i++) {
        _buildTypeArgumentMappings(
          parameter.parameters[i].type,
          GenericInterfaceType(argumentType.parameters[i].type, []),
          mapping,
          propertyName,
          formFieldType,
        );
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
}
