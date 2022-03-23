// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:meta/meta.dart';

import 'config.dart';
import 'dependency.dart';
import 'emitter/instantiation.dart';
import 'model.dart';
import 'node_provider.dart';
import 'parameter.dart';
import 'type_instantiation.dart';

part 'emitter/field_factory.dart';
part 'emitter/typed_property.dart';

const _todoHeader = 'TODO(CompanionGenerator):';

/// Emits lines for specified data.
Stream<Object> emitFromData(
  LibraryElement sourceLibrary,
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Config config,
) async* {
  for (final global in emitGlobal(sourceLibrary, data, config)) {
    yield global;
  }

  yield emitPropertyAccessor(data.name, data.properties, config);
  if (!config.suppressFieldFactory) {
    yield await emitFieldFactoriesAsync(nodeProvider, data, config);
  }
}

final _formCompanionPresenterImport = LibraryImport(
  'package:form_companion_presenter/form_companion_presenter.dart',
);

// TODO(yfakariya): test `asPart`

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

  final sortedImports = [...data.imports, _formCompanionPresenterImport]
    ..sort((l, r) => l.library.compareTo(r.library));

  final dartImports =
      sortedImports.where((i) => i.library.startsWith('dart:')).toList();
  final packageImports = sortedImports.skip(dartImports.length).toList();

  if (config.asPart) {
    yield "// This file is part of '${sourceLibrary.source.shortName}' file,";
    yield '// so you have to declare following import directives in it.';
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

  if (config.asPart) {
    yield "// import '${sourceLibrary.source.shortName}';";
  } else {
    yield "import '${sourceLibrary.source.shortName}';";
  }
}

Iterable<String> _emitImport(LibraryImport import, bool mustBeComment) sync* {
  final prefix = mustBeComment ? '// ' : '';
  final sortedTypes = [...import.showingTypes]..sort();
  if (sortedTypes.isEmpty) {
    yield "${prefix}import '${import.library}';";
  } else {
    yield "${prefix}import '${import.library}' show ${sortedTypes.join(', ')};";
  }

  if (import.prefixes.isEmpty) {
    return;
  }

  final sortedPrefixes = [...import.prefixes]
    ..sort((l, r) => l.key.compareTo(r.key));
  for (final prefixed in sortedPrefixes) {
    final sortedPrefixedTypes = [...prefixed.value]..sort();
    if (sortedPrefixedTypes.isEmpty) {
      yield "${prefix}import '${import.library}' as ${prefixed.key};";
    } else {
      yield "${prefix}import '${import.library}' as ${prefixed.key} show ${sortedPrefixedTypes.join(', ')};";
    }
  }
}
