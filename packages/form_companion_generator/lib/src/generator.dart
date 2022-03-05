// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'config.dart';
import 'emitter.dart';
import 'form_field_locator.dart';
import 'model.dart';
import 'node_provider.dart';
import 'parser.dart';

// TODO(yfakariya): Integration testing of generator.
// TODO(yfakariya): Integration testing via build_runner.
// TODO(yfakariya): Integration testing which runs generated codes.

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
  ) =>
      generateCore(library);

  /// Generate form companion source code from specified library.
  @visibleForTesting
  FutureOr<String?> generateCore(
    LibraryReader library,
  ) async {
    final values = <String>{};

    for (final classElement in library.classes
        .where((c) => c.metadata.any(isFormCompanionAnnotation))) {
      final annotation = ConstantReader(classElement.metadata
          .firstWhere(isFormCompanionAnnotation)
          .computeConstantValue());
      await generateForAnnotatedElement(
        classElement,
        FormCompanionAnnotation(annotation),
      ).forEach(values.add);
    }

    return values.join('\n\n');
  }

  /// Generate form companion source code from specified class and its annotation.
  ///
  /// It is caller's responsibility to provide [element] which has [annotation].
  @visibleForTesting
  Stream<String> generateForAnnotatedElement(
    ClassElement element,
    FormCompanionAnnotation annotation,
  ) async* {
    final config = Config.withOverride(
      _config,
      suppressFieldFactory: annotation.suppressFieldFactory,
    );

    final nodeProvider = NodeProvider();
    final formFieldLocator = await FormFieldLocator.createAsync(
      element.session!,
      _config.extraLibraries,
    );

    await for (final value in emitFromData(
      nodeProvider,
      await parseElementAsync(
        nodeProvider,
        formFieldLocator,
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
