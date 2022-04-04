// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseExpressionAsync and its sub functions.

FutureOr<PropertyDescriptorsBuilding?> _parseExpressionAsync(
  ParseContext context,
  Element contextElement,
  Expression expression,
) async {
  final unparenthesized = expression.unParenthesized;
  _eliminateControlExpression(unparenthesized, contextElement);

  if (unparenthesized is Identifier) {
    return await _parseIdentifierAsync(
      context,
      unparenthesized,
      contextElement,
    );
  } else if (unparenthesized is AssignmentExpression) {
    if (!isPropertyDescriptorsBuilder(unparenthesized.staticType)) {
      context.logger.fine(
          "Skip assignment expression '$expression' because right hand type is not $pdbTypeName at ${getNodeLocation(expression, contextElement)}.");
      return null;
    }

    final leftHand = unparenthesized.leftHandSide;
    if (leftHand is Identifier) {
      if (leftHand.staticElement is! PromotableElement) {
        // x[n] or x.n, so just skip
        context.logger.fine(
            "Skip left hand part '$leftHand' of assignment expression '$expression' because it is not a variable at ${getNodeLocation(expression, contextElement)}.");
        // fall through
        return await _parseExpressionAsync(
          context,
          contextElement,
          unparenthesized.rightHandSide,
        );
      } else {
        // x = y
        return await _processAssignmentAsync(
          context,
          expression,
          contextElement,
          leftHand.name,
          unparenthesized.rightHandSide,
        );
      }
    } else {
      // It is extremely hard to analyze and determine PropertyDescritporsBuilder
      // state statically when it is setup via field and/or top level variable.
      throwError(
        message:
            "Failed to parse complex $pdbTypeName setup via '$leftHand' at ${getNodeLocation(leftHand, contextElement)}.",
        todo:
            'Do not assign $pdbTypeName to fields or top level variables, use local variables instead.',
        element: contextElement,
      );
    }
  } else if (unparenthesized is CascadeExpression) {
    final target = unparenthesized.target;
    final targetClass = target.staticType?.element as ClassElement?;
    if (targetClass?.name != pdbTypeName) {
      throwNotSupportedYet(
        node: unparenthesized,
        contextElement: contextElement,
      );
    }

    late final PropertyDescriptorsBuilding building;
    if (target is Identifier && target.staticElement is PromotableElement) {
      context.logger.fine(
        "Found cascading method invocation for $pdbTypeName '$target' at ${getNodeLocation(expression, contextElement)}.",
      );

      building = context.buildings[target.name]!;
    } else if (target is InstanceCreationExpression ||
        target is InvocationExpression) {
      context.logger.fine(
        "Found cascading method invocation for $pdbTypeName '$target' at ${getNodeLocation(expression, contextElement)}.",
      );
      // constructor or factory method
      building = (await _parseExpressionAsync(
        context,
        contextElement,
        target,
      ))!;
    } else {
      // x[n] or x.n, so just skip
      context.logger.fine(
          "Skip cascade expression for '$target' (${target.runtimeType}) because it is not a $pdbTypeName variable at ${getNodeLocation(expression, contextElement)}.");
      return null;
    }

    building.addAll(
      await unparenthesized.cascadeSections
          .whereType<MethodInvocation>()
          .map(
            (e) => resolvePropertyDefinitionAsync(
              context: context,
              contextElement: contextElement,
              methodInvocation: e,
              targetClass: targetClass,
              targetMethodElement: lookupMethod(
                contextElement,
                targetClass,
                e.methodName.name,
                e,
              ),
              propertyName: null,
              typeArguments: e.typeArgumentTypes
                      ?.map((e) => GenericInterfaceType(e, []))
                      .toList() ??
                  [],
              isInferred:
                  e.typeArguments?.length != e.typeArgumentTypes?.length,
            ),
          )
          .toListAsync(),
      contextElement,
    );
    return building;
  }

  if (unparenthesized is InstanceCreationExpression &&
      unparenthesized.argumentList.arguments.isEmpty) {
    return _handleConstructorCall(context, unparenthesized, contextElement);
  }

  if (unparenthesized is MethodInvocation) {
    if (unparenthesized.methodName.name == pdbTypeName &&
        unparenthesized.argumentList.arguments.isEmpty) {
      // constructor
      return _handleConstructorCall(context, unparenthesized, contextElement);
    } else {
      // method call

      if (unparenthesized.methodName.name ==
          initializeCompanionMixinMethodName) {
        assert(unparenthesized.argumentList.arguments.length == 1);
        context.initializeCompanionMixinArgument = await _parseExpressionAsync(
          context,
          contextElement,
          unparenthesized.argumentList.arguments[0],
        );
        return null;
      }

      final target = unparenthesized.target;
      final targetClass = lookupTargetClass(contextElement, unparenthesized);
      if (targetClass?.name == pdbTypeName) {
        if (target is SimpleIdentifier) {
          // Found PDB method call.
          context.buildings[target.name]!.add(
            await resolvePropertyDefinitionAsync(
              context: context,
              contextElement: contextElement,
              methodInvocation: unparenthesized,
              targetClass: targetClass,
              targetMethodElement: lookupMethod(
                contextElement,
                targetClass,
                unparenthesized.methodName.name,
                unparenthesized,
              ),
              propertyName: null,
              typeArguments: unparenthesized.typeArgumentTypes
                      ?.map((e) => GenericInterfaceType(e, []))
                      .toList() ??
                  [],
              isInferred: unparenthesized.typeArguments?.length !=
                  unparenthesized.typeArgumentTypes?.length,
            ),
            contextElement,
          );
          return null;
        } else {
          throwNotSupportedYet(
            node: unparenthesized,
            contextElement: contextElement,
          );
        }
      }

      late final ExecutableNode? method;
      final localFunction =
          context.localFunctions[unparenthesized.methodName.name];
      if (localFunction != null) {
        method = ExecutableNode(
          context.nodeProvider,
          localFunction,
          localFunction.declaredElement!,
        );
      } else {
        final methodElement = lookupMethod(
          contextElement,
          targetClass,
          unparenthesized.methodName.name,
          unparenthesized,
        );

        method = ExecutableNode(
          context.nodeProvider,
          await context.nodeProvider.getElementDeclarationAsync(methodElement),
          methodElement,
        );
      }

      final parameters = await method.getParametersAsync();
      if (!isPropertyDescriptorsBuilder(method.returnType) &&
          !parameters.any((p) => isPropertyDescriptorsBuilder(p.type))) {
        context.logger.fine(
          "Skip trivial method or function call '$unparenthesized' at ${getNodeLocation(unparenthesized, contextElement)}.",
        );
        return null;
      }

      // initialize arguments
      Map<String, PropertyDescriptorsBuilding>? arguments;
      if (parameters.isNotEmpty) {
        arguments = {};
        for (var i = 0; i < parameters.length; i++) {
          if (isPropertyDescriptorsBuilder(parameters[i].type)) {
            final argument = await _parseExpressionAsync(
              context,
              contextElement,
              unparenthesized.argumentList.arguments[i],
            );
            assert(
              argument != null,
              "$pdbTypeName typed expression '${unparenthesized.argumentList.arguments[i]}'"
              ' (${unparenthesized.argumentList.arguments[i].runtimeType}) does not return building.',
            );
            // bind argument to parameter
            arguments[parameters[i].name] = argument!;
          }
        }
      }

      context.logger.fine(
        "Parse method or function '${method.name}' at ${getNodeLocation(unparenthesized, contextElement)}",
      );

      return await _parseFunctionBodyAsync(
        context,
        method.element,
        arguments,
        method.body,
      );
    } // method or function
  } // is MethodInvocation

  if (unparenthesized is FunctionExpressionInvocation ||
      unparenthesized is FunctionExpression) {
    // (a.getter)(x) or () => x;
    // Too complex and it should not be used for builder construction.
    throwNotSupportedYet(
      node: expression,
      contextElement: contextElement,
    );
  }

  context.logger.fine(
      "Skip trivial expression '$expression'(${unparenthesized.runtimeType}) at ${getNodeLocation(expression, contextElement)}.");
  return null;
}

void _eliminateControlExpression(
  Expression expression,
  Element contextElement,
) {
  if (expression is ConditionalExpression ||
      expression is ThrowExpression ||
      expression is RethrowExpression) {
    throwError(
      message:
          'Failed to analyze complex construction logics at ${getNodeLocation(expression, contextElement)}.',
      todo:
          'Do not use conditional or throw like expression in methods or functions for $pdbTypeName construction.',
      element: contextElement,
    );
  }
}

FutureOr<PropertyDescriptorsBuilding> _handleConstructorCall(
  ParseContext context,
  Expression expression,
  Element contextElement,
) {
  context.logger.fine(
    'Found constructor initialization of $pdbTypeName at ${getNodeLocation(expression, contextElement)}.',
  );
  return PropertyDescriptorsBuilding.begin();
}
