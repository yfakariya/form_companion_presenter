// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'config.dart';
import 'emitter.dart';
import 'model.dart';
import 'parser.dart';

/// [Generator] for `@formCompanion`.
@sealed
class CompanionGenerator extends Generator {
  final Config _config;
  final Logger _logger = Logger('ComnpanionGenerator');

  /// Initialize a new [CompanionGenerator] instance.
  CompanionGenerator(Map<String, dynamic> config) : _config = Config(config);

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) async {
    final values = <String>{};

    for (final classElement in library.classes
        .where((c) => c.metadata.any(isFormCompanionAnnotation))) {
      final annotation = ConstantReader(classElement.metadata
          .firstWhere(isFormCompanionAnnotation)
          .computeConstantValue());
      await _generateForAnnotatedElement(
        library,
        classElement,
        FormCompanionAnnotation(annotation),
        buildStep,
      ).forEach(values.add);
    }

    return values.join('\n\n');
  }

  Stream<String> _generateForAnnotatedElement(
    LibraryReader library,
    ClassElement element,
    FormCompanionAnnotation annotation,
    BuildStep buildStep,
  ) async* {
    final config = Config.withOverride(
      _config,
      suppressFieldFactory: annotation.suppressFieldFactory,
    );

    for (final value in emitFromData(
      await parseElementAsync(
        buildStep,
        library,
        element,
        annotation,
        _logger,
      ),
      config,
    )) {
      yield value.toString();
    }
  }
}
