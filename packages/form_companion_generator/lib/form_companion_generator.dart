// See LICENCE file in the root.

import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/config.dart';
import 'src/generator.dart';

const _extension = '.fcp.dart';
const _header = '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target
''';

/// Generator entry point.
Builder generate(BuilderOptions options) {
  final asPart = options.config[Config.asPartKey] == true;

  return asPart
      ? PartBuilder(
          [CompanionGenerator(options.config)],
          _extension,
          header: _header,
          options: options,
        )
      : LibraryBuilder(
          CompanionGenerator(options.config),
          generatedExtension: _extension,
          header: _header,
          options: options,
        );
}
