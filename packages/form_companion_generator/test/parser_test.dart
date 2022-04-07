// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/arguments_handler.dart';
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
    (await getResolvedLibraryResult('presenter.dart')).element,
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
      void Function(List<PropertyAndFormFieldDefinition>) propertiesAssertion, {
      void Function(List<String>)? warningsAssertion,
      required bool isFormBuilder,
    }) async {
      final targetClass = findType(name);
      final warnings = <String>[];
      final result = await getPropertiesAsync(
        nodeProvider,
        formFieldLocator,
        findConstructor(targetClass),
        warnings,
        logger,
        isFormBuilder: isFormBuilder,
      );

      if (warningsAssertion != null) {
        warningsAssertion(warnings);
      } else {
        expect(
          warnings.isEmpty,
          isTrue,
          reason: 'Some warnings are found: $warnings',
        );
      }

      propertiesAssertion(result);
    }

    // FutureOr<void> testGetPropertiesError<TElement>(
    //   String name, {
    //   required String message,
    //   required String todo,
    // }) =>
    //     _testGetPropertiesErrorCore<TElement>(name,
    //         message: message, todo: todo, withElement: true);
    // FutureOr<void> testGetPropertiesErrorWithoutElement(
    //   String name, {
    //   required String message,
    //   required String todo,
    // }) =>
    //     _testGetPropertiesErrorCore<Null>(name,
    //         message: message, todo: todo, withElement: false);

    FutureOr<void> testGetPropertiesError<TElement>(
      String name, {
      required String message,
      required String todo,
      // required bool withElement,
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
          isFormBuilder: true,
        );
        fail(
          'No error occurred. Properties: {${result.map((e) => '{name: ${e.name}, '
              'propertyType: ${e.propertyValueType}, '
              'fieldType: ${e.fieldValueType}, '
              'formFieldType: ${e.formFieldTypeName}, '
              'warnings: ${e.warnings}}').join(', ')}}',
        );
      }
      // ignore: avoid_catching_errors
      on InvalidGenerationSourceError catch (e, s) {
        printOnFailure(e.toString());
        printOnFailure(s.toString());
        expect(
          e.element,
          isA<TElement>(),
          reason: e.element.runtimeType.toString(),
        );
        // "at ..." in tail should not be verified.
        expect(e.message, startsWith(message));
        expect(e.todo, equals(todo));
      }
    }

    void testBasicProperties(
      List<PropertyAndFormFieldDefinition> props,
    ) {
      expect(props[0], isNotNull);
      expect(props[0].name, 'propInt');
      expect(props[0].propertyValueType.rawType, typeProvider.intType);
      expect(props[0].fieldValueType.rawType, typeProvider.stringType);
      expect(props[0].formFieldConstructors.length, 1);
      expect(props[0].formFieldConstructors.first.constructor.name, isNull);
      expect(props[0].formFieldType, isNotNull);
      expect(props[0].formFieldType!.toString(), 'FormBuilderTextField');
      expect(props[0].formFieldTypeName, 'FormBuilderTextField');
      expect(props[0].warnings, isEmpty);
      expect(props[0].instantiationContext, isNotNull);

      expect(props[1], isNotNull);
      expect(props[1].name, 'propString');
      expect(props[1].propertyValueType.rawType, typeProvider.stringType);
      expect(props[1].fieldValueType.rawType, typeProvider.stringType);
      expect(props[1].formFieldConstructors.length, 1);
      expect(props[1].formFieldConstructors.first.constructor.name, isNull);
      expect(props[1].formFieldType, isNotNull);
      expect(props[1].formFieldType!.toString(), 'FormBuilderTextField');
      expect(props[1].formFieldTypeName, 'FormBuilderTextField');
      expect(props[1].warnings, isEmpty);
      expect(props[1].instantiationContext, isNotNull);

      expect(props[2], isNotNull);
      expect(props[2].name, 'propBool');
      expect(props[2].propertyValueType.rawType, typeProvider.boolType);
      expect(props[2].fieldValueType.rawType, typeProvider.boolType);
      expect(props[2].formFieldConstructors.length, 1);
      expect(props[2].formFieldConstructors.first.constructor.name, isNull);
      expect(props[2].formFieldType, isNotNull);
      expect(props[2].formFieldType!.toString(), 'FormBuilderSwitch');
      expect(props[2].formFieldTypeName, 'FormBuilderSwitch');
      expect(props[2].warnings, isEmpty);
      expect(props[2].instantiationContext, isNotNull);

      expect(props[3], isNotNull);
      expect(props[3].name, 'propEnum');
      expect(props[3].propertyValueType.toString(), 'MyEnum');
      expect(props[3].fieldValueType.toString(), 'MyEnum');
      expect(props[3].formFieldConstructors.length, 1);
      expect(props[3].formFieldConstructors.first.constructor.name, isNull);
      expect(props[3].formFieldType, isNotNull);
      expect(props[3].formFieldType!.toString(), 'FormBuilderDropdown<T>');
      expect(props[3].formFieldTypeName, 'FormBuilderDropdown');
      expect(props[3].warnings, isEmpty);
      expect(props[3].instantiationContext, isNotNull);

      expect(props[4], isNotNull);
      expect(props[4].name, 'propEnumList');
      expect(props[4].propertyValueType.toString(), 'List<MyEnum>');
      expect(props[4].fieldValueType.toString(), 'List<MyEnum>');
      expect(props[4].formFieldConstructors.length, 1);
      expect(props[4].formFieldConstructors.first.constructor.name, isNull);
      expect(props[4].formFieldType, isNotNull);
      expect(props[4].formFieldType!.toString(), 'FormBuilderFilterChip<T>');
      expect(props[4].formFieldTypeName, 'FormBuilderFilterChip');
      expect(props[4].warnings, isEmpty);
      expect(props[4].instantiationContext, isNotNull);
    }

    void testExtraProperties(
      List<PropertyAndFormFieldDefinition> props,
    ) {
      expect(props[5], isNotNull);
      expect(props[5].name, 'extra');
      expect(props[5].propertyValueType.rawType, typeProvider.stringType);
      expect(props[5].fieldValueType.rawType, typeProvider.stringType);
      expect(props[5].formFieldConstructors.length, 1);
      expect(props[5].formFieldConstructors.first.constructor.name, isNull);
      expect(props[5].formFieldType, isNotNull);
      expect(props[5].formFieldType!.toString(), 'FormBuilderTextField');
      expect(props[5].formFieldTypeName, 'FormBuilderTextField');
      expect(props[5].warnings, isEmpty);
      expect(props[5].instantiationContext, isNotNull);
    }

    FutureOr<void> testGetPropertiesSuccess(String name) => testGetProperties(
          name,
          (props) {
            expect(props.length, 5);
            testBasicProperties(props);
          },
          isFormBuilder: true,
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
          isFormBuilder: true,
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
        () => testGetProperties(
          'ExtensionMethod',
          (props) {
            expect(props.length, 2);
            expect(props[0], isNotNull);
            expect(props[0].name, 'propDouble');
            expect(
              props[0].propertyValueType.maybeAsInterfaceType,
              typeProvider.doubleType,
            );
            expect(
              props[0].fieldValueType.maybeAsInterfaceType,
              typeProvider.doubleType,
            );
            expect(props[0].formFieldConstructors.length, 1);
            expect(
              props[0].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[0].formFieldType, isNotNull);
            expect(props[0].formFieldType!.toString(), 'FormBuilderSlider');
            expect(props[0].formFieldTypeName, 'FormBuilderSlider');
            expect(props[0].warnings, isEmpty);
            expect(props[0].instantiationContext, isNotNull);

            expect(props[1], isNotNull);
            expect(props[1].name, 'propEnumList');
            expect(
              props[1].propertyValueType.maybeAsInterfaceType,
              typeProvider.listType(myEnumType),
            );
            expect(
              props[1].fieldValueType.maybeAsInterfaceType,
              typeProvider.listType(myEnumType),
            );
            expect(props[1].formFieldConstructors.length, 1);
            expect(
              props[1].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[1].formFieldType, isNotNull);
            expect(
              props[1].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderCheckboxGroup<MyEnum>',
            );
            expect(
              props[1].formFieldTypeName,
              'FormBuilderCheckboxGroup',
            );
            expect(props[1].warnings, isEmpty);
            expect(props[1].instantiationContext, isNotNull);
          },
          isFormBuilder: true,
        ),
      );

      test(
        'convinient wrappers',
        () => testGetProperties(
          'ConvinientExtensionMethod',
          (props) {
            expect(props.length, 7);
            expect(props[0], isNotNull);
            expect(props[0].name, 'propInt');
            expect(
              props[0].propertyValueType.maybeAsInterfaceType,
              typeProvider.intType,
            );
            expect(
              props[0].fieldValueType.maybeAsInterfaceType,
              typeProvider.stringType,
            );
            expect(props[0].formFieldConstructors.length, 1);
            expect(
              props[0].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[0].formFieldType, isNotNull);
            expect(
              props[0].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderTextField',
            );
            expect(props[0].formFieldTypeName, 'FormBuilderTextField');
            expect(props[0].warnings, isEmpty);
            expect(props[0].instantiationContext, isNotNull);

            expect(props[1], isNotNull);
            expect(props[1].name, 'propString');
            expect(
              props[1].propertyValueType.maybeAsInterfaceType,
              typeProvider.stringType,
            );
            expect(
              props[1].fieldValueType.maybeAsInterfaceType,
              typeProvider.stringType,
            );
            expect(props[1].formFieldConstructors.length, 1);
            expect(
              props[1].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[1].formFieldType, isNotNull);
            expect(
              props[1].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderTextField',
            );
            expect(props[1].formFieldTypeName, 'FormBuilderTextField');
            expect(props[1].warnings, isEmpty);
            expect(props[1].instantiationContext, isNotNull);

            expect(props[2], isNotNull);
            expect(props[2].name, 'propBool');
            expect(
              props[2].propertyValueType.maybeAsInterfaceType,
              typeProvider.boolType,
            );
            expect(
              props[2].fieldValueType.maybeAsInterfaceType,
              typeProvider.boolType,
            );
            expect(props[2].formFieldConstructors.length, 1);
            expect(
              props[2].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[2].formFieldType, isNotNull);
            expect(
              props[2].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderSwitch',
            );
            expect(props[2].formFieldTypeName, 'FormBuilderSwitch');
            expect(props[2].warnings, isEmpty);
            expect(props[2].instantiationContext, isNotNull);

            expect(props[3], isNotNull);
            expect(props[3].name, 'propEnum');
            expect(props[3].propertyValueType.maybeAsInterfaceType, myEnumType);
            expect(props[3].fieldValueType.maybeAsInterfaceType, myEnumType);
            expect(props[3].formFieldConstructors.length, 1);
            expect(
              props[3].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[3].formFieldType, isNotNull);
            expect(
              props[3].formFieldType!.toString(),
              'FormBuilderDropdown<T>',
            );
            expect(props[3].formFieldTypeName, 'FormBuilderDropdown');
            expect(props[3].warnings, isEmpty);
            expect(props[3].instantiationContext, isNotNull);

            expect(props[4], isNotNull);
            expect(props[4].name, 'propEnumList');
            expect(
              props[4]
                  .propertyValueType
                  .getDisplayString(withNullability: true),
              typeProvider
                  .listType(myEnumType)
                  .getDisplayString(withNullability: true),
            );
            expect(
              props[4].fieldValueType.getDisplayString(withNullability: true),
              typeProvider
                  .listType(myEnumType)
                  .getDisplayString(withNullability: true),
            );
            expect(props[4].formFieldConstructors.length, 1);
            expect(
              props[4].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[4].formFieldType, isNotNull);
            expect(
              props[4].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderFilterChip<T>',
            );
            expect(props[4].formFieldTypeName, 'FormBuilderFilterChip');
            expect(props[4].warnings, isEmpty);
            expect(props[4].instantiationContext, isNotNull);

            expect(props[5], isNotNull);
            expect(props[5].name, 'propDouble');
            expect(
              props[5].propertyValueType.maybeAsInterfaceType,
              typeProvider.doubleType,
            );
            expect(
              props[5].fieldValueType.maybeAsInterfaceType,
              typeProvider.doubleType,
            );
            expect(props[5].formFieldConstructors.length, 1);
            expect(
              props[5].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[5].formFieldType, isNotNull);
            expect(
              props[5].formFieldType!.getDisplayString(withNullability: true),
              'FormBuilderSlider',
            );
            expect(props[5].formFieldTypeName, 'FormBuilderSlider');
            expect(props[5].warnings, isEmpty);
            expect(props[5].instantiationContext, isNotNull);

            expect(props[6], isNotNull);
            expect(props[6].name, 'propEnumList2');
            expect(
              props[6]
                  .propertyValueType
                  .getDisplayString(withNullability: true),
              typeProvider
                  .listType(myEnumType)
                  .getDisplayString(withNullability: true),
            );
            expect(
              props[6].fieldValueType.getDisplayString(withNullability: true),
              typeProvider
                  .listType(myEnumType)
                  .getDisplayString(withNullability: true),
            );
            expect(props[6].formFieldConstructors.length, 1);
            expect(
              props[6].formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props[6].formFieldType, isNotNull);
            // Generic type is resolved when it is specified via type argument.
            expect(
              props[6].formFieldType!.toString(),
              'FormBuilderCheckboxGroup<MyEnum>',
            );
            expect(props[6].formFieldTypeName, 'FormBuilderCheckboxGroup');
            expect(props[6].warnings, isEmpty);
            expect(props[6].instantiationContext, isNotNull);
          },
          isFormBuilder: true,
        ),
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
            testBasicProperties(props);
            testExtraProperties(props);
          },
          isFormBuilder: true,
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
            testBasicProperties(props);
            testExtraProperties(props);
          },
          isFormBuilder: true,
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
            expect(props.length, 1);
            expect(props.single.name, 'prop2');
          },
          warningsAssertion: (warnings) {
            expect(
              warnings,
              [
                "initializeCompanionMixin(PropertyDescriptorsBuilder) is called multiply in constructor of class 'MultipleInitializeCompanionMixin', so last one is used.",
              ],
            );
          },
          isFormBuilder: true,
        ),
      );

      test(
        'with dynamic name - error',
        () => testGetPropertiesError<ConstructorElement>(
          'DynamicPropertyName',
          message:
              "Failed to parse non-literal 'name' argument from expression '..add<int, String>(name: 'prop\${Platform.numberOfProcessors}')'.",
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

    group('inferrance error -- default FormField is used and warnings', () {
      const fieldValueWarning =
          '`Object` is used for field value type because type parameter `F` '
          'is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `F` explicitly.';
      const propertyValueWarning =
          '`Object` is used for property value type because type parameter `P` '
          'is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `P` explicitly.';

      const fieldEnumValueWarning =
          '`Enum` is used for field value type because type parameter `F` '
          'is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `F` explicitly.';
      const propertyEnumValueWarning =
          '`Enum` is used for property value type because type parameter `P` '
          'is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `P` explicitly.';
      const fieldEnumListValueWarning =
          '`List<Enum>` is used for field value type because type parameter '
          '`F` is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `F` explicitly.';
      const propertyEnumListValueWarning =
          '`List<Enum>` is used for property value type because type parameter '
          '`P` is not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `P` explicitly.';

      const preferredFormFieldWarningBase =
          'is used for FormField type because type parameter `TField` is '
          'not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `TField` explicitly.';

      const defaultFormFieldWarningBase =
          'is used for FormField type because type parameter `F` is '
          'not specified and it cannot be inferred with parameters. '
          'Ensure specify type argument `F` explicitly.';
      const defaultFormFieldWarningVanilla =
          '`FormField<Object>` $defaultFormFieldWarningBase';
      const defaultFormFieldWarningBuilder =
          '`FormBuilderField<Object>` $defaultFormFieldWarningBase';

      FutureOr<void> testRawType(
        String presenterName,
        String propertyValueType,
        String fieldValueType,
        String formFieldTypeName,
        List<String> warnings, {
        required bool isFormBuilder,
      }) {
        final anglePosition = formFieldTypeName.indexOf('<');
        final formFieldRawTypeName =
            formFieldTypeName.substring(0, anglePosition);
        return testGetProperties(
          presenterName,
          (props) {
            expect(props.length, 1, reason: props.toString());
            expect(props.single, isNotNull);
            expect(props.single.name, 'propRaw');
            expect(
              props.single.propertyValueType
                  .getDisplayString(withNullability: true),
              propertyValueType,
            );
            expect(
              props.single.fieldValueType
                  .getDisplayString(withNullability: true),
              fieldValueType,
            );
            expect(props.single.formFieldConstructors.length, 1);
            expect(
              props.single.formFieldConstructors.first.constructor.name,
              isNull,
            );
            expect(props.single.formFieldType, isNotNull);
            expect(props.single.formFieldType!.toString(), formFieldTypeName);
            expect(props.single.formFieldTypeName, formFieldRawTypeName);
            expect(props.single.warnings, warnings);
            expect(props.single.instantiationContext, isNotNull);
          },
          isFormBuilder: isFormBuilder,
        );
      }

      group('Vanilla Form', () {
        for (final testCase in [
          Tuple5(
            '', // intentionally empty
            'Object',
            'Object',
            'FormField<T>',
            [
              propertyValueWarning,
              fieldValueWarning,
              defaultFormFieldWarningVanilla
            ],
          ),
          Tuple5(
            'WithField',
            'Object',
            'Object',
            'FormField<Object>',
            [
              propertyValueWarning,
              fieldValueWarning,
              '`FormField<Object>` $preferredFormFieldWarningBase'
            ],
          ),
          Tuple5(
            'BigIntWithField',
            'BigInt',
            'BigInt',
            'FormField<BigInt>',
            ['`FormField<BigInt>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'BoolWithField',
            'bool',
            'bool',
            'FormField<bool>',
            ['`FormField<bool>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'DoubleWithField',
            'double',
            'double',
            'FormField<double>',
            ['`FormField<double>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'EnumWithField',
            'Enum',
            'Enum',
            'FormField<Enum>',
            [
              propertyEnumValueWarning,
              fieldEnumValueWarning,
              '`FormField<Enum>` $preferredFormFieldWarningBase'
            ],
          ),
          Tuple5(
            'IntWithField',
            'int',
            'int',
            'FormField<int>',
            ['`FormField<int>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'StringWithField',
            'Object',
            'String',
            'FormField<String>',
            [
              propertyValueWarning,
              '`FormField<String>` $preferredFormFieldWarningBase'
            ],
          ),
        ]) {
          test(
            'add${testCase.item1}',
            () => testRawType(
              'RawAdd${testCase.item1}Vanilla',
              testCase.item2,
              testCase.item3,
              testCase.item4,
              testCase.item5,
              isFormBuilder: false,
            ),
          );
        }
      });

      group('FormBuilder', () {
        for (final testCase in [
          Tuple5(
            '',
            'Object',
            'Object',
            'FormBuilderField<T>',
            [
              propertyValueWarning,
              fieldValueWarning,
              defaultFormFieldWarningBuilder
            ],
          ), // item1 is intentionally empty
          Tuple5(
            'WithField',
            'Object',
            'Object',
            'FormField<Object>',
            [
              propertyValueWarning,
              fieldValueWarning,
              '`FormField<Object>` $preferredFormFieldWarningBase'
            ],
          ),
          Tuple5(
            'BigIntWithField',
            'BigInt',
            'BigInt',
            'FormField<BigInt>',
            ['`FormField<BigInt>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'BoolListWithField',
            'List<bool>',
            'List<bool>',
            'FormField<List<bool>>',
            ['`FormField<List<bool>>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'BoolWithField',
            'bool',
            'bool',
            'FormField<bool>',
            ['`FormField<bool>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'DoubleWithField',
            'double',
            'double',
            'FormField<double>',
            ['`FormField<double>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'EnumListWithField',
            'List<Enum>',
            'List<Enum>',
            'FormField<List<Enum>>',
            [
              propertyEnumListValueWarning,
              fieldEnumListValueWarning,
              '`FormField<List<Enum>>` $preferredFormFieldWarningBase'
            ],
          ),
          Tuple5(
            'EnumWithField',
            'Enum',
            'Enum',
            'FormField<Enum>',
            [
              propertyEnumValueWarning,
              fieldEnumValueWarning,
              '`FormField<Enum>` $preferredFormFieldWarningBase'
            ],
          ),
          Tuple5(
            'IntWithField',
            'int',
            'int',
            'FormField<int>',
            ['`FormField<int>` $preferredFormFieldWarningBase'],
          ),
          Tuple5(
            'StringWithField',
            'Object',
            'String',
            'FormField<String>',
            [
              propertyValueWarning,
              '`FormField<String>` $preferredFormFieldWarningBase'
            ],
          ),
        ]) {
          test(
            'add${testCase.item1}',
            () => testRawType(
              'RawAdd${testCase.item1}FormBuilder',
              testCase.item2,
              testCase.item3,
              testCase.item4,
              testCase.item5,
              isFormBuilder: true,
            ),
          );
        }
      });
    });

    test(
      'type inferrence is available',
      () => testGetProperties(
        'InferredTypes',
        (props) {
          expect(props.length, 5);
          expect(props[0], isNotNull);
          expect(props[0].name, 'addWithValueConverter');
          expect(props[0].propertyValueType.rawType, typeProvider.intType);
          expect(props[0].fieldValueType.rawType, typeProvider.stringType);
          expect(props[0].formFieldConstructors.length, 1);
          expect(props[0].formFieldConstructors.first.constructor.name, isNull);
          expect(props[0].formFieldType, isNotNull);
          expect(props[0].formFieldType!.toString(), 'FormBuilderTextField');
          expect(props[0].formFieldTypeName, 'FormBuilderTextField');
          expect(props[0].warnings, isEmpty);
          expect(props[0].instantiationContext, isNotNull);

          expect(props[1], isNotNull);
          expect(props[1].name, 'addStringWithStringConverter');
          expect(
            props[1].propertyValueType.getDisplayString(withNullability: true),
            'BigInt',
          );
          expect(props[1].fieldValueType.rawType, typeProvider.stringType);
          expect(props[1].formFieldConstructors.length, 1);
          expect(props[1].formFieldConstructors.first.constructor.name, isNull);
          expect(props[1].formFieldType, isNotNull);
          expect(props[1].formFieldType!.toString(), 'FormBuilderTextField');
          expect(props[1].formFieldTypeName, 'FormBuilderTextField');
          expect(props[1].warnings, isEmpty);
          expect(props[1].instantiationContext, isNotNull);

          expect(props[2], isNotNull);
          expect(props[2].name, 'addStringWithInitialValue');
          expect(props[2].propertyValueType.rawType, typeProvider.doubleType);
          expect(props[2].fieldValueType.rawType, typeProvider.stringType);
          expect(props[2].formFieldConstructors.length, 1);
          expect(props[2].formFieldConstructors.first.constructor.name, isNull);
          expect(props[2].formFieldType, isNotNull);
          expect(props[2].formFieldType!.toString(), 'FormBuilderTextField');
          expect(props[2].formFieldTypeName, 'FormBuilderTextField');
          expect(props[2].warnings, isEmpty);
          expect(props[2].instantiationContext, isNotNull);

          expect(props[3], isNotNull);
          expect(props[3].name, 'addEnumWithInitialValue');
          expect(props[3].propertyValueType.rawType, myEnumType);
          expect(props[3].fieldValueType.rawType, myEnumType);
          expect(props[3].formFieldConstructors.length, 1);
          expect(props[3].formFieldConstructors.first.constructor.name, isNull);
          expect(props[3].formFieldType, isNotNull);
          expect(props[3].formFieldType!.toString(), 'FormBuilderDropdown<T>');
          expect(props[3].formFieldTypeName, 'FormBuilderDropdown');
          expect(props[3].warnings, isEmpty);
          expect(props[3].instantiationContext, isNotNull);

          expect(props[4], isNotNull);
          expect(props[4].name, 'addEnumListWithInitialValue');
          expect(
            props[4].propertyValueType.getDisplayString(withNullability: true),
            typeProvider
                .listType(myEnumType)
                .getDisplayString(withNullability: true),
          );
          expect(
            props[4].fieldValueType.getDisplayString(withNullability: true),
            typeProvider
                .listType(myEnumType)
                .getDisplayString(withNullability: true),
          );
          expect(props[4].formFieldConstructors.length, 1);
          expect(props[4].formFieldConstructors.first.constructor.name, isNull);
          expect(props[4].formFieldType, isNotNull);
          expect(
            props[4].formFieldType!.toString(),
            'FormBuilderFilterChip<T>',
          );
          expect(props[4].formFieldTypeName, 'FormBuilderFilterChip');
          expect(props[4].warnings, isEmpty);
          expect(props[4].instantiationContext, isNotNull);
        },
        isFormBuilder: true,
      ),
    );
  });

  group('collectDependencies', () {
    FutureOr<PropertyAndFormFieldDefinition> makeProperty(
      String formFieldTypeName,
      InterfaceType valueType, {
      required bool isFormBuilder,
    }) async {
      final formFieldType = formFieldLocator.resolveFormFieldType(
        formFieldTypeName,
      )!;

      final property = PropertyDefinition(
        name: 'prop',
        fieldType: GenericType.fromDartType(valueType),
        propertyType: GenericType.fromDartType(valueType),
        preferredFormFieldType: GenericType.generic(
          formFieldType,
          formFieldType.typeArguments.any((t) => t is TypeParameterType)
              ? [GenericType.fromDartType(valueType)]
              : [],
        ),
        warnings: [],
      );

      final formFieldConstructor =
          await nodeProvider.getElementDeclarationAsync<ConstructorDeclaration>(
        formFieldType.element.unnamedConstructor!,
      );

      return PropertyAndFormFieldDefinition(
        property: property,
        formFieldType: formFieldType,
        formFieldTypeName: formFieldTypeName,
        formFieldConstructors: [
          FormFieldConstructorDefinition(
            formFieldConstructor,
            await ArgumentsHandler.createAsync(
              formFieldConstructor,
              nodeProvider,
              isFormBuilder: isFormBuilder,
            ),
          ),
        ],
        instantiationContext: null, // This is OK
      );
    }

    void assertImports(
      List<LibraryImport> result,
      List<ExpectedImport> expected,
    ) {
      result.sort((l, r) => l.library.compareTo(r.library));
      expected.sort((l, r) => l.identifier.compareTo(r.identifier));
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
        ExpectedImport('dart:ui', shows: ['Color', 'Locale']),
      ),
      Tuple2(
        'alias',
        ExpectedImport('dart:ui', shows: ['Locale', 'VoidCallback']),
      ),
      Tuple2(
        'prefixed',
        ExpectedImport(
          'dart:ui',
          shows: ['Locale'],
          prefixes: [
            MapEntry('ui', ['VoidCallback']),
          ],
        ),
      ),
      Tuple2(
        'function',
        ExpectedImport(
          'dart:ui',
          shows: ['Color', 'Locale'],
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
          fieldType: GenericType.fromDartType(typeProvider.stringType),
          propertyType: GenericType.fromDartType(typeProvider.stringType),
          preferredFormFieldType: null,
          warnings: [],
        );

        final formFieldConstructor = await nodeProvider
            .getElementDeclarationAsync<ConstructorDeclaration>(
          dependencyHolder.constructors.singleWhere((c) => c.name == kind),
        );

        final propertyAndField = PropertyAndFormFieldDefinition(
          property: property,
          formFieldType: null, // This is OK
          formFieldTypeName: '', // This is OK
          formFieldConstructors: [
            FormFieldConstructorDefinition(
              formFieldConstructor,
              await ArgumentsHandler.createAsync(
                formFieldConstructor,
                nodeProvider,
                isFormBuilder: false,
              ),
            ),
          ],
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
                shows: ['BuildContext', 'Localizations']),
            ExpectedImport('parameters.dart'),
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
        [
          await makeProperty(
            fieldName,
            valueType,
            isFormBuilder: isFormBuilder,
          ),
        ],
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
            'enum.dart',
            shows: ['MyEnum'],
          ),
        );
      }

      expected.add(ExpectedImport('presenter.dart'));

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

    test('relative imports should be after packages', () async {});
  });

  // TODO(yfakariya): field related tests.

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
    shows: ['Color', 'Locale', 'VoidCallback'],
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
      'Localizations',
    ],
  ),
];

const _builderCommonImports = [
  ExpectedImport(
    'dart:ui',
    shows: ['Color', 'Locale', 'VoidCallback'],
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
      'Localizations',
    ],
  ),
  ExpectedImport(
    'package:flutter_form_builder/flutter_form_builder.dart',
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
