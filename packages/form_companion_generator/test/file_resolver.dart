// See LICENCE file in the root.

import 'dart:collection';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';

// TODO(yfakariya): Rename to SessionResolver
class FileResolver implements Resolver {
  // This resolver based on AnalyzerResolver of build_resolvers source (3-Clause BSD License)
  // https://github.com/dart-lang/build/blob/a387d70094c464901d0d29e9ae90293f50dcf90b/build_resolvers/lib/src/resolver.dart#L146

  final AnalysisSession _session;
  final AssetId _inputId;
  final List<AssetId> _entryPoints = [];
  final Map<AssetId, String> _assetPathes = {};

  FileResolver(LibraryElement input)
      : _session = input.session,
        _inputId = _assetIdForElement(input) {
    _assetPathes[_inputId] = input.source.fullName;
  }

  Future<void> _resolveIfNecessary(AssetId id,
      {required bool transitive}) async {
    if (!_entryPoints.contains(id)) {
      // We only want transitively resolved ids in `_entrypoints`.
      if (transitive) {
        _entryPoints.add(id);
      }
    }
  }

  static AssetId _assetIdForElement(Element element) {
    final source = element.source;
    if (source == null) {
      throw UnresolvableAssetException(
          '${element.name} does not have a source');
    }

    final uri = source.uri;
    if (!uri.isScheme('package') && !uri.isScheme('asset')) {
      throw UnresolvableAssetException('${element.name} in ${source.uri}');
    }

    return AssetId.resolve(source.uri);
  }

  @override
  Future<AssetId> assetIdForElement(
    Element element,
  ) async {
    final assetId = _assetIdForElement(element);
    _assetPathes[assetId] = element.source!.fullName;
    return assetId;
  }

  @override
  Future<AstNode?> astNodeFor(
    Element element, {
    bool resolve = false,
  }) async {
    final library = element.library;
    if (library == null) {
      // Invalid elements (e.g. an MultiplyDefinedElement) are not part of any
      // library and can't be resolved like this.
      return null;
    }

    final path = library.source.fullName;

    if (resolve) {
      return (await _session.getResolvedLibrary(path) as ResolvedLibraryResult)
          .getElementDeclaration(element)
          ?.node;
    } else {
      return (_session.getParsedLibrary(path) as ParsedLibraryResult)
          .getElementDeclaration(element)
          ?.node;
    }
  }

  @override
  Future<CompilationUnit> compilationUnitFor(
    AssetId assetId, {
    bool allowSyntaxErrors = false,
  }) async {
    await _resolveIfNecessary(assetId, transitive: false);
    await _resolveIfNecessary(assetId, transitive: false);
    final path = _assetPath(assetId);
    final parsedResult = _session.getParsedUnit(path) as ParsedUnitResult;
    if (!allowSyntaxErrors && parsedResult.errors.isNotEmpty) {
      throw SyntaxErrorInAssetException(assetId, [parsedResult]);
    }
    return parsedResult.unit;
  }

  @override
  Future<LibraryElement?> findLibraryByName(String libraryName) async {
    await for (final library in libraries) {
      if (library.name == libraryName) {
        return library;
      }
    }
    return null;
  }

  @override
  Future<bool> isLibrary(AssetId assetId) async {
    await _resolveIfNecessary(assetId, transitive: true);
    if (assetId.extension != '.dart') {
      return false;
    }

    final result = _session.getFile(_assetPath(assetId)) as FileResult;
    return !result.isPart;
  }

  @override
  Stream<LibraryElement> get libraries async* {
    await _resolveIfNecessary(_inputId, transitive: true);

    final seen = <LibraryElement>{};
    final toVisit = Queue<LibraryElement>();

    // keep a copy of entry points in case [_resolveIfNecessary] is called
    // before this stream is done.
    final entryPoints = _entryPoints.toList();
    for (final entryPoint in entryPoints) {
      if (!await isLibrary(entryPoint)) {
        continue;
      }
      final library = await libraryFor(entryPoint, allowSyntaxErrors: true);
      toVisit.add(library);
      seen.add(library);
    }
    while (toVisit.isNotEmpty) {
      final current = toVisit.removeFirst();
      yield current;
      final toCrawl = current.importedLibraries
          .followedBy(current.exportedLibraries)
          .where((l) => !seen.contains(l))
          .toSet();
      toVisit.addAll(toCrawl);
      seen.addAll(toCrawl);
    }
  }

  @override
  Future<LibraryElement> libraryFor(
    AssetId assetId, {
    bool allowSyntaxErrors = false,
  }) async {
    await _resolveIfNecessary(assetId, transitive: true);
    final uri = assetId.uri;

    final library = await _session.getLibraryByUri(uri.toString());
    if (library is! LibraryElementResult) {
      if (library is NotLibraryButPartResult) {
        throw NonLibraryAssetException(assetId);
      } else {
        throw AssetNotFoundException(assetId);
      }
    }

    // NOTE: this implementation does not support syntax error reporting.

    return library.element;
  }

  String _assetPath(AssetId assetId) {
    final path = _assetPathes[assetId];
    if (path == null) {
      throw Exception(
        "Asset '$assetId' cannot be located. Known libraries are: $_assetPathes",
      );
    }

    return path;
  }
}
