// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseAsignmentAsync function.

FutureOr<PropertyDescriptorsBuilding> _processAssignmentAsync(
  ParseContext context,
  AstNode contextNode,
  Element contextElement,
  String leftHand,
  Expression rightHand,
) async {
  assert(isPropertyDescriptorsBuilder(rightHand.staticType));

  late final PropertyDescriptorsBuilding? rightHandBuilding;
  if (rightHand is Identifier) {
    context.logger.fine(
      "Assign variable '$leftHand' with variable '${rightHand.name}' at ${getNodeLocation(contextNode, contextElement)}.",
    );
    rightHandBuilding = await _parseIdentifierAsync(
      context,
      rightHand,
      contextElement,
    );
  } else {
    context.logger.fine(
      "Assign variable '$leftHand' with expression '$rightHand' at ${getNodeLocation(contextNode, contextElement)}.",
    );
    rightHandBuilding = await _parseExpressionAsync(
      context,
      contextElement,
      rightHand,
    );
  }

  // rightHandBuilding should not be null.
  return context.buildings[leftHand] = rightHandBuilding!.chain(leftHand);
}
