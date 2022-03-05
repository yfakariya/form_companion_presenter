import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'src/generator.dart';

/// Generator entry point.
Builder formCompanionPresenterGenerator(BuilderOptions options) {
  // TODO(yfakariya): Use standard builder instead of part builder to handle complex import handling of factroies for FormBuilderField<T>
  return PartBuilder(
    [CompanionGenerator(options.config)],
    '.fcp.dart',
    header: '''
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target
    ''',
    options: options,
  );
}
