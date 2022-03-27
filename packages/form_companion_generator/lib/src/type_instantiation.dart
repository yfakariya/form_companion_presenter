// See LICENCE file in the root.

import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

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

    final formFieldTypeArgument = currentType.typeArguments.single;

    // We use element here to erase generic argument information, which may be
    // specified via generic type argument of addWithField.
    if (formFieldType.element.typeParameters.isEmpty) {
      if (formFieldTypeArgument.getDisplayString(withNullability: true) !=
          property.fieldType.toString()) {
        _throwTypeMismatch(
          detail:
              "The type is '${property.fieldType}', but resolved field value type is '$formFieldTypeArgument' "
              "for form field type '$formFieldType'.",
          propertyName: property.name,
        );
      }

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
      mapping[parameter.getDisplayString(withNullability: false)] =
          argument.getDisplayString(withNullability: false);
      return;
    }

    final argumentType = argument.rawType;

    if (parameter is ParameterizedType) {
      if (argumentType is! ParameterizedType) {
        _throwTypeMismatch(
          detail:
              "Kinds of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's kind is '${argumentType.element!.kind}' but parameter's kind is '${parameter.element!.kind}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.element!.name! != argumentType.element!.name!) {
        _throwTypeMismatch(
          detail:
              "Names of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's name is '${argumentType.element!.name}' but parameter's name is '${parameter.element!.name}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.typeArguments.length != argumentType.typeArguments.length) {
        _throwTypeMismatch(
          detail:
              "Types parameters arity of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's arity is '${argumentType.typeArguments.length}' but parameter's arity is '${parameter.typeArguments.length}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.typeArguments.isNotEmpty) {
        late final List<GenericInterfaceType> argumentTypeArguments;
        if (argument.typeArguments.isNotEmpty) {
          argumentTypeArguments = argument.typeArguments;
        } else {
          argumentTypeArguments = argumentType.typeArguments
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
      if (argumentType is! FunctionType) {
        _throwTypeMismatch(
          detail:
              "Kinds of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's kind is '${argumentType.element!.kind}' but parameter's kind is '${parameter.element!.kind}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.returnType != argumentType.returnType) {
        _throwTypeMismatch(
          detail:
              "Return types of function types are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's return type is '${argumentType.returnType}' but parameter's return type is '${parameter.returnType}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.typeFormals.isNotEmpty) {
        // We believe that we cannot declare generic function type
        // like `Foo<T> extends Bar<T Function<S>(S)>`...
        throw InvalidGenerationSourceError(
          "Failed to parse complex type '$formFieldType'. "
          'Generic type parameter with generic function type is not supported yet.',
          todo:
              'Please report the issue with sample code to reproduce this problem with description of the scenario which you want to do.',
        );
      }

      if (parameter.parameters.length != argumentType.parameters.length) {
        _throwTypeMismatch(
          detail:
              "Parameters counts of function types are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's parameters count is '${argumentType.parameters.length}' but parameter's parameters count is '${parameter.parameters.length}'.",
          propertyName: propertyName,
        );
      }

      _buildTypeArgumentMappings(
        parameter.returnType,
        GenericInterfaceType(argumentType.returnType, []),
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

  static Never _throwTypeMismatch({
    required String detail,
    required String propertyName,
  }) =>
      throw InvalidGenerationSourceError(
        "Failed to parse property '$propertyName'. $detail",
        todo: 'Ensure specifying type parameter `TField` which is subtype of '
            'FormField<T> where `T` is same as type parameter `F`. '
            "Don't forget specify generic type arguments.",
      );

  /// Gets a mapped type string which was specified as type argument.
  /// If the [mayBeTypeParameter] is not a type parameter,
  /// then its value will be returned.
  ///
  /// This method is a core of type instantiation.
  String getMappedType(String mayBeTypeParameter) =>
      _typeArgumentsMappings[mayBeTypeParameter] ?? mayBeTypeParameter;
}
