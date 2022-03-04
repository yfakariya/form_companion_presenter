// See LICENCE file in the root.

part of '../parser.dart';

// Defines presenter constructor anlysis related constructs.

FutureOr<Object> _detectArgumentOfLastInitializeCompanionMixinInvocationAsync(
  ParseContext context,
  ConstructorDeclaration ast,
  ConstructorElement element,
) async {
  final finder = _InitializeCompanionMixinFinder();
  ast.accept(finder);
  if (finder.invocations.isEmpty) {
    throwError(
      message:
          "No $initializeCompanionMixinMethodName($pdbTypeName) invocation in constructor body of '${element.enclosingElement.name}' class.",
      todo:
          'Call $initializeCompanionMixinMethodName($pdbTypeName) in constructor body.',
      element: element,
    );
  }

  if (finder.invocations.length > 1) {
    final multipleInvocationsWarning =
        "initializeCompanionMixin($pdbTypeName) is called multiply in constructor of class '${element.enclosingElement.name}', so last one is used.";
    context.addGlobalWarning(multipleInvocationsWarning);
    context.logger.warning(multipleInvocationsWarning);
  }

  return finder.invocations.last.argumentList.arguments.first;
}

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
