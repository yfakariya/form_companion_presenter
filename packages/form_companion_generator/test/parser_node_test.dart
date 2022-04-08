// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser/parser_helpers.dart';
import 'package:form_companion_generator/src/parser/parser_node.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tuple/tuple.dart';

import 'session_resolver.dart';

class _MethodInvocationFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> founds = [];
  _MethodInvocationFinder();

  @override
  void visitMethodInvocation(MethodInvocation node) {
    founds.add(node);
    super.visitMethodInvocation(node);
  }
}

class _SimpleIdentityFinder extends RecursiveAstVisitor<void> {
  final List<SimpleIdentifier> founds = [];
  _SimpleIdentityFinder();

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    founds.add(node);
    super.visitSimpleIdentifier(node);
  }
}

class _LocalFunctionFinder extends RecursiveAstVisitor<void> {
  final List<FunctionDeclaration> founds = [];
  _LocalFunctionFinder();

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    founds.add(node);
    super.visitFunctionDeclaration(node);
  }
}

Future<void> main() async {
  Future<void> testCore<T>({
    required FutureOr<Tuple2<AstNode, Element>> Function(
            Resolver, LibraryElement)
        targetSelector,
    required String code,
    required T Function(AstNode node, Element element) factory,
    FutureOr<void> Function(T)? assertion,
    void Function(Object)? errorAssertion,
  }) async {
    final disposeResolver = Completer<void>();
    try {
      late final Resolver resolver;
      final library = await resolveSource(
        '''
library code;

$code
''',
        (r) {
          resolver = r;
          return r.findLibraryByName('code');
        },
        tearDown: disposeResolver.future,
      );

      if (library == null) {
        fail('Failed to get library.');
      }

      final pair = await targetSelector(resolver, library);
      late final T result;
      try {
        result = factory(pair.item1, pair.item2);
        if (errorAssertion != null) {
          fail('Success: $result');
        }
      }
      // ignore: avoid_catches_without_on_clauses
      catch (e) {
        // ignore: invariant_booleans
        if (errorAssertion == null) {
          rethrow;
        }

        errorAssertion(e);
      }

      if (assertion != null) {
        await assertion(result);
      }
    } finally {
      disposeResolver.complete();
    }
  }

  Future<void> testVariableNode({
    required Element Function(LibraryElement) contextElementSelector,
    required String code,
    AstNode Function(AstNode)? declarationAdjuster,
    void Function(VariableNode)? assertion,
    void Function(Object)? errorAssertion,
  }) =>
      testCore<VariableNode>(
        targetSelector: (r, l) async {
          final contextElement = contextElementSelector(l);
          final contextNode = await r.astNodeFor(contextElement, resolve: true);
          late final Identifier identifier;
          if (contextNode is MethodDeclaration) {
            identifier = (contextNode.body as ExpressionFunctionBody).expression
                as Identifier;
          } else {
            identifier = ((contextNode! as FunctionDeclaration)
                    .functionExpression
                    .body as ExpressionFunctionBody)
                .expression as Identifier;
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

          final declaration =
              await NodeProvider(r).getElementDeclarationAsync(getter!);
          return Tuple2(
            declarationAdjuster?.call(declaration) ?? declaration,
            getter,
          );
        },
        code: code,
        assertion: assertion == null ? null : (v) => assertion(v),
        errorAssertion: errorAssertion,
        factory: VariableNode.new,
      );

  Future<void> testExecutableNode({
    required Element Function(LibraryElement) contextElementSelector,
    required String code,
    FutureOr<Tuple2<AstNode, Element>> Function(Resolver, LibraryElement)?
        customTargetSelector,
    FutureOr<Element> Function(Element)? methodElementSelector,
    FutureOr<void> Function(ExecutableNode)? assertion,
    void Function(Object)? errorAssertion,
  }) =>
      testCore(
        targetSelector: customTargetSelector ??
            (r, l) async {
              final contextElement = contextElementSelector(l);
              final contextNode = await r.astNodeFor(contextElement);
              final finder = _MethodInvocationFinder();
              contextNode!.accept(finder);
              final invocation = finder.founds.single;
              final invocationTarget = invocation.realTarget;
              final element =
                  (await methodElementSelector?.call(contextElement)) ??
                      lookupMethod(
                        contextElement,
                        invocationTarget is Identifier
                            ? contextElement.library!.scope
                                .lookup(invocationTarget.toString())
                                .getter as ClassElement?
                            : null,
                        invocation.methodName.name,
                        invocation,
                      );

              return Tuple2(
                await NodeProvider(r).getElementDeclarationAsync(element),
                element,
              );
            },
        code: code,
        assertion: assertion,
        errorAssertion: errorAssertion,
        factory: (n, e) => ExecutableNode(
          NodeProvider(
            SessionResolver(e.library!),
          ),
          n,
          e,
        ),
      );

  group('variable', () {
    test(
      'single top level variable',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
final v = 1;

int foo => v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_VariableNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer?.toString(), '1');
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );

    test(
      'single top level variable as TopLevelDeclaration',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        declarationAdjuster: (v) => v
            .thisOrAncestorOfType<CompilationUnit>()!
            .declarations
            .whereType<TopLevelVariableDeclaration>()
            .single,
        code: '''
final v = 1;

int foo => v;
''',
        errorAssertion: (e) {
          expect(e, isA<InvalidGenerationSourceError>());
          expect(
            (e as InvalidGenerationSourceError).message,
            startsWith(
              "Unexpected node 'final v = 1;' (TopLevelVariableDeclaration",
            ),
          );
          expect(
            e.message,
            endsWith(
              '), it is not a single field or property reference.',
            ),
          );
          expect(e.element, isA<PropertyAccessorElement>());
        },
      ),
    );

    test(
      'multiple top level variable is referred as VariableDeclaration instead of TopLevelVariableDeclaration',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
int v, w;

int foo => v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_VariableNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer, isNull);
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );

    test(
      'single top level getter',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
int get v => 1;

void foo => v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_GetterFunctionNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer?.toString(), '1');
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );

    test(
      'single field',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
class C {
  static final v = 1;
}

int foo => C.v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_VariableNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer?.toString(), '1');
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );

    test(
      'single field as FieldDeclaration',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        declarationAdjuster: (v) => v
            .thisOrAncestorOfType<CompilationUnit>()!
            .declarations
            .whereType<ClassDeclaration>()
            .expand((c) => c.members)
            .whereType<FieldDeclaration>()
            .single,
        code: '''
class C {
  static final v = 1;
}

int foo => C.v;
''',
        errorAssertion: (e) {
          expect(e, isA<InvalidGenerationSourceError>());
          expect(
            (e as InvalidGenerationSourceError).message,
            startsWith(
              "Unexpected node 'static final v = 1;' (FieldDeclaration",
            ),
          );
          expect(
            e.message,
            endsWith(
              '), it is not a single field or property reference.',
            ),
          );
          expect(e.element, isA<PropertyAccessorElement>());
        },
      ),
    );

    test(
      'multiple field variable is referred as VariableDeclaration instead of FieldDeclaration',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
class C {
  static int v, w;
}

int foo => C.v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_VariableNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer, isNull);
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );

    test(
      'single field getter',
      () => testVariableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
class C {
  static int get v => 1;
}

int foo => C.v;
''',
        assertion: (v) {
          expect(v.runtimeType.toString(), '_GetterMethodNode');
          expect(v.element, isA<PropertyAccessorElement>());
          expect(v.initializer?.toString(), '1');
          expect(v.name, 'v');
          expect(v.toString(), v.element.toString());
        },
      ),
    );
  });

  group('executable', () {
    test(
      'top level function',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
void f() {}

void foo() => f();
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_FunctionNode');
          expect(x.element, isA<FunctionElement>());
          expect(x.body, isA<BlockFunctionBody>());
          expect(x.returnType.isVoid, isTrue);
          expect(x.name, 'f');
          final parameters = await x.getParametersAsync();
          expect(parameters, isEmpty);
          expect(x.toString(), x.element.toString());
        },
      ),
    );

    test(
      'top level getter',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        customTargetSelector: (r, l) async {
          final contextElement = l.topLevelElements
              .singleWhere((e) => !e.isSynthetic && e.name == 'foo');
          final contextNode = await r.astNodeFor(contextElement);
          final finder = _SimpleIdentityFinder();
          (contextNode! as FunctionDeclaration)
              .functionExpression
              .body
              .visitChildren(finder);
          final reference = finder.founds.single;
          final element = lookupMethod(
            contextElement,
            null,
            reference.toString(),
            reference,
          );

          return Tuple2(
            await NodeProvider(r).getElementDeclarationAsync(element),
            element,
          );
        },
        code: '''
int get f => 1;

int foo() => f;
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_FunctionNode');
          expect(x.element, isA<PropertyAccessorElement>());
          expect(x.body, isA<ExpressionFunctionBody>());
          expect(x.returnType.isDartCoreInt, isTrue);
          expect(x.name, 'f');
          final parameters = await x.getParametersAsync();
          expect(parameters, isEmpty);
          expect(x.toString(), x.element.toString());
        },
      ),
    );

    test(
      'method',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
class C {
  static void f() {}
}

void foo() => C.f();
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_MethodNode');
          expect(x.element, isA<MethodElement>());
          expect(x.body, isA<BlockFunctionBody>());
          expect(x.returnType.isVoid, isTrue);
          expect(x.name, 'f');
          final parameters = await x.getParametersAsync();
          expect(parameters, isEmpty);
          expect(x.toString(), x.element.toString());
        },
      ),
    );

    test(
      'local function',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        methodElementSelector: (x) async {
          final result =
              await x.session!.getResolvedLibraryByElement(x.library!);
          if (result is! ResolvedLibraryResult) {
            fail('Failed to resolve library.');
          }
          final node = result.getElementDeclaration(x)!.node;
          final finder = _LocalFunctionFinder();
          node.visitChildren(finder);
          return finder.founds.single.declaredElement!;
        },
        code: '''
void foo() {
  void f() {}

  f();
}
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_FunctionNode');
          expect(x.element, isA<FunctionElement>());
          expect(x.body, isA<BlockFunctionBody>());
          expect(x.returnType.isVoid, isTrue);
          expect(x.name, 'f');
          final parameters = await x.getParametersAsync();
          expect(parameters, isEmpty);
          expect(x.toString(), x.element.toString());
        },
      ),
    );

    test(
      'parameters are ordered as declared',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
void f(int b, String d, {required int c, String? a}) {}

void foo() => f(0, '1', a: '2', c: 3 );
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_FunctionNode');
          expect(x.element, isA<FunctionElement>());
          expect(x.body, isA<BlockFunctionBody>());
          expect(x.returnType.isVoid, isTrue);
          expect(x.name, 'f');
          expect(x.toString(), x.element.toString());
          final parameters = await x.getParametersAsync();
          expect(parameters.length, 4);
          expect(parameters[0].name, 'b');
          expect(parameters[1].name, 'd');
          expect(parameters[2].name, 'c');
          expect(parameters[3].name, 'a');
        },
      ),
    );

    test(
      'deprected parameters are skipped',
      () => testExecutableNode(
        contextElementSelector: (l) => l.topLevelElements
            .singleWhere((e) => !e.isSynthetic && e.name == 'foo'),
        code: '''
void f({required int c, @deprecated String? a}) {}

void foo() => f(a: '2', c: 3 );
''',
        assertion: (x) async {
          expect(x.runtimeType.toString(), '_FunctionNode');
          expect(x.element, isA<FunctionElement>());
          expect(x.body, isA<BlockFunctionBody>());
          expect(x.returnType.isVoid, isTrue);
          expect(x.name, 'f');
          expect(x.toString(), x.element.toString());
          final parameters = await x.getParametersAsync();
          expect(parameters.length, 1);
          expect(parameters[0].name, 'c');
        },
      ),
    );

    test(
      'non executable',
      () => testCore(
        targetSelector: (r, l) async {
          final contextElement = l.topLevelElements
              .singleWhere((e) => !e.isSynthetic && e.name == 'foo');
          final contextNode = await r.astNodeFor(contextElement);
          return Tuple2(contextNode!, contextElement);
        },
        factory: (n, e) => ExecutableNode(
          NodeProvider(SessionResolver(e.library!)),
          n,
          e,
        ),
        errorAssertion: (e) {
          // OK
        },
        code: '''
final foo = 1;
''',
      ),
    );
  });
}
