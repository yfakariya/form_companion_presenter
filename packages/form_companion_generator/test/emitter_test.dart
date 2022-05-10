// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/arguments_handler.dart';
import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/dependency.dart';
import 'package:form_companion_generator/src/emitter.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser.dart';
import 'package:form_companion_generator/src/type_instantiation.dart';
import 'package:form_companion_generator/src/utilities.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'session_resolver.dart';
import 'test_helpers.dart';

/// 1. Name of property.
/// 2. Value type of property.
/// 3. Value type of form field.
/// 4. Form field class element resolved by preceding processes.
/// 5. Form field type specified with addWithField.
/// 6. Warnings emitted by preceding processes.
typedef PropertyDefinitionSpec = Tuple6<String, InterfaceType, InterfaceType,
    ClassElement?, GenericType?, List<String>>;

typedef FactoryParameterSpec = Tuple2<String, String>;
typedef NamedFactorySpec = Tuple3<String?, String, List<FactoryParameterSpec>>;

Config get _emptyConfig => Config(<String, dynamic>{});

Future<void> main() async {
  final logger = Logger('emitter_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  final library = await getFormFieldsLibrary();
  final nodeProvider = NodeProvider(SessionResolver(library.library));
  final myEnumType = await getMyEnumType();
  final dateTimeType = await getDateTimeType();
  final dateTimeRangeType = await getDateTimeRangeType();
  final rangeValuesType = await getRangeValuesType();

  final nullableBoolType = await getNullableBoolType();
  final nullableMyEnumType = await getNullableMyEnumType();
  final nullableStringType = await getNullableStringType();
  final nullableListOfStringType = await getNullableListOfStringType();
  final nullableListOfNullableStringType =
      await getNullableListOfNullableStringType();

  final textFormField = library.lookupClass('TextFormField');
  final dropdownButtonFormField =
      library.lookupClass('DropdownButtonFormField');
  final formBuilderCheckbox =
      await lookupFormBuilderClass('FormBuilderCheckbox');
  final formBuilderCheckboxGroup =
      await lookupFormBuilderClass('FormBuilderCheckboxGroup');
  final formBuilderChoiceChip =
      await lookupFormBuilderClass('FormBuilderChoiceChip');
  final formBuilderDateRangePicker =
      await lookupFormBuilderClass('FormBuilderDateRangePicker');
  final formBuilderDateTimePicker =
      await lookupFormBuilderClass('FormBuilderDateTimePicker');
  final formBuilderDropdown =
      await lookupFormBuilderClass('FormBuilderDropdown');
  final formBuilderFilterChip =
      await lookupFormBuilderClass('FormBuilderFilterChip');
  final formBuilderRadioGroup =
      await lookupFormBuilderClass('FormBuilderRadioGroup');
  final formBuilderRangeSlider =
      await lookupFormBuilderClass('FormBuilderRangeSlider');
  final formBuilderSegmentedControl =
      await lookupFormBuilderClass('FormBuilderSegmentedControl');
  final formBuilderSlider = await lookupFormBuilderClass('FormBuilderSlider');
  final formBuilderSwitch = await lookupFormBuilderClass('FormBuilderSwitch');
  final formBuilderTextField =
      await lookupFormBuilderClass('FormBuilderTextField');
  final formFieldWithPropertyParameter =
      library.getType('FormFieldWithPropertyParameter')!;

  final parametersLibrary = await getParametersLibrary();

  final defaultConfig = await readDefaultOptions();

  FutureOr<List<PropertyAndFormFieldDefinition>> makePropertiesFully(
    Iterable<PropertyDefinitionSpec> specs, {
    required bool isFormBuilder,
  }) async =>
      await specs.map((spec) async {
        final name = spec.item1;
        final propertyValueType = spec.item2;
        final fieldValueType = spec.item3;
        final formFieldClass = spec.item4;
        final preferredFormFieldType = spec.item5;
        final warnings = spec.item6;

        final property = PropertyDefinition(
          name: name,
          propertyType: toGenericType(propertyValueType),
          fieldType: toGenericType(fieldValueType),
          preferredFormFieldType: preferredFormFieldType,
          warnings: warnings,
        );

        return PropertyAndFormFieldDefinition(
          property: property,
          formFieldTypeName: preferredFormFieldType?.toString() ??
              formFieldClass?.name ??
              '<UNRESOLVED>', // This value is actually 'TextFormField' or 'FormBuilderTextField'.
          formFieldConstructors: formFieldClass == null
              ? []
              : await formFieldClass.constructors
                  .where((e) => e.isPublic)
                  .map(
                    (e) async => await nodeProvider
                        .getElementDeclarationAsync<ConstructorDeclaration>(e),
                  )
                  .map(
                  (e) async {
                    final constructor = await e;
                    return FormFieldConstructorDefinition(
                      constructor,
                      await ArgumentsHandler.createAsync(
                        constructor,
                        property,
                        nodeProvider,
                        defaultConfig,
                        isFormBuilder: isFormBuilder,
                      ),
                    );
                  },
                ).toListAsync(),
          formFieldType: formFieldClass?.thisType,
          instantiationContext: formFieldClass == null
              ? null
              : TypeInstantiationContext.create(
                  property,
                  formFieldClass.thisType,
                  logger,
                ),
        );
      }).toListAsync();

  FutureOr<List<PropertyAndFormFieldDefinition>> makeProperties(
    Iterable<Tuple4<String, InterfaceType, InterfaceType, ClassElement>>
        specs, {
    required bool isFormBuilder,
  }) =>
      makePropertiesFully(
        specs.map(
          (e) => PropertyDefinitionSpec(
            e.item1,
            e.item2,
            e.item3,
            e.item4,
            null,
            [],
          ),
        ),
        isFormBuilder: isFormBuilder,
      );

  FutureOr<List<PropertyAndFormFieldDefinition>> makeProperty(
    String name,
    InterfaceType propertyValueType,
    InterfaceType fieldValueType,
    ClassElement formField, {
    required bool isFormBuilder,
  }) =>
      makeProperties(
        [Tuple4(name, propertyValueType, fieldValueType, formField)],
        isFormBuilder: isFormBuilder,
      );

  group('emitPropertyAccessor', () {
    test('1 property of String', () async {
      final properties = await makeProperty(
        'prop',
        library.typeProvider.stringType,
        library.typeProvider.stringType,
        textFormField,
        isFormBuilder: false,
      );
      final data = PresenterDefinition(
        name: 'Test01',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: false,
        ),
        properties: properties,
      );
      expect(
        emitPropertyAccessor(data.name, data.properties, _emptyConfig),
        typedProperties('Test01', [Tuple3('prop', 'String', 'String')]),
      );
    });

    test('2 properties of String and int', () async {
      final properties = await makeProperties(
        [
          Tuple4(
            'prop1',
            library.typeProvider.stringType,
            library.typeProvider.stringType,
            textFormField,
          ),
          Tuple4(
            'prop2',
            library.typeProvider.intType,
            library.typeProvider.stringType,
            textFormField,
          ),
        ],
        isFormBuilder: false,
      );
      final data = PresenterDefinition(
        name: 'Test02',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: false,
        ),
        properties: properties,
      );
      expect(
        emitPropertyAccessor(data.name, data.properties, _emptyConfig),
        typedProperties(
          'Test02',
          [
            Tuple3('prop1', 'String', 'String'),
            Tuple3('prop2', 'int', 'String'),
          ],
        ),
      );
    });

    test('1 property of List<Enum>', () async {
      final properties = await makeProperty(
        'prop',
        library.typeProvider.listType(myEnumType),
        library.typeProvider.listType(myEnumType),
        dropdownButtonFormField,
        isFormBuilder: false,
      );
      final data = PresenterDefinition(
        name: 'Test01',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: false,
        ),
        properties: properties,
      );
      expect(
        emitPropertyAccessor(data.name, data.properties, _emptyConfig),
        typedProperties(
          'Test01',
          [Tuple3('prop', 'List<MyEnum>', 'List<MyEnum>')],
        ),
      );
    });
  });

  group('emitGlobal', () {
    group('warnings', () {
      test('no warnings -- empty', () async {
        final properties = await makeProperty(
          'prop1',
          library.typeProvider.stringType,
          library.typeProvider.stringType,
          textFormField,
          isFormBuilder: false,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: false,
          doAutovalidate: false,
          warnings: [],
          imports: [],
          properties: properties,
        );
        expect(
          emitGlobal(library, data, _emptyConfig),
          [
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            '',
          ],
        );
      });

      test('1 warning -- 1 line', () async {
        final properties = await makeProperty(
          'prop1',
          library.typeProvider.stringType,
          library.typeProvider.stringType,
          textFormField,
          isFormBuilder: false,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: false,
          doAutovalidate: false,
          warnings: ['AAA'],
          imports: [],
          properties: properties,
        );

        expect(
          emitGlobal(library, data, _emptyConfig),
          [
            '// TODO(CompanionGenerator): WARNING - AAA',
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            '',
          ],
        );
      });

      test('2 warnings -- 2 line', () async {
        final properties = await makeProperty(
          'prop1',
          library.typeProvider.stringType,
          library.typeProvider.stringType,
          textFormField,
          isFormBuilder: false,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: false,
          doAutovalidate: false,
          warnings: ['AAA', 'BBB'],
          imports: [],
          properties: properties,
        );

        expect(
          emitGlobal(library, data, _emptyConfig),
          [
            '// TODO(CompanionGenerator): WARNING - AAA',
            '// TODO(CompanionGenerator): WARNING - BBB',
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            '',
          ],
        );
      });
    });

    group('imports', () {
      test('imports - vanilla', () async {
        final properties = await makeProperty(
          'prop1',
          library.typeProvider.stringType,
          library.typeProvider.stringType,
          textFormField,
          isFormBuilder: false,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: false,
          doAutovalidate: false,
          warnings: [],
          imports: await collectDependenciesAsync(
            library,
            properties,
            nodeProvider,
            logger,
            isFormBuilder: false,
          ),
          properties: properties,
        );
        final lines = emitGlobal(library, data, _emptyConfig).toList();
        expect(
          lines,
          [
            "import 'dart:ui' show Brightness, Color, Locale, Radius, TextAlign, TextDirection, VoidCallback;",
            '',
            "import 'package:flutter/foundation.dart' show ValueChanged;",
            "import 'package:flutter/gestures.dart' show GestureTapCallback;",
            "import 'package:flutter/material.dart' show InputCounterWidgetBuilder, InputDecoration, TextFormField;",
            "import 'package:flutter/painting.dart' show EdgeInsets, StrutStyle, TextAlignVertical, TextStyle;",
            "import 'package:flutter/services.dart' show MaxLengthEnforcement, MouseCursor, SmartDashesType, SmartQuotesType, TextCapitalization, TextInputAction, TextInputFormatter, TextInputType;",
            "import 'package:flutter/widgets.dart' show AutovalidateMode, BuildContext, FocusNode, Localizations, ScrollController, ScrollPhysics, TextEditingController, TextSelectionControls, ToolbarOptions;",
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            '',
            "import 'form_fields.dart';"
          ],
        );
      });

      test('imports - form builder', () async {
        final properties = await makeProperty(
          'prop1',
          dateTimeType,
          dateTimeType,
          formBuilderDateTimePicker,
          isFormBuilder: true,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: true,
          doAutovalidate: false,
          warnings: [],
          imports: await collectDependenciesAsync(
            library,
            properties,
            nodeProvider,
            logger,
            isFormBuilder: true,
          ),
          properties: properties,
        );
        final lines = emitGlobal(library, data, _emptyConfig).toList();
        expect(
          lines,
          [
            "import 'dart:ui' show Brightness, Color, Locale, Radius, TextAlign, VoidCallback;",
            "import 'dart:ui' as ui show TextDirection;",
            '',
            "import 'package:flutter/foundation.dart' show Key, ValueChanged;",
            "import 'package:flutter/material.dart' show DatePickerEntryMode, DatePickerMode, Icons, InputCounterWidgetBuilder, InputDecoration, SelectableDayPredicate, TimeOfDay, TimePickerEntryMode;",
            "import 'package:flutter/painting.dart' show EdgeInsets, StrutStyle, TextStyle;",
            "import 'package:flutter/services.dart' show MaxLengthEnforcement, TextCapitalization, TextInputAction, TextInputFormatter, TextInputType;",
            "import 'package:flutter/widgets.dart' show AutovalidateMode, BuildContext, FocusNode, Icon, Localizations, RouteSettings, TextEditingController, TransitionBuilder;",
            "import 'package:flutter_form_builder/flutter_form_builder.dart' show FormBuilderDateTimePicker, InputType, ValueTransformer;",
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            "import 'package:intl/intl.dart' show DateFormat;",
            '',
            "import 'form_fields.dart';"
          ],
        );
      });
    });

    group('warnings and imports mix', () {
      test('imports - builder', () async {
        final properties = await makeProperty(
          'prop1',
          dateTimeType,
          dateTimeType,
          formBuilderDateTimePicker,
          isFormBuilder: true,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: true,
          doAutovalidate: false,
          warnings: ['AAA', 'BBB'],
          imports: await collectDependenciesAsync(
            library,
            properties,
            nodeProvider,
            logger,
            isFormBuilder: true,
          ),
          properties: properties,
        );
        final lines = emitGlobal(library, data, _emptyConfig).toList();
        expect(
          lines,
          [
            '// TODO(CompanionGenerator): WARNING - AAA',
            '// TODO(CompanionGenerator): WARNING - BBB',
            '',
            "import 'dart:ui' show Brightness, Color, Locale, Radius, TextAlign, VoidCallback;",
            "import 'dart:ui' as ui show TextDirection;",
            '',
            "import 'package:flutter/foundation.dart' show Key, ValueChanged;",
            "import 'package:flutter/material.dart' show DatePickerEntryMode, DatePickerMode, Icons, InputCounterWidgetBuilder, InputDecoration, SelectableDayPredicate, TimeOfDay, TimePickerEntryMode;",
            "import 'package:flutter/painting.dart' show EdgeInsets, StrutStyle, TextStyle;",
            "import 'package:flutter/services.dart' show MaxLengthEnforcement, TextCapitalization, TextInputAction, TextInputFormatter, TextInputType;",
            "import 'package:flutter/widgets.dart' show AutovalidateMode, BuildContext, FocusNode, Icon, Localizations, RouteSettings, TextEditingController, TransitionBuilder;",
            "import 'package:flutter_form_builder/flutter_form_builder.dart' show FormBuilderDateTimePicker, InputType, ValueTransformer;",
            "import 'package:form_companion_presenter/form_companion_presenter.dart';",
            "import 'package:intl/intl.dart' show DateFormat;",
            '',
            "import 'form_fields.dart';"
          ],
        );
      });

      test('asPart = true -- a comment for it and commneted out imports',
          () async {
        final properties = await makeProperty(
          'prop1',
          dateTimeType,
          dateTimeType,
          formBuilderDateTimePicker,
          isFormBuilder: true,
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: true,
          doAutovalidate: false,
          warnings: ['AAA', 'BBB'],
          imports: await collectDependenciesAsync(
            library,
            properties,
            nodeProvider,
            logger,
            isFormBuilder: true,
          ),
          properties: properties,
        );
        final lines = emitGlobal(
          library,
          data,
          Config(<String, dynamic>{Config.asPartKey: true}),
        ).toList();
        expect(
          lines,
          [
            '// TODO(CompanionGenerator): WARNING - AAA',
            '// TODO(CompanionGenerator): WARNING - BBB',
            '',
            "// This file is part of '${library.source.shortName}' file,",
            '// so you have to declare following import directives in it.',
            '',
            "// import 'dart:ui' show Brightness, Color, Locale, Radius, TextAlign, VoidCallback;",
            "// import 'dart:ui' as ui show TextDirection;",
            '',
            "// import 'package:flutter/foundation.dart' show Key, ValueChanged;",
            "// import 'package:flutter/material.dart' show DatePickerEntryMode, DatePickerMode, Icons, InputCounterWidgetBuilder, InputDecoration, SelectableDayPredicate, TimeOfDay, TimePickerEntryMode;",
            "// import 'package:flutter/painting.dart' show EdgeInsets, StrutStyle, TextStyle;",
            "// import 'package:flutter/services.dart' show MaxLengthEnforcement, TextCapitalization, TextInputAction, TextInputFormatter, TextInputType;",
            "// import 'package:flutter/widgets.dart' show AutovalidateMode, BuildContext, FocusNode, Icon, Localizations, RouteSettings, TextEditingController, TransitionBuilder;",
            "// import 'package:flutter_form_builder/flutter_form_builder.dart' show FormBuilderDateTimePicker, InputType, ValueTransformer;",
            "// import 'package:form_companion_presenter/form_companion_presenter.dart';",
            "// import 'package:intl/intl.dart' show DateFormat;",
            '',
            "// import 'form_fields.dart';"
          ],
        );
      });
    });
  });

  group('emitFieldFactories', () {
    test('1 property of String, vanilla, no warnings', () async {
      final properties = await makeProperty(
        'prop',
        library.typeProvider.stringType,
        library.typeProvider.stringType,
        textFormField,
        isFormBuilder: false,
      );
      final data = PresenterDefinition(
        name: 'Test01',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: false,
        ),
        properties: properties,
      );
      await expectLater(
        await emitFieldFactoriesAsync(nodeProvider, data, _emptyConfig),
        fieldFactories('Test01', [textFormFieldFactory('prop')]),
      );
    });

    test('2 properties of String and enum', () async {
      final properties = await makeProperties(
        [
          Tuple4(
            'prop1',
            library.typeProvider.stringType,
            library.typeProvider.stringType,
            textFormField,
          ),
          Tuple4(
            'prop2',
            library.typeProvider.boolType,
            library.typeProvider.boolType,
            dropdownButtonFormField,
          ),
        ],
        isFormBuilder: false,
      );
      final data = PresenterDefinition(
        name: 'Test02',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: false,
        ),
        properties: properties,
      );
      await expectLater(
        await emitFieldFactoriesAsync(nodeProvider, data, _emptyConfig),
        fieldFactories(
          'Test02',
          [
            textFormFieldFactory('prop1'),
            dropdownButtonFieldFactory('prop2', 'bool'),
          ],
        ),
      );
    });

    group('multiple constructors', () {
      /// [construtorAndDescriptionAndKeyParameterNames] contains
      /// expected constructor name,
      /// description suffix (with leading space and without trailing period),
      /// and parameter spec(type and name)s.
      Future<void> testMultipleConstructors(
        String formFieldClassName,
        List<Tuple3<String?, String, String>>
            construtorAndDescriptionAndKeyParameterNames,
      ) async {
        final formFieldClass =
            lookupExportedClass(parametersLibrary, formFieldClassName);
        const propertyName = 'prop';
        const isFormBuilder = false;
        final hasNamedConstructors =
            construtorAndDescriptionAndKeyParameterNames
                .any((e) => e.item1?.isNotEmpty ?? false);
        final expectedConstructorNameAndParameters =
            construtorAndDescriptionAndKeyParameterNames
                .map(
                  (e) => NamedFactorySpec(
                    e.item1,
                    e.item2,
                    [
                      FactoryParameterSpec(
                          'InputDecoration?', 'inputDecoration'),
                      FactoryParameterSpec('String?', e.item3),
                    ],
                  ),
                )
                .toList();

        final property = PropertyDefinition(
          name: propertyName,
          propertyType:
              toGenericType(parametersLibrary.typeProvider.stringType),
          fieldType: toGenericType(parametersLibrary.typeProvider.stringType),
          preferredFormFieldType: toGenericType(formFieldClass.thisType),
          warnings: [],
        );
        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: isFormBuilder,
          doAutovalidate: false,
          warnings: [],
          imports: [],
          properties: [
            PropertyAndFormFieldDefinition(
              property: property,
              formFieldType: formFieldClass.thisType,
              formFieldTypeName: formFieldClass.name,
              formFieldConstructors: await formFieldClass.constructors
                  .where((e) => e.isPublic)
                  .map(
                    (e) async => await nodeProvider
                        .getElementDeclarationAsync<ConstructorDeclaration>(e),
                  )
                  .map(
                (e) async {
                  final constructor = await e;
                  return FormFieldConstructorDefinition(
                    constructor,
                    await ArgumentsHandler.createAsync(
                      constructor,
                      property,
                      nodeProvider,
                      defaultConfig,
                      isFormBuilder: isFormBuilder,
                    ),
                  );
                },
              ).toListAsync(),
              instantiationContext: TypeInstantiationContext.create(
                property,
                formFieldClass.thisType,
                logger,
              ),
            )
          ],
        );

        String fieldFactory(NamedFactorySpec spec,
            {required bool hasNamedConstructors}) {
          final methodName = spec.item1 ??
              (hasNamedConstructors ? 'withDefaultConstructor' : propertyName);
          final construtorName = spec.item1 == null
              ? formFieldClass.thisType.getDisplayString(withNullability: false)
              : '${formFieldClass.thisType.getDisplayString(withNullability: false)}.${spec.item1}';
          return '''
  /// Gets a [FormField] for `$propertyName` property${spec.item2}.
  ${formFieldClass.thisType.getDisplayString(withNullability: true)} $methodName(
    BuildContext context, {
${spec.item3.map((p) => '    ${p.item1} ${p.item2}').join(',\n')},
  }) {
    final property = _presenter.$propertyName;
    return $construtorName(
${spec.item3.map((p) => '      ${p.item2}: ${p.item2}').join(',\n')},
    );
  }''';
        }

        await expectLater(
          await emitFieldFactoriesAsync(nodeProvider, data, _emptyConfig),
          (expectedConstructorNameAndParameters.length == 1 &&
                  expectedConstructorNameAndParameters[0].item1 == null)
              ? fieldFactories(
                  'Test',
                  expectedConstructorNameAndParameters
                      .map((e) => fieldFactory(e,
                          hasNamedConstructors: hasNamedConstructors))
                      .toList(),
                )
              : multiFieldFactories(
                  'Test',
                  [propertyName],
                  {
                    propertyName: expectedConstructorNameAndParameters
                        .map((e) => fieldFactory(e,
                            hasNamedConstructors: hasNamedConstructors))
                        .toList()
                  },
                ),
        );
      }

      test(
        'only anonymous factory',
        () async => testMultipleConstructors(
          'OnlyAnonymousFactory',
          [Tuple3(null, '', 'factoryParameter')],
        ),
      );

      test(
        'only named constructor',
        () async => testMultipleConstructors(
          'OnlyNamedConstructor',
          [
            Tuple3(
              'generative',
              ' with [OnlyNamedConstructor.generative] constructor',
              'namedConstructorParameter',
            )
          ],
        ),
      );

      test(
        'only named factory',
        () async => testMultipleConstructors(
          'OnlyNamedFactory',
          [
            Tuple3(
              'factory',
              ' with [OnlyNamedFactory.factory] constructor',
              'namedFactoryParameter',
            )
          ],
        ),
      );

      test(
        'constructor with named constructor and named factory',
        () async => testMultipleConstructors(
          'ConstructorWithNamedConstructors',
          [
            Tuple3(
              null,
              ' with [ConstructorWithNamedConstructors.new] constructor',
              'constructorParameter',
            ),
            Tuple3(
              'generative',
              ' with [ConstructorWithNamedConstructors.generative] constructor',
              'namedConstructorParameter',
            ),
            Tuple3(
              'factory',
              ' with [ConstructorWithNamedConstructors.factory] constructor',
              'namedFactoryParameter',
            )
          ],
        ),
      );

      test(
        'factory with named constructor and named factory',
        () async => testMultipleConstructors(
          'FactoryWithNamedConstructors',
          [
            Tuple3(
              null,
              ' with [FactoryWithNamedConstructors.new] constructor',
              'factoryParameter',
            ),
            Tuple3(
              'generative',
              ' with [FactoryWithNamedConstructors.generative] constructor',
              'namedConstructorParameter',
            ),
            Tuple3(
              'factory',
              ' with [FactoryWithNamedConstructors.factory] constructor',
              'namedFactoryParameter',
            )
          ],
        ),
      );

      test(
        'constructor with multiple named constructor and named factory',
        () async => testMultipleConstructors(
          'ConstructorWithMultipleNamedConstructors',
          [
            Tuple3(
              null,
              ' with [ConstructorWithMultipleNamedConstructors.new] constructor',
              'constructorParameter',
            ),
            Tuple3(
              'generative1',
              ' with [ConstructorWithMultipleNamedConstructors.generative1] constructor',
              'namedConstructorParameter1',
            ),
            Tuple3(
              'generative2',
              ' with [ConstructorWithMultipleNamedConstructors.generative2] constructor',
              'namedConstructorParameter2',
            ),
            Tuple3(
              'factory1',
              ' with [ConstructorWithMultipleNamedConstructors.factory1] constructor',
              'namedFactoryParameter1',
            ),
            Tuple3(
              'factory2',
              ' with [ConstructorWithMultipleNamedConstructors.factory2] constructor',
              'namedFactoryParameter2',
            ),
          ],
        ),
      );
    });

    test(
      'mixed constructors',
      () async {
        const isFormBuilder = false;
        final constructorWithNamedConstructorsClass = lookupExportedClass(
            parametersLibrary, 'ConstructorWithNamedConstructors');
        final factoryWithNamedConstructorsClass = lookupExportedClass(
            parametersLibrary, 'FactoryWithNamedConstructors');

        final data = PresenterDefinition(
          name: 'Test',
          isFormBuilder: isFormBuilder,
          doAutovalidate: false,
          warnings: [],
          imports: [],
          properties: await makePropertiesFully(
            [
              PropertyDefinitionSpec(
                'prop1',
                library.typeProvider.stringType,
                library.typeProvider.stringType,
                textFormField,
                null,
                [],
              ),
              PropertyDefinitionSpec(
                'p',
                library.typeProvider.stringType,
                library.typeProvider.stringType,
                constructorWithNamedConstructorsClass,
                toGenericType(constructorWithNamedConstructorsClass.thisType),
                [],
              ),
              PropertyDefinitionSpec(
                'prop3',
                library.typeProvider.boolType,
                library.typeProvider.boolType,
                dropdownButtonFormField,
                null,
                [],
              ),
              PropertyDefinitionSpec(
                'p4',
                library.typeProvider.stringType,
                library.typeProvider.stringType,
                factoryWithNamedConstructorsClass,
                toGenericType(factoryWithNamedConstructorsClass.thisType),
                [],
              ),
            ],
            isFormBuilder: isFormBuilder,
          ),
        );

        await expectLater(
          await emitFieldFactoriesAsync(nodeProvider, data, _emptyConfig),
          '''
/// Defines [FormField] factory methods for properties of [Test].
class \$TestFieldFactory {
  final Test _presenter;

  /// Gets a [FormField] factory for `p` property.
  final \$\$TestPFieldFactory p;

  /// Gets a [FormField] factory for `p4` property.
  final \$\$TestP4FieldFactory p4;

  \$TestFieldFactory._(Test presenter) :
    _presenter = presenter,
    p = \$\$TestPFieldFactory(presenter),
    p4 = \$\$TestP4FieldFactory(presenter);

${textFormFieldFactory('prop1')}

${dropdownButtonFieldFactory('prop3', 'bool')}
}

/// A [FormField] factory for `p` property of [Test].
class \$\$TestPFieldFactory {
  final Test _presenter;

  \$\$TestPFieldFactory._(this._presenter);

  /// Gets a [FormField] for `p` property with [ConstructorWithNamedConstructors.new] constructor.
  ConstructorWithNamedConstructors withDefaultConstructor(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? constructorParameter,
  }) {
    final property = _presenter.p;
    return ConstructorWithNamedConstructors(
      inputDecoration: inputDecoration,
      constructorParameter: constructorParameter,
    );
  }

  /// Gets a [FormField] for `p` property with [ConstructorWithNamedConstructors.generative] constructor.
  ConstructorWithNamedConstructors generative(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? namedConstructorParameter,
  }) {
    final property = _presenter.p;
    return ConstructorWithNamedConstructors.generative(
      inputDecoration: inputDecoration,
      namedConstructorParameter: namedConstructorParameter,
    );
  }

  /// Gets a [FormField] for `p` property with [ConstructorWithNamedConstructors.factory] constructor.
  ConstructorWithNamedConstructors factory(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? namedFactoryParameter,
  }) {
    final property = _presenter.p;
    return ConstructorWithNamedConstructors.factory(
      inputDecoration: inputDecoration,
      namedFactoryParameter: namedFactoryParameter,
    );
  }
}

/// A [FormField] factory for `p4` property of [Test].
class \$\$TestP4FieldFactory {
  final Test _presenter;

  \$\$TestP4FieldFactory._(this._presenter);

  /// Gets a [FormField] for `p4` property with [FactoryWithNamedConstructors.new] constructor.
  FactoryWithNamedConstructors withDefaultConstructor(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? factoryParameter,
  }) {
    final property = _presenter.p4;
    return FactoryWithNamedConstructors(
      inputDecoration: inputDecoration,
      factoryParameter: factoryParameter,
    );
  }

  /// Gets a [FormField] for `p4` property with [FactoryWithNamedConstructors.generative] constructor.
  FactoryWithNamedConstructors generative(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? namedConstructorParameter,
  }) {
    final property = _presenter.p4;
    return FactoryWithNamedConstructors.generative(
      inputDecoration: inputDecoration,
      namedConstructorParameter: namedConstructorParameter,
    );
  }

  /// Gets a [FormField] for `p4` property with [FactoryWithNamedConstructors.factory] constructor.
  FactoryWithNamedConstructors factory(
    BuildContext context, {
    InputDecoration? inputDecoration,
    String? namedFactoryParameter,
  }) {
    final property = _presenter.p4;
    return FactoryWithNamedConstructors.factory(
      inputDecoration: inputDecoration,
      namedFactoryParameter: namedFactoryParameter,
    );
  }
}

/// Defines an extension property to get [\$TestFieldFactory] from [Test].
extension \$TestFieldFactoryExtension on Test {
  /// Gets a [FormField] factory.
  \$TestFieldFactory get fields => \$TestFieldFactory._(this);
}
''',
        );
      },
    );
  });

  group('emitFieldFactory', () {
    FutureOr<void> testEmitFieldFactory({
      required bool isFormBuilder,
      required InterfaceType propertyValueType,
      required InterfaceType fieldValueType,
      required ClassElement? formFieldClass,
      GenericType? preferredFieldType,
      bool doAutovalidate = false,
      List<String>? warnings,
      required String expectedBody,
    }) async {
      final realWarnings = warnings ?? [];
      final properties = await makePropertiesFully(
        [
          PropertyDefinitionSpec(
            'prop',
            propertyValueType,
            fieldValueType,
            formFieldClass,
            preferredFieldType,
            realWarnings,
          )
        ],
        isFormBuilder: isFormBuilder,
      );
      final data = PresenterDefinition(
        name: 'Test',
        isFormBuilder: isFormBuilder,
        doAutovalidate: doAutovalidate,
        warnings: [],
        imports: await collectDependenciesAsync(
          library,
          properties,
          nodeProvider,
          logger,
          isFormBuilder: isFormBuilder,
        ),
        properties: properties,
      );

      final lines = emitFieldFactory(
        nodeProvider,
        data,
        properties.first,
      ).toList();

      expect(lines.isNotEmpty, isTrue);

      final warningLines = lines.take(realWarnings.length).toList();
      final body =
          (realWarnings.isEmpty ? lines : lines.skip(realWarnings.length + 1))
              .join('\n');

      expect(warningLines.length, realWarnings.length);
      for (final i in List.generate(realWarnings.length, (i) => i)) {
        expect(
          warningLines[i],
          '  // TODO(CompanionGenerator): WARNING - ${realWarnings[i]}',
          reason: 'warnings[$i]',
        );
      }

      expect(body, expectedBody);
    }

    group('vanilla form', () {
      for (final warnings in [
        <String>[],
        ['AAA'],
        ['AAA', 'BBB']
      ]) {
        test(
          'String with ${warnings.length} warnings',
          () => testEmitFieldFactory(
            isFormBuilder: false,
            propertyValueType: library.typeProvider.stringType,
            fieldValueType: library.typeProvider.stringType,
            formFieldClass: textFormField,
            warnings: warnings,
            expectedBody: textFormFieldFactory('prop'),
          ),
        );
      }

      for (final isEnum in [false, true]) {
        final typeName = isEnum ? 'MyEnum' : 'bool';
        final type = isEnum ? myEnumType : library.typeProvider.boolType;
        test(
          isEnum ? 'enum' : 'bool',
          () => testEmitFieldFactory(
            isFormBuilder: false,
            propertyValueType: type,
            fieldValueType: type,
            formFieldClass: dropdownButtonFormField,
            expectedBody: dropdownButtonFieldFactory('prop', typeName),
          ),
        );
      }

      test(
        'String with known preferredFieldType -- preferredFieldType is used',
        () => testEmitFieldFactory(
          isFormBuilder: false,
          propertyValueType: library.typeProvider.stringType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: dropdownButtonFormField,
          preferredFieldType: GenericType.generic(
            dropdownButtonFormField.thisType,
            [toGenericType(library.typeProvider.stringType)],
            dropdownButtonFormField,
          ),
          expectedBody: dropdownButtonFieldFactory(
            'prop',
            'String',
            withItemsTemplateError: true,
          ),
        ),
      );

      test(
        'bool with known preferredFieldType -- preferredFieldType is used',
        () => testEmitFieldFactory(
          isFormBuilder: false,
          propertyValueType: library.typeProvider.intType,
          fieldValueType: library.typeProvider.intType,
          formFieldClass: dropdownButtonFormField,
          preferredFieldType: GenericType.generic(
            dropdownButtonFormField.thisType,
            [toGenericType(library.typeProvider.intType)],
            dropdownButtonFormField,
          ),
          expectedBody: dropdownButtonFieldFactory(
            'prop',
            'int',
            withItemsTemplateError: true,
          ),
        ),
      );

      test(
        'Unknown preferredFieldType -- error',
        () => testEmitFieldFactory(
          isFormBuilder: false,
          propertyValueType: library.typeProvider.stringType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: null,
          preferredFieldType: toGenericType(library.typeProvider.objectType),
          expectedBody:
              "  // TODO(CompanionGenerator): ERROR - Cannot generate field factory for 'prop' property, because FormField type 'Object' is unknown.",
        ),
      );

      for (final value in [true, false]) {
        test(
          'doAutovalidate ($value) is respected',
          () => testEmitFieldFactory(
            isFormBuilder: false,
            propertyValueType: library.typeProvider.stringType,
            fieldValueType: library.typeProvider.stringType,
            formFieldClass: textFormField,
            doAutovalidate: value,
            expectedBody: textFormFieldFactory('prop', isAutovalidate: value),
          ),
        );
      }
    });

    group('form builder', () {
      for (final warnings in [
        <String>[],
        ['AAA'],
        ['AAA', 'BBB']
      ]) {
        test(
          'String with ${warnings.length} warnings',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: library.typeProvider.stringType,
            fieldValueType: library.typeProvider.stringType,
            formFieldClass: formBuilderTextField,
            warnings: warnings,
            expectedBody: formBuilderTextFieldFactory('prop'),
          ),
        );
      }

      test(
        'enum',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: myEnumType,
          fieldValueType: myEnumType,
          formFieldClass: formBuilderDropdown,
          expectedBody: formBuilderDropdownFactory('prop', 'MyEnum'),
        ),
      );

      test(
        'bool',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: library.typeProvider.boolType,
          fieldValueType: library.typeProvider.boolType,
          formFieldClass: formBuilderSwitch,
          expectedBody: formBuilderSwitchFactory('prop'),
        ),
      );

      test(
        'DateTime',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: dateTimeType,
          fieldValueType: dateTimeType,
          formFieldClass: formBuilderDateTimePicker,
          expectedBody: formBuilderDateTimePickerFactory('prop'),
        ),
      );

      test(
        'DateTimeRange',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: dateTimeRangeType,
          fieldValueType: dateTimeRangeType,
          formFieldClass: formBuilderDateRangePicker,
          expectedBody: formBuilderDateRangePickerFactory('prop'),
        ),
      );

      test(
        'RangeValue',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: rangeValuesType,
          fieldValueType: rangeValuesType,
          formFieldClass: formBuilderRangeSlider,
          expectedBody: formBuilderRangeSliderFactory('prop'),
        ),
      );

      test(
        'String with known preferredFieldType -- preferredFieldType is used',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: library.typeProvider.stringType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: formBuilderDropdown,
          preferredFieldType: GenericType.generic(
            formBuilderDropdown.thisType,
            [toGenericType(library.typeProvider.stringType)],
            formBuilderDropdown,
          ),
          expectedBody: formBuilderDropdownFactory(
            'prop',
            'String',
            withItemsTemplateError: true,
          ),
        ),
      );

      test(
        'bool with known preferredFieldType -- preferredFieldType is used',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: library.typeProvider.boolType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: formBuilderTextField,
          preferredFieldType: toGenericType(formBuilderTextField.thisType),
          expectedBody: formBuilderTextFieldFactory('prop'),
        ),
      );

      // preferred
      for (final spec in [
        FormBuilderTestSpec(
          'FormBuilderCheckbox',
          library.typeProvider.boolType,
          formBuilderCheckbox,
          formBuilderCheckboxFactory('prop'),
        ),
        FormBuilderTestSpec(
          'FormBuilderSwitch',
          library.typeProvider.boolType,
          formBuilderSwitch,
          formBuilderSwitchFactory('prop'),
        ),
      ]) {
        test(
          'preferredFieldType of ${spec.name} for bool',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: spec.type,
            fieldValueType: spec.type,
            formFieldClass: spec.formFieldClass,
            preferredFieldType: toGenericType(spec.formFieldClass.thisType),
            expectedBody: spec.expectedBody,
          ),
        );
      }

      for (final spec in [
        FormBuilderTestSpec(
          'FormBuilderRangeSlider',
          rangeValuesType,
          formBuilderRangeSlider,
          formBuilderRangeSliderFactory(
            'prop',
          ),
        ),
        FormBuilderTestSpec(
          'FormBuilderSlider',
          library.typeProvider.doubleType,
          formBuilderSlider,
          formBuilderSliderFactory('prop'),
        ),
      ]) {
        test(
          'preferredFieldType of ${spec.name} for numeric',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: spec.type,
            fieldValueType: spec.type,
            formFieldClass: spec.formFieldClass,
            preferredFieldType: toGenericType(spec.formFieldClass.thisType),
            expectedBody: spec.expectedBody,
          ),
        );
      }

      for (final spec in [
        FormBuilderTestSpec(
          'FormBuilderCheckboxGroup',
          library.typeProvider.listType(myEnumType),
          formBuilderCheckboxGroup,
          formBuilderCheckboxGroupFactory('prop', 'MyEnum'),
        ),
        FormBuilderTestSpec(
          'FormBuilderChoiceChip',
          myEnumType,
          formBuilderChoiceChip,
          formBuilderChoiceChipFactory('prop', 'MyEnum'),
        ),
        FormBuilderTestSpec(
          'FormBuilderFilterChip',
          library.typeProvider.listType(myEnumType),
          formBuilderFilterChip,
          formBuilderFilterChipFactory('prop', 'MyEnum'),
        ),
        FormBuilderTestSpec(
          'FormBuilderRadioGroup',
          myEnumType,
          formBuilderRadioGroup,
          formBuilderRadioGroupFactory('prop', 'MyEnum'),
        ),
        FormBuilderTestSpec(
          'FormBuilderSegmentedControl',
          myEnumType,
          formBuilderSegmentedControl,
          formBuilderSegmentedControlFactory('prop', 'MyEnum'),
        ),
      ]) {
        test(
          'preferredFieldType of ${spec.name} for enum',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: spec.type,
            fieldValueType: spec.type,
            formFieldClass: spec.formFieldClass,
            preferredFieldType: GenericType.generic(
              spec.formFieldClass.thisType,
              [toGenericType(spec.type)],
              spec.formFieldClass,
            ),
            expectedBody: spec.expectedBody,
          ),
        );
      }

      test(
        'String with unknown preferredFieldType -- error',
        () => testEmitFieldFactory(
          isFormBuilder: true,
          propertyValueType: library.typeProvider.stringType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: null,
          preferredFieldType: toGenericType(
            library.typeProvider.objectType,
          ),
          expectedBody:
              "  // TODO(CompanionGenerator): ERROR - Cannot generate field factory for 'prop' property, because FormField type 'Object' is unknown.",
        ),
      );

      for (final value in [true, false]) {
        test(
          'doAutovalidate ($value) is respected',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: library.typeProvider.stringType,
            fieldValueType: library.typeProvider.stringType,
            formFieldClass: formBuilderTextField,
            doAutovalidate: value,
            expectedBody:
                formBuilderTextFieldFactory('prop', isAutovalidate: value),
          ),
        );
      }
    });

    group('special cases', () {
      test(
        'parameter has property -- local variable changed to property_',
        () => testEmitFieldFactory(
          isFormBuilder: false,
          propertyValueType: library.typeProvider.stringType,
          fieldValueType: library.typeProvider.stringType,
          formFieldClass: formFieldWithPropertyParameter,
          expectedBody: '''
  /// Gets a [FormField] for `prop` property.
  FormFieldWithPropertyParameter prop(
    BuildContext context, {
    InputDecoration? decoration,
    String? property,
  }) {
    final property_ = _presenter.prop;
    return FormFieldWithPropertyParameter(
      key: _presenter.getKey(property_.name, context),
      initialValue: property_.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property_.name, hintText: null),
      onSaved: (v) => property_.setFieldValue(v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property_.getValidator(context),
      property: property,
    );
  }''',
        ),
      );

      for (final type in [
        library.typeProvider.boolType,
        myEnumType,
        library.typeProvider.stringType,
        nullableBoolType,
        nullableMyEnumType,
        nullableStringType,
      ]) {
        test(
          'items of $type',
          () => testEmitFieldFactory(
            isFormBuilder: false,
            propertyValueType: type,
            fieldValueType: type,
            formFieldClass: dropdownButtonFormField,
            expectedBody: dropdownButtonFieldFactory(
              'prop',
              type.getDisplayString(withNullability: true),
              withItemsTemplateError:
                  type.getDisplayString(withNullability: false) == 'String',
            ),
          ),
        );
      }

      for (final type in [
        library.typeProvider.listType(
          library.typeProvider.stringType,
        ),
        nullableListOfStringType,
        nullableListOfNullableStringType,
        library.typeProvider.listType(
          nullableStringType,
        ),
      ]) {
        test(
          'options of $type',
          () => testEmitFieldFactory(
            isFormBuilder: true,
            propertyValueType: type,
            fieldValueType: type,
            formFieldClass: formBuilderFilterChip,
            expectedBody: formBuilderFilterChipFactory(
              'prop',
              type.typeArguments.single.getDisplayString(withNullability: true),
            ),
          ),
        );
      }
    });
  });

  group('emitFromData', () {
    test(
      'builder - warnings, imports, typed property accessors, and field factories',
      () async => expect(
        await emitFromData(
          library,
          nodeProvider,
          PresenterDefinition(
            name: 'Test',
            isFormBuilder: true,
            doAutovalidate: true,
            warnings: ['AAA'],
            imports: [LibraryImport('dart:ui')],
            properties: await makeProperty(
              'prop1',
              library.typeProvider.stringType,
              library.typeProvider.stringType,
              formBuilderTextField,
              isFormBuilder: true,
            ),
          ),
          _emptyConfig,
        ).join('\n'),
        [
          '// TODO(CompanionGenerator): WARNING - AAA',
          '',
          "import 'dart:ui';",
          '',
          "import 'package:form_companion_presenter/form_companion_presenter.dart';",
          '',
          typedProperties(
            'Test',
            [
              Tuple3('prop1', 'String', 'String'),
            ],
          ),
          fieldFactories(
            'Test',
            [
              formBuilderTextFieldFactory('prop1', isAutovalidate: true),
            ],
          )
        ].join('\n'),
      ),
    );

    test(
      'no properties -- warnings',
      () async => expect(
        await emitFromData(
          library,
          nodeProvider,
          PresenterDefinition(
            name: 'Test',
            isFormBuilder: true,
            doAutovalidate: true,
            warnings: ['AAA'],
            imports: [LibraryImport('dart:ui')],
            properties: [],
          ),
          _emptyConfig,
        ).join('\n'),
        '''
// TODO(CompanionGenerator): WARNING - AAA
// TODO(CompanionGenerator): WARNING - No properties are found in Test class.
''',
      ),
    );
  });
}

class FormBuilderTestSpec {
  final String name;
  final InterfaceType type;
  final ClassElement formFieldClass;
  final String expectedBody;
  FormBuilderTestSpec(
    this.name,
    this.type,
    this.formFieldClass,
    this.expectedBody,
  );
}

/// Each tuples in [propertyTypes] are: `name`, `propertyType`, and `fieldType`.
String typedProperties(
  String className,
  Iterable<Tuple3<String, String, String>> propertyTypes,
) =>
    '''
/// Defines typed property accessors as extension properties for [$className].
extension \$${className}PropertyExtension on $className {
${propertyTypes.isEmpty ? '  // No properties were found.' : propertyTypes.map((e) => typedProperty(e.item1, e.item2, e.item3)).join('\n\n')}
}
''';

String typedProperty(String name, String propertyType, String fieldType) => '''
  /// Gets a [PropertyDescriptor] of `$name` property.
  PropertyDescriptor<$propertyType, $fieldType> get $name =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['$name']! as PropertyDescriptor<$propertyType, $fieldType>;''';

String fieldFactories(
  String className,
  Iterable<String> factories,
) =>
    '''
/// Defines [FormField] factory methods for properties of [$className].
class \$${className}FieldFactory {
  final $className _presenter;

  \$${className}FieldFactory._(this._presenter);

${factories.isEmpty ? '  // No properties were found.' : factories.join('\n\n')}
}

/// Defines an extension property to get [\$${className}FieldFactory] from [$className].
extension \$${className}FieldFactoryExtension on $className {
  /// Gets a [FormField] factory.
  \$${className}FieldFactory get fields => \$${className}FieldFactory._(this);
}
''';

String multiFieldFactories(
  String className,
  List<String> propertyNames,
  Map<String, List<String>> factories,
) {
  String childFieldFactory(String propertyName) {
    return '''
/// A [FormField] factory for `$propertyName` property of [$className].
class \$\$$className${pascalize(propertyName)}FieldFactory {
  final $className _presenter;

  \$\$$className${pascalize(propertyName)}FieldFactory._(this._presenter);

${factories.isEmpty ? '  // No properties were found.' : factories[propertyName]!.join('\n\n')}
}
''';
  }

  return '''
/// Defines [FormField] factory methods for properties of [$className].
class \$${className}FieldFactory {
${propertyNames.map((e) => '  /// Gets a [FormField] factory for `$e` property.\n'
          '  final \$\$$className${pascalize(e)}FieldFactory $e;').join('\n')}

  \$${className}FieldFactory._($className presenter) :
    ${propertyNames.map((e) => '$e = \$\$$className${pascalize(e)}FieldFactory(presenter)').join(',\n      ')};
}

${propertyNames.map(childFieldFactory).join('\n')}
/// Defines an extension property to get [\$${className}FieldFactory] from [$className].
extension \$${className}FieldFactoryExtension on $className {
  /// Gets a [FormField] factory.
  \$${className}FieldFactory get fields => \$${className}FieldFactory._(this);
}
''';
}

String itemsExpression(
  String itemWidgetType,
  String fieldValueType, {
  bool isCollection = false,
}) {
  if (!isCollection) {
    switch (fieldValueType) {
      case 'bool':
        return '[true, false].map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x.toString()))).toList()';
      case 'bool?':
        return "[true, false, null].map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x?.toString() ?? ''))).toList()";
      case 'MyEnum':
        return '[MyEnum.one, MyEnum.two].map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x.toString()))).toList()';
      case 'MyEnum?':
        return "[MyEnum.one, MyEnum.two, null].map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x?.toString() ?? ''))).toList()";
      default:
        break;
    }
  }

  switch (fieldValueType) {
    case 'String?':
      return "property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))?.map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x ?? ''))).toList() ?? []";
    case 'String':
      return "property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))?.map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x))).toList() ?? []";
    default:
      if (fieldValueType.endsWith('?')) {
        return "property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))?.map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x?.toString() ?? ''))).toList() ?? []";
      } else {
        return "property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))?.map((x) => $itemWidgetType<$fieldValueType>(value: x, child: Text(x.toString()))).toList() ?? []";
      }
  }
}

String textFormFieldFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  TextFormField $propertyName(
    BuildContext context, {
    TextEditingController? controller,
    FocusNode? focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    String? restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.$propertyName;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      readOnly: readOnly,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: (v) => property.setFieldValue(v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
    );
  }''';

String dropdownButtonFieldFactory(
  String propertyName,
  String propertyType, {
  bool isAutovalidate = false,
  bool withItemsTemplateError = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  DropdownButtonFormField<$propertyType> $propertyName(
    BuildContext context, {
'''
    '${withItemsTemplateError ? '''
    required List<DropdownMenuItem<$propertyType>>? items,
''' : '''
    List<DropdownMenuItem<$propertyType>>? items,
'''}'
    '''
    DropdownButtonBuilder? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    ValueChanged<$propertyType?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  }) {
    final property = _presenter.$propertyName;
    return DropdownButtonFormField<$propertyType>(
      key: _presenter.getKey(property.name, context),
'''
    '${withItemsTemplateError ? '''
      // TODO(CompanionGenerator): WARNING - Template `items_item_template` is ignored because property's type `$propertyType` is not collection, enum, nor bool type.
      items: items,
''' : '''
      items: ${itemsExpression('DropdownMenuItem', propertyType)},
'''}'
    '''
      selectedItemBuilder: selectedItemBuilder,
      value: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged ?? (_) {},
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      decoration: decoration ?? InputDecoration(labelText: property.name, hintText: null),
      onSaved: (v) => property.setFieldValue(v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
    );
  }''';

String formBuilderCheckboxFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderCheckbox $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<bool?>? onChanged,
    ValueTransformer<bool?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required Widget title,
    Color? activeColor,
    bool autofocus = false,
    Color? checkColor,
    EdgeInsets contentPadding = EdgeInsets.zero,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    Widget? secondary,
    bool selected = false,
    bool shouldRequestFocus = false,
    Widget? subtitle,
    bool tristate = false,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderCheckbox(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none).copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      title: title,
      activeColor: activeColor,
      autofocus: autofocus,
      checkColor: checkColor,
      contentPadding: contentPadding,
      controlAffinity: controlAffinity,
      secondary: secondary,
      selected: selected,
      shouldRequestFocus: shouldRequestFocus,
      subtitle: subtitle,
      tristate: tristate,
    );
  }''';

String formBuilderCheckboxGroupFactory(
  String propertyName,
  String propertyElementType, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderCheckboxGroup<$propertyElementType> $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<List<$propertyElementType>?>? onChanged,
    ValueTransformer<List<$propertyElementType>?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<FormBuilderFieldOption<$propertyElementType>>? options,
    Color? activeColor,
    Color? checkColor,
    Color? focusColor,
    Color? hoverColor,
    List<MyEnum>? disabled,
    MaterialTapTargetSize? materialTapTargetSize,
    bool tristate = false,
    Axis wrapDirection = Axis.horizontal,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    double wrapSpacing = 0.0,
    WrapAlignment wrapRunAlignment = WrapAlignment.start,
    double wrapRunSpacing = 0.0,
    WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? wrapTextDirection,
    VerticalDirection wrapVerticalDirection = VerticalDirection.down,
    Widget? separator,
    ControlAffinity controlAffinity = ControlAffinity.leading,
    OptionsOrientation orientation = OptionsOrientation.wrap,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderCheckboxGroup<$propertyElementType>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      options: ${itemsExpression('FormBuilderFieldOption', propertyElementType, isCollection: true)},
      activeColor: activeColor,
      checkColor: checkColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      disabled: disabled,
      materialTapTargetSize: materialTapTargetSize,
      tristate: tristate,
      wrapDirection: wrapDirection,
      wrapAlignment: wrapAlignment,
      wrapSpacing: wrapSpacing,
      wrapRunAlignment: wrapRunAlignment,
      wrapRunSpacing: wrapRunSpacing,
      wrapCrossAxisAlignment: wrapCrossAxisAlignment,
      wrapTextDirection: wrapTextDirection,
      wrapVerticalDirection: wrapVerticalDirection,
      separator: separator,
      controlAffinity: controlAffinity,
      orientation: orientation,
      shouldRequestFocus: shouldRequestFocus,
    );
  }''';

String formBuilderChoiceChipFactory(
  String propertyName,
  String propertyType, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderChoiceChip<$propertyType> $propertyName(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<$propertyType>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    VisualDensity? visualDensity,
    ValueChanged<$propertyType?>? onChanged,
    ValueTransformer<$propertyType?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderChoiceChip<$propertyType>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      key: key,
      name: property.name,
      options: ${itemsExpression('FormBuilderFieldOption', propertyType)},
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      alignment: alignment,
      backgroundColor: backgroundColor,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      visualDensity: visualDensity,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }''';

String formBuilderDateRangePickerFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderDateRangePicker $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<DateTimeRange?>? onChanged,
    ValueTransformer<DateTimeRange?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required DateTime firstDate,
    required DateTime lastDate,
    intl.DateFormat? format,
    int maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    TextInputType? keyboardType,
    TextStyle? style,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<DateTimeRange?>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    InputCounterWidgetBuilder? buildCounter,
    bool expands = false,
    int? minLines,
    bool showCursor = false,
    Locale? locale,
    String? cancelText,
    String? confirmText,
    DateTime? currentDate,
    String? errorFormatText,
    Widget Function(BuildContext, Widget?)? pickerBuilder,
    String? errorInvalidRangeText,
    String? errorInvalidText,
    String? fieldEndHintText,
    String? fieldEndLabelText,
    String? fieldStartHintText,
    String? fieldStartLabelText,
    String? helpText,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    RouteSettings? routeSettings,
    String? saveText,
    bool useRootNavigator = true,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderDateRangePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      firstDate: firstDate,
      lastDate: lastDate,
      format: format,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      keyboardType: keyboardType,
      style: style,
      controller: controller,
      textInputAction: textInputAction,
      strutStyle: strutStyle,
      textDirection: textDirection,
      maxLength: maxLength,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      buildCounter: buildCounter,
      expands: expands,
      minLines: minLines,
      showCursor: showCursor,
      locale: locale,
      cancelText: cancelText,
      confirmText: confirmText,
      currentDate: currentDate,
      errorFormatText: errorFormatText,
      pickerBuilder: pickerBuilder,
      errorInvalidRangeText: errorInvalidRangeText,
      errorInvalidText: errorInvalidText,
      fieldEndHintText: fieldEndHintText,
      fieldEndLabelText: fieldEndLabelText,
      fieldStartHintText: fieldStartHintText,
      fieldStartLabelText: fieldStartLabelText,
      helpText: helpText,
      initialEntryMode: initialEntryMode,
      routeSettings: routeSettings,
      saveText: saveText,
      useRootNavigator: useRootNavigator,
    );
  }''';

String formBuilderDateTimePickerFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderDateTimePicker $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<DateTime?>? onChanged,
    ValueTransformer<DateTime?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    InputType inputType = InputType.both,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    double cursorWidth = 2.0,
    bool enableInteractiveSelection = true,
    Icon resetIcon = const Icon(Icons.close),
    TimeOfDay initialTime = const TimeOfDay(hour: 12, minute: 0),
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = true,
    int? maxLines = 1,
    bool expands = false,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    TransitionBuilder? transitionBuilder,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool useRootNavigator = true,
    bool alwaysUse24HourFormat = false,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    TimePickerEntryMode timePickerInitialEntryMode = TimePickerEntryMode.dial,
    DateFormat? format,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    Locale? locale,
    int? maxLength,
    ui.TextDirection? textDirection,
    ValueChanged<DateTime?>? onFieldSubmitted,
    TextEditingController? controller,
    TextStyle? style,
    MaxLengthEnforcement maxLengthEnforcement = MaxLengthEnforcement.none,
    List<TextInputFormatter>? inputFormatters,
    bool showCursor = false,
    int? minLines,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
    InputCounterWidgetBuilder? buildCounter,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    String? cancelText,
    String? confirmText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    String? helpText,
    RouteSettings? routeSettings,
    StrutStyle? strutStyle,
    SelectableDayPredicate? selectableDayPredicate,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderDateTimePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      inputType: inputType,
      scrollPadding: scrollPadding,
      cursorWidth: cursorWidth,
      enableInteractiveSelection: enableInteractiveSelection,
      resetIcon: resetIcon,
      initialTime: initialTime,
      keyboardType: keyboardType,
      textAlign: textAlign,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      maxLines: maxLines,
      expands: expands,
      initialDatePickerMode: initialDatePickerMode,
      transitionBuilder: transitionBuilder,
      textCapitalization: textCapitalization,
      useRootNavigator: useRootNavigator,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
      initialEntryMode: initialEntryMode,
      timePickerInitialEntryMode: timePickerInitialEntryMode,
      format: format,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      locale: locale,
      maxLength: maxLength,
      textDirection: textDirection,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      style: style,
      maxLengthEnforcement: maxLengthEnforcement,
      inputFormatters: inputFormatters,
      showCursor: showCursor,
      minLines: minLines,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      buildCounter: buildCounter,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      cancelText: cancelText,
      confirmText: confirmText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      helpText: helpText,
      routeSettings: routeSettings,
      strutStyle: strutStyle,
      selectableDayPredicate: selectableDayPredicate,
    );
  }''';

String formBuilderDropdownFactory(
  String propertyName,
  String propertyType, {
  bool isAutovalidate = false,
  bool withItemsTemplateError = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderDropdown<$propertyType> $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<$propertyType?>? onChanged,
    ValueTransformer<$propertyType?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
'''
    '${withItemsTemplateError ? '''
    required List<DropdownMenuItem<$propertyType>> items,
''' : '''
    List<DropdownMenuItem<$propertyType>>? items,
'''}'
    '''
    bool isExpanded = true,
    bool isDense = true,
    int elevation = 8,
    double iconSize = 24.0,
    Widget? hint,
    TextStyle? style,
    Widget? disabledHint,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    bool allowClear = false,
    Widget clearIcon = const Icon(Icons.close),
    VoidCallback? onTap,
    bool autofocus = false,
    bool shouldRequestFocus = false,
    Color? dropdownColor,
    Color? focusColor,
    double itemHeight = kMinInteractiveDimension,
    DropdownButtonBuilder? selectedItemBuilder,
    double? menuMaxHeight,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderDropdown<$propertyType>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
'''
    '${withItemsTemplateError ? '''
      // TODO(CompanionGenerator): WARNING - Template `items_item_template` is ignored because property's type `$propertyType` is not collection, enum, nor bool type.
      items: items,
''' : '''
      items: ${itemsExpression('DropdownMenuItem', propertyType)},
'''}'
    '''
      isExpanded: isExpanded,
      isDense: isDense,
      elevation: elevation,
      iconSize: iconSize,
      hint: hint,
      style: style,
      disabledHint: disabledHint,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      allowClear: allowClear,
      clearIcon: clearIcon,
      onTap: onTap,
      autofocus: autofocus,
      shouldRequestFocus: shouldRequestFocus,
      dropdownColor: dropdownColor,
      focusColor: focusColor,
      itemHeight: itemHeight,
      selectedItemBuilder: selectedItemBuilder,
      menuMaxHeight: menuMaxHeight,
    );
  }''';

String formBuilderFilterChipFactory(
  String propertyName,
  String propertyElementType, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderFilterChip<$propertyElementType> $propertyName(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<$propertyElementType>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    Color? checkmarkColor,
    Clip clipBehavior = Clip.none,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    int? maxChips,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    bool showCheckmark = true,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    ValueChanged<List<$propertyElementType>?>? onChanged,
    ValueTransformer<List<$propertyElementType>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderFilterChip<$propertyElementType>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      key: key,
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      name: property.name,
      options: ${itemsExpression('FormBuilderFieldOption', propertyElementType, isCollection: true)},
      alignment: alignment,
      backgroundColor: backgroundColor,
      checkmarkColor: checkmarkColor,
      clipBehavior: clipBehavior,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      maxChips: maxChips,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      showCheckmark: showCheckmark,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }''';

String formBuilderRadioGroupFactory(
  String propertyName,
  String propertyType, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderRadioGroup<$propertyType> $propertyName(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<$propertyType>>? options,
    bool shouldRadioRequestFocus = false,
    Color? activeColor,
    ControlAffinity controlAffinity = ControlAffinity.leading,
    List<MyEnum>? disabled,
    Color? focusColor,
    Color? hoverColor,
    MaterialTapTargetSize? materialTapTargetSize,
    OptionsOrientation orientation = OptionsOrientation.wrap,
    Widget? separator,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start,
    Axis wrapDirection = Axis.horizontal,
    WrapAlignment wrapRunAlignment = WrapAlignment.start,
    double wrapRunSpacing = 0.0,
    double wrapSpacing = 0.0,
    TextDirection? wrapTextDirection,
    VerticalDirection wrapVerticalDirection = VerticalDirection.down,
    ValueChanged<$propertyType?>? onChanged,
    ValueTransformer<$propertyType?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderRadioGroup<$propertyType>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      key: key,
      name: property.name,
      options: ${itemsExpression('FormBuilderFieldOption', propertyType)},
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      shouldRadioRequestFocus: shouldRadioRequestFocus,
      activeColor: activeColor,
      controlAffinity: controlAffinity,
      disabled: disabled,
      focusColor: focusColor,
      hoverColor: hoverColor,
      materialTapTargetSize: materialTapTargetSize,
      orientation: orientation,
      separator: separator,
      wrapAlignment: wrapAlignment,
      wrapCrossAxisAlignment: wrapCrossAxisAlignment,
      wrapDirection: wrapDirection,
      wrapRunAlignment: wrapRunAlignment,
      wrapRunSpacing: wrapRunSpacing,
      wrapSpacing: wrapSpacing,
      wrapTextDirection: wrapTextDirection,
      wrapVerticalDirection: wrapVerticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }''';

String formBuilderRangeSliderFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderRangeSlider $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<RangeValues?>? onChanged,
    ValueTransformer<RangeValues?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required double min,
    required double max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    ValueChanged<RangeValues>? onChangeStart,
    ValueChanged<RangeValues>? onChangeEnd,
    RangeLabels? labels,
    SemanticFormatterCallback? semanticFormatterCallback,
    DisplayValues displayValues = DisplayValues.all,
    TextStyle? minTextStyle,
    TextStyle? textStyle,
    TextStyle? maxTextStyle,
    NumberFormat? numberFormat,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderRangeSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      labels: labels,
      semanticFormatterCallback: semanticFormatterCallback,
      displayValues: displayValues,
      minTextStyle: minTextStyle,
      textStyle: textStyle,
      maxTextStyle: maxTextStyle,
      numberFormat: numberFormat,
      shouldRequestFocus: shouldRequestFocus,
    );
  }''';

String formBuilderSegmentedControlFactory(
  String propertyName,
  String propertyType, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderSegmentedControl<$propertyType> $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<$propertyType?>? onChanged,
    ValueTransformer<$propertyType?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<FormBuilderFieldOption<$propertyType>>? options,
    Color? borderColor,
    Color? selectedColor,
    Color? pressedColor,
    EdgeInsetsGeometry? padding,
    Color? unselectedColor,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderSegmentedControl<$propertyType>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      options: ${itemsExpression('FormBuilderFieldOption', propertyType)},
      borderColor: borderColor,
      selectedColor: selectedColor,
      pressedColor: pressedColor,
      padding: padding,
      unselectedColor: unselectedColor,
      shouldRequestFocus: shouldRequestFocus,
    );
  }''';

String formBuilderSliderFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderSlider $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<double?>? onChanged,
    ValueTransformer<double?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required double min,
    required double max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    String? label,
    SemanticFormatterCallback? semanticFormatterCallback,
    NumberFormat? numberFormat,
    DisplayValues displayValues = DisplayValues.all,
    TextStyle? minTextStyle,
    TextStyle? textStyle,
    TextStyle? maxTextStyle,
    bool autofocus = false,
    MouseCursor? mouseCursor,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.prop;
    return FormBuilderSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      min: min,
      max: max,
      divisions: divisions,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      label: label,
      semanticFormatterCallback: semanticFormatterCallback,
      numberFormat: numberFormat,
      displayValues: displayValues,
      minTextStyle: minTextStyle,
      textStyle: textStyle,
      maxTextStyle: maxTextStyle,
      autofocus: autofocus,
      mouseCursor: mouseCursor,
      shouldRequestFocus: shouldRequestFocus,
    );
  }''';

String formBuilderSwitchFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderSwitch $propertyName(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<bool?>? onChanged,
    ValueTransformer<bool?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required Widget title,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider? activeThumbImage,
    ImageProvider? inactiveThumbImage,
    Widget? subtitle,
    Widget? secondary,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.trailing,
    EdgeInsets contentPadding = EdgeInsets.zero,
    bool autofocus = false,
    bool shouldRequestFocus = false,
    bool selected = false,
  }) {
    final property = _presenter.prop;
    return FormBuilderSwitch(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      title: title,
      activeColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      activeThumbImage: activeThumbImage,
      inactiveThumbImage: inactiveThumbImage,
      subtitle: subtitle,
      secondary: secondary,
      controlAffinity: controlAffinity,
      contentPadding: contentPadding,
      autofocus: autofocus,
      shouldRequestFocus: shouldRequestFocus,
      selected: selected,
    );
  }''';

String formBuilderTextFieldFactory(
  String propertyName, {
  bool isAutovalidate = false,
}) =>
    '''
  /// Gets a [FormField] for `$propertyName` property.
  FormBuilderTextField $propertyName(
    BuildContext context, {
    Key? key,
    bool readOnly = false,
    InputDecoration? decoration,
    ValueChanged<String?>? onChanged,
    ValueTransformer<String?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    int? maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    TextInputType? keyboardType,
    TextStyle? style,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<String?>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    InputCounterWidgetBuilder? buildCounter,
    bool expands = false,
    int? minLines,
    bool? showCursor,
    GestureTapCallback? onTap,
    bool enableSuggestions = false,
    TextAlignVertical? textAlignVertical,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.$propertyName;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ?? const InputDecoration().copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.${isAutovalidate ? 'onUserInteraction' : 'disabled'},
      onReset: onReset,
      focusNode: focusNode,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      keyboardType: keyboardType,
      style: style,
      controller: controller,
      textInputAction: textInputAction,
      strutStyle: strutStyle,
      textDirection: textDirection,
      maxLength: maxLength,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      buildCounter: buildCounter,
      expands: expands,
      minLines: minLines,
      showCursor: showCursor,
      onTap: onTap,
      enableSuggestions: enableSuggestions,
      textAlignVertical: textAlignVertical,
      dragStartBehavior: dragStartBehavior,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      selectionWidthStyle: selectionWidthStyle,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      toolbarOptions: toolbarOptions,
      selectionHeightStyle: selectionHeightStyle,
      autofillHints: autofillHints,
      obscuringCharacter: obscuringCharacter,
      mouseCursor: mouseCursor,
    );
  }''';
