// See LICENCE file in the root.

import 'dart:async';

import 'package:build/build.dart';
import 'package:form_companion_generator/src/form_field_locator.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import 'session_resolver.dart';
import 'test_helpers.dart';

Future<void> main() async {
  final logger = Logger('form_field_locator_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  final library = await getParametersLibrary();
  final resolver = SessionResolver(library);

  group('createAsync', () {
    test('no extra libraries should succeed', () async {
      await FormFieldLocator.createAsync(resolver, [], logger);
    });

    test('package is in presenter dependency can be resolved', () async {
      final result = await FormFieldLocator.createAsync(
        resolver,
        ['package:flutter/material.dart'],
        logger,
      );
      expect(
        result.resolveFormFieldType('InputDecoration'),
        isNotNull,
      );
    });

    test('package is not in presenter dependency causes exception', () async {
      await expectLater(
        FormFieldLocator.createAsync(
          resolver,
          ['package:form_builder_extras/form_builder_extras.dart'],
          logger,
        ),
        throwsA(isA<AssetNotFoundException>()),
      );
    });
  });
  group('vanilla', () {
    for (final field in ['TextFormField', 'DropdownButtonFormField']) {
      test(field, () async {
        final target = await FormFieldLocator.createAsync(resolver, [], logger);
        final result = target.resolveFormFieldType(
          field,
        );
        expect(result, isNotNull);
        expect(
          result?.toString(),
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
        final target = await FormFieldLocator.createAsync(resolver, [], logger);
        final result = target.resolveFormFieldType(field);
        expect(result, isNotNull);
        expect(
          result?.toString(),
          // may be generic
          startsWith(field),
        );
      });
    }
  });
}
