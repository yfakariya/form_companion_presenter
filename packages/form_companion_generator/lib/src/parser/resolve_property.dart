// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../model.dart';
import '../utilities.dart';
import 'parser_data.dart';
import 'parser_helpers.dart';
import 'parser_node.dart';

/// Resolves [MethodInvocation] to [PropertyDefinitionWithSource].
FutureOr<PropertyDefinitionWithSource> resolvePropertyDefinitionAsync({
  required ParseContext context,
  required Element contextElement,
  required MethodInvocation methodInvocation,
  required ClassElement? targetClass,
  required String? propertyName,
  required List<GenericType> typeArguments,
  required MethodInvocation originalMethodInvocation,
  required bool isInferred,
}) async {
  context.logger.finer(
    "Resolve invocation chain '$methodInvocation$typeArguments', found name: '$propertyName'.",
  );

  final targetMethodElement = lookupMethod(
    contextElement,
    targetClass,
    methodInvocation.methodName.name,
    methodInvocation,
  );

  if (methodInvocation.methodName.name ==
          PropertyDescriptorsBuilderMethods.add ||
      methodInvocation.methodName.name ==
          PropertyDescriptorsBuilderMethods.addWithField) {
    return _createPropertyDefinition(
      context: context,
      contextElement: contextElement,
      methodInvocation: methodInvocation,
      targetMethodElement: targetMethodElement,
      propertyName: propertyName,
      typeArguments: typeArguments,
      originalMethodInvocation: originalMethodInvocation,
      isInferred: isInferred,
    );
  }

  final passingPropertyName = propertyName ??
      _getPropertyNameFromInvocation(
        methodInvocation,
        contextElement,
        mayNotExist: true,
      );

  final targetMethodNode = ExecutableNode(
    context.nodeProvider,
    await context.nodeProvider.getElementDeclarationAsync(
      targetMethodElement,
    ),
    targetMethodElement,
  );

  final targetMethodBody = targetMethodNode.body;
  if (targetMethodBody is! ExpressionFunctionBody) {
    throwError(
      message:
          "PropertyDescriptorsBuilder's extension method must have expression body, "
          "but method '$targetMethodElement' at "
          '${getNodeLocation(targetMethodNode.body, targetMethodElement)} is not.',
      todo:
          "Declare method '$targetMethodElement' as an expression bodied method.",
    );
  }

  final targetMethodBodyExpression =
      targetMethodBody.expression.unParenthesized;
  if (targetMethodBodyExpression is! MethodInvocation) {
    throwError(
      message:
          "PropertyDescriptorsBuilder's extension method must have expression "
          "body with another PropertyDescriptorsBuilder's (extension) method invocation, "
          "but expresion '$targetMethodBodyExpression' at "
          '${getNodeLocation(targetMethodNode.body, targetMethodElement)} is not.',
      todo:
          "Declare method '$targetMethodElement' as an expression bodied method with "
          "another PropertyDescriptorsBuilder's (extension) method invocation.",
    );
  }

  final invocationTypeArguments = _mapTypeArguments(
    targetMethodElement,
    targetMethodBodyExpression,
    targetMethodElement,
    typeArguments,
  );

  final nextTargetClass =
      lookupTargetClass(targetMethodElement, targetMethodBodyExpression);

  return await resolvePropertyDefinitionAsync(
    context: context,
    contextElement: targetMethodElement,
    methodInvocation: targetMethodBodyExpression,
    targetClass: nextTargetClass,
    propertyName: passingPropertyName,
    typeArguments: invocationTypeArguments,
    originalMethodInvocation: originalMethodInvocation,
    isInferred: isInferred,
  );
}

PropertyDefinitionWithSource _createPropertyDefinition({
  required ParseContext context,
  required Element contextElement,
  required MethodInvocation methodInvocation,
  required ExecutableElement targetMethodElement,
  required String? propertyName,
  required List<GenericType> typeArguments,
  required MethodInvocation originalMethodInvocation,
  required bool isInferred,
}) {
  bool isGenericType(GenericType type) {
    bool isGenericRawType(DartType rawType) {
      if (rawType.isDartCoreObject || rawType.isDartCoreEnum) {
        return true;
      }

      if (rawType is TypeParameterType) {
        return true;
      }

      if (rawType is! InterfaceType) {
        return false;
      }

      if (rawType.typeArguments.any(isGenericRawType)) {
        return true;
      }

      return false;
    } // isGenericRawType

    final rawType = type.rawType;
    if (isGenericRawType(rawType) && type.typeArguments.isEmpty) {
      return true;
    }

    if (type.typeArguments.any(isGenericType)) {
      return true;
    }

    return false;
  } // isGenericType

  final warnings = <String>[];

  assert(typeArguments.length > 1);

  final typeArgument1 = typeArguments[0];
  final typeArgument2 = typeArguments[1];
  final typeArgument3 = typeArguments.length > 2 ? typeArguments[2] : null;

  if (isInferred) {
    if (isGenericType(typeArgument1)) {
      warnings.add(
        '`${typeArgument1.getDisplayString(withNullability: true)}` is used '
        'for property value type because type parameter `P` is not specified '
        'and it cannot be inferred with parameters. Ensure specify type '
        'argument `P` explicitly.',
      );
    }

    if (isGenericType(typeArgument2)) {
      warnings.add(
        '`${typeArgument2.getDisplayString(withNullability: true)}` is used '
        'for field value type because type parameter `F` is not specified and '
        'it cannot be inferred with parameters. Ensure specify type argument '
        '`F` explicitly.',
      );

      if (methodInvocation.methodName.name ==
          PropertyDescriptorsBuilderMethods.add) {
        warnings.add(
          '`${context.isFormBuilder ? 'FormBuilderField' : 'FormField'}'
          '<${typeArgument2.getDisplayString(withNullability: true)}>` is used '
          'for FormField type because type parameter `F` is not specified and '
          'it cannot be inferred with parameters. Ensure specify type argument '
          '`F` explicitly.',
        );
      }
    }

    if (typeArgument3?.rawType.element?.name == 'FormField') {
      warnings.add(
        '`FormField<${typeArgument2.getDisplayString(withNullability: true)}>` '
        'is used for FormField type because type parameter `TField` is not '
        'specified and it cannot be inferred with parameters. Ensure specify '
        'type argument `TField` explicitly.',
      );
    }
  }

  return PropertyDefinitionWithSource(
    PropertyDefinition(
      name: propertyName ??
          _getPropertyNameFromInvocation(
            methodInvocation,
            contextElement,
            mayNotExist: false,
          )!,
      propertyType: typeArgument1,
      fieldType: typeArgument2,
      preferredFormFieldType: typeArgument3,
      warnings: warnings,
    ),
    originalMethodInvocation,
  );
}

String? _getPropertyNameFromInvocation(
  MethodInvocation method,
  Element contextElement, {
  required bool mayNotExist,
}) {
  final namedArguments = {
    for (final ne in method.argumentList.arguments.whereType<NamedExpression>())
      ne.name.label.name: ne.expression.unParenthesized
  };

  return _extractLiteralStringValue(
    namedArguments,
    'name',
    method,
    contextElement,
    mayNotExist: mayNotExist,
  );
}

List<GenericType> _mapTypeArguments(
  ExecutableElement current,
  MethodInvocation invocation,
  ExecutableElement targetMethod,
  List<GenericType> typeArguments,
) {
  final invocationTypeArguments = invocation.typeArgumentTypes!;
  final typeArgumentsMap = _buildTypeArgumentsMap(current, typeArguments);

  final result = <GenericType>[];
  for (var i = 0; i < invocationTypeArguments.length; i++) {
    final invocationTypeArgument = invocationTypeArguments[i];
    if (invocationTypeArgument is InterfaceType) {
      result.add(
        GenericType.generic(
          invocationTypeArgument,
          _resolveTypeArguments(
            invocationTypeArgument,
            typeArgumentsMap,
            invocation,
            current,
          ).toList(),
        ),
      );
    } else if (invocationTypeArgument is TypeParameterType) {
      result.add(
        typeArgumentsMap[invocationTypeArgument.element.name]!,
      );
    } else {
      throwNotSupportedYet(node: invocation, contextElement: current);
    }
  }

  return result;
}

Map<String, GenericType> _buildTypeArgumentsMap(
  ExecutableElement method,
  List<GenericType> typeArguments,
) {
  assert(method.typeParameters.length == typeArguments.length);
  final typeArgumentsMap = <String, GenericType>{};
  for (var i = 0; i < method.typeParameters.length; i++) {
    typeArgumentsMap[method.typeParameters[i].name] = typeArguments[i];
  }
  return typeArgumentsMap;
}

Iterable<GenericType> _resolveTypeArguments(
  InterfaceType currentType,
  Map<String, GenericType> typeArguments,
  AstNode node,
  Element contextElement,
) sync* {
  for (final typeArgument in currentType.typeArguments) {
    if (typeArgument is TypeParameterType) {
      yield typeArguments[typeArgument.element.name]!;
    } else if (typeArgument is InterfaceType) {
      yield GenericType.generic(
        typeArgument,
        _resolveTypeArguments(
          typeArgument,
          typeArguments,
          node,
          contextElement,
        ).toList(),
      );
    } else {
      throwNotSupportedYet(node: node, contextElement: contextElement);
    }
  }
}

String? _extractLiteralStringValue(
  Map<String, Expression> arguments,
  String argumentName,
  MethodInvocation methodInvocation,
  Element contextElement, {
  bool mayNotExist = false,
}) {
  final expression = arguments[argumentName];
  if (expression == null && mayNotExist) {
    // No error.
    return null;
  }

  if (expression is StringLiteral) {
    final literalValue = expression.stringValue;
    if (literalValue != null) {
      return literalValue;
    }
  }

  throwError(
    message:
        "Failed to parse non-literal '$argumentName' argument from expression '$methodInvocation'.",
    todo: "Use constant expression for '$argumentName' argument.",
    element: contextElement,
  );
}
