// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:meta/meta.dart';

import 'utilities.dart';

/// Provides [AstNode] for [Element].
///
/// This class also provides:
///
/// * Caching. `AnalysisSession.getResolvedLibrary` always kick resolution,
///   so it is reasonable to build cache of [ResolvedLibraryResult].
///   In addition, calling [ResolvedLibraryResult.getElementDeclaration] also
///   requires traverse of AST tree, so caching it also usable.
/// * Library routing. This class automatically select appropriate
///   [ResolvedLibraryResult] for specified [Element].
@sealed
class NodeProvider {
  /// Keys are URI of the library.
  final Map<Uri, _NodeCache> _caches = {};

  /// Returns a [AstNode] which is associated to specified [element].
  ///
  /// This method just returns from library resolution cache synchronously.
  /// If the library resolution is not cached, throws [StateError].
  @optionalTypeArgs
  T getElementDeclarationSync<T extends AstNode>(
    Element element,
  ) {
    final key = element.nonSynthetic.source!.uri;
    final cache = _caches[key];
    if (cache == null) {
      throw StateError("Library '${element.library}' is not resolved yet.");
    }

    return cache.getElementDeclaration<T>(element);
  }

  // TODO(yfakariya): This may not be necessary.

  /// Resolves specified [libraries] and caches it.
  ///
  /// This method exists for avoid asynchronous in following tasks.
  FutureOr<void> resolveLibrariesAsync(
    Iterable<LibraryElement> libraries,
  ) async {
    final asMap = {for (final l in libraries) l.source.uri: l};
    for (final entry in asMap.entries) {
      if (!_caches.containsKey(entry.key)) {
        _caches[entry.key] = await _buildLibraryCacheAsync(entry.value);
      }
    }
  }

  /// Returns a [AstNode] which is associated to specified [element].
  @optionalTypeArgs
  FutureOr<T> getElementDeclarationAsync<T extends AstNode>(
    Element element,
  ) async {
    final key = element.nonSynthetic.source!.uri;
    var cache = _caches[key];
    cache ??= _caches[key] = await _buildLibraryCacheAsync(element);
    return cache.getElementDeclaration<T>(element);
  }

  Future<_NodeCache> _buildLibraryCacheAsync(Element element) async {
    final result =
        await element.session!.getResolvedLibraryByElement(element.library!);
    if (result is! ResolvedLibraryResult) {
      throwError(
        message: "Failed to resolve library '${element.library!}'. $result",
        element: element.library!,
      );
    }

    return _NodeCache(result);
  }
}

class _NodeCache {
  final ResolvedLibraryResult _library;

  Uri get key => _library.element.source.uri;

  /// Keys are offset fetched via [Element.nameOffset].
  final Map<int, AstNode> _cache = {};

  _NodeCache(this._library);

  @optionalTypeArgs
  T getElementDeclaration<T extends AstNode>(Element element) {
    final realElement = element.nonSynthetic;
    return _cache.putIfAbsent(
      realElement.nameOffset,
      () {
        final result = _library.getElementDeclaration(realElement);
        assert(
          result != null,
          "Failed to call '${_library.element}'.getElementDeclaration('$realElement').",
        );
        return result!.node;
      },
    ) as T;
  }
}
