// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseExpressionAsync and its sub functions.

FutureOr<PropertyDescriptorsBuilding?> _parseExpressionAsync(
  ParseContext context,
  Element contextElement,
  Expression expression,
) async {
  final unParenthesized = expression.unParenthesized;
  _eliminateControlExpression(unParenthesized, contextElement);

  if (unParenthesized is Identifier) {
    return await _parseIdentifierAsync(
      context,
      unParenthesized,
      contextElement,
    );
  } else if (unParenthesized is AssignmentExpression) {
    if (!_isPropertyDescriptorsBuilder(unParenthesized.staticType)) {
      context.logger.fine(
          "Skip assignment expression '$expression' because right hand type is not $pdbTypeName at ${getNodeLocation(expression, contextElement)}.");
      return null;
    }

    final leftHand = unParenthesized.leftHandSide;
    if (leftHand is Identifier) {
      if (leftHand.staticElement is! PromotableElement) {
        // x[n] or x.n, so just skip
        context.logger.fine(
            "Skip left hand part '$leftHand' of assignment expression '$expression' because it is not a variable at ${getNodeLocation(expression, contextElement)}.");
        // fall through
        return await _parseExpressionAsync(
          context,
          contextElement,
          unParenthesized.rightHandSide,
        );
      } else {
        // x = y
        return await _processAssignmentAsync(
          context,
          expression,
          contextElement,
          leftHand.name,
          unParenthesized.rightHandSide,
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
  } else if (unParenthesized is CascadeExpression) {
    final target = unParenthesized.target;
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
      unParenthesized.cascadeSections.whereType<MethodInvocation>(),
      contextElement,
    );
    return building;
  }

  if (unParenthesized is InstanceCreationExpression &&
      unParenthesized.argumentList.arguments.isEmpty) {
    return _handleConstructorCall(context, unParenthesized, contextElement);
  }

  if (unParenthesized is MethodInvocation) {
    if (unParenthesized.methodName.name == pdbTypeName &&
        unParenthesized.argumentList.arguments.isEmpty) {
      // constructor
      return _handleConstructorCall(context, unParenthesized, contextElement);
    } else {
      // method call

      if (unParenthesized.methodName.name ==
          initializeCompanionMixinMethodName) {
        assert(unParenthesized.argumentList.arguments.length == 1);
        context.initializeCompanionMixinArgument = await _parseExpressionAsync(
          context,
          contextElement,
          unParenthesized.argumentList.arguments[0],
        );
        return null;
      }

      final target = unParenthesized.target;
      final targetClass = _getTargetClass(unParenthesized);
      if (targetClass?.name == pdbTypeName) {
        if (target is SimpleIdentifier) {
          // Found PDB method call.
          context.buildings[target.name]!.add(unParenthesized, contextElement);
          return null;
        } else {
          throwNotSupportedYet(
            node: unParenthesized,
            contextElement: contextElement,
          );
        }
      }

      late final ExecutableNode? method;
      final localFunction =
          context.localFunctions[unParenthesized.methodName.name];
      if (localFunction != null) {
        method = ExecutableNode(
          context.nodeProvider,
          localFunction,
          localFunction.declaredElement!,
        );
      } else {
        final methodElement = targetClass?.lookUpMethod(
                unParenthesized.methodName.name, contextElement.library!) ??
            contextElement.library!.scope
                .lookup(unParenthesized.methodName.name)
                .getter;
        if (methodElement != null) {
          method = ExecutableNode(
            context.nodeProvider,
            await context.nodeProvider
                .getElementDeclarationAsync(methodElement),
            methodElement,
          );
        } else {
          method = null;
        }
      }

      if (method == null) {
        throwError(
          message:
              "Failed to lookup method or function '$unParenthesized' in context of ${contextElement.library} at ${getNodeLocation(unParenthesized, contextElement)}.",
          element: contextElement,
        );
      }

      final parameters = await method.getParametersAsync();
      if (!_isPropertyDescriptorsBuilder(method.returnType) &&
          !parameters.any((p) => _isPropertyDescriptorsBuilder(p.type))) {
        context.logger.fine(
          "Skip trivial method or function call '$unParenthesized' at ${getNodeLocation(unParenthesized, contextElement)}.",
        );
        return null;
      }

      // initialize arguments
      Map<String, PropertyDescriptorsBuilding>? arguments;
      if (parameters.isNotEmpty) {
        arguments = {};
        for (var i = 0; i < parameters.length; i++) {
          if (_isPropertyDescriptorsBuilder(parameters[i].type)) {
            final argument = await _parseExpressionAsync(
              context,
              contextElement,
              unParenthesized.argumentList.arguments[i],
            );
            assert(
              argument != null,
              "$pdbTypeName typed expression '${unParenthesized.argumentList.arguments[i]}'"
              ' (${unParenthesized.argumentList.arguments[i].runtimeType}) does not return building.',
            );
            // bind argument to parameter
            arguments[parameters[i].name] = argument!;
          }
        }
      }

      context.logger.fine(
        "Parse method or function '${method.name}' at ${getNodeLocation(unParenthesized, contextElement)}",
      );

      return await _parseFunctionBodyAsync(
        context,
        method.element,
        arguments,
        method.body,
      );
    } // method or function
  } // is MethodInvocation

  if (unParenthesized is FunctionExpressionInvocation ||
      unParenthesized is FunctionExpression) {
    // (a.getter)(x) or () => x;
    // Too complex and it should not be used for builder construction.
    throwNotSupportedYet(
      node: expression,
      contextElement: contextElement,
    );
  }

  context.logger.fine(
      "Skip trivial expression '$expression'(${unParenthesized.runtimeType}) at ${getNodeLocation(expression, contextElement)}.");
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
