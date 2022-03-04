// See LICENCE file in the root.

import 'dart:io';

import 'package:form_field_builder_emitter/form_field_builder_emitter.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

Future<dynamic> main(List<String> args) => grind(args);

@DefaultTask()
@Task('''
Generates builder classes for vanilla FormField classes to the file
which is specified by --out option.
If the --out options is omitted, the result will be written to stdout.
''')
Future<dynamic> generateFactorySpecs(GrinderContext context) => emit(
      '${path.dirname(Platform.executable)}/../../../../packages/flutter/lib/src/material',
      {'dropdown', 'text_form_field'},
      {'TextFormField', 'DropdownButtonFormField'},
      [
        // TODO(yfakariya): Revise order.
        'coverage:ignore-file',
        'See LICENCE file in the root.',
        'ignore_for_file: type=lint',
        'GENERATED CODE - DO NOT MODIFY BY HAND',
      ],
      [
        'flutter/material.dart',
        'flutter/services.dart',
        'meta/meta.dart',
      ],
      context.invocation.arguments.getOption('out') ??
          'lib/src/form_field_builder.dart',
    );
