// See LICENCE file in the root.

import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/emitter.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:test/test.dart';

const _emptyConfig = Config(<String, dynamic>{});

// TODO(yfakariya): DropdownItems support w/ label template
// labelTemplate:
//    @FormCompanion(labelTemplate: 'L.\${property}_label.tr()', hintTemplate: 'L.\${property}_hint.tr()')
// \$(\{(<ID>?[_A-Za-z$][_A-Za-z0-9$]*)\}|(<ID>?[_A-Za-z][_A-Za-z0-9]*))

void main() {
  group('emitPropertyAccessor', () {
    test('1 property of String', () {
      final data = PresenterDefinition(
        name: 'Test01',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      data.properties['prop'] =
          PropertyDefinition(name: 'prop', type: 'String');
      expect(
        emitPropertyAccessor(data.name, data.properties.values, _emptyConfig),
        equals('''
extension \$Test01PropertyExtension on Test01 {
  /// Gets a [PropertyDescriptor] of prop property.
  PropertyDescriptor<String> get prop => this.properties['prop'] as PropertyDescriptor<String>;
}
'''),
      );
    });

    test('2 properties of String and int', () {
      final data = PresenterDefinition(
        name: 'Test02',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      data.properties['prop1'] =
          PropertyDefinition(name: 'prop1', type: 'String');
      data.properties['prop2'] = PropertyDefinition(name: 'prop2', type: 'int');
      expect(
        emitPropertyAccessor(data.name, data.properties.values, _emptyConfig),
        equals('''
extension \$Test02PropertyExtension on Test02 {
  /// Gets a [PropertyDescriptor] of prop1 property.
  PropertyDescriptor<String> get prop1 => this.properties['prop1'] as PropertyDescriptor<String>;

  /// Gets a [PropertyDescriptor] of prop2 property.
  PropertyDescriptor<int> get prop2 => this.properties['prop2'] as PropertyDescriptor<int>;
}
'''),
      );
    });

    test('no properties - empty', () {
      final data = PresenterDefinition(
        name: 'Test03',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      expect(
        emitPropertyAccessor(data.name, data.properties.values, _emptyConfig),
        equals('''
extension \$Test03PropertyExtension on Test03 {
  // No properties were found.
}
'''),
      );
    });
  });

  group('emitGlobal', () {
    test('no warnings -- empty', () {
      final data = PresenterDefinition(
        name: 'Test',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      data.properties['prop1'] =
          PropertyDefinition(name: 'prop1', type: 'String');
      expect(emitGlobal(data, _emptyConfig).isEmpty, isTrue);
    });

    test('1 warning -- 1 line', () {
      final data = PresenterDefinition(
        name: 'Test',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: ['AAA'],
      );
      data.properties['prop1'] =
          PropertyDefinition(name: 'prop1', type: 'String');
      final lines = emitGlobal(data, _emptyConfig).toList();
      expect(lines.length, equals(1));
      expect(lines.first, equals('// TODO(CompanionGenerator): WARNING - AAA'));
    });

    test('2 warnings -- 2 line', () {
      final data = PresenterDefinition(
        name: 'Test',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: ['AAA', 'BBB'],
      );
      data.properties['prop1'] =
          PropertyDefinition(name: 'prop1', type: 'String');
      final lines = emitGlobal(data, _emptyConfig).toList();
      expect(lines.length, equals(2));
      expect(lines[0], equals('// TODO(CompanionGenerator): WARNING - AAA'));
      expect(lines[1], equals('// TODO(CompanionGenerator): WARNING - BBB'));
    });
  });

  group('emitFieldFactories', () {
    test('1 property of String, vanilla, no warnings', () {
      final data = PresenterDefinition(
        name: 'Test01',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      data.properties['prop'] =
          PropertyDefinition(name: 'prop', type: 'String');
      expect(
        emitFieldFactories(data, _emptyConfig),
        equals('''
class \$Test01FieldFactories {
  final Map<String, PropertyDescriptor<Object>> _properties;

  \$Test01FieldFactories._(this._properties);

  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(TextFormFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = TextFormFieldBuilder()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }
}

extension \$Test01FieldFactoryExtension on Test01 {
  /// Gets a form field factories.
  \$Test01FieldFactories get fields => \$Test01FieldFactories(this.properties);
}
'''),
      );
    });

    test('2 properties of String and enum', () {
      final data = PresenterDefinition(
        name: 'Test02',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      data.properties['prop1'] =
          PropertyDefinition(name: 'prop1', type: 'String');
      data.properties['prop2'] =
          PropertyDefinition(name: 'prop2', type: 'MyEnum', isEnum: true);
      expect(
        emitFieldFactories(data, _emptyConfig),
        equals('''
class \$Test02FieldFactories {
  final Map<String, PropertyDescriptor<Object>> _properties;

  \$Test02FieldFactories._(this._properties);

  /// Gets a [FormField] for prop1 property.
  FormField prop1(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(TextFormFieldBuilder)? setup,
  ]) {
    final property = this.prop1;
    final builder = TextFormFieldBuilder()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }

  /// Gets a [FormField] for prop2 property.
  FormField prop2(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(DropdownButtonFormFieldBuilder<MyEnum>)? setup,
  ]) {
    final property = this.prop2;
    final builder = DropdownButtonFormFieldBuilder<MyEnum>()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..value = property.value
      // Tip: required to work correctly
      ..onChanged = (_) {};
    setup?.call(builder);
    return builder.build();
  }
}

extension \$Test02FieldFactoryExtension on Test02 {
  /// Gets a form field factories.
  \$Test02FieldFactories get fields => \$Test02FieldFactories(this.properties);
}
'''),
      );
    });

    test('no properties - empty class and extensions', () {
      final data = PresenterDefinition(
        name: 'Test03',
        isFormBuilder: false,
        doAutovalidate: false,
        warnings: [],
      );
      expect(
        emitFieldFactories(data, _emptyConfig),
        equals('''
class \$Test03FieldFactories {
  final Map<String, PropertyDescriptor<Object>> _properties;

  \$Test03FieldFactories._(this._properties);

  // No properties were found.
}

extension \$Test03FieldFactoryExtension on Test03 {
  /// Gets a form field factories.
  \$Test03FieldFactories get fields => \$Test03FieldFactories(this.properties);
}
'''),
      );
    });
  });
  group('emitFieldFactory', () {
    void _testEmitFieldFactory({
      required bool isFormBuilder,
      required String type,
      String? preferredFieldType,
      bool doAutovalidate = false,
      bool isEnum = false,
      List<String> warnings = const <String>[],
      required String expectedBody,
    }) {
      final data = PresenterDefinition(
        name: 'Test',
        isFormBuilder: isFormBuilder,
        doAutovalidate: doAutovalidate,
        warnings: [],
      );
      final property = PropertyDefinition(
        name: 'prop',
        type: type,
        isEnum: isEnum,
        preferredFieldType: preferredFieldType,
        warnings: warnings,
      );

      final lines = emitFieldFactory(data, property).toList();

      expect(lines.isNotEmpty, isTrue);
      expect(lines.first.isEmpty, isTrue);

      final warningLines = lines.skip(1).take(warnings.length).toList();
      final body = lines.skip(warnings.length + 1).join('\n');

      expect(warningLines.length, equals(warnings.length));
      for (final i in List.generate(warnings.length, (i) => i)) {
        expect(
          warningLines[i],
          equals('  // TODO(CompanionGenerator): WARNING - ${warnings[i]}'),
          reason: 'warnings[$i]',
        );
      }

      expect(body, equals(expectedBody));
    }

    group('vanilla form', () {
      for (final warnings in [
        <String>[],
        ['AAA'],
        ['AAA', 'BBB']
      ]) {
        test(
          'String with ${warnings.length} warnings',
          () => _testEmitFieldFactory(
            isFormBuilder: false,
            type: 'String',
            warnings: warnings,
            expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(TextFormFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = TextFormFieldBuilder()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }''',
          ),
        );
      }

      for (final isEnum in [false, true]) {
        final type = isEnum ? 'MyEnum' : 'bool';
        test(
          isEnum ? 'enum' : 'bool',
          () => _testEmitFieldFactory(
            isFormBuilder: false,
            isEnum: isEnum,
            type: type,
            expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(DropdownButtonFormFieldBuilder<$type>)? setup,
  ]) {
    final property = this.prop;
    final builder = DropdownButtonFormFieldBuilder<$type>()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..value = property.value
      // Tip: required to work correctly
      ..onChanged = (_) {};
    setup?.call(builder);
    return builder.build();
  }''',
          ),
        );
      }

      test(
        'String with known preferredFieldType -- preferredFieldType is used',
        () => _testEmitFieldFactory(
          isFormBuilder: false,
          type: 'String',
          preferredFieldType: 'DropdownButtonFormField<String>',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(DropdownButtonFormFieldBuilder<String>)? setup,
  ]) {
    final property = this.prop;
    final builder = DropdownButtonFormFieldBuilder<String>()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..value = property.value
      // Tip: required to work correctly
      ..onChanged = (_) {};
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'bool with known preferredFieldType -- preferredFieldType is used',
        () => _testEmitFieldFactory(
          isFormBuilder: false,
          type: 'bool',
          preferredFieldType: 'TextFormField',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(TextFormFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = TextFormFieldBuilder()
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'Unknown preferredFieldType -- error',
        () => _testEmitFieldFactory(
          isFormBuilder: false,
          type: 'String',
          preferredFieldType: 'UnknownFormField',
          expectedBody:
              "  // TODO(CompanionGenerator): ERROR - Cannot generate field factory for 'prop' property, because FormField type 'UnknownFormField' is unknown.",
        ),
      );

      for (final value in [true, false]) {
        test(
          'doAutovalidate ($value) is respected',
          () => _testEmitFieldFactory(
              isFormBuilder: false,
              type: 'String',
              doAutovalidate: value,
              expectedBody: '''  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context,
    FormCompanionPresenterMixin presenter, [
    void Function(TextFormFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = TextFormFieldBuilder()${value ? '\n      ..autovalidateMode = AutovalidateMode.onUserInteraction' : ''}
      ..key = presenter.getKey(property.name, context)
      ..onSaved = property.savePropertyValue
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }'''),
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
          () => _testEmitFieldFactory(
            isFormBuilder: true,
            type: 'String',
            warnings: warnings,
            expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderTextFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderTextFieldBuilder()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }''',
          ),
        );
      }

      test(
        'enum',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          isEnum: true,
          type: 'MyEnum',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderDropdownBuilder<MyEnum>)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderDropdownBuilder<MyEnum>()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value
      // Tip: required to work correctly
      ..onChanged = (_) {};
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'bool',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'bool',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderSwitchBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderSwitchBuilder()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value;
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'DateTime',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'DateTime',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderDateTimePickerBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderDateTimePickerBuilder()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value;
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'DateTimeRange',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'DateTimeRange',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderDateRangePickerBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderDateRangePickerBuilder()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value;
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'String with known preferredFieldType -- preferredFieldType is used',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'String',
          preferredFieldType: 'FormBuilderDropdown<String>',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderDropdownBuilder<String>)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderDropdownBuilder<String>()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value
      // Tip: required to work correctly
      ..onChanged = (_) {};
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      test(
        'bool with known preferredFieldType -- preferredFieldType is used',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'bool',
          preferredFieldType: 'FormBuilderTextField',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderTextFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderTextFieldBuilder()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }''',
        ),
      );

      void _testPreferredFieldTypeOfBuilder({
        required String type,
        required String preferredFieldType,
        String? expectedBuilderType,
        bool isEnum = false,
      }) =>
          _testEmitFieldFactory(
            isFormBuilder: true,
            type: type,
            isEnum: isEnum,
            preferredFieldType: preferredFieldType,
            expectedBody: '''
  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(${expectedBuilderType ?? '${preferredFieldType}Builder'})? setup,
  ]) {
    final property = this.prop;
    final builder = ${expectedBuilderType ?? '${preferredFieldType}Builder'}()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value;
    setup?.call(builder);
    return builder.build();
  }''',
          );

      // preferred
      for (final knownNonGenericBoolPreferredFieldType in [
        'FormBuilderCheckbox',
        'FormBuilderSwitch',
      ]) {
        test(
          'preferredFieldType of $knownNonGenericBoolPreferredFieldType for bool',
          () => _testPreferredFieldTypeOfBuilder(
            preferredFieldType: knownNonGenericBoolPreferredFieldType,
            type: 'bool',
          ),
        );
      }

      for (final knownNonGenericNumericPrefferedFieldType in [
        'FormBuilderRangeSlider',
        'FormBuilderSlider',
      ]) {
        test(
          'preferredFieldType of $knownNonGenericNumericPrefferedFieldType for numeric',
          () => _testPreferredFieldTypeOfBuilder(
            preferredFieldType: knownNonGenericNumericPrefferedFieldType,
            type: 'int',
          ),
        );
      }

      for (final knownGenericEnumPrefferedFieldType in [
        'FormBuilderCheckboxGroup',
        'FormBuilderChoiceChip',
        'FormBuilderFilterChip',
        'FormBuilderRadioGroup',
        'FormBuilderSegmentedControl',
      ]) {
        test(
          'preferredFieldType of $knownGenericEnumPrefferedFieldType for enum',
          () => _testPreferredFieldTypeOfBuilder(
            preferredFieldType: '$knownGenericEnumPrefferedFieldType<MyEnum>',
            expectedBuilderType:
                '${knownGenericEnumPrefferedFieldType}Builder<MyEnum>',
            type: 'MyEnum',
            isEnum: true,
          ),
        );
      }

      test(
        'String with unknown preferredFieldType -- generated with required customFactgory',
        () => _testEmitFieldFactory(
          isFormBuilder: true,
          type: 'String',
          preferredFieldType: 'FormBuilderUnknown<String>',
          expectedBody: '''
  /// Gets a [FormField] for prop property.
  /// This takes [customFactory] because FormField type 'FormBuilderUnknown' is unknown.
  FormField prop(
    BuildContext context,
    FormField Function(GenericFormBuilderFieldBuilder<String>, PropertyDescriptor<String>) customFactory,
  ) {
    final property = this.prop;
    final builder = GenericFormBuilderFieldBuilder<String>()
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value;
    return customFactory(builder, property);
  }''',
        ),
      );

      for (final value in [true, false]) {
        test(
          'doAutovalidate ($value) is respected',
          () => _testEmitFieldFactory(
              isFormBuilder: true,
              type: 'String',
              doAutovalidate: value,
              expectedBody: '''  /// Gets a [FormField] for prop property.
  FormField prop(
    BuildContext context, [
    void Function(FormBuilderTextFieldBuilder)? setup,
  ]) {
    final property = this.prop;
    final builder = FormBuilderTextFieldBuilder()${value ? '\n      ..autovalidateMode = AutovalidateMode.onUserInteraction' : ''}
      ..name = property.name
      ..decoration = InputDecoration(
        labelText: property.name,
      )
      ..initialValue = property.value.toString()
      ..validator = property.getValidator(context);
    setup?.call(builder);
    return builder.build();
  }'''),
        );
      }
    });
  });
}
