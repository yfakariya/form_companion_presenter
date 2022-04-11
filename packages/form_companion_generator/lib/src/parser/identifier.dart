// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseIdentifierAsync function.

FutureOr<PropertyDescriptorsBuilding> _parseIdentifierAsync(
  ParseContext context,
  Identifier identifier,
  Element contextElement,
) async {
  assert(isPropertyDescriptorsBuilder(identifier.staticType));

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

  final getter = lookupContextElement
          .thisOrAncestorOfType<ClassElement>()
          ?.lookUpGetter(lookupId, contextElement.library!) ??
      contextElement.library!.scope.lookup(lookupId).getter;

  return await _parseGetterAsync(context, getter, identifier, contextElement);
}

FutureOr<PropertyDescriptorsBuilding> _parsePropertyAccessAsync(
  ParseContext context,
  PropertyAccess access,
  Element contextElement,
) async {
  assert(isPropertyDescriptorsBuilder(access.staticType));

  final target = access.target;
  final lookupContextElement = target is PrefixedIdentifier
      ? target.identifier.staticElement!
      : target is SimpleIdentifier
          ? target.staticElement!
          : contextElement;

  final getter = lookupContextElement
          .thisOrAncestorOfType<ClassElement>()
          ?.lookUpGetter(access.propertyName.name, contextElement.library!) ??
      contextElement.library!.scope.lookup(access.propertyName.name).getter;

  return await _parseGetterAsync(
    context,
    getter,
    access,
    contextElement,
  );
}

FutureOr<PropertyDescriptorsBuilding> _parseGetterAsync(
  ParseContext context,
  Element? getter,
  AstNode node,
  Element contextElement,
) async {
  if (getter is TopLevelVariableElement ||
      getter is FieldElement ||
      getter is PropertyAccessorElement) {
    // return fieldOrTopLevelVariable

    final getterNode =
        await context.nodeProvider.getElementDeclarationAsync(getter!);
    final property = VariableNode(getterNode, getter);
    final initializer = property.initializer;
    if (initializer == null) {
      throwError(
        message: 'Failed to parse field, property, or top level variable '
            "'${property.name}' which does not have inline initialization "
            'at ${getNodeLocation(getterNode, getter)}.',
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
      node: node,
      element: getter,
      contextElement: contextElement,
    );
  }
}
