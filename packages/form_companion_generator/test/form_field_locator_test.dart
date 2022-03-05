// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/exception/exception.dart';
import 'package:form_companion_generator/src/form_field_locator.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final library = await getParametersLibrary();

  group('createAsync', () {
    test('no extra libraries should succeed', () async {
      await FormFieldLocator.createAsync(library.session, []);
    });

    test('package is not in project dependency', () async {
      await expectLater(
        FormFieldLocator.createAsync(
          library.session,
          ['package:form_builder_extras/form_builder_extras.dart'],
        ),
        throwsA(isA<AnalysisException>()),
      );
    });
  });
  group('vanilla', () {
    for (final field in ['TextFormField', 'DropdownButtonFormField']) {
      test(field, () async {
        final target = await FormFieldLocator.createAsync(library.session, []);
        final result = target.resolveFormFieldType(field);
        expect(result, isNotNull);
        expect(
          result?.getDisplayString(withNullability: false),
          // may be generic
          startsWith(field),
        );
      });
    }
  });
  group('form builder', () {
    for (final field in [
      'FormBuilderCheckbox',
      'FormBuilderCheckboxGroup',
      'FormBuilderChoiceChip',
      'FormBuilderDateRangePicker',
      'FormBuilderDateTimePicker',
      'FormBuilderDropdown',
      'FormBuilderFilterChip',
      'FormBuilderRadioGroup',
      'FormBuilderRangeSlider',
      'FormBuilderSegmentedControl',
      'FormBuilderSlider',
      'FormBuilderSwitch',
      'FormBuilderTextField',
    ]) {
      test(field, () async {
        final target = await FormFieldLocator.createAsync(library.session, []);
        final result = target.resolveFormFieldType(field);
        expect(result, isNotNull);
        expect(
          result?.getDisplayString(withNullability: false),
          // may be generic
          startsWith(field),
        );
      });
    }
  });
}
