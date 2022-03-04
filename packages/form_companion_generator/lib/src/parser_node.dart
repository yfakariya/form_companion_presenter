// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'parser_utilities.dart';

/// Represents an any kind variable.
abstract class VariableNode {
  /// Gets a name of this variable.
  String get name;

  /// Gets a initialization [Expression] of this variable if exists.
  Expression? get initializer;

  /// Gets an [Element] which is associated to underlying [AstNode] of this.
  Element get element;

  VariableNode._();

  /// Creates an appropriate [VariableNode] instance for specified [AstNode].
  ///
  /// [Element] is source element which is used to get [node].
  factory VariableNode.fromNode(AstNode node, Element sourceElement) {
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
            "Unexpected node '$node' (${node.runtimeType} from ${sourceElement.runtimeType}), it is not field or property.",
        element: sourceElement,
      );
    }
  }
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

/// Represents a parameter.
@sealed
class ParameterInfo {
  /// Gets a name of this parameter.
  String name;

  /// Gets a static [DartType] of this parameter.
  DartType type;

  ParameterInfo._(this.name, this.type);
}

/// Represents an any kind executable (method, function, or property accessor).
///
/// Note that this object never represents native or external method or function,
/// so underlying node always have [FunctionBody].
abstract class ExecutableNode {
  /// Gets a name of this executable.
  String get name;

  /// Gets a body of this executable.
  FunctionBody get body;

  /// Gets a list of parameters of this executable.
  List<ParameterInfo> get parameters;

  /// Gets a [DartType] of the return value of this executable.
  DartType get returnType;

  /// Gets a [Element] of target executable node declaration.
  ExecutableElement get element;

  ExecutableNode._();

  /// Creates an appropriate [ExecutableNode] instance for specified [AstNode].
  ///
  /// [Element] is source element which is used to get [node].
  factory ExecutableNode.fromNode(AstNode node, Element sourceElement) {
    if (node is FunctionDeclaration) {
      return _FunctionNode(node);
    } else if (node is MethodDeclaration) {
      return _MethodNode(node);
    } else {
      throwError(
        message:
            "Unexpected node '$node' (${node.runtimeType} from ${sourceElement.runtimeType}), it is not executable.",
        element: sourceElement,
      );
    }
  }

  Iterable<ParameterInfo> _iterateParameterInfo(
      FormalParameterList? parameters) sync* {
    if (parameters != null) {
      for (final parameter in parameters.parameterElements) {
        yield ParameterInfo._(
          parameter!.name,
          parameter.type,
        );
      }
    }
  }
}

class _FunctionNode extends ExecutableNode {
  final FunctionDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  FunctionBody get body => _declaration.functionExpression.body;

  @override
  List<ParameterInfo> get parameters =>
      _iterateParameterInfo(_declaration.functionExpression.parameters)
          .toList();

  @override
  DartType get returnType => _declaration.returnType!.type!;

  @override
  ExecutableElement get element => _declaration.declaredElement!;

  _FunctionNode(this._declaration) : super._();
}

class _MethodNode extends ExecutableNode {
  final MethodDeclaration _declaration;

  @override
  String get name => _declaration.name.name;

  @override
  FunctionBody get body => _declaration.body;

  @override
  List<ParameterInfo> get parameters =>
      _iterateParameterInfo(_declaration.parameters).toList();

  @override
  DartType get returnType => _declaration.returnType!.type!;

  @override
  ExecutableElement get element => _declaration.declaredElement!;

  _MethodNode(this._declaration) : super._();
}
