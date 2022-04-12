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

    if (unparenthesized.writeElement is! PromotableElement) {
      throwError(
        message: 'Failed to parse complex setup logic. '
            "'$unparenthesized' changes field or top level variable which is "
            '$pdbTypeName type at ${getNodeLocation(expression, contextElement)}.',
        todo:
            'Do not re-assign field or top level variable which is $pdbTypeName type.',
        element: unparenthesized.writeElement,
      );
    }

    final leftHand = unparenthesized.leftHandSide;
    if (leftHand is Identifier) {
      // x = y
      return await _processAssignmentAsync(
        context,
        expression,
        contextElement,
        leftHand.name,
        unparenthesized.rightHandSide,
      );
    }
  } else if (unparenthesized is CascadeExpression) {
    final target = unparenthesized.target;
    final targetClass = target.staticType?.element as ClassElement?;
    if (targetClass?.name == pdbTypeName) {
      late final PropertyDescriptorsBuilding building;
      if (target is Identifier) {
        context.logger.fine(
          "Found cascading method invocation for $pdbTypeName '$target' at ${getNodeLocation(expression, contextElement)}.",
        );

        building = await _parseIdentifierAsync(context, target, contextElement);
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
        throwNotSupportedYet(
          node: unparenthesized,
          contextElement: contextElement,
        );
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
                propertyName: null,
                typeArguments:
                    e.typeArgumentTypes!.map(GenericType.fromDartType).toList(),
                originalMethodInvocation: e,
                isInferred:
                    e.typeArguments?.length != e.typeArgumentTypes?.length,
              ),
            )
            .toListAsync(),
        contextElement,
      );
      return building;
    }
  }

  if (unparenthesized is InstanceCreationExpression) {
    return _handleConstructorCall(context, unparenthesized, contextElement);
  }

  if (unparenthesized is MethodInvocation) {
    if (unparenthesized.methodName.name == initializeCompanionMixinMethodName) {
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
        final building = context.buildings[target.name];
        if (building == null) {
          // We think invoking method to field or getter results is useless.
          throwNotSupportedYet(
            node: unparenthesized,
            contextElement: contextElement,
          );
        }

        // Found PDB method call.
        building.add(
          await resolvePropertyDefinitionAsync(
            context: context,
            contextElement: contextElement,
            methodInvocation: unparenthesized,
            targetClass: targetClass,
            propertyName: null,
            typeArguments: unparenthesized.typeArgumentTypes!
                .map(GenericType.fromDartType)
                .toList(),
            originalMethodInvocation: unparenthesized,
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
          assert(argument != null);
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
  } // is MethodInvocation

  if (unparenthesized is PropertyAccess &&
      isPropertyDescriptorsBuilder(unparenthesized.staticType)) {
    return await _parsePropertyAccessAsync(
      context,
      unparenthesized,
      contextElement,
    );
  }

  if (unparenthesized is FunctionExpressionInvocation) {
    final functionType = unparenthesized.staticInvokeType;
    if (isPropertyDescriptorsBuilder(unparenthesized.staticType) ||
        (functionType is FunctionType &&
            functionType.parameters
                .any((e) => isPropertyDescriptorsBuilder(e.type)))) {
      // (a.getter)(x) or () => x;
      // Too complex and it should not be used for builder construction.
      throwNotSupportedYet(
        node: expression,
        contextElement: contextElement,
      );
    }
  }

  if (unparenthesized is PostfixExpression) {
    return await _parseExpressionAsync(
      context,
      contextElement,
      unparenthesized.operand,
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
  assert(isPropertyDescriptorsBuilder(expression.staticType));
  context.logger.fine(
    'Found constructor initialization of $pdbTypeName at ${getNodeLocation(expression, contextElement)}.',
  );
  return PropertyDescriptorsBuilding.begin();
}
