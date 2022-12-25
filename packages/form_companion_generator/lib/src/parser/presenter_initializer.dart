// See LICENCE file in the root.

part of '../parser.dart';

// Defines presenter member analysis related to constructs or initialization methods.

/// Represents an initializer member which calls `initializeCompanionMixin()`.
class Initializer {
  /// An [Element] of this initializer member.
  final Element element;

  /// A [FunctionBody] of this initializer member.
  final FunctionBody ast;

  /// A found [Expression] which is passed to `initializeCompanionMixin()` as
  /// a first argument.
  final Expression propertyDescriptorBuilderTypedArgument;

  /// Initializes a new [Initializer].
  Initializer(
    this.element,
    this.ast,
    this.propertyDescriptorBuilderTypedArgument,
  );
}

FutureOr<Expression?>
    _findArgumentOfLastInitializeCompanionMixinInvocationAsync(
  ParseContext context,
  AstNode ast,
  Element element,
) async {
  final finder = _InitializeCompanionMixinFinder();
  ast.accept(finder);

  if (finder.invocations.isEmpty) {
    return null;
  }

  if (finder.invocations.length > 1) {
    final multipleInvocationsWarning =
        "`initializeCompanionMixin($pdbTypeName)` is called multiply in '${element.displayName}'(${element.kind}), so last one is used.";
    context.addGlobalWarning(multipleInvocationsWarning);
    context.logger.warning(multipleInvocationsWarning);
  }

  return finder.invocations.last.argumentList.arguments.first;
}

@sealed
class _InitializeCompanionMixinFinder extends RecursiveAstVisitor<void> {
  final _invocations = <MethodInvocation>[];
  List<MethodInvocation> get invocations => _invocations;
  _InitializeCompanionMixinFinder();

  @override
  void visitMethodInvocation(MethodInvocation invocation) {
    if (invocation.methodName.name == initializeCompanionMixinMethodName &&
        invocation.argumentList.arguments.length == 1) {
      _invocations.add(invocation);
    }
  }
}
