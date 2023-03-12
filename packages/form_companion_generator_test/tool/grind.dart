// See LICENCE file in the root.
// ignore_for_file: unreachable_from_main

import 'dart:convert';
import 'dart:io';

import 'package:grinder/grinder.dart';

const asPartDir = 'test_as_part';
const notAsPartDir = 'test_not_as_part';

Future<dynamic> main(List<String> args) => grind(args);

@Task()
Future<dynamic> anaylize() => runAsync(
      'fvm',
      arguments: [
        'flutter',
        'analyze',
        '.',
      ],
    );

@DefaultTask()
@Depends(clean, prepare, runBuildRunner, anaylize)
void test() {}

@Task()
void prepare() {
  final root = 'test${Platform.pathSeparator}src${Platform.pathSeparator}';
  final sources = [
    File('${root}the_form_builder_presenter.dart'),
    File('${root}the_form_presenter.dart'),
  ];

  void copyFiles(Directory destination) {
    final asPart = fileName(destination) == 'as_part';

    delete(destination);
    for (final source in sources) {
      final isBuilder = fileName(source).contains('_builder_');
      copy(source, destination);
      final targetName = fileName(source);
      final target =
          File('${destination.path}${Platform.pathSeparator}$targetName');
      final content = target.readAsStringSync();
      if (asPart) {
        target.writeAsStringSync(
          content
              .replaceAll(
                '/* #PART# */',
                "part '${targetName.replaceAll('.dart', '.fcp.dart')}';",
              )
              .replaceAll(
                '/* #PRE_IMPORT# */',
                isBuilder
                    ? '''
import 'dart:ui'
    show
        Brightness,
        Clip,
        Color,
        Locale,
        Offset,
        Radius,
        TextAlign,
        TextDirection,
        VoidCallback;
import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle, TextDirection;

import 'package:flutter/foundation.dart' show Key, ValueChanged;
import 'package:flutter/gestures.dart'
    show DragStartBehavior, GestureTapCallback;
import 'package:flutter/material.dart'
    show
        DatePickerEntryMode,
        DatePickerMode,
        DateTimeRange,
        DropdownButtonBuilder,
        DropdownMenuItem,
        EntryModeChangeCallback,
        Icons,
        InputBorder,
        InputCounterWidgetBuilder,
        InputDecoration,
        ListTileControlAffinity,
        MaterialTapTargetSize,
        RangeLabels,
        RangeValues,
        SelectableDayPredicate,
        SemanticFormatterCallback,
        TimeOfDay,
        TimePickerEntryMode,
        VisualDensity;
import 'package:flutter/painting.dart'
    show
        AlignmentDirectional,
        AlignmentGeometry,
        Axis,
        BorderRadius,
        BorderSide,
        CircleBorder,
        EdgeInsets,
        EdgeInsetsGeometry,
        ImageProvider,
        OutlinedBorder,
        ShapeBorder,
        StrutStyle,
        TextAlignVertical,
        TextStyle,
        VerticalDirection;
import 'package:flutter/rendering.dart' show WrapAlignment, WrapCrossAlignment;
import 'package:flutter/services.dart'
    show
        MaxLengthEnforcement,
        MouseCursor,
        SmartDashesType,
        SmartQuotesType,
        TextCapitalization,
        TextInputAction,
        TextInputFormatter,
        TextInputType;
import 'package:flutter/widgets.dart'
    show
        AutovalidateMode,
        BuildContext,
        EditableTextContextMenuBuilder,
        FocusNode,
        Icon,
        RouteSettings,
        ScrollController,
        ScrollPhysics,
        Text,
        TextEditingController,
        TextMagnifierConfiguration,
        TransitionBuilder,
        Widget;
'''
                    : '''
import 'package:flutter/services.dart'
    show
        MaxLengthEnforcement,
        MouseCursor,
        SmartDashesType,
        SmartQuotesType,
        TextCapitalization,
        TextInputAction,
        TextInputFormatter,
        TextInputType;
''',
              )
              .replaceAll(
                '/* #POST_IMPORT# */',
                isBuilder
                    ? '''
import 'package:intl/intl.dart' show DateFormat, NumberFormat;
import 'package:intl/intl.dart' as intl show DateFormat;
import 'package:meta/meta.dart' show immutable, sealed;
'''
                    : '''
import 'package:meta/meta.dart' show immutable, sealed;
''',
              ),
        );
      } else {
        target.writeAsStringSync(
          content
              .replaceAll('^/* #PART# */', '')
              .replaceAll('/* #PRE_IMPORT# */', '')
              .replaceAll('/* #POST_IMPORT# */', ''),
        );
      }
    }
  }

  copyFiles(Directory('$root${Platform.pathSeparator}as_part'));
  copyFiles(
    Directory('$root${Platform.pathSeparator}not_as_part'),
  );
}

@Task()
void clean() => defaultClean();

@Task(
  'Run form_companion_generator for multiple build.*.yaml.',
)
Future<void> runBuildRunner() async {
  await runAsync(
    'fvm',
    arguments: [
      'flutter',
      'pub',
      'run',
      'build_runner',
      'build',
      '--delete-conflicting-outputs',
    ],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );

  final notAsPart = Directory(
    'test${Platform.pathSeparator}src${Platform.pathSeparator}not_as_part',
  );
  notAsPart.listSync().forEach((f) => f.renameSync('${f.path}.tmp'));

  await runAsync(
    'fvm',
    arguments: [
      'flutter',
      'pub',
      'run',
      'build_runner',
      'build',
      '--config',
      'as_part',
      '--delete-conflicting-outputs',
    ],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );

  notAsPart
      .listSync()
      .forEach((f) => f.renameSync(f.path.replaceAll('.dart.tmp', '.dart')));
}
