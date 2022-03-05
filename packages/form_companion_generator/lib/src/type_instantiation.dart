// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'model.dart';
import 'node_provider.dart';

/// A context information holder of type instantiaion.
@sealed
class TypeInstantiationContext {
  static final _formFieldPattern = RegExp(RegExp.escape('FormField<'));

  final NodeProvider _nodeProvider;
  final Map<String, String> _typeArgumentsMappings;

  TypeInstantiationContext._(
    this._nodeProvider,
    this._typeArgumentsMappings,
  );

  /// Creates a new [TypeInstantiationContext] instance
  /// for the [PropertyDefinition].
  factory TypeInstantiationContext.create(
    NodeProvider nodeProvider,
    PropertyDefinition property,
    InterfaceType formFieldType,
  ) {
    final typeParameters =
        formFieldType.typeArguments.whereType<TypeParameterType?>().toList();

    // NOTE: we cannot use supertype.element here -- it may lose generic argument information
    var currentType = formFieldType;
    while (!currentType
        .getDisplayString(withNullability: false)
        .startsWith(_formFieldPattern)) {
      currentType = currentType.superclass!;
    }

    final valueType = currentType.typeArguments.single;
    if (typeParameters.isEmpty) {
      // If valueType is String, it is OK because conversion between
      // property.type and String should be handled by converter.
      if (!valueType.isDartCoreString &&
          valueType.getDisplayString(withNullability: true) !=
              property.type.getDisplayString(withNullability: true)) {
        _throwTypeMismatch(
          detail:
              "The type is '${property.type}', but resolved field value type is '$valueType' "
              "for form field type '$formFieldType'.",
          propertyName: property.name,
        );
      }
      return TypeInstantiationContext._(nodeProvider, {});
    }

    final mapping = <String, String>{};
    _buildTypeArgumentMappings(
      valueType,
      property.type,
      mapping,
      property.name,
      formFieldType,
    );
    return TypeInstantiationContext._(nodeProvider, mapping);
  }

  static void _buildTypeArgumentMappings(
    DartType parameter,
    DartType argument,
    Map<String, String> mapping,
    String propertyName,
    DartType formFieldType,
  ) {
    if (parameter is TypeParameterType) {
      mapping[parameter.getDisplayString(withNullability: false)] =
          argument.getDisplayString(withNullability: false);
      return;
    }

    if (parameter is ParameterizedType) {
      if (argument is! ParameterizedType) {
        _throwTypeMismatch(
          detail:
              "Kinds of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's kind is '${argument.element!.kind}' but parameter's kind is '${parameter.element!.kind}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.element!.name! != argument.element!.name!) {
        _throwTypeMismatch(
          detail:
              "Names of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's name is '${argument.element!.name}' but parameter's name is '${parameter.element!.name}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.typeArguments.length != argument.typeArguments.length) {
        _throwTypeMismatch(
          detail:
              "Types parameters arity of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's arity is '${argument.typeArguments.length}' but parameter's arity is '${parameter.typeArguments.length}'.",
          propertyName: propertyName,
        );
      }

      for (var i = 0; i < parameter.typeArguments.length; i++) {
        _buildTypeArgumentMappings(
          parameter.typeArguments[i],
          argument.typeArguments[i],
          mapping,
          propertyName,
          formFieldType,
        );
      }

      return;
    }

    if (parameter is FunctionType) {
      if (argument is! FunctionType) {
        _throwTypeMismatch(
          detail:
              "Kinds of type parts are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's kind is '${argument.element!.kind}' but parameter's kind is '${parameter.element!.kind}'.",
          propertyName: propertyName,
        );
      }

      if (parameter.returnType != argument.returnType) {
        _throwTypeMismatch(
          detail:
              "Return types of function types are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's return type is '${argument.returnType}' but parameter's return type is '${parameter.returnType}'.",
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

      if (parameter.parameters.length != argument.parameters.length) {
        _throwTypeMismatch(
          detail:
              "Parameters counts of function types are not match between the type argument type '$argument' and the type parameter type '$parameter'. "
              "Argument's parameters count is '${argument.parameters.length}' but parameter's parameters count is '${parameter.parameters.length}'.",
          propertyName: propertyName,
        );
      }

      _buildTypeArgumentMappings(
        parameter.returnType,
        argument.returnType,
        mapping,
        propertyName,
        formFieldType,
      );

      for (var i = 0; i < parameter.parameters.length; i++) {
        _buildTypeArgumentMappings(
          parameter.parameters[i].type,
          argument.parameters[i].type,
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
        todo:
            'Ensure `preferredFieldType` has compatible value type for the property.',
      );

  /// Gets a mapped type string which was specified as type argument.
  /// If the [mayBeTypeParameter] is not a type parameter,
  /// then its value will be returned.
  ///
  /// This method is a core of type instantiation.
  String getMappedType(String mayBeTypeParameter) =>
      _typeArgumentsMappings[mayBeTypeParameter] ?? mayBeTypeParameter;

  /// Get an [AstNode] for specified [Element].
  ///
  /// This method assumes that caller passes resolved element only.
  T getElementDeclaration<T extends AstNode>(Element element) =>
      _nodeProvider.getElementDeclarationSync<T>(element);
}
