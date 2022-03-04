// See LICENCE file in the root.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:path/path.dart' as path;

const _sourceDirectory = '../form_companion_generator_test/lib';

final _contextCollection = AnalysisContextCollection(
  includedPaths: Directory(_sourceDirectory)
      .listSync(recursive: true, followLinks: false)
      .where((e) => e.existsSync() && e.path.toLowerCase().endsWith('.dart'))
      .map((e) => path.canonicalize(e.path))
      .toList(),
);

FutureOr<ResolvedLibraryResult> getElement(String fileName) async {
  final filePath = path.canonicalize('$_sourceDirectory/$fileName');
  final result = await _contextCollection
      .contextFor(filePath)
      .currentSession
      .getResolvedLibrary(filePath);
  if (result is! ResolvedLibraryResult) {
    throw Exception('Failed to resolve "$filePath": ${result.runtimeType}');
  }

  return result;
}

// @deprecated
// FutureOr<Resolver> getResolver(
//   String fileName,
//   Completer<void> tearDownEvent,
// ) async =>
//     await resolveSource(
//       path.canonicalize('$_sourceDirectory/$fileName'),
//       (r) => r,
//       tearDown: tearDownEvent.future,
//     );

// FutureOr<LibraryReader> getLibraryReader(
//   String libraryName,
//   Completer<void> tearDownEvent,
// ) async
// //  =>
// //     LibraryReader((await (await getResolver('$libraryName.dart', tearDownEvent))
// //         .libraries
// //         .singleWhere((future) async {
// //       final element = await future;
// //       printOnFailure('Library: ${element.library.name}');
// //       return element.library.name == libraryName;
// //     })));
// {
//   resolveFile2(path: path);
//   await for (final element
//       in (await getResolver('$libraryName.dart', tearDownEvent)).libraries) {
//     printOnFailure('Library: ${element.library.name}');
//     if (element.library.name == libraryName) {
//       return LibraryReader(element);
//     }
//   }

//   throw Exception('Failed to find library ${libraryName}');
// }
