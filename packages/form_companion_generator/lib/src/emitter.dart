// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:collection/collection.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'config.dart';
import 'dependency.dart';
import 'emitter/instantiation.dart';
import 'model.dart';
import 'node_provider.dart';
import 'type_instantiation.dart';

part 'emitter/field_factory.dart';
part 'emitter/typed_property.dart';
part 'emitter/typed_property/form_properties_builder.dart';
part 'emitter/typed_property/descriptors.dart';
part 'emitter/typed_property/extension.dart';
part 'emitter/typed_property/form_properties.dart';
part 'emitter/typed_property/values.dart';

const _todoHeader = 'TODO(CompanionGenerator):';

/// Emits lines for specified data.
Stream<Object> emitFromData(
  LibraryElement sourceLibrary,
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Config config,
  Logger logger,
) async* {
  if (data.properties.isEmpty) {
    for (final warning in data.warnings) {
      yield '// $_todoHeader WARNING - $warning';
    }

    yield '// TODO(CompanionGenerator): WARNING - No properties are found in ${data.name} class.\n';
    return;
  }

  for (final global in emitGlobal(sourceLibrary, data, config)) {
    yield global;
  }

  yield emitPropertyAccessor(data.name, data.properties, config);

  // blank line
  yield '';

  yield await emitFieldFactoriesAsync(nodeProvider, data, config, logger);
}

final _formCompanionPresenterImport = LibraryImport(
  'package:form_companion_presenter/form_companion_presenter.dart',
);

/// Emits global parts.
@visibleForTesting
Iterable<String> emitGlobal(
  LibraryElement sourceLibrary,
  PresenterDefinition data,
  Config config,
) sync* {
  for (final warning in data.warnings) {
    yield '// $_todoHeader WARNING - $warning';
  }

  if (data.warnings.isNotEmpty && data.imports.isNotEmpty) {
    yield '';
  }

  // For as_part mode, importing 'form_companion_presenter' is not required
  // because source file should have @FormCompanion,
  // which is declared in 'form_companion_presenter' itself.
  final sortedImports = (config.asPart
      ? data.imports
      : [...data.imports, _formCompanionPresenterImport])
    ..sort((l, r) => l.library.compareTo(r.library));

  final dartImports =
      sortedImports.where((i) => i.library.startsWith('dart:')).toList();
  final packageImports =
      sortedImports.where((i) => i.library.startsWith('package:')).toList();
  final relativeImports = sortedImports
      .where(
        (i) =>
            !i.library.startsWith('dart:') && !i.library.startsWith('package:'),
      )
      .toList();

  if (config.asPart) {
    yield "// This file is part of '${sourceLibrary.source.shortName}' file,";
    yield '// so you have to declare following import directives in it.';
    yield '';
  }

  for (final import in dartImports) {
    yield* _emitImport(import, config.asPart);
  }

  if (dartImports.isNotEmpty) {
    yield '';
  }

  for (final import in packageImports) {
    yield* _emitImport(import, config.asPart);
  }

  if (packageImports.isNotEmpty) {
    yield '';
  }

  for (final import in relativeImports) {
    if (config.asPart && import.library == sourceLibrary.source.shortName) {
      // For as_part mode, importing parent file is not required obviously.
      continue;
    }

    yield* _emitImport(import, config.asPart);
  }
}

Iterable<String> _emitImport(LibraryImport import, bool mustBeComment) sync* {
  final prefix = mustBeComment ? '// ' : '';
  if (import.shouldEmitSimpleImports) {
    yield "${prefix}import '${import.library}';";
  } else if (import.showingTypes.isNotEmpty) {
    final sortedTypes = [...import.showingTypes]..sort();
    yield "${prefix}import '${import.library}' show ${sortedTypes.join(', ')};";
  }

  if (import.prefixes.isEmpty) {
    return;
  }

  final sortedPrefixes = [...import.prefixes]
    ..sort((l, r) => l.key.compareTo(r.key));
  for (final prefixed in sortedPrefixes) {
    final sortedPrefixedTypes = [...prefixed.value]..sort();
    assert(sortedPrefixedTypes.isNotEmpty);
    yield "${prefix}import '${import.library}' as ${prefixed.key} show ${sortedPrefixedTypes.join(', ')};";
  }
}
