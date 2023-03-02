// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/form_field_locator.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser.dart';
import 'package:form_companion_generator/src/parser/parser_data.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'session_resolver.dart';
import 'test_helpers.dart';

Config get _emptyConfig => Config(<String, dynamic>{});

class FailureFormFieldLocator implements FormFieldLocator {
  const FailureFormFieldLocator();

  @override
  InterfaceType? resolveFormFieldType(String typeName) => null;
}

Future<void> main() async {
  final logger = Logger('parser_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  final library = await getFormFieldsLibrary();
  final resolver = SessionResolver(library);
  final nodeProvider = NodeProvider(SessionResolver(library));
  final typeProvider = library.typeProvider;
  final formFieldLocator =
      await FormFieldLocator.createAsync(resolver, [], logger);

  final interfaceTypes = {
    'bool': typeProvider.boolType,
    'DateTime': await getDateTimeType(),
    'DateTimeRange': await getDateTimeRangeType(),
    'RangeValues': await getRangeValuesType(),
    'MyEnum': await getMyEnumType(),
    'String': typeProvider.stringType,
    'Object': typeProvider.objectType,
  };
  final formBuilderCheckbox = library.lookupClass('FormBuilderCheckbox');
  final parametersLibrary = await getParametersLibrary();

  Future<void> testResolveMultiConstructorsFormFieldAsync(
    InterfaceType propertyType,
    InterfaceType fieldType,
    GenericType? preferredFormFieldType,
    String expectedFormFieldTypeName, {
    required bool isFormBuilder,
    required bool shouldBeContructorFound,
    void Function(Object)? errorAssertion,
    void Function(List<FormFieldConstructorDefinition>)? constructorsAssertion,
  }) async {
    final input = PropertyDefinition(
      name: 'prop',
      propertyType: toGenericType(propertyType),
      fieldType: toGenericType(fieldType),
      preferredFormFieldType: preferredFormFieldType,
      warnings: [],
    );

    late final PropertyAndFormFieldDefinition result;
    try {
      result = await resolveFormFieldAsync(
        ParseContext(
          library.languageVersion,
          _emptyConfig,
          logger,
          nodeProvider,
          formFieldLocator,
          typeProvider,
          library.typeSystem,
          [],
          isFormBuilder: isFormBuilder,
        ),
        input,
        isFormBuilder: isFormBuilder,
      );

      if (errorAssertion != null) {
        fail('Error is not occurred.');
      }
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      // ignore: invariant_booleans
      if (errorAssertion == null) {
        rethrow;
      }

      errorAssertion(e);
      return;
    }

    expect(result.name, input.name);
    expect(result.fieldValueType, same(input.fieldType));
    expect(result.propertyValueType, same(input.propertyType));
    expect(result.warnings, same(input.warnings));
    if (input.preferredFormFieldType != null) {
      expect(
        result.formFieldType,
        same(
          input.preferredFormFieldType!.maybeAsInterfaceType,
        ),
      );
    } else {
      expect(result.formFieldType, isNotNull);
      // getDisplayString() may contain <T>, so we use startsWith here.
      expect(
        result.formFieldType!.getDisplayString(withNullability: true),
        startsWith(expectedFormFieldTypeName),
      );
    }
    expect(result.formFieldTypeName, expectedFormFieldTypeName);

    if (shouldBeContructorFound) {
      expect(result.formFieldConstructors, isNotEmpty);
      constructorsAssertion?.call(result.formFieldConstructors);
    } else {
      expect(result.formFieldConstructors, isEmpty);
    }
  }

  Future<void> testResolveFormFieldAsync(
    InterfaceType propertyType,
    InterfaceType fieldType,
    GenericType? preferredFormFieldType,
    String expectedFormFieldTypeName, {
    required bool isFormBuilder,
    required bool shouldBeContructorFound,
    void Function(Object)? errorAssertion,
    void Function(ConstructorDeclaration)? constructorAssertion,
  }) =>
      testResolveMultiConstructorsFormFieldAsync(
        propertyType,
        fieldType,
        preferredFormFieldType,
        expectedFormFieldTypeName,
        isFormBuilder: isFormBuilder,
        shouldBeContructorFound: shouldBeContructorFound,
        errorAssertion: errorAssertion,
        constructorsAssertion: (c) {
          expect(c.length, 1);
          constructorAssertion?.call(c[0].constructor);
        },
      );

  for (final spec in [
    // isFormBuilder, typeMap
    Tuple2(false, vanillaTypeMap),
    Tuple2(true, formBuilderTypeMap),
  ]) {
    group(spec.item1 ? 'form builder' : 'vanilla form', () {
      for (final type in spec.item2.keys) {
        test(
          type,
          () => testResolveFormFieldAsync(
            interfaceTypes[type]!,
            interfaceTypes[type]!,
            null,
            spec.item2[type]!,
            isFormBuilder: spec.item1,
            shouldBeContructorFound: true,
            constructorAssertion: (c) {
              expect(c.declaredElement, isNotNull);
              expect(c.declaredElement!.name, isEmpty);
            },
          ),
        );
      }
    });
  }

  group('special cases', () {
    test(
      'preferred field type is reflected, non generic',
      () => testResolveFormFieldAsync(
        typeProvider.boolType,
        typeProvider.boolType,
        toGenericType(formBuilderCheckbox.thisType),
        'FormBuilderCheckbox',
        isFormBuilder: true,
        shouldBeContructorFound: true,
      ),
    );

    test(
      'preferred field type is reflected, generic',
      () => testResolveFormFieldAsync(
        typeProvider.stringType,
        typeProvider.stringType,
        GenericType.fromDartType(
          library.lookupTypeFromTopLevelVariable(
            'dropdownButtonFormFieldOfString',
          ),
          library,
        ),
        'DropdownButtonFormField',
        isFormBuilder: false,
        shouldBeContructorFound: true,
      ),
    );
    test(
      'property and field type mismatch is allowed',
      () => testResolveFormFieldAsync(
        typeProvider.intType,
        typeProvider.stringType,
        null,
        'TextFormField',
        isFormBuilder: false,
        shouldBeContructorFound: true,
      ),
    );
  });

  group('errors', () {
    test(
      'failed to resolve form field type',
      () async {
        const isFormBuilder = false;
        final context = ParseContext(
          library.languageVersion,
          _emptyConfig,
          logger,
          nodeProvider,
          const FailureFormFieldLocator(),
          typeProvider,
          library.typeSystem,
          [],
          isFormBuilder: isFormBuilder,
        );

        final property = PropertyDefinition(
          name: 'prop',
          propertyType: toGenericType(typeProvider.stringType),
          fieldType: toGenericType(typeProvider.stringType),
          preferredFormFieldType: null,
          warnings: [],
        );

        final result = await resolveFormFieldAsync(
          context,
          property,
          isFormBuilder: isFormBuilder,
        );

        expect(result.formFieldType, isNull);
        expect(result.formFieldTypeName, 'TextFormField');
        expect(result.formFieldConstructors, isEmpty);
      },
    );
  });

  group('multile constructors', () {
    /// [constructorSpecs] contains nullable constructor names and the value
    /// which indicates whether the constructor is factory or not.
    Future<void> testMultipleConstructors(
      String formFieldClassName,
      List<Tuple2<String?, bool>> constructorSpecs,
    ) {
      final formFieldClass =
          lookupExportedClass(parametersLibrary, formFieldClassName);
      return testResolveMultiConstructorsFormFieldAsync(
        typeProvider.stringType,
        typeProvider.stringType,
        toGenericType(formFieldClass.thisType),
        formFieldClass.thisType.getDisplayString(withNullability: false),
        isFormBuilder: false,
        shouldBeContructorFound: true,
        constructorsAssertion: (c) {
          expect(
            c.every((e) => e.constructor.declaredElement!.isPublic),
            isTrue,
            reason: c
                .map(
                  (e) => '${e.constructor.name} -> '
                      'isPublic: ${e.constructor.declaredElement?.isPublic}',
                )
                .join('\n'),
          );
          expect(
            c.map((e) => e.constructor.name?.toString()),
            constructorSpecs.map((e) => e.item1),
            reason: c.map((e) => e.constructor.name).join('\n'),
          );
          expect(
            c.map((e) => e.constructor.declaredElement!.isFactory),
            constructorSpecs.map((e) => e.item2),
            reason: c
                .map(
                  (e) => '${e.constructor.name} -> '
                      'isFactory: ${e.constructor.declaredElement?.isFactory}',
                )
                .join('\n'),
          );
        },
      );
    }

    test(
      'only anonymous factory',
      () async => testMultipleConstructors(
        'OnlyAnonymousFactory',
        [Tuple2(null, true)],
      ),
    );

    test(
      'only named constructor',
      () async => testMultipleConstructors(
        'OnlyNamedConstructor',
        [Tuple2('generative', false)],
      ),
    );

    test(
      'only named factory',
      () async => testMultipleConstructors(
        'OnlyNamedFactory',
        [Tuple2('factory', true)],
      ),
    );

    test(
      'constructor with named constructor and named factory',
      () async => testMultipleConstructors(
        'ConstructorWithNamedConstructors',
        [
          Tuple2(null, false),
          Tuple2('generative', false),
          Tuple2('factory', true)
        ],
      ),
    );

    test(
      'factory with named constructor and named factory',
      () async => testMultipleConstructors(
        'FactoryWithNamedConstructors',
        [
          Tuple2(null, true),
          Tuple2('generative', false),
          Tuple2('factory', true)
        ],
      ),
    );

    test(
      'constructor with multiple named constructor and named factory',
      () async => testMultipleConstructors(
        'ConstructorWithMultipleNamedConstructors',
        [
          Tuple2(null, false),
          Tuple2('generative1', false),
          Tuple2('generative2', false),
          Tuple2('factory1', true),
          Tuple2('factory2', true),
        ],
      ),
    );
  });
}

final formBuilderTypeMap = {
  'bool': 'FormBuilderSwitch',
  'DateTime': 'FormBuilderDateTimePicker',
  'DateTimeRange': 'FormBuilderDateRangePicker',
  'RangeValues': 'FormBuilderRangeSlider',
  'MyEnum': 'FormBuilderDropdown',
  'String': 'FormBuilderTextField',
  'Object': 'FormBuilderField',
};

final vanillaTypeMap = {
  'bool': 'DropdownButtonFormField',
  'MyEnum': 'DropdownButtonFormField',
  'String': 'TextFormField',
  'Object': 'FormField',
};
