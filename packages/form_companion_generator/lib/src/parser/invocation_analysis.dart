// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseMethodInvocations and its sub functions.

Map<String, PropertyDefinition> _parseMethodInvocations(
  LibraryReader libraryReader,
  Iterable<MethodInvocation> invocations,
  Element contextElement,
  List<String> warnings,
  Logger logger,
) {
  final result = <String, PropertyDefinition>{};
  for (final p in invocations
      .map((m) => _parseBuilderMethodCall(
          libraryReader, m, contextElement, warnings, logger))
      .where((p) => p != null)) {
    if (result.containsKey(p!.name)) {
      throwError(
        message:
            "Property '${p.name}' is defined more than once ${getNodeLocation(p.node, p.element)}.",
        todo: 'Fix to define each properties only once for given $pdbTypeName.',
        element: p.element,
      );
    }

    result[p.name] = p.property;
  }

  return result;
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
  LibraryReader libraryReader,
  MethodInvocation methodInvocation,
  Element contextElement,
  List<String> globalWarnings,
  Logger logger,
) {
  switch (methodInvocation.methodName.name) {
    case 'add':
      final namedArguments = {
        for (final ne in methodInvocation.argumentList.arguments
            .whereType<NamedExpression>())
          ne.name.label.name: ne.expression.unParenthesized
      };

      final name = _extractLiteralStringValue(
        namedArguments,
        'name',
        methodInvocation,
        contextElement,
        globalWarnings,
        logger,
      )!;

      late final String typeName;
      late final bool isEnum;

      final warnings = <String>[];
      final typeArguments = methodInvocation.typeArguments;
      if (typeArguments == null) {
        // Because add method is declared as add<T extends Object>,
        // so raw type will be Object rather than dynamic here.
        typeName = 'Object';
        isEnum = false;
      } else {
        final typeArgument = typeArguments.arguments.single.type!.element;
        if (typeArgument?.name != null) {
          typeName = typeArgument!.name!;

          if (typeArgument is! ClassElement) {
            isEnum = false;
            final failedToResolveTypeMessage =
                "Failed to resolve type arguments of $pdbTypeName.add<T>(): '$typeArgument'.";
            warnings.add(failedToResolveTypeMessage);
            logger.warning(failedToResolveTypeMessage);
          } else {
            isEnum = typeArgument.isEnum;
          }
        } else {
          typeName = 'Object';
          final failedToResolveTypeMessage =
              "Failed to resolve type arguments of $pdbTypeName.add<T>(): '$typeArgument'.";
          warnings.add(failedToResolveTypeMessage);
          logger.warning(failedToResolveTypeMessage);
          isEnum = false;
        }
      }

      final preferredFieldType = _extractLiteralStringValue(
        namedArguments,
        'preferredFieldType',
        methodInvocation,
        contextElement,
        warnings,
        logger,
        mayNotExist: true,
      );

      return _PropertyDefinitionWithSource(
        PropertyDefinition(
          name: name,
          type: typeName,
          isEnum: isEnum,
          preferredFieldType: preferredFieldType,
          warnings: warnings,
        ),
        methodInvocation,
        _getDeclaringElement(methodInvocation),
      );
  }

  // Unknown method.
  final unexpectedMethodWarning =
      "Unexpected method: '${methodInvocation.methodName.name}'.";
  globalWarnings.add(unexpectedMethodWarning);
  logger.warning(unexpectedMethodWarning);
  return null;
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
  Element contextElement,
  List<String> globalWarnings,
  Logger logger, {
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
