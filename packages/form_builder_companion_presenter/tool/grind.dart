// See LICENCE file in the root.

import 'dart:io';

import 'package:form_field_builder_emitter/form_field_builder_emitter.dart';
import 'package:grinder/grinder.dart';

Future<dynamic> main(List<String> args) => grind(args);

@DefaultTask()
@Task('''
Generates builder classes for vanilla FormField classes to the file
which is specified by --out option.
If the --out options is omitted, the result will be written to stdout.
''')
Future<dynamic> generateFactorySpecs(GrinderContext context) {
  const flutterFormBuilderVersion = '7.0.0';

  final pubCacheRoot = Platform.environment['PUB_CACHE'] ??
      (Platform.isWindows
          ? '${Platform.environment['LocalAppData']}/Pub/Cache'
          : '/home/.pub-cache');
  return emit(
    // C:\Users\Yusuke\AppData\Local\Pub\Cache\hosted\pub.dartlang.org\flutter_form_builder-7.0.0\lib\src\fields
    '$pubCacheRoot/hosted/pub.dartlang.org/flutter_form_builder-$flutterFormBuilderVersion/lib/src/fields',
    {
      'form_builder_checkbox',
      'form_builder_checkbox_group',
      'form_builder_choice_chips',
      'form_builder_date_range_picker',
      'form_builder_date_time_picker',
      'form_builder_dropdown',
      'form_builder_filter_chips',
      'form_builder_radio_group',
      'form_builder_range_slider',
      'form_builder_segmented_control',
      'form_builder_slider',
      'form_builder_switch',
      'form_builder_text_field',
    },
    {
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
    },
    [
      // TODO(yfakariya): Revise order.
      'coverage:ignore-file',
      'See LICENCE file in the root.',
      'ignore_for_file: type=lint',
      'GENERATED CODE - DO NOT MODIFY BY HAND',
    ],
    [
      "import 'dart:ui' as ui",
      '',
      "import 'package:flutter_form_builder/flutter_form_builder.dart'",
      "import 'package:flutter/gestures.dart'",
      "import 'package:flutter/material.dart'",
      "import 'package:flutter/services.dart'",
      "import 'package:intl/intl.dart' as intl",
      "import 'package:meta/meta.dart'",
    ],
    context.invocation.arguments.getOption('out') ??
        'lib/src/form_builder_field_builder.dart',
    (typeName) => typeName == 'NumberFormat'
        ? 'intl.NumberFormat'
        : typeName == 'NumberFormat?'
            ? 'intl.NumberFormat?'
            : typeName == 'DateFormat?'
                ? 'intl.DateFormat?'
                : typeName,
  );
}
