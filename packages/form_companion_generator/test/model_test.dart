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
  };
  final nullableStringType =
      interfaceTypeParameters['nullable']!['interface']!.type;

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
    final typeSystem = libraryReader.element.typeSystem;

    Future<void> testCore({
      required ParameterElement source,
      required List<GenericType> typeArguments,
      required List<String> expectedTypeArguments,
      required String rawTypeName,
      required String displayStringWithNullability,
      required String displayStringWithoutNullability,
    }) async {
      final type = source.type;
      final target = typeArguments.isEmpty
          ? GenericType.fromDartType(type)
          : GenericType.generic(type, typeArguments);
      if (type is InterfaceType) {
        expect(
          target.maybeAsInterfaceType?.getDisplayString(withNullability: true),
          type.getDisplayString(withNullability: true),
        );
      } else {
        expect(target.maybeAsInterfaceType, isNull);
      }

      expect(
        target.rawType.getDisplayString(withNullability: false),
        rawTypeName,
      );

      expect(
        target.toString(),
        displayStringWithNullability,
      );
      expect(
        target.getDisplayString(withNullability: false),
        displayStringWithoutNullability,
      );
      expect(
        target.typeArguments.map((e) => e.toString()).toList().toString(),
        expectedTypeArguments.toString(),
      );
    }

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
            .map(GenericType.fromDartType)
            .toList();
        final expectedTypeArguments =
            nullable ? spec.item4.map((t) => '$t?').toList() : spec.item4;
        final displayStringWithoutNullability = spec.item6;
        final displayStringWithNullability =
            nullable ? spec.item5 : displayStringWithoutNullability;
        final rawTypeName = spec.item7;
        test(
          caseName,
          () => testCore(
            source: parameter,
            rawTypeName: rawTypeName,
            typeArguments: typeArguments,
            expectedTypeArguments: expectedTypeArguments,
            displayStringWithNullability: displayStringWithNullability,
            displayStringWithoutNullability: displayStringWithoutNullability,
          ),
        );
      }
    } // interface types

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
            .map(GenericType.fromDartType)
            .toList();
        final expectedTypeArguments =
            nullable ? spec.item4.map((t) => '$t?').toList() : spec.item4;
        final displayStringWithoutNullability = spec.item6;
        final displayStringWithNullability =
            nullable ? spec.item5 : displayStringWithoutNullability;
        final rawTypeName = spec.item7;
        test(
          caseName,
          () => testCore(
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
  });

  // Other classes can be tested well via emitter_test.
}
