// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseIdentifierAsync function.

FutureOr<PropertyDescriptorsBuilding> _parseIdentifierAsync(
  ParseContext context,
  Identifier identifier,
  Element contextElement,
) async {
  assert(
    _isPropertyDescriptorsBuilder(identifier.staticType),
    "Type of identifier '$identifier' (${identifier.runtimeType}) is ${identifier.staticType}, not $pdbTypeName type.",
  );

  if (identifier.staticElement is PromotableElement) {
    // localOrParameter
    return context.buildings[identifier.name]!;
  }

  final lookupContextElement = identifier is PrefixedIdentifier
      ? identifier.prefix.staticElement!
      : contextElement;
  final lookupId = identifier is PrefixedIdentifier
      ? identifier.identifier.name
      : identifier.name;

  final getter = _getClass(lookupContextElement)
          ?.lookUpGetter(lookupId, contextElement.library!) ??
      contextElement.library!.scope.lookup(lookupId).getter;

  if (getter is TopLevelVariableElement ||
      getter is FieldElement ||
      getter is PropertyAccessorElement) {
    // return fieldOrTopLevelVariable
    final property =
        VariableNode.fromNode(await _getAstNodeAsync(getter!), getter);
    final initializer = property.initializer;
    if (initializer == null) {
      throwError(
        message:
            "Failed to parse field, property, or top level variable '${property.name}' which does not have inline initialization.",
        todo:
            "Initialize field, property, or top level variable '${property.name}' inline.",
        element: property.element,
      );
    }

    final building = (await _parseExpressionAsync(
      context,
      contextElement,
      initializer,
    ))!;
    if (getter is TopLevelVariableElement ||
        getter is FieldElement ||
        (getter is PropertyAccessorElement && getter.isSynthetic)) {
      building.markAsMutable();
    }

    return building;
  } else {
    throwNotSupportedYet(
      node: identifier,
      element: getter,
      contextElement: contextElement,
    );
  }
}
