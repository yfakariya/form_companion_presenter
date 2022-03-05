// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'node_provider.dart';
import 'utilities.dart';

/// Represents a parameter.
@sealed
class ParameterInfo {
  /// Gets a name of this parameter.
  final String name;

  /// Gets a static [DartType] of this parameter.
  final DartType type;

  /// Gets a declared [TypeAnnotation] of this parameter.
  ///
  /// `null` if parameter is a function type formal parameter like `int foo(String bar)`.
  final TypeAnnotation? typeAnnotation;

  /// Gets a declared parameter as [FunctionTypedFormalParameter].
  ///
  /// `null` if parameter is not a function type formal parameter like `int foo(String bar)`.
  final FunctionTypedFormalParameter? functionTypedParameter;

  /// Gets a requiability of this parameter.
  final ParameterRequirability requirability;

  /// Gets a default value of this parameter if exists.
  final String? defaultValue;

  /// Returns `true` if this parameter has default value.
  bool get hasDefaultValue => defaultValue != null;

  /// Initializes a new [ParameterInfo] instance.
  ParameterInfo(
    this.name,
    this.type,
    this.typeAnnotation,
    this.functionTypedParameter,
    this.defaultValue,
    this.requirability,
  );

  /// Creates a new [ParameterInfo] isntance from specified [FormalParameter].
  static FutureOr<ParameterInfo> fromNodeAsync(
    NodeProvider nodeProvider,
    FormalParameter node,
  ) async {
    if (node is DefaultFormalParameter) {
      return await ParameterInfo.fromNodeAsync(nodeProvider, node.parameter);
    }

    if (node is SimpleFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo(
        node.identifier!.name,
        element.type,
        node.type,
        null,
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
      return ParameterInfo(
        node.identifier.name,
        parameterElement.type,
        fieldType,
        null,
        parameterElement.defaultValueCode,
        parameterElement.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.optional,
      );
    }

    if (node is FunctionTypedFormalParameter) {
      final element = node.declaredElement!;
      return ParameterInfo(
        node.identifier.name,
        element.type,
        null,
        node,
        element.defaultValueCode,
        element.isRequiredNamed
            ? ParameterRequirability.required
            : ParameterRequirability.optional,
      );
    }

    throwError(
      message:
          "Failed to parse complex parameter '$node' (${node.runtimeType}) at ${getNodeLocation(node, node.declaredElement!)} ",
      element: node.declaredElement!,
    );
  }
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
