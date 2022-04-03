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

/// Resolves [MethodInvocation] to [PropertyDefinitionAndSource].
FutureOr<PropertyDefinitionAndSource> resolvePropertyDefinitionAsync(
  ParseContext context,
  Element contextElement,
  MethodInvocation methodInvocation,
  ClassElement? targetClass,
  ExecutableElement targetMethodElement,
  String? propertyName,
  List<GenericInterfaceType> typeArguments, {
  required bool isInferred,
}) async {
  context.logger.finer(
    "Resolve invocation chain '$methodInvocation$typeArguments', found name: '$propertyName'.",
  );
  if (methodInvocation.methodName.name ==
          PropertyDescriptorsBuilderMethods.add ||
      methodInvocation.methodName.name ==
          PropertyDescriptorsBuilderMethods.addWithField) {
    return _createPropertyDefinition(
      context,
      contextElement,
      methodInvocation,
      targetMethodElement,
      propertyName,
      typeArguments,
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
          "but method '$targetMethodNode' at "
          '${getNodeLocation(targetMethodNode.body, targetMethodElement)} is not.',
      todo:
          "Declare method '$targetMethodNode' as an expression bodied method.",
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
          "Declare method '$targetMethodNode' as an expression bodied method with "
          " another PropertyDescriptorsBuilder's (extension) method invocation.",
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

  final nextTargetMethodElement = lookupMethod(
    targetMethodElement,
    nextTargetClass,
    targetMethodBodyExpression.methodName.name,
    targetMethodBodyExpression,
  );

  return await resolvePropertyDefinitionAsync(
    context,
    targetMethodElement,
    targetMethodBodyExpression,
    targetClass,
    nextTargetMethodElement,
    passingPropertyName,
    invocationTypeArguments,
    isInferred: isInferred,
  );
}

PropertyDefinitionAndSource _createPropertyDefinition(
  ParseContext context,
  Element contextElement,
  MethodInvocation methodInvocation,
  ExecutableElement targetMethodElement,
  String? propertyName,
  List<GenericInterfaceType> typeArguments, {
  required bool isInferred,
}) {
  bool isGenericType(GenericInterfaceType type) {
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

  final typeArgumentsMap =
      _buildTypeArgumentsMap(targetMethodElement, typeArguments);
  final warnings = <String>[];

  GenericInterfaceType getRequiredTypeArgument(int index) =>
      (typeArguments.length > index ? typeArguments[index] : null) ??
      _getTypeFromTypeArgument(
        context,
        methodInvocation,
        index,
        typeArgumentsMap,
        warnings,
      ); // getRequiredTypeArgument

  final typeArgument1 = getRequiredTypeArgument(0);
  final typeArgument2 = getRequiredTypeArgument(1);
  final typeArgument3 = (typeArguments.length > 2 ? typeArguments[2] : null) ??
      _tryGetTypeFromTypeArgument(
        context,
        methodInvocation,
        2,
        typeArgumentsMap,
      );

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

    if (typeArgument3?.rawTypeName == 'FormField') {
      warnings.add(
        '`FormField<${typeArgument2.getDisplayString(withNullability: true)}>` '
        'is used for FormField type because type parameter `TField` is not '
        'specified and it cannot be inferred with parameters. Ensure specify '
        'type argument `TField` explicitly.',
      );
    }
  }

  return PropertyDefinitionAndSource(
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
    methodInvocation,
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

List<GenericInterfaceType> _mapTypeArguments(
  ExecutableElement current,
  MethodInvocation invocation,
  ExecutableElement targetMethod,
  List<GenericInterfaceType> typeArguments,
) {
  final invocationTypeArguments = invocation.typeArgumentTypes;
  if (invocationTypeArguments == null) {
    return [];
  }

  final typeArgumentsMap = _buildTypeArgumentsMap(current, typeArguments);

  final result = <GenericInterfaceType>[];
  for (var i = 0; i < invocationTypeArguments.length; i++) {
    final invocationTypeArgument = invocationTypeArguments[i];
    if (invocationTypeArgument is InterfaceType) {
      result.add(
        GenericInterfaceType(
          invocationTypeArgument,
          _resolveTypeArguments(invocationTypeArgument, typeArgumentsMap)
              .toList(),
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

Map<String, GenericInterfaceType> _buildTypeArgumentsMap(
  ExecutableElement method,
  List<GenericInterfaceType> typeArguments,
) {
  assert(
    method.typeParameters.length == typeArguments.length,
    '$method (${method.typeParameters.length}) != $typeArguments',
  );
  final typeArgumentsMap = <String, GenericInterfaceType>{};
  for (var i = 0; i < method.typeParameters.length; i++) {
    typeArgumentsMap[method.typeParameters[i].name] = typeArguments[i];
  }
  return typeArgumentsMap;
}

Iterable<GenericInterfaceType> _resolveTypeArguments(
  InterfaceType currentType,
  Map<String, GenericInterfaceType> typeArguments,
) sync* {
  for (final typeArgument in currentType.typeArguments) {
    if (typeArgument is TypeParameterType) {
      yield typeArguments[typeArgument.element.name]!;
    } else if (typeArgument is InterfaceType) {
      yield GenericInterfaceType(
        typeArgument,
        _resolveTypeArguments(typeArgument, typeArguments).toList(),
      );
    } else {
      yield GenericInterfaceType(typeArgument, []);
    }
  }
}

GenericInterfaceType? _tryGetTypeFromTypeArgument(
  ParseContext context,
  MethodInvocation methodInvocation,
  int position,
  Map<String, GenericInterfaceType> typeArguments,
) {
  final invocationTypeArguments = methodInvocation.typeArguments;
  if (invocationTypeArguments == null ||
      invocationTypeArguments.arguments.length <= position) {
    // Because add method is declared as add<T extends Object>,
    // so raw type will be Object rather than dynamic here.
    return null;
  } else {
    final invocationTypeArgument =
        invocationTypeArguments.arguments[position].type;
    if (invocationTypeArgument is InterfaceType) {
      return GenericInterfaceType(
        invocationTypeArgument,
        _resolveTypeArguments(invocationTypeArgument, typeArguments).toList(),
      );
    } else {
      return null;
    }
  }
}

GenericInterfaceType _getTypeFromTypeArgument(
  ParseContext context,
  MethodInvocation methodInvocation,
  int position,
  Map<String, GenericInterfaceType> typeArguments,
  List<String> warnings,
) {
  final invocationTypeArguments = methodInvocation.typeArguments;
  if (invocationTypeArguments == null ||
      invocationTypeArguments.length <= position) {
    // Because add method is declared as add<T extends Object>,
    // so raw type will be Object rather than dynamic here.
    return GenericInterfaceType(context.typeProvider.objectType, []);
  } else {
    final typeArgument = invocationTypeArguments.arguments[position].type;
    if (typeArgument is InterfaceType) {
      return GenericInterfaceType(
        typeArgument,
        _resolveTypeArguments(typeArgument, typeArguments).toList(),
      );
    } else {
      final type = context.typeProvider.objectType;
      final failedToResolveTypeMessage =
          "Failed to resolve type argument at ${position + 1} of $pdbTypeName.${methodInvocation.methodName}${methodInvocation.typeArguments}(): '$typeArgument'.";
      warnings.add(failedToResolveTypeMessage);
      context.logger.warning(failedToResolveTypeMessage);
      return GenericInterfaceType(type, []);
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
