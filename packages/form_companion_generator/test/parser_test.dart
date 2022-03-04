// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/parser.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

// TODO(yfakariya): preferredFieldType support.

Future<void> main() async {
  final presenterLibrary = LibraryReader(
    (await getElement('presenter.dart')).element,
  );
  final logger = Logger('test');
  Logger.root.level = Level.FINEST;
  logger.onRecord.listen(print);

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
      void Function(Map<String, PropertyDefinition>) propertiesAssertion, {
      void Function(List<String>)? warningsAssertion,
    }) async {
      final targetClass = findType(name);
      final warnings = <String>[];
      final result = await getPropertiesAsync(
        presenterLibrary,
        findConstructor(targetClass),
        warnings,
        logger,
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
          presenterLibrary,
          findConstructor(targetClass),
          warnings,
          logger,
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

    FutureOr<void> testGetPropertiesSuccess(String name) => testGetProperties(
          name,
          (props) {
            expect(props.length, equals(5));
            expect(props['propInt'], isNotNull);
            expect(props['propInt']!.isEnum, isFalse);
            expect(props['propInt']!.name, equals('propInt'));
            expect(props['propInt']!.preferredFieldType, isNull);
            expect(props['propInt']!.type, equals('int'));
            expect(props['propInt']!.warnings, isEmpty);
            expect(props['propString'], isNotNull);
            expect(props['propString']!.isEnum, isFalse);
            expect(props['propString']!.name, equals('propString'));
            expect(props['propString']!.preferredFieldType, isNull);
            expect(props['propString']!.type, equals('String'));
            expect(props['propString']!.warnings, isEmpty);
            expect(props['propBool'], isNotNull);
            expect(props['propBool']!.isEnum, isFalse);
            expect(props['propBool']!.name, equals('propBool'));
            expect(props['propBool']!.preferredFieldType, isNull);
            expect(props['propBool']!.type, equals('bool'));
            expect(props['propBool']!.warnings, isEmpty);
            expect(props['propEnum'], isNotNull);
            expect(props['propEnum']!.isEnum, isTrue);
            expect(props['propEnum']!.name, equals('propEnum'));
            expect(props['propEnum']!.preferredFieldType, isNull);
            expect(props['propEnum']!.type, equals('MyEnum'));
            expect(props['propEnum']!.warnings, isEmpty);
            expect(props['propRaw'], isNotNull);
            expect(props['propRaw']!.isEnum, isFalse);
            expect(props['propRaw']!.name, equals('propRaw'));
            expect(props['propRaw']!.preferredFieldType, isNull);
            expect(props['propRaw']!.type, equals('Object'));
            expect(props['propRaw']!.warnings, isEmpty);
          },
        );

    FutureOr<void> testGetPropertiesNoProperties(String name) =>
        testGetProperties(
          'InlineWithNoAddition',
          (props) => expect(props, isEmpty),
          warningsAssertion: (warnings) {
            expect(warnings.length, equals(1));
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
            expect(props.length, equals(6));
            expect(props['propInt'], isNotNull);
            expect(props['propInt']!.isEnum, isFalse);
            expect(props['propInt']!.name, equals('propInt'));
            expect(props['propInt']!.preferredFieldType, isNull);
            expect(props['propInt']!.type, equals('int'));
            expect(props['propInt']!.warnings, isEmpty);
            expect(props['propString'], isNotNull);
            expect(props['propString']!.isEnum, isFalse);
            expect(props['propString']!.name, equals('propString'));
            expect(props['propString']!.preferredFieldType, isNull);
            expect(props['propString']!.type, equals('String'));
            expect(props['propString']!.warnings, isEmpty);
            expect(props['propBool'], isNotNull);
            expect(props['propBool']!.isEnum, isFalse);
            expect(props['propBool']!.name, equals('propBool'));
            expect(props['propBool']!.preferredFieldType, isNull);
            expect(props['propBool']!.type, equals('bool'));
            expect(props['propBool']!.warnings, isEmpty);
            expect(props['propEnum'], isNotNull);
            expect(props['propEnum']!.isEnum, isTrue);
            expect(props['propEnum']!.name, equals('propEnum'));
            expect(props['propEnum']!.preferredFieldType, isNull);
            expect(props['propEnum']!.type, equals('MyEnum'));
            expect(props['propEnum']!.warnings, isEmpty);
            expect(props['propRaw'], isNotNull);
            expect(props['propRaw']!.isEnum, isFalse);
            expect(props['propRaw']!.name, equals('propRaw'));
            expect(props['propRaw']!.preferredFieldType, isNull);
            expect(props['propRaw']!.type, equals('Object'));
            expect(props['propRaw']!.warnings, isEmpty);
            expect(props['extra'], isNotNull);
            expect(props['extra']!.isEnum, isFalse);
            expect(props['extra']!.name, equals('extra'));
            expect(props['extra']!.preferredFieldType, isNull);
            expect(props['extra']!.type, equals('String'));
            expect(props['extra']!.warnings, isEmpty);
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
            expect(props.length, equals(6));
            expect(props['propInt'], isNotNull);
            expect(props['propInt']!.isEnum, isFalse);
            expect(props['propInt']!.name, equals('propInt'));
            expect(props['propInt']!.preferredFieldType, isNull);
            expect(props['propInt']!.type, equals('int'));
            expect(props['propInt']!.warnings, isEmpty);
            expect(props['propString'], isNotNull);
            expect(props['propString']!.isEnum, isFalse);
            expect(props['propString']!.name, equals('propString'));
            expect(props['propString']!.preferredFieldType, isNull);
            expect(props['propString']!.type, equals('String'));
            expect(props['propString']!.warnings, isEmpty);
            expect(props['propBool'], isNotNull);
            expect(props['propBool']!.isEnum, isFalse);
            expect(props['propBool']!.name, equals('propBool'));
            expect(props['propBool']!.preferredFieldType, isNull);
            expect(props['propBool']!.type, equals('bool'));
            expect(props['propBool']!.warnings, isEmpty);
            expect(props['propEnum'], isNotNull);
            expect(props['propEnum']!.isEnum, isTrue);
            expect(props['propEnum']!.name, equals('propEnum'));
            expect(props['propEnum']!.preferredFieldType, isNull);
            expect(props['propEnum']!.type, equals('MyEnum'));
            expect(props['propEnum']!.warnings, isEmpty);
            expect(props['propRaw'], isNotNull);
            expect(props['propRaw']!.isEnum, isFalse);
            expect(props['propRaw']!.name, equals('propRaw'));
            expect(props['propRaw']!.preferredFieldType, isNull);
            expect(props['propRaw']!.type, equals('Object'));
            expect(props['propRaw']!.warnings, isEmpty);
            expect(props['extra'], isNotNull);
            expect(props['extra']!.isEnum, isFalse);
            expect(props['extra']!.name, equals('extra'));
            expect(props['extra']!.preferredFieldType, isNull);
            expect(props['extra']!.type, equals('String'));
            expect(props['extra']!.warnings, isEmpty);
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
        'multiple initializeCompanionMixin invocation - last one is adapted and warning',
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

  // TODO(yfakariya): parseElement (integrated)
}
