// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/dependency.dart';
import 'package:form_companion_generator/src/form_field_locator.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'file_resolver.dart';
import 'test_helpers.dart';

typedef FieldNameAndValueType = Tuple2<String, InterfaceType>;

class ExpectedImport {
  final String identifier;
  final List<String> shows;
  final List<MapEntry<String, List<String>>> prefixes;

  const ExpectedImport(
    this.identifier, {
    this.shows = const [],
    this.prefixes = const [],
  });
}

Future<void> main() async {
  final logger = Logger('parser_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  final presenterLibrary = LibraryReader(
    (await getElement('presenter.dart')).element,
  );
  final resolver = FileResolver(presenterLibrary.element);
  final nodeProvider = NodeProvider(FileResolver(presenterLibrary.element));
  final typeProvider = presenterLibrary.element.typeProvider;
  final formFieldLocator =
      await FormFieldLocator.createAsync(resolver, [], logger);
  final myEnumType = await getMyEnumType();
  final dateTimeType = await getDateTimeType();
  final dateTimeRangeType = await getDateTimeRangeType();
  final rangeValuesType = await getRangeValuesType();
  final dependencyHolder =
      (await getParametersLibrary()).lookupClass('DependencyHolder');

  ClassElement findType(String name) {
    final type = presenterLibrary.findType(name);
    if (type == null) {
      fail("Failed to find '$name' from ${presenterLibrary.element.name}.");
    }

    return type;
  }

  group('detectMixinType', () {
    // Note: We cannot declare class which only mix-in FormCompanionPresenterMixin
    // or FormBuilderCompanionPresenterMixin because they require the class implements
    // CompanionPresenterMixin.

    test(
      'with FormCompanionPresenterMixin is detected as formCompanionPresenterMixin',
      () => expect(
        detectMixinType(findType('FormPresenter')),
        equals(MixinType.formCompanionMixin),
      ),
    );

    test(
      'with FormBuilderCompanionPresenterMixin is detected as formBuilderCompanionPresenterMixin',
      () => expect(
        detectMixinType(findType('FormBuilderPresenter')),
        equals(MixinType.formBuilderCompanionMixin),
      ),
    );

    test(
      'with both of mix-in is detected as error.',
      () => expect(
        () => detectMixinType(findType('DualPresenter')),
        throwsA(isA<InvalidGenerationSourceError>()),
      ),
    );

    test(
      'without any mix-in is detected as null',
      () => expect(
        detectMixinType(findType('VanillaPresenter')),
        isNull,
      ),
    );

    test(
      'with only CompanionPresenterMixin is detected as null',
      () => expect(
        detectMixinType(findType('InvalidCompanionPresenter')),
        isNull,
      ),
    );
  });

  group('findConstructor', () {
    test('1 public constructor - found it', () {
      final found = findConstructor(findType('FormPresenter'));
      expect(found, isNotNull);
      expect(found.isPublic, isTrue);
    });

    test('1 private constructor - found it', () {
      final found = findConstructor(findType('WithPrivateConstructor'));
      expect(found, isNotNull);
      expect(found.isPrivate, isTrue);
    });

    test('with delegating constructors - found non-delegated one', () {
      final found = findConstructor(findType('WithDelegatingConstructors'));
      expect(found, isNotNull);
      expect(found.isDefaultConstructor, isFalse);
      expect(found.isPrivate, isTrue);
      expect(found.isFactory, isFalse);
    });

    test(
      'Multiple constructor bodies - error',
      () => expect(
        () => findConstructor(findType('MultipleConstructorBody')),
        throwsA(isA<InvalidGenerationSourceError>()),
      ),
    );

    test(
      'No constructors - error',
      () => expect(
        () => findConstructor(findType('WithoutConstructor')),
        throwsA(isA<InvalidGenerationSourceError>()),
      ),
    );

    test('No default constructors - found not delegated one', () {
      final found = findConstructor(findType('NoDefaultConstructors'));
      expect(found, isNotNull);
      expect(found.isDefaultConstructor, isFalse);
      expect(found.isPublic, isTrue);
      expect(found.isFactory, isFalse);
      expect(found.name, equals('toBeDetected'));
    });
  });

  group('getProperties', () {
    FutureOr<void> testGetProperties(
      String name,
      void Function(Map<String, PropertyAndFormFieldDefinition>)
          propertiesAssertion, {
      void Function(List<String>)? warningsAssertion,
    }) async {
      final targetClass = findType(name);
      final warnings = <String>[];
      final result = await getPropertiesAsync(
        nodeProvider,
        formFieldLocator,
        findConstructor(targetClass),
        warnings,
        logger,
        isFormBuilder: false,
      );

      propertiesAssertion(result);
      if (warningsAssertion != null) {
        warningsAssertion(warnings);
      } else {
        expect(
          warnings.isEmpty,
          isTrue,
          reason: 'Some warnings are found: $warnings',
        );
      }
    }

    FutureOr<void> testGetPropertiesError<TElement>(
      String name, {
      required String message,
      required String todo,
    }) async {
      final targetClass = findType(name);
      final warnings = <String>[];
      try {
        final result = await getPropertiesAsync(
          nodeProvider,
          formFieldLocator,
          findConstructor(targetClass),
          warnings,
          logger,
          isFormBuilder: false,
        );
        fail('No error occurred. Properties: $result');
      }
      // ignore: avoid_catching_errors
      on InvalidGenerationSourceError catch (e, s) {
        printOnFailure(e.toString());
        printOnFailure(s.toString());
        expect(e.element, isA<TElement>());
        // "at ..." in tail should not be verified.
        expect(e.message, startsWith(message));
        expect(e.todo, equals(todo));
      }
    }

    void testBasicProperties(
      Map<String, PropertyAndFormFieldDefinition> props,
    ) {
      expect(props['propInt'], isNotNull);
      expect(props['propInt']!.name, 'propInt');
      expect(props['propInt']!.type, typeProvider.intType);
      expect(props['propInt']!.fieldConstructor, isNotNull);
      expect(props['propInt']!.fieldConstructor!.name, isNull);
      expect(props['propInt']!.fieldType, isNotNull);
      expect(
        props['propInt']!.fieldType!.getDisplayString(withNullability: true),
        equals('TextFormField'),
      );
      expect(props['propInt']!.fieldTypeName, 'TextFormField');
      expect(props['propInt']!.warnings, isEmpty);
      expect(props['propInt']!.instantiationContext, isNotNull);
      expect(props['propString'], isNotNull);
      expect(props['propString']!.name, 'propString');
      expect(props['propString']!.type, typeProvider.stringType);
      expect(props['propString']!.fieldConstructor, isNotNull);
      expect(props['propString']!.fieldConstructor!.name, isNull);
      expect(props['propString']!.fieldType, isNotNull);
      expect(
        props['propString']!.fieldType!.getDisplayString(withNullability: true),
        'TextFormField',
      );
      expect(props['propString']!.fieldTypeName, 'TextFormField');
      expect(props['propString']!.warnings, isEmpty);
      expect(props['propString']!.instantiationContext, isNotNull);
      expect(props['propBool'], isNotNull);
      expect(props['propBool']!.type, typeProvider.boolType);
      expect(props['propBool']!.fieldConstructor, isNotNull);
      expect(props['propBool']!.fieldConstructor!.name, isNull);
      expect(props['propBool']!.fieldType, isNotNull);
      expect(
        props['propBool']!.fieldType!.getDisplayString(withNullability: true),
        'DropdownButtonFormField<T>',
      );
      expect(props['propBool']!.fieldTypeName, 'DropdownButtonFormField');
      expect(props['propBool']!.warnings, isEmpty);
      expect(props['propBool']!.instantiationContext, isNotNull);
      expect(props['propEnum'], isNotNull);
      expect(
        props['propEnum']!.type.getDisplayString(withNullability: true),
        'MyEnum',
      );
      expect(props['propEnum']!.fieldConstructor, isNotNull);
      expect(props['propEnum']!.fieldConstructor!.name, isNull);
      expect(props['propEnum']!.fieldType, isNotNull);
      expect(
        props['propEnum']!.fieldType!.getDisplayString(withNullability: true),
        'DropdownButtonFormField<T>',
      );
      expect(props['propEnum']!.fieldTypeName, 'DropdownButtonFormField');
      expect(props['propEnum']!.warnings, isEmpty);
      expect(props['propEnum']!.instantiationContext, isNotNull);
      expect(props['propEnumList'], isNotNull);
      expect(
        props['propEnumList']!.type.getDisplayString(withNullability: true),
        'List<MyEnum>',
      );
      expect(props['propEnumList']!.fieldConstructor, isNotNull);
      expect(props['propEnumList']!.fieldConstructor!.name, isNull);
      expect(props['propEnumList']!.fieldType, isNotNull);
      expect(
        props['propEnumList']!
            .fieldType!
            .getDisplayString(withNullability: true),
        'TextFormField',
      );
      expect(props['propEnumList']!.fieldTypeName, 'TextFormField');
      expect(props['propEnumList']!.warnings, isEmpty);
      expect(props['propEnumList']!.instantiationContext, isNotNull);
      expect(props['propRaw'], isNotNull);
      expect(props['propRaw']!.type, typeProvider.objectType);
      expect(props['propRaw']!.fieldConstructor, isNotNull);
      expect(props['propRaw']!.fieldConstructor!.name, isNull);
      expect(props['propRaw']!.fieldType, isNotNull);
      expect(
        props['propRaw']!.fieldType!.getDisplayString(withNullability: true),
        equals('TextFormField'),
      );
      expect(props['propRaw']!.fieldTypeName, 'TextFormField');
      expect(props['propRaw']!.warnings, isEmpty);
      expect(props['propRaw']!.instantiationContext, isNotNull);
    }

    void testExtraProperties(
      Map<String, PropertyAndFormFieldDefinition> props,
    ) {
      expect(props['extra'], isNotNull);
      expect(props['extra']!.name, 'extra');
      expect(props['extra']!.type, typeProvider.stringType);
      expect(props['extra']!.fieldConstructor, isNotNull);
      expect(props['extra']!.fieldConstructor!.name, isNull);
      expect(props['extra']!.fieldType, isNotNull);
      expect(
        props['extra']!.fieldType!.getDisplayString(withNullability: true),
        'TextFormField',
      );
      expect(props['extra']!.fieldTypeName, 'TextFormField');
      expect(props['extra']!.warnings, isEmpty);
      expect(props['extra']!.instantiationContext, isNotNull);
    }

    FutureOr<void> testGetPropertiesSuccess(String name) => testGetProperties(
          name,
          (props) {
            expect(props.length, 6);
            testBasicProperties(props);
          },
        );

    FutureOr<void> testGetPropertiesNoProperties(String name) =>
        testGetProperties(
          'InlineWithNoAddition',
          (props) => expect(props, isEmpty),
          warningsAssertion: (warnings) {
            expect(warnings.length, 1);
            expect(
              warnings[0],
              equals(
                "initializeCompanionMixin(PropertyDescriptorsBuilder) is called with empty PropertyDescriptorsBuilder in class 'InlineWithNoAddition'.",
              ),
            );
          },
        );

    group('inline', () {
      test(
        'with cascading - detected',
        () => testGetPropertiesSuccess('InlineWithCascading'),
      );

      test(
        'no addition - empty',
        () => testGetPropertiesNoProperties('InlineWithNoAddition'),
      );
    });

    group('extension method', () {
      test(
        'addWithField',
        () => testGetProperties('ExtensionMethod', (props) {
          expect(props.length, 2);
          expect(props['propDouble'], isNotNull);
          expect(props['propDouble']!.type, typeProvider.doubleType);
          expect(props['propDouble']!.fieldConstructor, isNotNull);
          expect(props['propDouble']!.fieldConstructor!.name, isNull);
          expect(props['propDouble']!.fieldType, isNotNull);
          expect(
            props['propDouble']!
                .fieldType!
                .getDisplayString(withNullability: true),
            'FormBuilderSlider',
          );
          expect(props['propDouble']!.fieldTypeName, 'FormBuilderSlider');
          expect(props['propDouble']!.warnings, isEmpty);
          expect(props['propDouble']!.instantiationContext, isNotNull);
          expect(props['propEnumList'], isNotNull);
          expect(
            props['propEnumList']!.type,
            typeProvider.listType(myEnumType),
          );
          expect(props['propEnumList']!.fieldConstructor, isNotNull);
          expect(props['propEnumList']!.fieldConstructor!.name, isNull);
          expect(props['propEnumList']!.fieldType, isNotNull);
          expect(
            props['propEnumList']!
                .fieldType!
                .getDisplayString(withNullability: true),
            'FormBuilderCheckboxGroup<T>',
          );
          expect(
            props['propEnumList']!.fieldTypeName,
            'FormBuilderCheckboxGroup',
          );
          expect(props['propEnumList']!.warnings, isEmpty);
          expect(props['propEnumList']!.instantiationContext, isNotNull);
        }),
      );
    });

    group('factory method', () {
      test(
        'cascading factory calls - detected',
        () => testGetPropertiesSuccess('CallsCascadingFactory'),
      );

      test(
        'classic factory calls - detected',
        () => testGetPropertiesSuccess('CallsClassicFactory'),
      );

      test(
        'classic factory with helpers calls - detected',
        () => testGetPropertiesSuccess('CallsWithHelperFactory'),
      );
    });

    for (final spec in [
      ['field', 'StaticField', 'StaticMethod'],
      ['global variable/function', 'GlobalVariable', 'GlobalFunction']
    ]) {
      final description = spec[0];
      final fieldPrefix = spec[1];
      final functionPrefix = spec[2];
      group('$description reference', () {
        test(
          'no addition - warning',
          () => testGetPropertiesNoProperties(
              'Refers${fieldPrefix}WithNoAddition'),
        );

        test(
          'with getter for inline initialized - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}GetterForInlineInitialized'),
        );

        test(
          'with getter for factory initialized - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}GetterForFactoryInitialized'),
        );

        test(
          'with getter for factory method - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}GetterForFactoryMethod'),
        );

        test(
          'refers member from cascading factory method calls - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}CascadingFactoryMethod'),
        );

        test(
          'refers member from classic factory method calls - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}ClassicFactoryMethod'),
        );

        test(
          'refers member from classic factory method with helpers calls - detected',
          () => testGetPropertiesSuccess(
              'Refers${fieldPrefix}WithHelpersFactoryMethod'),
        );

        test(
          'calls cascading factory method - detected',
          () => testGetPropertiesSuccess(
              'Calls${functionPrefix}CascadingFactory'),
        );

        test(
          'calls classic factory method - detected',
          () =>
              testGetPropertiesSuccess('Calls${functionPrefix}ClassicFactory'),
        );

        test(
          'calls classic factory method with helpers - detected',
          () => testGetPropertiesSuccess(
              'Calls${functionPrefix}WithHelperFactory'),
        );
      });
    }

    group('local variable', () {
      test(
        'with field inline initialized - detected',
        () => testGetPropertiesSuccess('LocalVariableInlineInitialized'),
      );

      test(
        'no addition - warning',
        () => testGetPropertiesNoProperties('LocalVariableNoAddition'),
      );

      test(
        'with field refers field - detected',
        () => testGetPropertiesSuccess('LocalVariableRefersField'),
      );

      test(
        'with field refers field and modify it - error',
        // always error
        () => testGetPropertiesError<ConstructorElement>(
          'LocalVariableRefersFieldWithModification',
          message:
              'Modification of shared PropertyDescriptorsBuilder object is detected at',
          todo:
              'Do not define extra properties to PropertyDescriptorsBuilder when it is declared as fields or top level variables because PropertyDescriptorsBuilder is mutable object.',
        ),
      );

      test(
        'with field refers getter - detected',
        () => testGetPropertiesSuccess('LocalVariableRefersGetter'),
      );

      test(
        'with field refers always-same getter with modification - error',
        // always error
        () => testGetPropertiesError<ConstructorElement>(
          'LocalVariableRefersAlwaysSameGetterWithModification',
          message:
              'Modification of shared PropertyDescriptorsBuilder object is detected at',
          todo:
              'Do not define extra properties to PropertyDescriptorsBuilder when it is declared as fields or top level variables because PropertyDescriptorsBuilder is mutable object.',
        ),
      );

      test(
        'with field refers always-new getter with modification - detected',
        () => testGetProperties(
          'LocalVariableRefersAlwaysNewGetterWithModification',
          (props) {
            expect(props.length, equals(7));
            testBasicProperties(props);
            testExtraProperties(props);
          },
        ),
      );

      test(
        'with factory method calls - detected',
        () => testGetPropertiesSuccess('LocalVariableRefersFactoryMethod'),
      );

      test(
        'with always-same factory method calls with modification - error',
        // always error
        () => testGetPropertiesError<ConstructorElement>(
          'LocalVariableRefersAlwaysSameFactoryMethodWithMofidication',
          message:
              'Modification of shared PropertyDescriptorsBuilder object is detected at',
          todo:
              'Do not define extra properties to PropertyDescriptorsBuilder when it is declared as fields or top level variables because PropertyDescriptorsBuilder is mutable object.',
        ),
      );

      test(
        'with always-new factory method calls with modification - detected',
        () => testGetProperties(
          'LocalVariableRefersAlwaysNewFactoryMethodWithMofidication',
          (props) {
            expect(props.length, equals(7));
            testBasicProperties(props);
            testExtraProperties(props);
          },
        ),
      );

      test(
        'calls helpers - detected',
        () => testGetPropertiesSuccess('LocalVariableCallsHelpers'),
      );

      test(
        'calls factory with duplicated property definition - error',
        () => testGetPropertiesError<FunctionElement>(
          'InvalidLocalVariableWithDuplication',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );

      test(
        'calls factory with helper which does duplicated property definition - error',
        () => testGetPropertiesError<FunctionElement>(
          'InvalidLocalVariableWithDuplicationHelper',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );

      test(
        'initialized with duplicated property definition - error',
        () => testGetPropertiesError<ConstructorElement>(
          'InvalidLocalVariableInitializationWithDuplication',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );
    });

    group('error cases', () {
      test(
        'no initializeCompanionMixin invocation - error',
        () => testGetPropertiesError<ConstructorElement>(
          'NoInitializeCompanionMixin',
          message:
              "No initializeCompanionMixin(PropertyDescriptorsBuilder) invocation in constructor body of 'NoInitializeCompanionMixin' class.",
          todo:
              'Call initializeCompanionMixin(PropertyDescriptorsBuilder) in constructor body.',
        ),
      );

      test(
        'multiple initializeCompanionMixin invocation - last one is adopted and warning',
        () => testGetProperties(
          'MultipleInitializeCompanionMixin',
          (props) {
            expect(props.length, equals(1));
            expect(props['prop1'], isNull);
            expect(props['prop2'], isNotNull);
          },
          warningsAssertion: (warnings) {
            expect(warnings.length, equals(1));
            expect(
              warnings[0],
              equals(
                "initializeCompanionMixin(PropertyDescriptorsBuilder) is called multiply in constructor of class 'MultipleInitializeCompanionMixin', so last one is used.",
              ),
            );
          },
        ),
      );

      test(
        'with dynamic name - error',
        () => testGetPropertiesError<ConstructorElement>(
          'DynamicPropertyName',
          message:
              "Failed to parse non-literal 'name' argument from expression '..add<int>(name: 'prop\${Platform.numberOfProcessors}')'.",
          todo: "Use constant expression for 'name' argument.",
        ),
      );

      for (final spec in [
        ['if statement', 'If'],
        ['for statement', 'For'],
        ['while statement', 'While'],
        ['do-while statement', 'Do'],
        ['try statement', 'Try'],
      ]) {
        final description = spec[0];
        final suffix = spec[1];

        test(
          'calls invalid factory with $description - error',
          () => testGetPropertiesError<FunctionElement>(
            'InvalidFactoryWith$suffix',
            message: 'Failed to analyze complex construction logics at',
            todo:
                'Do not use if or any loop statement in methods or functions for PropertyDescriptorsBuilder construction.',
          ),
        );

        test(
          'calls invalid factory with helper which does $description - error',
          () => testGetPropertiesError<FunctionElement>(
            'InvalidFactoryWith${suffix}Helper',
            message: 'Failed to analyze complex construction logics at',
            todo:
                'Do not use if or any loop statement in methods or functions for PropertyDescriptorsBuilder construction.',
          ),
        );
      }

      test(
        'calls factory with duplicated property definition - error',
        () => testGetPropertiesError<FunctionElement>(
          'InvalidFactoryWithDuplication',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );

      test(
        'calls factory with helper which does duplicated property definition - error',
        () => testGetPropertiesError<FunctionElement>(
          'InvalidFactoryWithDuplicationHelper',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );

      test(
        'initialized with duplicated property definition - error',
        () => testGetPropertiesError<ConstructorElement>(
          'InvalidInitializationWithDuplication',
          message: "Property 'propInt' is defined more than once",
          todo:
              'Fix to define each properties only once for given PropertyDescriptorsBuilder.',
        ),
      );
    });
  });

  group('collectDependencies', () {
    FutureOr<PropertyAndFormFieldDefinition> makeProperty(
      String formFieldTypeName,
      InterfaceType valueType,
    ) async {
      final property = PropertyDefinition(
        name: 'prop',
        type: valueType,
        preferredFieldType: formFieldTypeName,
        warnings: [],
      );

      final formFieldType =
          formFieldLocator.resolveFormFieldType(formFieldTypeName)!;

      return PropertyAndFormFieldDefinition(
        property: property,
        fieldType: formFieldType,
        fieldTypeName: formFieldTypeName,
        fieldConstructor: await nodeProvider.getElementDeclarationAsync(
            formFieldType.element.unnamedConstructor!),
        instantiationContext: null, // This is OK
      );
    }

    void assertImports(
      List<LibraryImport> result,
      List<ExpectedImport> expected,
    ) {
      result.sort((l, r) => l.library.compareTo(r.library));
      expect(
        result.map((e) => e.library).toList(),
        expected.map((e) => e.identifier).toList(),
      );
      for (var i = 0; i < expected.length; i++) {
        expect(result[i].library, expected[i].identifier);
        expect(
          result[i].showingTypes.toList()..sort(),
          expected[i].shows,
          reason: result[i].library,
        );
        expect(
          result[i].prefixes.length,
          expected[i].prefixes.length,
          reason:
              '${result[i].library}: ${result[i].prefixes.toList()} != ${expected[i].prefixes.toList()}',
        );
        final prefixes = result[i].prefixes.toList()
          ..sort((l, r) => l.key.compareTo(r.key));
        for (var j = 0; j < expected[i].prefixes.length; j++) {
          expect(prefixes[j].key, expected[i].prefixes[j].key);
          expect(
            prefixes[j].value.toList()..sort(),
            expected[i].prefixes[j].value,
            reason: prefixes[j].key,
          );
        }
      }
    }

    for (final spec in [
      Tuple2(
        'normal',
        ExpectedImport('dart:ui', shows: ['Color']),
      ),
      Tuple2(
        'alias',
        ExpectedImport('dart:ui', shows: ['VoidCallback']),
      ),
      Tuple2(
        'prefixed',
        ExpectedImport(
          'dart:ui',
          prefixes: [
            MapEntry('ui', ['VoidCallback']),
          ],
        ),
      ),
      Tuple2(
        'function',
        ExpectedImport(
          'dart:ui',
          shows: ['Color'],
          prefixes: [
            MapEntry('ui', ['VoidCallback'])
          ],
        ),
      ),
    ]) {
      final kind = spec.item1;
      final expected = spec.item2;

      test('unit test: $kind', () async {
        final property = PropertyDefinition(
          name: 'prop',
          type: typeProvider.stringType,
          preferredFieldType: null,
          warnings: [],
        );

        final propertyAndField = PropertyAndFormFieldDefinition(
          property: property,
          fieldType: null, // This is OK
          fieldTypeName: '', // This is OK
          fieldConstructor: await nodeProvider
              .getElementDeclarationAsync<ConstructorDeclaration>(
            dependencyHolder.constructors.singleWhere((c) => c.name == kind),
          ),
          instantiationContext: null,
        );

        final result = await collectDependenciesAsync(
          dependencyHolder.library,
          [propertyAndField],
          nodeProvider,
          logger,
          isFormBuilder: false,
        );

        assertImports(
          result,
          [
            expected,
            ExpectedImport('package:flutter/widgets.dart',
                shows: ['BuildContext']),
          ],
        );
      });
    }

    Future<void> testCollectDependenciesAsync(
      String fieldName,
      InterfaceType valueType, {
      required bool isFormBuilder,
    }) async {
      final result = await collectDependenciesAsync(
        presenterLibrary.element,
        [await makeProperty(fieldName, valueType)],
        nodeProvider,
        logger,
        isFormBuilder: isFormBuilder,
      );

      final expected = [..._expectedImports[fieldName]!];
      if (valueType == myEnumType ||
          (valueType.isDartCoreList &&
              valueType.typeArguments.length == 1 &&
              valueType.typeArguments.first == myEnumType)) {
        expected.add(
          ExpectedImport(
            'package:form_companion_generator_test_targets/properties.dart',
            shows: ['MyEnum'],
          ),
        );
      }

      assertImports(result, expected);
    }

    for (final spec in [
      FieldNameAndValueType('TextFormField', typeProvider.stringType),
      FieldNameAndValueType('DropdownButtonFormField', typeProvider.boolType),
    ]) {
      final fieldName = spec.item1;
      final valueType = spec.item2;
      test('vanilla form: $fieldName', () async {
        await testCollectDependenciesAsync(
          fieldName,
          valueType,
          isFormBuilder: false,
        );
      });
    }

    for (final spec in [
      FieldNameAndValueType('FormBuilderCheckbox', typeProvider.boolType),
      FieldNameAndValueType(
        'FormBuilderCheckboxGroup',
        typeProvider.listType(typeProvider.boolType),
      ),
      FieldNameAndValueType('FormBuilderChoiceChip', myEnumType),
      FieldNameAndValueType('FormBuilderDateRangePicker', dateTimeRangeType),
      FieldNameAndValueType('FormBuilderDateTimePicker', dateTimeType),
      FieldNameAndValueType('FormBuilderDropdown', myEnumType),
      FieldNameAndValueType(
        'FormBuilderFilterChip',
        typeProvider.listType(myEnumType),
      ),
      FieldNameAndValueType('FormBuilderRadioGroup', myEnumType),
      FieldNameAndValueType('FormBuilderRangeSlider', rangeValuesType),
      FieldNameAndValueType('FormBuilderSegmentedControl', myEnumType),
      FieldNameAndValueType('FormBuilderSlider', typeProvider.doubleType),
      FieldNameAndValueType('FormBuilderSwitch', typeProvider.boolType),
      FieldNameAndValueType('FormBuilderTextField', typeProvider.stringType),
    ]) {
      final fieldName = spec.item1;
      final valueType = spec.item2;
      test('form builder $fieldName', () async {
        await testCollectDependenciesAsync(
          fieldName,
          valueType,
          isFormBuilder: true,
        );
      });
    }
  });

  // TODO(yfakariya): field related tests.
  // preferredType
  // resolveFormFieldAsync() - isFormBuilder x types x preferredType

  // TODO(yfakariya): parseElementAsync : isFormBuilder x warnings
  // TODO(yfakariya): generator integration test.
}

List<ExpectedImport> _merge(List<ExpectedImport> lists) {
  final map = <String, Tuple2<Set<String>, Map<String, Set<String>>>>{};
  for (final import in lists) {
    final existing = map[import.identifier];
    if (existing != null) {
      existing.item1.addAll(import.shows);
      for (final prefix in import.prefixes) {
        final existingPrefix = existing.item2[prefix.key];
        if (existingPrefix != null) {
          existingPrefix.addAll(prefix.value);
        } else {
          existing.item2[prefix.key] = {...prefix.value};
        }
      }
    } else {
      map[import.identifier] = Tuple2(
        Set.from(import.shows),
        {
          for (final p in import.prefixes) p.key: {...p.value}
        },
      );
    }
  }

  final sortedKeys = map.keys.toList()..sort();
  return sortedKeys
      .map(
        (k) => ExpectedImport(
          k,
          shows: map[k]!.item1.toList()..sort(),
          prefixes: map[k]!
              .item2
              .keys
              .map((p) => MapEntry(p, [...map[k]!.item2[p]!]..sort()))
              .toList()
            ..sort(),
        ),
      )
      .toList();
}

const _vanillaCommonImports = [
  ExpectedImport(
    'dart:ui',
    shows: ['Color', 'VoidCallback'],
  ),
  ExpectedImport(
    'package:flutter/foundation.dart',
    shows: ['ValueChanged'],
  ),
  ExpectedImport(
    'package:flutter/material.dart',
    shows: ['InputDecoration'],
  ),
  ExpectedImport(
    'package:flutter/painting.dart',
    shows: ['TextStyle'],
  ),
  ExpectedImport(
    'package:flutter/widgets.dart',
    shows: [
      'AutovalidateMode',
      'BuildContext',
      'FocusNode',
    ],
  ),
];

const _builderCommonImports = [
  ExpectedImport(
    'dart:ui',
    shows: ['Color', 'VoidCallback'],
  ),
  ExpectedImport(
    'package:flutter/foundation.dart',
    shows: ['Key', 'ValueChanged'],
  ),
  ExpectedImport(
    'package:flutter/material.dart',
    shows: ['InputDecoration'],
  ),
  ExpectedImport(
    'package:flutter/widgets.dart',
    shows: [
      'AutovalidateMode',
      'BuildContext',
      'FocusNode',
    ],
  ),
  ExpectedImport(
    'package:flutter_form_builder/flutter_form_builder.dart',
    // TODO(yfakariya): This may affects converter
    shows: ['ValueTransformer'],
  ),
];

final _expectedImports = {
  'TextFormField': _merge([
    ..._vanillaCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['Brightness', 'Radius', 'TextAlign', 'TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/gestures.dart',
      shows: ['GestureTapCallback'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['InputCounterWidgetBuilder', 'TextFormField'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets', 'StrutStyle', 'TextAlignVertical'],
    ),
    ExpectedImport(
      'package:flutter/services.dart',
      shows: [
        'MaxLengthEnforcement',
        'SmartDashesType',
        'SmartQuotesType',
        'TextCapitalization',
        'TextInputAction',
        'TextInputFormatter',
        'TextInputType',
      ],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: [
        'ScrollController',
        'ScrollPhysics',
        'TextEditingController',
        'TextSelectionControls',
        'ToolbarOptions',
      ],
    ),
  ]),
  'DropdownButtonFormField': _merge([
    ..._vanillaCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: [
        'DropdownButtonBuilder',
        'DropdownButtonFormField',
        'DropdownMenuItem',
        'InputDecoration'
      ],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['AlignmentDirectional', 'AlignmentGeometry'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Widget'],
    ),
  ]),
  'FormBuilderCheckbox': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['InputBorder', 'ListTileControlAffinity'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderCheckbox'],
    ),
  ]),
  'FormBuilderCheckboxGroup': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['MaterialTapTargetSize'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['Axis', 'VerticalDirection'],
    ),
    ExpectedImport(
      'package:flutter/rendering.dart',
      shows: ['WrapAlignment', 'WrapCrossAlignment'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: [
        'ControlAffinity',
        'FormBuilderCheckboxGroup',
        'FormBuilderFieldOption',
        'OptionsOrientation'
      ],
    ),
  ]),
  'FormBuilderChoiceChip': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['MaterialTapTargetSize', 'VisualDensity'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: [
        'Axis',
        'EdgeInsets',
        'OutlinedBorder',
        'TextStyle',
        'VerticalDirection'
      ],
    ),
    ExpectedImport(
      'package:flutter/rendering.dart',
      shows: ['WrapAlignment', 'WrapCrossAlignment'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderChoiceChip', 'FormBuilderFieldOption'],
    ),
  ]),
  'FormBuilderDateRangePicker': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['Brightness', 'Locale', 'Radius', 'TextAlign', 'TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: [
        'DatePickerEntryMode',
        'DateTimeRange',
        'InputCounterWidgetBuilder'
      ],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets', 'StrutStyle', 'TextStyle'],
    ),
    ExpectedImport(
      'package:flutter/services.dart',
      shows: [
        'MaxLengthEnforcement',
        'TextCapitalization',
        'TextInputAction',
        'TextInputFormatter',
        'TextInputType'
      ],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['RouteSettings', 'TextEditingController', 'Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderDateRangePicker'],
    ),
    ExpectedImport(
      'package:intl/intl.dart',
      prefixes: [
        MapEntry('intl', ['DateFormat']),
      ],
    ),
  ]),
  'FormBuilderDateTimePicker': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['Brightness', 'Locale', 'Radius', 'TextAlign'],
      prefixes: [
        MapEntry('ui', ['TextDirection']),
      ],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: [
        'DatePickerEntryMode',
        'DatePickerMode',
        'Icons',
        'InputCounterWidgetBuilder',
        'SelectableDayPredicate',
        'TimeOfDay',
        'TimePickerEntryMode'
      ],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets', 'StrutStyle', 'TextStyle'],
    ),
    ExpectedImport(
      'package:flutter/services.dart',
      shows: [
        'MaxLengthEnforcement',
        'TextCapitalization',
        'TextInputAction',
        'TextInputFormatter',
        'TextInputType'
      ],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: [
        'Icon',
        'RouteSettings',
        'TextEditingController',
        'TransitionBuilder'
      ],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderDateTimePicker', 'InputType'],
    ),
    ExpectedImport(
      'package:intl/intl.dart',
      shows: ['DateFormat'],
    ),
  ]),
  'FormBuilderDropdown': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: [
        'DropdownButtonBuilder',
        'DropdownMenuItem',
        'Icons',
        'kMinInteractiveDimension'
      ],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['TextStyle'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Icon', 'Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderDropdown'],
    ),
  ]),
  'FormBuilderFilterChip': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['Clip', 'TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['MaterialTapTargetSize'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: [
        'Axis',
        'EdgeInsets',
        'OutlinedBorder',
        'TextStyle',
        'VerticalDirection'
      ],
    ),
    ExpectedImport(
      'package:flutter/rendering.dart',
      shows: ['WrapAlignment', 'WrapCrossAlignment'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderFieldOption', 'FormBuilderFilterChip'],
    ),
  ]),
  'FormBuilderRadioGroup': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['TextDirection'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['MaterialTapTargetSize'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['Axis', 'VerticalDirection'],
    ),
    ExpectedImport(
      'package:flutter/rendering.dart',
      shows: ['WrapAlignment', 'WrapCrossAlignment'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: [
        'ControlAffinity',
        'FormBuilderFieldOption',
        'FormBuilderRadioGroup',
        'OptionsOrientation'
      ],
    ),
  ]),
  'FormBuilderRangeSlider': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['RangeLabels', 'RangeValues', 'SemanticFormatterCallback'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['TextStyle'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['DisplayValues', 'FormBuilderRangeSlider'],
    ),
    ExpectedImport(
      'package:intl/intl.dart',
      shows: ['NumberFormat'],
    ),
  ]),
  'FormBuilderSegmentedControl': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsetsGeometry'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderFieldOption', 'FormBuilderSegmentedControl'],
    ),
  ]),
  'FormBuilderSlider': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['SemanticFormatterCallback'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['TextStyle'],
    ),
    ExpectedImport(
      'package:flutter/services.dart',
      shows: ['MouseCursor'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['DisplayValues', 'FormBuilderSlider'],
    ),
    ExpectedImport(
      'package:intl/intl.dart',
      shows: ['NumberFormat'],
    ),
  ]),
  'FormBuilderSwitch': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['ListTileControlAffinity'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets', 'ImageProvider'],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: ['Widget'],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderSwitch'],
    ),
  ]),
  'FormBuilderTextField': _merge([
    ..._builderCommonImports,
    ExpectedImport(
      'dart:ui',
      shows: ['Brightness', 'Radius', 'TextAlign', 'TextDirection'],
      prefixes: [
        MapEntry('ui', ['BoxHeightStyle', 'BoxWidthStyle']),
      ],
    ),
    ExpectedImport(
      'package:flutter/gestures.dart',
      shows: ['DragStartBehavior', 'GestureTapCallback'],
    ),
    ExpectedImport(
      'package:flutter/material.dart',
      shows: ['InputCounterWidgetBuilder'],
    ),
    ExpectedImport(
      'package:flutter/painting.dart',
      shows: ['EdgeInsets', 'StrutStyle', 'TextAlignVertical', 'TextStyle'],
    ),
    ExpectedImport(
      'package:flutter/services.dart',
      shows: [
        'MaxLengthEnforcement',
        'MouseCursor',
        'SmartDashesType',
        'SmartQuotesType',
        'TextCapitalization',
        'TextInputAction',
        'TextInputFormatter',
        'TextInputType',
      ],
    ),
    ExpectedImport(
      'package:flutter/widgets.dart',
      shows: [
        'ScrollController',
        'ScrollPhysics',
        'TextEditingController',
        'ToolbarOptions'
      ],
    ),
    ExpectedImport(
      'package:flutter_form_builder/flutter_form_builder.dart',
      shows: ['FormBuilderTextField'],
    ),
  ]),
};
