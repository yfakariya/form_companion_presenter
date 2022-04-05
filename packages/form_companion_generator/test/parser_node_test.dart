
import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser/parser_node.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tuple/tuple.dart';

import 'file_resolver.dart';

Future<void> main() async {
  Future<void> testCore<T>({
    required FutureOr<Tuple2<AstNode, Element>> Function(
            Resolver, LibraryElement)
        targetSelector,
    required String code,
    required T Function(AstNode node, Element element) factory,
    void Function(T)? assertion,
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

      assertion?.call(result);
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
      testCore(
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
        assertion: assertion,
        errorAssertion: errorAssertion,
        factory: VariableNode.new,
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
}
