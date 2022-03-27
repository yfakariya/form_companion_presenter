// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:meta/meta.dart';

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
  final Map<String, _NodeCache> _caches = {};
  final Resolver _resolver;

  /// Gets a libraries [Stream] of current builder session.
  Stream<LibraryElement> get libraries => _resolver.libraries;

  /// Initializes a new [NodeProvider] instance.
  NodeProvider(this._resolver);

  /// Returns a [AstNode] which is associated to specified [element].
  @optionalTypeArgs
  FutureOr<T> getElementDeclarationAsync<T extends AstNode>(
    Element element,
  ) async {
    final key = element.nonSynthetic.library!.identifier;
    var cache = _caches[key];
    cache ??= _caches[key] = _NodeCache(element.library!.identifier, _resolver);
    return await cache.getElementDeclarationAsync<T>(element);
  }
}

class _NodeCache {
  final Resolver _resolver;
  final String key;

  /// Keys are offset fetched via [Element.nameOffset].
  final Map<int, AstNode> _cache = {};

  _NodeCache(this.key, this._resolver);

  @optionalTypeArgs
  FutureOr<T> getElementDeclarationAsync<T extends AstNode>(
    Element element,
  ) async {
    final realElement = element.nonSynthetic;
    return (_cache[realElement.nameOffset] ??=
        (await _resolver.astNodeFor(realElement, resolve: true))!) as T;
  }
}
