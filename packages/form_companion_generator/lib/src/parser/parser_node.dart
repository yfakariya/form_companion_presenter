// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../model.dart';
import '../node_provider.dart';
import '../utilities.dart';

/// Represents an any kind variable.
abstract class VariableNode {
  /// Gets a name of this variable.
  String get name;

  /// Gets a initialization [Expression] of this variable if exists.
  Expression? get initializer;

  /// Gets an [Element] which is associated to underlying [AstNode] of this.
  Element get element;

  /// Creates an appropriate [VariableNode] instance for specified [AstNode].
  ///
  /// [Element] is source element which is used to get [node].
  factory VariableNode(AstNode node, Element sourceElement) {
    if (node is TopLevelVariableDeclaration) {
      if (node.variables.variables.length != 1) {
        throwError(
          message:
              "Failed to parse top level variable '${sourceElement.name}' which is not a single variable declaration.",
          todo:
              "Declare top level variable '${sourceElement.name}' as standalone decleration.",
          element: sourceElement,
        );
      }

      return _TopLevelVariableNode(node);
    } else if (node is FieldDeclaration) {
      if (node.fields.variables.length != 1) {
        throwError(
          message:
              "Failed to parse field '${sourceElement.name}' which is not a single field declaration.",
          todo:
              "Declare field '${sourceElement.name}' as standalone decleration.",
          element: sourceElement,
        );
      }
      return _FieldNode(node);
    } else if (node is VariableDeclaration) {
      return _VariableNode(node);
    } else if (node is MethodDeclaration && node.isGetter) {
      return _GetterMethodNode(node);
    } else if (node is FunctionDeclaration && node.isGetter) {
      return _GetterFunctionNode(node);
    } else {
      throwError(
        message:
            "Unexpected node '$node' (${node.runtimeType} from ${sourceElement.runtimeType}), "
            'it is not a single field or property reference.',
        element: sourceElement,
      );
    }
  }

  VariableNode._();
}

class _TopLevelVariableNode extends VariableNode {
  final TopLevelVariableDeclaration _declaration;

  @override
  String get name => _declaration.variables.variables.first.name.name;

  @override
  Expression? get initializer =>
      _declaration.variables.variables.first.initializer;

  @override
  Element get element => _declaration.declaredElement!;

  _TopLevelVariableNode(this._declaration) : super._();
}

class _VariableNode extends VariableNode {
  final VariableDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  Expression? get initializer => _declaration.initializer;

  @override
  Element get element => _declaration.declaredElement!;

  _VariableNode(this._declaration) : super._();
}

class _FieldNode extends VariableNode {
  final FieldDeclaration _declaration;

  @override
  String get name => _declaration.fields.variables.first.name.name;

  @override
  Expression? get initializer =>
      _declaration.fields.variables.first.initializer;

  @override
  Element get element => _declaration.declaredElement!;

  _FieldNode(this._declaration) : super._();
}

class _GetterMethodNode extends VariableNode {
  final MethodDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  Expression? get initializer =>
      (_declaration.body as ExpressionFunctionBody).expression;

  @override
  Element get element => _declaration.declaredElement!;

  _GetterMethodNode(this._declaration) : super._();
}

class _GetterFunctionNode extends VariableNode {
  final FunctionDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  Expression? get initializer =>
      (_declaration.functionExpression.body as ExpressionFunctionBody)
          .expression;

  @override
  Element get element => _declaration.declaredElement!;

  _GetterFunctionNode(this._declaration) : super._();
}

/// Represents an any kind executable (method, function, or property accessor).
///
/// Note that this object never represents native or external method or function,
/// so underlying node always have [FunctionBody].
abstract class ExecutableNode {
  final NodeProvider _nodeProvider;

  /// Gets a name of this executable.
  String get name;

  /// Gets a body of this executable.
  FunctionBody get body;

  /// Gets a list of parameters of this executable.
  FutureOr<List<ParameterInfo>> getParametersAsync();

  /// Gets a [DartType] of the return value of this executable.
  DartType get returnType;

  /// Gets a [Element] of target executable node declaration.
  ExecutableElement get element;

  /// Creates an appropriate [ExecutableNode] instance for specified [AstNode].
  ///
  /// [Element] is source element which is used to get [node].
  factory ExecutableNode(
    NodeProvider nodeProvider,
    AstNode node,
    Element sourceElement,
  ) {
    if (node is FunctionDeclaration) {
      return _FunctionNode(nodeProvider, node);
    } else if (node is MethodDeclaration) {
      return _MethodNode(nodeProvider, node);
    } else {
      throwError(
        message:
            "Unexpected node '$node' (${node.runtimeType} from ${sourceElement.runtimeType}), it is not executable.",
        element: sourceElement,
      );
    }
  }

  ExecutableNode._(this._nodeProvider);

  FutureOr<List<ParameterInfo>> _iterateParameterInfoAsync(
    FormalParameterList? parameters,
  ) async {
    if (parameters != null) {
      return await parameters.parameters
          .where((p) => !p.declaredElement!.hasDeprecated)
          .map((p) => ParameterInfo.fromNodeAsync(_nodeProvider, p))
          .toListAsync();
    }

    return [];
  }
}

class _FunctionNode extends ExecutableNode {
  final FunctionDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  FunctionBody get body => _declaration.functionExpression.body;

  @override
  FutureOr<List<ParameterInfo>> getParametersAsync() =>
      _iterateParameterInfoAsync(_declaration.functionExpression.parameters);

  @override
  DartType get returnType => _declaration.returnType!.type!;

  @override
  ExecutableElement get element => _declaration.declaredElement!;

  _FunctionNode(NodeProvider nodeProvider, this._declaration)
      : super._(nodeProvider);
}

class _MethodNode extends ExecutableNode {
  final MethodDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  FunctionBody get body => _declaration.body;

  @override
  FutureOr<List<ParameterInfo>> getParametersAsync() =>
      _iterateParameterInfoAsync(_declaration.parameters);

  @override
  DartType get returnType => _declaration.returnType!.type!;

  @override
  ExecutableElement get element => _declaration.declaredElement!;

  _MethodNode(NodeProvider nodeProvider, this._declaration)
      : super._(nodeProvider);
}
