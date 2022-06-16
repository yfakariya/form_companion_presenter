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
  final Logger _logger = Logger('CompanionGenerator');

  /// Initialize a new [CompanionGenerator] instance.
  CompanionGenerator(Map<String, dynamic> config) : _config = Config(config) {
    _logger.fine('Options: $config');
  }

  @override
  FutureOr<String?> generate(
    LibraryReader library,
    BuildStep buildStep,
  ) =>
      generateCore(buildStep.resolver, library);

  /// Generate form companion source code from specified library.
  @visibleForTesting
  FutureOr<String?> generateCore(
    Resolver resolver,
    LibraryReader library,
  ) async {
    final values = <String>{};
    _logger.fine('Processing ${library.element.source.shortName}');
    for (final classElement in library.classes
        .where((c) => c.metadata.any(isFormCompanionAnnotation))) {
      _logger.fine('Processing ${classElement.name} class');
      await generateForAnnotatedElement(
        resolver,
        classElement,
        FormCompanionAnnotation.forClass(classElement)!,
      ).forEach(values.add);
    }

    return values.join('\n\n');
  }

  /// Generate form companion source code from specified class and its annotation.
  ///
  /// It is caller's responsibility to provide [element] which has [annotation].
  @visibleForTesting
  Stream<String> generateForAnnotatedElement(
    Resolver resolver,
    ClassElement element,
    FormCompanionAnnotation annotation,
  ) async* {
    final nodeProvider = NodeProvider(resolver);
    final formFieldLocator = await FormFieldLocator.createAsync(
      resolver,
      _config.extraLibraries,
      _logger,
    );

    await for (final value in emitFromData(
      element.library,
      nodeProvider,
      await parseElementAsync(
        _config,
        nodeProvider,
        formFieldLocator,
        element,
        annotation,
        _logger,
      ),
      _config,
      _logger,
    )) {
      yield value.toString();
    }
  }
}
