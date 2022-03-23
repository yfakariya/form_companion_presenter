// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseMethodInvocations and its sub functions.

Iterable<PropertyDefinition> _toUniquePropertyDefinitions(
  ParseContext context,
  Iterable<PropertyDefinitionAndSource> definitions,
  Element contextElement, {
  required bool isFormBuilder,
}) sync* {
  final names = <String>{};
  for (final definition in definitions) {
    final property = definition.property;
    final element = _getDeclaringElement(definition.source);
    if (!names.add(property.name)) {
      throwError(
        message:
            "Property '${property.name}' is defined more than once ${getNodeLocation(definition.source, element)}.",
        todo: 'Fix to define each properties only once for given $pdbTypeName.',
        element: element,
      );
    }

    yield property;
  }
}

FutureOr<PropertyDefinitionAndSource> _getRealMethodAsync(
  ParseContext context,
  Element contextElement,
  MethodInvocation method,
  ExecutableElement methodElement,
  ClassElement? targetClass,
  String? propertyName,
  List<GenericInterfaceType> typeArguments, {
  required bool isInferred,
}) async {
  context.logger.finer(
    "Resolve invocation chain '$method$typeArguments', found name: '$propertyName'.",
  );
  if (method.methodName.name == PropertyDescriptorsBuilderMethods.add ||
      method.methodName.name ==
          PropertyDescriptorsBuilderMethods.addWithField) {
    return _createPropertyDefinition(
      context,
      contextElement,
      method,
      methodElement,
      propertyName,
      typeArguments,
      isInferred: isInferred,
    );
  }

  final passingPropertyName = propertyName ??
      _getPropertyNameFromInvocation(method, contextElement, mayNotExist: true);

  final targetMethodElement =
      _lookupMethod(contextElement, targetClass, method.methodName.name);

  assert(
    targetMethodElement != null,
    "Failed to lookup method '${method.methodName.name}' for class "
    "'${targetClass?.name}' and library '${contextElement.library?.source.fullName}'.",
  );

  final targetMethodNode = ExecutableNode(
    context.nodeProvider,
    await context.nodeProvider.getElementDeclarationAsync(
      targetMethodElement!,
    ),
    targetMethodElement,
  );

  final targetMethodBody = targetMethodNode.body;
  if (targetMethodBody is! ExpressionFunctionBody) {
    throwNotSupportedYet(
      node: targetMethodNode.body,
      contextElement: targetMethodElement,
    );
  }

  final targetMethodBodyExpression =
      targetMethodBody.expression.unParenthesized;
  if (targetMethodBodyExpression is! MethodInvocation) {
    throwNotSupportedYet(
      node: targetMethodBodyExpression,
      contextElement: targetMethodElement,
    );
  }

  final invocationTypeArguments = _mapTypeArguments(
    methodElement,
    targetMethodBodyExpression,
    targetMethodElement,
    typeArguments,
  );

  final invocationTargetClass =
      _getTargetClass(methodElement, targetMethodBodyExpression);

  final invocationTargetElement = _lookupMethod(
    methodElement,
    invocationTargetClass,
    targetMethodBodyExpression.methodName.name,
  );

  if (invocationTargetElement == null) {
    throwError(
      message:
          "Failed to resolve invocation target method or function '$targetMethodBodyExpression'.",
      element: methodElement,
    );
  }

  return await _getRealMethodAsync(
    context,
    targetMethodElement,
    targetMethodBodyExpression,
    invocationTargetElement,
    targetClass,
    passingPropertyName,
    invocationTypeArguments,
    isInferred: isInferred,
  );
}

PropertyDefinitionAndSource _createPropertyDefinition(
  ParseContext context,
  Element contextElement,
  MethodInvocation method,
  ExecutableElement methodElement,
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
    }

    final rawType = type.rawType;
    if (isGenericRawType(rawType) && type.typeArguments.isEmpty) {
      return true;
    }

    if (type.typeArguments.any(isGenericType)) {
      return true;
    }

    return false;
  }

  final typeArgumentsMap = _buildTypeArgumentsMap(methodElement, typeArguments);
  final warnings = <String>[];

  final typeArgument1 =
      // ignore: prefer_is_empty
      (typeArguments.length > 0 ? typeArguments[0] : null) ??
          _getTypeFromTypeArgument(
            context,
            method,
            0,
            typeArgumentsMap,
            warnings,
          );
  final typeArgument2 = (typeArguments.length > 1 ? typeArguments[1] : null) ??
      _getTypeFromTypeArgument(
        context,
        method,
        1,
        typeArgumentsMap,
        warnings,
      );
  final typeArgument3 = (typeArguments.length > 2 ? typeArguments[2] : null) ??
      _tryGetTypeFromTypeArgument(
        context,
        method,
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

      if (method.methodName.name == PropertyDescriptorsBuilderMethods.add) {
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
            method,
            contextElement,
            mayNotExist: false,
          )!,
      propertyType: typeArgument1,
      fieldType: typeArgument2,
      preferredFormFieldType: typeArgument3,
      warnings: warnings,
    ),
    method,
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

/// Packs [PropertyDefinition] and diagnostic informations ([AstNode] and [Element]).
class _PropertyDefinitionWithSource {
  final PropertyDefinition property;
  final AstNode node;
  final Element element;
  String get name => property.name;

  _PropertyDefinitionWithSource(this.property, this.node, this.element);
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

Element _getDeclaringElement(Expression expression) {
  for (AstNode? node = expression; node != null; node = node.parent) {
    if (node is Declaration && node is! VariableDeclaration) {
      // Any declaration other than local variable
      if (node is TopLevelVariableDeclaration) {
        // Manually look up because declaredElement is always null
        return (node.root as CompilationUnit)
            .declaredElement!
            .library
            .scope
            .lookup(node.variables.variables.first.name.name)
            .getter!;
      } else {
        return node.declaredElement!;
      }
    }

    if (node is CompilationUnit) {
      return node.declaredElement!;
    }
  }

  throw Exception(
    "Failed to get declered element of '$expression'.",
  );
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
