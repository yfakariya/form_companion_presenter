// See LICENCE file in the root.

part of '../parser.dart';

// Defines _parseFunctionBodyAsync, _parseBlockAsync and their sub functions.

FutureOr<PropertyDescriptorsBuilding?> _parseFunctionBodyAsync(
  ParseContext context,
  Element contextElement,
  Map<String, PropertyDescriptorsBuilding>? arguments,
  FunctionBody body,
) async {
  context.beginFunctionBody(arguments);
  try {
    if (body is BlockFunctionBody) {
      await _parseBlockAsync(
        context,
        contextElement,
        body.block,
      );

      return context.returnValue;
    } else {
      assert(body is ExpressionFunctionBody);
      return await _parseExpressionAsync(
        context,
        contextElement,
        (body as ExpressionFunctionBody).expression,
      );
    }
  } finally {
    context.endFunctionBody();
  }
}

FutureOr<void> _parseBlockAsync(
  ParseContext context,
  Element contextElement,
  Block block,
) async {
  context.beginBlock({
    for (final fds
        in block.statements.whereType<FunctionDeclarationStatement>())
      fds.functionDeclaration.name.name: fds.functionDeclaration
  });
  try {
    for (final statement in block.statements) {
      if (context.isReturned) {
        context.logger.fine(
          'Skip statements after return statement at ${getNodeLocation(statement, contextElement)}',
        );
        break;
      }

      // for, while, do, switch, if, try
      _eliminateControlStatement(statement, contextElement);
      if (statement is FunctionDeclarationStatement) {
        // already parsed, do nothing.
      } else if (statement is AssertStatement) {
        // do nothing
      } else if (statement is Block) {
        // Recursive call
        await _parseBlockAsync(
          context,
          contextElement,
          statement,
        );
      } else if (statement is ExpressionStatement) {
        // Ignore return value here.
        await _parseExpressionAsync(
          context,
          contextElement,
          statement.expression,
        );
      } else if (statement is VariableDeclarationStatement) {
        final variableType = _getVariableType(statement);
        if (isPropertyDescriptorsBuilder(variableType)) {
          final pdbVariableDeclarations = statement.variables.variables;
          for (final pdbVariableDeclaration in pdbVariableDeclarations) {
            final variableName = pdbVariableDeclaration.name.name;
            final initializer = pdbVariableDeclaration.initializer;
            if (initializer != null) {
              context.buildings[variableName] = await _processAssignmentAsync(
                context,
                statement,
                contextElement,
                variableName,
                initializer,
              );
            } else {
              context.logger.fine(
                "Found $pdbTypeName variable declaration '$variableName' without initialization at ${getNodeLocation(statement, contextElement)}.",
              );
            }
          }
        } else {
          context.logger.fine(
            'Skip $variableType variable declaration(s) at ${getNodeLocation(statement, contextElement)}.',
          );
        }
      } else if (statement is ReturnStatement) {
        final expression = statement.expression;
        if (expression != null &&
            isPropertyDescriptorsBuilder(expression.staticType)) {
          context.markAsReturned(
            await _parseExpressionAsync(
              context,
              contextElement,
              expression,
            )!,
          );
        } else {
          context.markAsReturned();
        }
      } else {
        throwNotSupportedYet(
          node: statement,
          contextElement: contextElement,
        );
      }
    }
  } finally {
    context.endBlock();
  }
}

void _eliminateControlStatement(Statement statement, Element contextElement) {
  if (statement is ForStatement ||
      statement is WhileStatement ||
      statement is DoStatement ||
      statement is SwitchStatement ||
      statement is IfStatement ||
      statement is TryStatement ||
      statement is BreakStatement ||
      statement is ContinueStatement ||
      // YieldStatement also represents yeald-each statement (yield *;)
      statement is YieldStatement) {
    throwError(
      message:
          'Failed to analyze complex construction logics at ${getNodeLocation(statement, contextElement)}.',
      todo:
          'Do not use if or any loop statement in methods or functions for $pdbTypeName construction.',
      element: contextElement,
    );
  }
}

DartType? _getVariableType(VariableDeclarationStatement statement) {
  // Use initializer's type instead of variables.type
  // because variables.type only be set when the variable was
  // declared explicitly typed like 'int i' instead of 'var i' or 'final i',
  // and most sources do not use explicitly typed variable declration.
  for (final variable
      in statement.variables.variables.where((v) => v.initializer != null)) {
    return variable.initializer!.staticType;
  }

  // without any initializers, so we can use type here.
  return statement.variables.type?.type;
}
