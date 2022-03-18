// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseMethodInvocations and its sub functions.

Iterable<PropertyDefinition> _parseMethodInvocations(
  ParseContext context,
  Iterable<MethodInvocation> invocations,
  Element contextElement, {
  required bool isFormBuilder,
}) {
  final result = <String, PropertyDefinition>{};
  for (final parameter in invocations.map((m) => _parseBuilderMethodCall(
        context,
        m,
        contextElement,
        isFormBuilder: isFormBuilder,
      ))) {
    if (parameter == null) {
      continue;
    }

    if (result.containsKey(parameter.name)) {
      throwError(
        message:
            "Property '${parameter.name}' is defined more than once ${getNodeLocation(parameter.node, parameter.element)}.",
        todo: 'Fix to define each properties only once for given $pdbTypeName.',
        element: parameter.element,
      );
    }

    result[parameter.name] = parameter.property;
  }

  return result.values;
}

/// Packs [PropertyDefinition] and diagnostic informations ([AstNode] and [Element]).
class _PropertyDefinitionWithSource {
  final PropertyDefinition property;
  final AstNode node;
  final Element element;
  String get name => property.name;

  _PropertyDefinitionWithSource(this.property, this.node, this.element);
}

_PropertyDefinitionWithSource? _parseBuilderMethodCall(
  ParseContext context,
  MethodInvocation methodInvocation,
  Element contextElement, {
  required bool isFormBuilder,
}) {
  switch (methodInvocation.methodName.name) {
    case 'add':
      final warnings = <String>[];
      return _buildPropertyDefinitionWithSource(
        methodInvocation,
        contextElement,
        _getPropertyTypeFromFirstTypeArgument(
          context,
          methodInvocation,
          warnings,
        ),
        null,
        warnings,
      );

    case 'addWithField':
      final warnings = <String>[];

      late final String? preferredFieldType;
      final typeArguments = methodInvocation.typeArguments;
      if (typeArguments == null || typeArguments.length < 2) {
        // If omitted, it means that preferredFieldType is not specified.
        preferredFieldType = null;
      } else {
        final typeArgument = typeArguments.arguments[1].type;
        if (typeArgument is InterfaceType) {
          // Use element name to erase type arguments here.
          preferredFieldType = typeArgument.element.name;
        } else {
          final failedToResolveTypeMessage =
              "Failed to resolve second type argument of $pdbTypeName.${methodInvocation.methodName}${methodInvocation.typeArguments}(): '$typeArgument'.";
          warnings.add(failedToResolveTypeMessage);
          context.logger.warning(failedToResolveTypeMessage);
          preferredFieldType = null;
        }
      }

      return _buildPropertyDefinitionWithSource(
        methodInvocation,
        contextElement,
        _getPropertyTypeFromFirstTypeArgument(
          context,
          methodInvocation,
          warnings,
        ),
        preferredFieldType,
        warnings,
      );
  }

  // Unknown method.
  final unexpectedMethodWarning =
      "Unexpected method: '${methodInvocation.methodName.name}'.";
  context.addGlobalWarning(unexpectedMethodWarning);
  return null;
}

InterfaceType _getPropertyTypeFromFirstTypeArgument(
  ParseContext context,
  MethodInvocation methodInvocation,
  List<String> warnings,
) {
  final typeArguments = methodInvocation.typeArguments;
  if (typeArguments == null) {
    // Because add method is declared as add<T extends Object>,
    // so raw type will be Object rather than dynamic here.
    return context.typeProvider.objectType;
  } else {
    final typeArgument = typeArguments.arguments.first.type;
    if (typeArgument is InterfaceType) {
      return typeArgument;
    } else {
      final type = context.typeProvider.objectType;
      final failedToResolveTypeMessage =
          "Failed to resolve first type argument of $pdbTypeName.${methodInvocation.methodName}${methodInvocation.typeArguments}(): '$typeArgument'.";
      warnings.add(failedToResolveTypeMessage);
      context.logger.warning(failedToResolveTypeMessage);
      return type;
    }
  }
}

_PropertyDefinitionWithSource _buildPropertyDefinitionWithSource(
  MethodInvocation methodInvocation,
  Element contextElement,
  InterfaceType type,
  String? preferredFieldType,
  List<String> warnings,
) {
  final namedArguments = {
    for (final ne
        in methodInvocation.argumentList.arguments.whereType<NamedExpression>())
      ne.name.label.name: ne.expression.unParenthesized
  };

  final name = _extractLiteralStringValue(
    namedArguments,
    'name',
    methodInvocation,
    contextElement,
  )!;

  return _PropertyDefinitionWithSource(
    PropertyDefinition(
      name: name,
      type: type,
      preferredFieldType: preferredFieldType,
      warnings: warnings,
    ),
    methodInvocation,
    _getDeclaringElement(methodInvocation),
  );
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
