// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:meta/meta.dart';

import 'config.dart';
import 'dependency.dart';
import 'emitter/assignment.dart';
import 'emitter/instantiation.dart';
import 'model.dart';
import 'node_provider.dart';
import 'parameter.dart';
import 'type_instantiation.dart';
import 'utilities.dart';

part 'emitter/field_factory.dart';
part 'emitter/typed_property.dart';

const _todoHeader = 'TODO(CompanionGenerator):';

/// Emits lines for specified data.
Stream<Object> emitFromData(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Config config,
) async* {
  for (final global in emitGlobal(data, config)) {
    yield global;
  }

  yield emitPropertyAccessor(data.name, data.properties.values, config);
  if (!config.suppressFieldFactory) {
    yield await emitFieldFactoriesAsync(nodeProvider, data, config);
  }
}

/// Emits global parts.
@visibleForTesting
Iterable<String> emitGlobal(
  PresenterDefinition data,
  Config config,
) sync* {
  for (final warning in data.warnings) {
    yield '// $_todoHeader WARNING - $warning';
  }

  if (data.warnings.isNotEmpty && data.imports.isNotEmpty) {
    yield '';
  }

  final sortedImports = [...data.imports]
    ..sort((l, r) => l.library.compareTo(r.library));

  final dartImports =
      sortedImports.where((i) => i.library.startsWith('dart:')).toList();
  final packageImports = sortedImports.skip(dartImports.length).toList();

  for (final import in dartImports) {
    yield* _emitImport(import);
  }

  if (dartImports.isNotEmpty && packageImports.isNotEmpty) {
    yield '';
  }

  for (final import in packageImports) {
    yield* _emitImport(import);
  }
}

Iterable<String> _emitImport(LibraryImport import) sync* {
  final sortedTypes = [...import.showingTypes]..sort();
  yield "import '${import.library}' show ${sortedTypes.join(', ')};";
  if (import.prefixes.isEmpty) {
    return;
  }

  final sortedPrefixes = [...import.prefixes]
    ..sort((l, r) => l.key.compareTo(r.key));
  for (final prefix in sortedPrefixes) {
    final sortedPrefixedTypes = [...prefix.value]..sort();
    yield "import '${import.library}' as ${prefix.key} show ${sortedPrefixedTypes.join(', ')};";
  }
}
