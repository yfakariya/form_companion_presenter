// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'test_helpers.dart';

/// caseName, parameterName, typeArguments, expectedTypeArguments,
/// displayStringWithNullability, displayStringWithoutNullability, rawTypeName
typedef TypeSpec = Tuple7<String, String, List<DartType>, List<String>, String,
    String, String>;

Future<void> main() async {
  final libraryReader = LibraryReader(
    (await getResolvedLibraryResult('form_companion_annotation.dart')).element,
  );

  final parametersLibrary = await getParametersLibrary();
  final parameterHolder = parametersLibrary.getType('ParameterHolder')!;
  final interfaceTypeParameters = {
    'nullable': {
      for (final p in parameterHolder.methods
          .singleWhere((c) => c.displayName == 'nullableInterface')
          .parameters)
        p.name: p
    },
    'non-nullable': {
      for (final p in parameterHolder.methods
          .singleWhere((c) => c.displayName == 'simpleInterface')
          .parameters)
        p.name: p
    },
  };

  final functionTypeParameters = {
    'nullable': {
      for (final p in parameterHolder.methods
          .singleWhere((c) => c.displayName == 'nullableFunction')
          .parameters)
        p.name: p
    },
    'non-nullable': {
      for (final p in parameterHolder.methods
          .singleWhere((c) => c.displayName == 'simpleFunction')
          .parameters)
        p.name: p
    },
    'complex': {
      for (final p in parameterHolder.methods
          .singleWhere((c) => c.displayName == 'complexFunction')
          .parameters)
        p.name: p
    },
  };
  final nullableStringType =
      interfaceTypeParameters['nullable']!['interface']!.type;

  final multiGenericFunctionAlias = parametersLibrary.topLevelElements
      .whereType<TypeAliasElement>()
      .singleWhere((a) => a.name.startsWith('MultiGenericFunction'));

  final complexGenericTypeParameters = {
    for (final m in parametersLibrary
        .getType('ComplexGenericTypeHolder')!
        .methods
        .single
        .parameters)
      m.name: m
  };

  ElementAnnotation findAnnotation(String className) {
    final type = libraryReader.findType(className);
    if (type == null) {
      throw AssertionError('Failed to find "$className" class.');
    }

    return type.metadata.single;
  }

  ConstantReader findAnnotationValue(String className) {
    final value = findAnnotation(className).computeConstantValue();
    if (value == null) {
      throw AssertionError(
          'Failed to resolve annotation of "$className" class.');
    }

    return ConstantReader(value);
  }

  group('FormCompanionAnnotation', () {
    test('default -> autovalidate is null', () {
      final target = FormCompanionAnnotation(findAnnotationValue('Default'));
      expect(target.autovalidate, isNull);
    });

    test('empty -> autovalidate is null', () {
      final target = FormCompanionAnnotation(findAnnotationValue('Empty'));
      expect(target.autovalidate, isNull);
    });

    test('autovalidate is true', () {
      final target =
          FormCompanionAnnotation(findAnnotationValue('AutovalidateIsTrue'));
      expect(target.autovalidate, isTrue);
    });

    test('autovalidate is false', () {
      final target =
          FormCompanionAnnotation(findAnnotationValue('AutovalidateIsFalse'));
      expect(target.autovalidate, isFalse);
    });
  });

  group('isFormCompanionAnnotation', () {
    test(
      '@formCompanion - true',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('Default')),
        isTrue,
      ),
    );

    test(
      '@FormCompanion() - true',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('Empty')),
        isTrue,
      ),
    );

    test(
      '@visibleForTesting - false',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('AnotherAnnotation')),
        isFalse,
      ),
    );
  });

  group('ParameterInfo edge cases', () {
    test('fromNodeAsync(SuperFormalParameter)', () async {
      final dispose = Completer<void>();
      try {
        late final Resolver resolver;
        await resolveSource(
          '''
library _lib;

class B {
  final int v;
  B(this.v);
}
class C {
  C(super.v);
}
''',
          (r) => resolver = r,
          tearDown: dispose.future,
        );
        final library = await resolver.findLibraryByName('_lib');
        final element = library!.getType('C')!.constructors.single;
        final target = await resolver.astNodeFor(element, resolve: true);
        await expectLater(
          ParameterInfo.fromNodeAsync(
            NodeProvider(resolver),
            target!.childEntities
                .whereType<FormalParameterList>()
                .single
                .childEntities
                .whereType<FormalParameter>()
                .single,
          ),
          throwsA(
            isA<InvalidGenerationSourceError>()
                .having(
                  (e) => e.message,
                  'message',
                  startsWith(
                    "Failed to parse complex parameter 'super.v' "
                    '(SuperFormalParameterImpl) at ',
                  ),
                )
                .having(
                  (e) => e.element,
                  'element',
                  isA<SuperFormalParameterElement>(),
                ),
          ),
        );
      } finally {
        dispose.complete();
      }
    });
  });

  group('GenericType', () {
    final typeProvider = libraryReader.element.typeProvider;
    final typeSystem = libraryReader.element.typeSystem;

    Future<void> assertGenericType({
      required DartType sourceType,
      required GenericType target,
      required List<String> expectedTypeArguments,
      required String rawTypeName,
      required String displayStringWithNullability,
      required String displayStringWithoutNullability,
    }) async {
      if (sourceType is InterfaceType) {
        expect(
          target.maybeAsInterfaceType?.getDisplayString(withNullability: true),
          sourceType.getDisplayString(withNullability: true),
          reason: 'maybeAsInterfaceType',
        );
      } else {
        expect(
          target.maybeAsInterfaceType,
          isNull,
          reason: 'maybeAsInterfaceType',
        );
      }

      expect(
        target.rawType.getDisplayString(withNullability: false),
        rawTypeName,
        reason: 'rawType',
      );

      expect(
        target.toString(),
        displayStringWithNullability,
        reason: 'toString()',
      );
      expect(
        target.getDisplayString(withNullability: false),
        displayStringWithoutNullability,
        reason: 'getDisplayString(withNullability: false)',
      );
      expect(
        target.typeArguments.map((e) => e.toString()).toList().toString(),
        expectedTypeArguments.toString(),
        reason: 'typeArguments',
      );
    }

    Future<void> testGenericType({
      required ParameterElement source,
      required List<GenericType> typeArguments,
      required List<String> expectedTypeArguments,
      required String rawTypeName,
      required String displayStringWithNullability,
      required String displayStringWithoutNullability,
    }) async {
      final type = source.type;
      final target = typeArguments.isEmpty
          ? GenericType.fromDartType(type, source)
          : GenericType.generic(type, typeArguments, source);
      await assertGenericType(
        sourceType: type,
        target: target,
        expectedTypeArguments: expectedTypeArguments,
        rawTypeName: rawTypeName,
        displayStringWithNullability: displayStringWithNullability,
        displayStringWithoutNullability: displayStringWithoutNullability,
      );
    }

    group('interface types', () {
      for (final nullable in [false, true]) {
        for (final spec in [
          TypeSpec(
            'non-generic, non-alias',
            'interface',
            [],
            [],
            'String?',
            'String',
            'String',
          ),
          TypeSpec(
            'generic, non-alias',
            'genericInterface',
            [nullableStringType],
            ['String'],
            'List<String?>?',
            'List<String>',
            'List<E>',
          ),
          TypeSpec(
            'instantiated-generic, non-alias',
            'instantiatedInterface',
            [],
            ['int'],
            'List<int?>?',
            'List<int>',
            'List<E>',
          ),
          TypeSpec(
            'non-generic, alias',
            'alias',
            [],
            [],
            'AString?',
            'AString',
            'String',
          ),
          TypeSpec(
            'generic, alias',
            'genericAlias',
            [nullableStringType],
            ['String'],
            'AList<String?>?',
            'AList<String>',
            'List<E>',
          ),
          TypeSpec(
            'instantiated-generic, alias',
            'instantiatedAlias',
            [],
            ['int'],
            'AList<int?>?',
            'AList<int>',
            'List<E>',
          ),
        ]) {
          final nullability = nullable ? 'nullable' : 'non-nullable';
          final caseName = 'interface type, ${spec.item1}, $nullability';
          final parameter = interfaceTypeParameters[nullability]![spec.item2]!;
          final typeArguments = (nullable
                  ? spec.item3
                  : spec.item3.map(typeSystem.promoteToNonNull))
              .map((t) => GenericType.fromDartType(t, parameter))
              .toList();
          final expectedTypeArguments =
              nullable ? spec.item4.map((t) => '$t?').toList() : spec.item4;
          final displayStringWithoutNullability = spec.item6;
          final displayStringWithNullability =
              nullable ? spec.item5 : displayStringWithoutNullability;
          final rawTypeName = spec.item7;
          test(
            caseName,
            () => testGenericType(
              source: parameter,
              rawTypeName: rawTypeName,
              typeArguments: typeArguments,
              expectedTypeArguments: expectedTypeArguments,
              displayStringWithNullability: displayStringWithNullability,
              displayStringWithoutNullability: displayStringWithoutNullability,
            ),
          );
        }
      }
    }); // interface types

    group('function types', () {
      for (final nullable in [false, true]) {
        for (final spec in [
          TypeSpec(
            'non-generic, non-alias',
            'function',
            [],
            [],
            'int? Function(String?)?',
            'int Function(String)',
            'int Function(String)',
          ),
          TypeSpec(
            'generic, non-alias',
            'genericFunction',
            [nullableStringType],
            ['String'],
            'String? Function(String?)?',
            'String Function(String)',
            'T Function(T)',
          ),
          TypeSpec(
            'parameterized, non-alias',
            'parameterizedFunction',
            [nullableStringType],
            ['String'],
            'String? Function(String?)?',
            'String Function(String)',
            'S Function<S>(S)',
          ),
          TypeSpec(
            'instantiated-generic, non-alias',
            'instantiatedFunction',
            [],
            [],
            'List<int>? Function(Map<String?, int?>?)?',
            'List<int> Function(Map<String, int>)',
            'List<int> Function(Map<String, int>)',
          ),
          TypeSpec(
            'non-generic, alias',
            'alias',
            [],
            [],
            'NonGenericCallback?',
            'NonGenericCallback',
            'int Function(String)',
          ),
          TypeSpec(
            'generic, alias',
            'genericAlias',
            [nullableStringType],
            ['String'],
            'GenericCallback<String?>?',
            'GenericCallback<String>',
            'void Function<T>(T)',
          ),
          TypeSpec(
            'instantiated-generic, alias',
            'instantiatedAlias',
            [],
            ['int'],
            'GenericCallback<int?>?',
            'GenericCallback<int>',
            'void Function<T>(T)',
          ),
        ]) {
          final nullability = nullable ? 'nullable' : 'non-nullable';
          final caseName = 'function type, ${spec.item1}, $nullability';
          final parameter = functionTypeParameters[nullability]![spec.item2]!;
          final typeArguments = (nullable
                  ? spec.item3
                  : spec.item3.map(typeSystem.promoteToNonNull))
              .map((t) => GenericType.fromDartType(t, parameter))
              .toList();
          final expectedTypeArguments =
              nullable ? spec.item4.map((t) => '$t?').toList() : spec.item4;
          final displayStringWithoutNullability = spec.item6;
          final displayStringWithNullability =
              nullable ? spec.item5 : displayStringWithoutNullability;
          final rawTypeName = spec.item7;
          test(
            caseName,
            () => testGenericType(
              source: parameter,
              rawTypeName: rawTypeName,
              typeArguments: typeArguments,
              expectedTypeArguments: expectedTypeArguments,
              displayStringWithNullability: displayStringWithNullability,
              displayStringWithoutNullability: displayStringWithoutNullability,
            ),
          );
        }
      } // function types

      for (final spec in [
        TypeSpec(
          'with optional parameters',
          'hasDefault',
          [],
          [],
          'void Function([int])?',
          'void Function([int])',
          'void Function([int])',
        ),
        TypeSpec(
          'with named parameters',
          'hasNamed',
          [],
          [],
          // NOTE: sorted lexically with their name
          'void Function({int optional, required String required})?',
          'void Function({int optional, required String required})',
          'void Function({int optional, required String required})',
        ),
      ]) {
        final caseName = 'function type, ${spec.item1}';
        final parameter = functionTypeParameters['complex']![spec.item2]!;
        final displayStringWithNullability = spec.item5;
        final displayStringWithoutNullability = spec.item6;
        final rawTypeName = spec.item7;
        test(
          caseName,
          () => testGenericType(
            source: parameter,
            rawTypeName: rawTypeName,
            typeArguments: [],
            expectedTypeArguments: [],
            displayStringWithNullability: displayStringWithNullability,
            displayStringWithoutNullability: displayStringWithoutNullability,
          ),
        );
      } // complex function types
    });

    group('Special cases', () {
      test(
        '.generic with no type arguments for interface type',
        () async {
          final type = typeProvider.stringType;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(type, [], type.element),
            expectedTypeArguments: [],
            rawTypeName: 'String',
            displayStringWithNullability: 'String',
            displayStringWithoutNullability: 'String',
          );
        },
      );

      test(
        '.generic with no type arguments for function type',
        () async {
          final parameter =
              functionTypeParameters['non-nullable']!['function']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(type, [], parameter),
            expectedTypeArguments: [],
            rawTypeName: 'int Function(String)',
            displayStringWithNullability: 'int Function(String)',
            displayStringWithoutNullability: 'int Function(String)',
          );
        },
      );

      test(
        '.generic with multiple type arguments for interface type',
        () async {
          final type = typeProvider
              .mapType(typeProvider.stringType, typeProvider.intType)
              .element
              .thisType;
          final typeArguments = [
            toGenericType(typeProvider.stringType),
            toGenericType(typeProvider.intType)
          ];
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(
              type.element.thisType,
              typeArguments,
              type.element,
            ),
            expectedTypeArguments: ['String', 'int'],
            rawTypeName: 'Map<K, V>',
            displayStringWithNullability: 'Map<String, int>',
            displayStringWithoutNullability: 'Map<String, int>',
          );
        },
      );

      test(
        '.generic with multiple type arguments for function type',
        () async {
          final typeArguments = [
            toGenericType(typeProvider.stringType),
            toGenericType(typeProvider.intType),
          ];
          await assertGenericType(
            sourceType: multiGenericFunctionAlias.aliasedType,
            target: GenericType.generic(
              multiGenericFunctionAlias.aliasedType,
              typeArguments,
              multiGenericFunctionAlias,
            ),
            expectedTypeArguments: ['String', 'int'],
            rawTypeName: 'R Function<T, R>(T)',
            displayStringWithNullability: 'int Function(String)',
            displayStringWithoutNullability: 'int Function(String)',
          );
        },
      );

      test(
        '.generic for special type',
        () async {
          await assertGenericType(
            sourceType: typeProvider.neverType,
            target: GenericType.generic(
              typeProvider.neverType,
              [],
              typeProvider.neverType.element!,
            ),
            expectedTypeArguments: [],
            rawTypeName: 'Never',
            displayStringWithNullability: 'Never',
            displayStringWithoutNullability: 'Never',
          );
        },
      );

      test(
        'alias function with multiple type params',
        () async {
          final parameter =
              complexGenericTypeParameters['multiParameterAliasFunction']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(type, [], parameter),
            expectedTypeArguments: [],
            rawTypeName: 'R Function<T, R>(T)',
            displayStringWithNullability: 'MultiGenericFunction<int, String>',
            displayStringWithoutNullability:
                'MultiGenericFunction<int, String>',
          );
        },
      );

      test(
        'non-alias interface with multiple type params',
        () async {
          final parameter =
              complexGenericTypeParameters['multiParameterGenericType']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(
              type,
              [
                toGenericType(typeProvider.stringType),
                toGenericType(typeProvider.intType),
              ],
              parameter,
            ),
            expectedTypeArguments: ['String', 'int'],
            rawTypeName: 'Map<K, V>',
            displayStringWithNullability: 'AMap<String, int>',
            displayStringWithoutNullability: 'AMap<String, int>',
          );
        },
      );

      test(
        'non-alias function with multiple type params',
        () async {
          final parameter =
              complexGenericTypeParameters['multiParameterGenericFunction']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(
              type,
              [
                toGenericType(typeProvider.intType),
                toGenericType(typeProvider.stringType),
              ],
              parameter,
            ),
            expectedTypeArguments: ['int', 'String'],
            rawTypeName: 'R Function<S, R>(S)',
            displayStringWithNullability: 'String Function(int)',
            displayStringWithoutNullability: 'String Function(int)',
          );
        },
      );

      test(
        '.generic for interface without type arguments for alias with multiple type arguments',
        () async {
          final parameter =
              complexGenericTypeParameters['instantiatedMultiGenericType']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(type, [], parameter),
            expectedTypeArguments: ['String', 'int'],
            rawTypeName: 'Map<K, V>',
            displayStringWithNullability: 'StringIntMap',
            displayStringWithoutNullability: 'StringIntMap',
          );
        },
      );

      test(
        '.generic for function without type arguments for alias with multiple type arguments',
        () async {
          final parameter =
              complexGenericTypeParameters['instantiatedMultiGenericFunction']!;
          final type = parameter.type;
          await assertGenericType(
            sourceType: type,
            target: GenericType.generic(type, [], parameter),
            expectedTypeArguments: [],
            rawTypeName: 'R Function<T, R>(T)',
            displayStringWithNullability: 'InstantiatedMultiGenericFunction',
            displayStringWithoutNullability: 'InstantiatedMultiGenericFunction',
          );
        },
      );

      test(
        'function type with type formals and context supplied type arguments are not allowed',
        () async {
          final parameter =
              complexGenericTypeParameters['mixedParameterGenericFunction']!;
          final type = parameter.type;
          expect(
            () => GenericType.generic(
              type,
              [
                toGenericType(typeProvider.intType),
                toGenericType(typeProvider.stringType),
              ],
              parameter,
            ),
            throwsA(
              isA<InvalidGenerationSourceError>()
                  .having(
                    (e) => e.message,
                    'message',
                    "Complex function type 'T1 Function<S>(S)' is not supported.",
                  )
                  .having(
                    (e) => e.todo,
                    'todo',
                    'Do not use complex function type which has type formals and '
                        'uses any type parameters other than type formals. '
                        'For example, `S Function<T>(T)` is not allowed, '
                        'but `T Function<T>(T)` is allowed.',
                  )
                  .having(
                    (e) => e.element,
                    'element',
                    same(parameter),
                  ),
            ),
          );
        },
      );

      test(
        'function type with multiple context supplied type arguments are not allowed',
        () async {
          final parameter = complexGenericTypeParameters[
              'multiContextParameterGenericFunction']!;
          final type = parameter.type;
          expect(
            () => GenericType.generic(
              type,
              [
                toGenericType(typeProvider.intType),
                toGenericType(typeProvider.stringType),
              ],
              parameter,
            ),
            throwsA(
              isA<InvalidGenerationSourceError>()
                  .having(
                    (e) => e.message,
                    'message',
                    "Complex function type 'T2 Function(T1)' is not supported.",
                  )
                  .having(
                    (e) => e.todo,
                    'todo',
                    'Do not use complex function type which has more than one type '
                        'parameters. '
                        'For example, `S Function(T)` is not allowed, '
                        'but `T Function(T)` is allowed.',
                  )
                  .having(
                    (e) => e.element,
                    'element',
                    same(parameter),
                  ),
            ),
          );
        },
      );
    });
  });

  // Other classes can be tested well via emitter_test.
}
