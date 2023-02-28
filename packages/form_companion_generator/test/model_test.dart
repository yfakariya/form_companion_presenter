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

class TypeSpec {
  final String caseName;
  final String parameterName;
  final List<DartType> typeArguments;
  final List<String> expectedTypeArguments;
  final String displayStringWithNullability;
  final String displayStringWithoutNullability;
  final String rawTypeName;
  final TypeKind kind;
  final String? collectionItemType;

  TypeSpec(
    this.caseName,
    this.parameterName,
    this.typeArguments,
    this.expectedTypeArguments,
    this.displayStringWithNullability,
    this.displayStringWithoutNullability,
    this.rawTypeName,
    this.kind,
    this.collectionItemType,
  );
}

enum TypeKind {
  boolType,
  enumType,
  stringType,
  otherType,
}

Future<void> main() async {
  final libraryReader = LibraryReader(
    (await getResolvedLibraryResult('form_companion_annotation.dart')).element,
  );

  final parametersLibrary = await getParametersLibrary();
  final parameterHolder = parametersLibrary.getClass('ParameterHolder')!;
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
        .getClass('ComplexGenericTypeHolder')!
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
        'Failed to resolve annotation of "$className" class.',
      );
    }

    return ConstantReader(value);
  }

  FutureOr<void> testFunctionDefaultsAndSuperParametersCore(
    String targetClassName,
    String targetParameterName,
    String sourceCode,
    void Function(LibraryElement, ParameterInfo) assertion,
  ) async {
    final dispose = Completer<void>();
    try {
      late final Resolver resolver;
      await resolveSource(
        '''
library _lib;

$sourceCode
''',
        (r) => resolver = r,
        tearDown: dispose.future,
      );

      final library = await resolver.findLibraryByName('_lib');
      final classElement = library!.getClass(targetClassName);
      assert(classElement != null, "'$targetClassName' is not found.");
      final parameterElement = classElement!.constructors.single;
      final target = await resolver.astNodeFor(parameterElement, resolve: true);
      final result = await ParameterInfo.fromNodeAsync(
        NodeProvider(resolver),
        target!.childEntities
            .whereType<FormalParameterList>()
            .single
            .childEntities
            .whereType<FormalParameter>()
            .singleWhere((p) => p.name?.lexeme == targetParameterName),
      );

      assertion(library, result);
    } finally {
      dispose.complete();
    }
  }

  group('FormCompanionAnnotation', () {
    test('default - autovalidate is null', () {
      final target = FormCompanionAnnotation(findAnnotationValue('Default'));
      expect(target.autovalidate, isNull);
    });

    test('empty - autovalidate is null', () {
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
    group('fromNodeAsync', () {
      test('SuperFormalParameter', () async {
        final dispose = Completer<void>();
        try {
          late final Resolver resolver;
          await resolveSource(
            '''
library _lib;

class A {
  final int v;
  A(this.v);
}

class B extends A {
  B(super.v);
}

class C extends B {
  C(super.v);
}
''',
            (r) => resolver = r,
            tearDown: dispose.future,
          );
          final library = await resolver.findLibraryByName('_lib');
          final element = library!.getClass('C')!.constructors.single;
          final target = await resolver.astNodeFor(element, resolve: true);
          final result = await ParameterInfo.fromNodeAsync(
            NodeProvider(resolver),
            target!.childEntities
                .whereType<FormalParameterList>()
                .single
                .childEntities
                .whereType<FormalParameter>()
                .single,
          );
          expect(result.name, 'v');
          expect(result.type.isDartCoreInt, isTrue);
          expect(result.typeAnnotation, isNotNull);
          expect(result.typeAnnotation?.type?.isDartCoreInt, isTrue);
          expect(result.functionTypedParameter, isNull);
          expect(result.keyword, isNull);
          expect(result.node, isA<SuperFormalParameter>());
          expect(result.requirability, ParameterRequirability.notRequired);
        } finally {
          dispose.complete();
        }
      });

      group('Function defaults and super parameters', () {
        for (final aliasSpec in [
          // label, parameter prefix
          Tuple2('alias', 'aliased'),
          Tuple2('non-aliase', 'nonAliased'),
        ]) {
          for (final accessibilitySpec in [
            // label, parameter infix, default value expression, is public, expected default value code
            Tuple5(
              'public method in same class',
              'PublicInSamePublic',
              'Functions.publicMethod',
              true,
              'Functions.publicMethod',
            ),
            Tuple5(
              'non-public method in same class',
              'NonPublicInSamePublic',
              'Functions._nonPublicMethod',
              false,
              '_default_Functions__nonPublicMethod',
            ),
            Tuple5(
              'public method in another public class',
              'PublicInAnotherPublic',
              'PublicFunctions.publicMethod',
              true,
              'PublicFunctions.publicMethod',
            ),
            Tuple5(
              'non-public method in another public class',
              'NonPublicInAnotherPublic',
              'PublicFunctions._nonPublicMethod',
              false,
              '_default_PublicFunctions__nonPublicMethod',
            ),
            Tuple5(
              'public method in another non public class',
              'PublicInNonPublic',
              '_NonPublicFunctions.publicMethod',
              false,
              '_default__NonPublicFunctions_publicMethod',
            ),
            Tuple5(
              'non-public method in another non public class',
              'NonPublicInNonPublic',
              '_NonPublicFunctions._nonPublicMethod',
              false,
              '_default__NonPublicFunctions__nonPublicMethod',
            ),
            Tuple5(
              'public top level function',
              'PublicTopLevel',
              'publicFunction',
              true,
              'publicFunction',
            ),
            Tuple5(
              'non-public top level function',
              'NonPublicTopLevel',
              '_nonPublicFunction',
              false,
              '_nonPublicFunction',
            ),
          ]) {
            test(
                'Function defaults of ${aliasSpec.item1}, ${accessibilitySpec.item1}',
                () async {
              await testFunctionDefaultsAndSuperParametersCore(
                // class name
                'Functions',
                // parameter name
                '${aliasSpec.item2}With${accessibilitySpec.item2}Default',
                _functionWithDefaultTestCode,
                (l, p) {
                  expect(p.declaringTypeName, 'Functions');
                  expect(p.defaultValue, accessibilitySpec.item5);

                  if (accessibilitySpec.item4) {
                    expect(p.defaultTargetNonPublicMethod, isNull);
                  } else {
                    expect(
                      p.defaultTargetNonPublicMethod?.name,
                      accessibilitySpec.item5,
                    );
                    expect(
                      p.defaultTargetNonPublicMethod?.returnType.type,
                      l.typeProvider.voidType,
                    );
                    expect(
                      p.defaultTargetNonPublicMethod?.parameters.parameters
                          .isEmpty,
                      isTrue,
                    );
                  }
                },
              );
            });
          }
        }

        for (final spec in [
          // label, target class name, default code
          Tuple3(
            'declared in this class',
            'IntermediateFunctions',
            '_default_IntermediateFunctions__nonPublicMethod',
          ),
          Tuple3(
            'declared in super class',
            'DerivedFunctions',
            '_default_DerivedFunctions__nonPublicMethod',
          ),
        ]) {
          test('Default value in super parameter, ${spec.item1}', () async {
            await testFunctionDefaultsAndSuperParametersCore(
              spec.item2,
              'parameter',
              _functionWithDefaultInIntermediateTestCode,
              (l, p) {
                // always this.* declaration
                expect(p.declaringTypeName, 'BaseFunctions');
                expect(p.defaultValue, spec.item3);
                expect(
                  p.defaultTargetNonPublicMethod?.name,
                  spec.item3,
                );
                expect(
                  p.defaultTargetNonPublicMethod?.returnType.type,
                  l.typeProvider.voidType,
                );
                expect(
                  p.defaultTargetNonPublicMethod?.parameters.parameters.isEmpty,
                  isTrue,
                );
              },
            );
          });
        }
      });
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
      required TypeKind kind,
      required bool isNullable,
      required String? collectionItemType,
      required bool hasTypeParameter,
    }) async {
      if (sourceType is InterfaceType) {
        expect(
          target.maybeAsInterfaceType?.getDisplayString(withNullability: true),
          sourceType.getDisplayString(withNullability: true),
          reason: 'maybeAsInterfaceType : ${target.runtimeType}',
        );
      } else {
        expect(
          target.maybeAsInterfaceType,
          isNull,
          reason: 'maybeAsInterfaceType : ${target.runtimeType}',
        );
      }

      expect(
        target.rawType.getDisplayString(withNullability: false),
        rawTypeName,
        reason: 'rawType : ${target.runtimeType}',
      );

      expect(
        target.toString(),
        displayStringWithNullability,
        reason: 'toString() : ${target.runtimeType}',
      );
      expect(
        target.getDisplayString(withNullability: false),
        displayStringWithoutNullability,
        reason:
            'getDisplayString(withNullability: false) : ${target.runtimeType}',
      );
      expect(
        target.typeArguments.map((e) => e.toString()).toList().toString(),
        expectedTypeArguments.toString(),
        reason: 'typeArguments : ${target.runtimeType}',
      );
      expect(
        target.isBoolType,
        kind == TypeKind.boolType,
        reason: 'isBoolType : ${target.runtimeType}',
      );
      expect(
        target.isEnumType,
        kind == TypeKind.enumType,
        reason: 'isEnumType : ${target.runtimeType}',
      );
      expect(
        target.isStringType,
        kind == TypeKind.stringType,
        reason: 'isStringType : ${target.runtimeType}',
      );
      expect(
        target.isNullable,
        isNullable,
        reason: 'isNullable : ${target.runtimeType}',
      );
      expect(
        target.collectionItemType?.getDisplayString(withNullability: true),
        collectionItemType,
        reason: 'collectionItemType : ${target.runtimeType}',
      );
      expect(
        target.hasTypeParameter,
        hasTypeParameter,
        reason:
            'hasTypeParameter : ${target.getDisplayString(withNullability: true)}',
      );
    }

    Future<void> testGenericType({
      required ParameterElement source,
      required List<GenericType> typeArguments,
      required List<String> expectedTypeArguments,
      required String rawTypeName,
      required String displayStringWithNullability,
      required String displayStringWithoutNullability,
      required TypeKind kind,
      required bool isNullable,
      required String? collectionItemType,
      required bool hasTypeParameter,
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
        kind: kind,
        isNullable: isNullable,
        collectionItemType: collectionItemType,
        hasTypeParameter: hasTypeParameter,
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
            TypeKind.stringType,
            null,
          ),
          TypeSpec(
            'generic, non-alias',
            'genericInterface',
            [nullableStringType],
            ['String'],
            'List<String?>?',
            'List<String>',
            'List<E>',
            TypeKind.otherType,
            'String',
          ),
          TypeSpec(
            'instantiated-generic, non-alias',
            'instantiatedInterface',
            [],
            ['int'],
            'List<int?>?',
            'List<int>',
            'List<E>',
            TypeKind.otherType,
            'int',
          ),
          TypeSpec(
            'non-generic, alias',
            'alias',
            [],
            [],
            'AString?',
            'AString',
            'String',
            TypeKind.stringType,
            null,
          ),
          TypeSpec(
            'generic, alias',
            'genericAlias',
            [nullableStringType],
            ['String'],
            'AList<String?>?',
            'AList<String>',
            'List<E>',
            TypeKind.otherType,
            'String',
          ),
          TypeSpec(
            'instantiated-generic, alias',
            'instantiatedAlias',
            [],
            ['int'],
            'AList<int?>?',
            'AList<int>',
            'List<E>',
            TypeKind.otherType,
            'int',
          ),
        ]) {
          final nullability = nullable ? 'nullable' : 'non-nullable';
          final caseName = 'interface type, ${spec.caseName}, $nullability';
          final parameter =
              interfaceTypeParameters[nullability]![spec.parameterName]!;
          final typeArguments = (nullable
                  ? spec.typeArguments
                  : spec.typeArguments.map(typeSystem.promoteToNonNull))
              .map((t) => GenericType.fromDartType(t, parameter))
              .toList();
          final expectedTypeArguments = nullable
              ? spec.expectedTypeArguments.map((t) => '$t?').toList()
              : spec.expectedTypeArguments;
          final displayStringWithoutNullability =
              spec.displayStringWithoutNullability;
          final displayStringWithNullability = nullable
              ? spec.displayStringWithNullability
              : displayStringWithoutNullability;
          test(
            caseName,
            () => testGenericType(
              source: parameter,
              rawTypeName: spec.rawTypeName,
              typeArguments: typeArguments,
              expectedTypeArguments: expectedTypeArguments,
              displayStringWithNullability: displayStringWithNullability,
              displayStringWithoutNullability: displayStringWithoutNullability,
              kind: spec.kind,
              isNullable: nullable,
              collectionItemType: spec.collectionItemType != null
                  ? '${spec.collectionItemType}${nullable ? '?' : ''}'
                  : null,
              hasTypeParameter: false,
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
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'generic, non-alias',
            'genericFunction',
            [nullableStringType],
            ['String'],
            'String? Function(String?)?',
            'String Function(String)',
            'T Function(T)',
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'parameterized, non-alias',
            'parameterizedFunction',
            [nullableStringType],
            ['String'],
            'String? Function(String?)?',
            'String Function(String)',
            'S Function<S>(S)',
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'instantiated-generic, non-alias',
            'instantiatedFunction',
            [],
            [],
            'List<int>? Function(Map<String?, int?>?)?',
            'List<int> Function(Map<String, int>)',
            'List<int> Function(Map<String, int>)',
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'non-generic, alias',
            'alias',
            [],
            [],
            'NonGenericCallback?',
            'NonGenericCallback',
            'int Function(String)',
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'generic, alias',
            'genericAlias',
            [nullableStringType],
            ['String'],
            'GenericCallback<String?>?',
            'GenericCallback<String>',
            'void Function<T>(T)',
            TypeKind.otherType,
            null,
          ),
          TypeSpec(
            'instantiated-generic, alias',
            'instantiatedAlias',
            [],
            ['int'],
            'GenericCallback<int?>?',
            'GenericCallback<int>',
            'void Function<T>(T)',
            TypeKind.otherType,
            null,
          ),
        ]) {
          final nullability = nullable ? 'nullable' : 'non-nullable';
          final caseName = 'function type, ${spec.caseName}, $nullability';
          final parameter =
              functionTypeParameters[nullability]![spec.parameterName]!;
          final typeArguments = (nullable
                  ? spec.typeArguments
                  : spec.typeArguments.map(typeSystem.promoteToNonNull))
              .map((t) => GenericType.fromDartType(t, parameter))
              .toList();
          final expectedTypeArguments = nullable
              ? spec.expectedTypeArguments.map((t) => '$t?').toList()
              : spec.expectedTypeArguments;
          final displayStringWithoutNullability =
              spec.displayStringWithoutNullability;
          final displayStringWithNullability = nullable
              ? spec.displayStringWithNullability
              : displayStringWithoutNullability;
          test(
            caseName,
            () => testGenericType(
              source: parameter,
              rawTypeName: spec.rawTypeName,
              typeArguments: typeArguments,
              expectedTypeArguments: expectedTypeArguments,
              displayStringWithNullability: displayStringWithNullability,
              displayStringWithoutNullability: displayStringWithoutNullability,
              kind: spec.kind,
              isNullable: nullable,
              collectionItemType: spec.collectionItemType,
              hasTypeParameter: false,
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
          TypeKind.otherType,
          null,
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
          TypeKind.otherType,
          null,
        ),
      ]) {
        final caseName = 'function type, ${spec.caseName}';
        final parameter =
            functionTypeParameters['complex']![spec.parameterName]!;
        test(
          caseName,
          () => testGenericType(
            source: parameter,
            rawTypeName: spec.rawTypeName,
            typeArguments: [],
            expectedTypeArguments: [],
            displayStringWithNullability: spec.displayStringWithNullability,
            displayStringWithoutNullability:
                spec.displayStringWithoutNullability,
            kind: spec.kind,
            isNullable: true,
            collectionItemType: spec.collectionItemType,
            hasTypeParameter: false,
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
            kind: TypeKind.stringType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: false,
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

      test(
        'open generic interface type',
        () async {
          final element = parametersLibrary.scope
              .lookup('AList')
              .getter!
              .thisOrAncestorOfType<TypeAliasElement>()!;
          final type = element.aliasedType;
          await assertGenericType(
            sourceType: type,
            target: GenericType.fromDartType(type, element),
            expectedTypeArguments: ['E'],
            rawTypeName: 'List<E>',
            displayStringWithNullability: 'List<E>',
            displayStringWithoutNullability: 'List<E>',
            kind: TypeKind.otherType,
            collectionItemType: 'E',
            isNullable: false,
            hasTypeParameter: true,
          );
        },
      );

      test(
        'open generic function type',
        () async {
          final element = parametersLibrary.scope
              .lookup('GenericCallback')
              .getter!
              .thisOrAncestorOfType<TypeAliasElement>()!;
          final type = element.aliasedType;
          await assertGenericType(
            sourceType: type,
            target: GenericType.fromDartType(type, element),
            expectedTypeArguments: ['T'],
            rawTypeName: 'void Function<T>(T)',
            displayStringWithNullability: 'void Function<T>(T)',
            displayStringWithoutNullability: 'void Function<T>(T)',
            kind: TypeKind.otherType,
            collectionItemType: null,
            isNullable: false,
            hasTypeParameter: true,
          );
        },
      );
    });
  });

  // Other classes can be tested well via emitter_test.
}

const _functionWithDefaultTestCode = '''
import 'dart:ui';

class PublicFunctions {
  static void publicMethod() {}

  static void _nonPublicMethod() {}
}

class _NonPublicFunctions {
  static void publicMethod() {}

  static void _nonPublicMethod() {}
}

void publicFunction() {}
void _nonPublicFunction() {}

class Functions {
  VoidCallback? aliasedWithPublicInSamePublicDefault;
  void Function()? nonAliasedWithPublicInSamePublicDefault;
  VoidCallback? aliasedWithNonPublicInSamePublicDefault;
  void Function()? nonAliasedWithNonPublicInSamePublicDefault;
  VoidCallback? aliasedWithPublicInAnotherPublicDefault;
  void Function()? nonAliasedWithPublicInAnotherPublicDefault;
  VoidCallback? aliasedWithNonPublicInAnotherPublicDefault;
  void Function()? nonAliasedWithNonPublicInAnotherPublicDefault;
  VoidCallback? aliasedWithPublicInNonPublicDefault;
  void Function()? nonAliasedWithPublicInNonPublicDefault;
  VoidCallback? aliasedWithNonPublicInNonPublicDefault;
  void Function()? nonAliasedWithNonPublicInNonPublicDefault;
  VoidCallback? aliasedWithPublicTopLevelDefault;
  void Function()? nonAliasedWithPublicTopLevelDefault;
  VoidCallback? aliasedWithNonPublicTopLevelDefault;
  void Function()? nonAliasedWithNonPublicTopLevelDefault;

  static void publicMethod() {}

  static void _nonPublicMethod() {}

  Functions({
    this.aliasedWithPublicInSamePublicDefault = publicMethod,
    this.nonAliasedWithPublicInSamePublicDefault = publicMethod,
    this.aliasedWithNonPublicInSamePublicDefault = _nonPublicMethod,
    this.nonAliasedWithNonPublicInSamePublicDefault = _nonPublicMethod,
    this.aliasedWithPublicInAnotherPublicDefault = PublicFunctions.publicMethod,
    this.nonAliasedWithPublicInAnotherPublicDefault =
        PublicFunctions.publicMethod,
    this.aliasedWithNonPublicInAnotherPublicDefault =
        PublicFunctions._nonPublicMethod,
    this.nonAliasedWithNonPublicInAnotherPublicDefault =
        PublicFunctions._nonPublicMethod,
    this.aliasedWithPublicInNonPublicDefault = _NonPublicFunctions.publicMethod,
    this.nonAliasedWithPublicInNonPublicDefault =
        _NonPublicFunctions.publicMethod,
    this.aliasedWithNonPublicInNonPublicDefault =
        _NonPublicFunctions._nonPublicMethod,
    this.nonAliasedWithNonPublicInNonPublicDefault =
        _NonPublicFunctions._nonPublicMethod,
    this.aliasedWithPublicTopLevelDefault = publicFunction,
    this.nonAliasedWithPublicTopLevelDefault = publicFunction,
    this.aliasedWithNonPublicTopLevelDefault = _nonPublicFunction,
    this.nonAliasedWithNonPublicTopLevelDefault = _nonPublicFunction,
  });
}
''';

const _functionWithDefaultInIntermediateTestCode = '''
import 'dart:ui';

class BaseFunctions {
  VoidCallback? parameter;

  BaseFunctions({
    this.parameter,
  });
}

class IntermediateFunctions extends BaseFunctions {
  static void _nonPublicMethod() {}

  IntermediateFunctions({
    super.parameter = _nonPublicMethod,
  });
}

class DerivedFunctions extends IntermediateFunctions {
  DerivedFunctions({
    super.parameter,
  });
}
''';
