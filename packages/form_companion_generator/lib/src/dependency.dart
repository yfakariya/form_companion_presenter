// See LICENCE file in the root.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'node_provider.dart';
import 'utilities.dart';

/// Represents library import.
@sealed
class LibraryImport {
  /// A library ID to be imported.
  ///
  /// Note that this ID is logical library ID, that is, directly under `lib/`
  /// rather than `lib/src/`.
  final String library;

  final Set<String> _types = {};

  /// A collection of type names which should be specified in `show`
  /// namespace combinator of a non-prefixed `import` directive.
  Iterable<String> get showingTypes => _types.toList()..sort();

  final Map<String, Set<String>> _prefixes = {};

  /// A collection of prefixes to emit prefixed `import` directives.
  Iterable<MapEntry<String, Iterable<String>>> get prefixes sync* {
    for (final key in [..._prefixes.keys]..sort()) {
      yield MapEntry(key, _prefixes[key]!.toList()..sort());
    }
  }

  /// Creates a new [LibraryImport] instance.
  LibraryImport(this.library);

  /// Adds a specified [Identifier] as imported from this [library].
  void addType(Identifier identifier) {
    if (identifier is PrefixedIdentifier) {
      final prefixed = _prefixes[identifier.prefix.name];
      if (prefixed == null) {
        _prefixes[identifier.prefix.name] = {identifier.identifier.name};
      } else {
        prefixed.add(identifier.identifier.name);
      }
    } else {
      assert(identifier is SimpleIdentifier);
      addTypeName(identifier.name);
    }
  }

  /// Adds a specified named type as imported from this [library].
  void addTypeName(String typeName) => _types.add(typeName);

  @override
  String toString() {
    final buffer = StringBuffer();
    final base = "import '$library'";
    buffer.write(base);

    if (_types.isNotEmpty) {
      buffer
        ..write(' show ')
        ..write(_types.join(', '));
    }

    for (final prefix in _prefixes.entries) {
      buffer
        ..write(';')
        ..write(base)
        ..write(' as ')
        ..write(prefix.key)
        ..write(' show ')
        ..write(prefix.value.join(', '));
    }

    return buffer.toString();
  }
}

/// A visitor for [AstNode] tree to collect dependent libraries.
@sealed
class DependentLibraryCollector extends RecursiveAstVisitor<void> {
  static final _dartCoreLibraryId = 'dart:core';

  final NodeProvider _nodeProvider;
  final Logger _logger;
  final String _targetLibraryId;
  final Map<String, LibraryImport> _imports = {};
  final Map<String, String> _librarySourceMap = {};
  final Map<String, List<LibraryElement>> _librariesCache = {};

  /// Context class of current traversal.
  late ClassElement _contextClass;

  late List<String> _warnings;

  /// Collected information as unordered collection of [LibraryElement].
  Iterable<LibraryImport> get imports => _imports.values;

  final List<Future<void>> _pendingAsyncOperations = [];

  /// Initializes a new [DependentLibraryCollector] instance.
  ///
  /// [targetLibrary] is the library itself to be scanned.
  /// References to this library will not be collected.
  DependentLibraryCollector(
    this._nodeProvider,
    this._logger,
    LibraryElement targetLibrary,
  ) : _targetLibraryId = targetLibrary.identifier;

  void reset(ClassElement contextClass, List<String> warnings) {
    assert(
      _pendingAsyncOperations.isEmpty,
      'endAsync() has not been called.',
    );
    _contextClass = contextClass;
    _warnings = warnings;
  }

  Completer<void> _beginAsync() {
    final completer = Completer<void>();
    _pendingAsyncOperations.add(completer.future);
    return completer;
  }

  Future<void> endAsync() async {
    await Future.wait(_pendingAsyncOperations);
    _pendingAsyncOperations.clear();
  }

  FutureOr<LibraryImport?> _getLibraryImportEntryAsync(Element element) async {
    assert(
      element.library != null,
      "element '$element' (${element.runtimeType}) may not be resolved.",
    );

    final library = element.library!;
    if (library.identifier == _targetLibraryId) {
      // Current library, so import is not necessary.
      return null;
    }

    if (library.identifier == _dartCoreLibraryId) {
      // dart:core have not been imported, so ignore it.
      return null;
    }

    var logicalLibraryId = _librarySourceMap[library.identifier];
    logicalLibraryId ??= _librarySourceMap[library.identifier] =
        await _findLogicalLibraryIdAsync(
      library.identifier,
      library.source.fullName,
      element,
    );

    final entry = _imports[logicalLibraryId];
    if (entry != null) {
      return entry;
    }

    return _imports[logicalLibraryId] = LibraryImport(logicalLibraryId);
  }

  static final _src =
      RegExp(r'src/.+\.dart$', caseSensitive: !Platform.isWindows);
  // static final _

  FutureOr<String> _findLogicalLibraryIdAsync(
    String sourceLibraryId,
    String sourceLibraryLocation,
    Element targetElement,
  ) async {
    final match = _src.firstMatch(sourceLibraryId);
    if (match == null) {
      // sourceLibraryId is not `src/` library.
      return sourceLibraryId;
    }

    final libraryDirectory = sourceLibraryLocation.substring(
      0,
      // end (exclusive): original_length - suffix_length + 1
      //   suffix_length = match.end - match.start + 1
      sourceLibraryLocation.length - (match.end - match.start),
    );

    var libraries = _librariesCache[libraryDirectory];
    libraries ??= _librariesCache[libraryDirectory] =
        (await Directory(libraryDirectory)
                .listSync()
                .where((e) => e.path.endsWith('.dart'))
                .map(
      (file) async {
        final normalizedPath = path.normalize(file.path);
        final resolvedLibrary =
            await targetElement.session!.getResolvedLibrary(normalizedPath);
        if (resolvedLibrary is! ResolvedLibraryResult) {
          throw AnalysisException(
            "Failed to resolve logical library candidate '$normalizedPath'"
            " for source library '$sourceLibraryId'. $resolvedLibrary",
          );
        }

        return resolvedLibrary.element;
      },
    ).toListAsync())
            .where((l) =>
                l.exportedLibraries.any((e) => e.identifier == sourceLibraryId))
            .toList();

    if (libraries.isEmpty) {
      throw AnalysisException(
          "Failed to resolve logical library for source library '$sourceLibraryId'"
          " for '$targetElement' in the directory '$libraryDirectory'. ");
    }

    if (libraries.length > 1) {
      final message =
          "Library import '${libraries.first.identifier}' may be incorrect because "
          'the locator failed to uniquely locate importing library for '
          "'$sourceLibraryId' for '$targetElement' in directory '$libraryDirectory'.";
      _logger.warning(message);
      _warnings.add(message);
    }

    _logger.fine('Found ${libraries.first.identifier} for $targetElement');
    return libraries.first.identifier;
  }

  void _processTypeAnnotation(TypeAnnotation type) {
    if (type is NamedType) {
      // Calls override
      visitNamedType(type);
    } else if (type is GenericFunctionType) {
      // Delegates super class implementation,
      // it should call visitNamedType() eventually.
      visitGenericFunctionType(type);
    } else {
      throw Exception("Type of '$type' (${type.runtimeType}) is unexpected.");
    }
  }

  Future<void> _recordTypeIdAsync(Element holderElement, Identifier id) async =>
      (await _getLibraryImportEntryAsync(holderElement))?.addType(id);

  Future<AstNode> _beginGetElementDeclaration(String fieldName) async =>
      _nodeProvider
          .getElementDeclarationAsync(_contextClass.getField(fieldName)!);

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    super.visitFieldFormalParameter(node);

    if (node.type == null) {
      // Process field here.
      final element = node.declaredElement;
      assert(
        element is FieldFormalParameterElement,
        "node.declaraedElement of '$node' is not 'FieldFormalParameterElement' but '${element.runtimeType}'.",
      );

      final completer = _beginAsync();
      _beginGetElementDeclaration(node.identifier.name).then((field) {
        try {
          if (field is FieldDeclaration) {
            final fieldType = field.fields.type;
            assert(
              fieldType != null,
              "Failed to fetch type of '${node.identifier.name}' field of '$_contextClass'.",
            );

            _processTypeAnnotation(fieldType!);
          } else if (field is VariableDeclaration) {
            final fieldType = (field.parent! as VariableDeclarationList).type;
            assert(
              fieldType != null,
              "Failed to fetch type of '${node.identifier.name}' field of '$_contextClass'.",
            );

            _processTypeAnnotation(fieldType!);
          } else {
            throw Exception(
              "Type of '$field' (${field.runtimeType}) is unexpected.",
            );
          }
        }
        // ignore: avoid_catches_without_on_clauses
        catch (e, s) {
          completer.completeError(e, s);
        } finally {
          if (!completer.isCompleted) {
            completer.complete();
          }
        }
      }).catchError(
        // ignore: avoid_types_on_closure_parameters
        (Object e, StackTrace s) async {
          if (!completer.isCompleted) {
            completer.completeError(e, s);
          }
        },
      );
    }
  }

  @override
  void visitNamedType(NamedType node) {
    assert(
      node.type != null,
      "NamedType.type of '$node'(${node.runtimeType}) is null.",
    );

    final type = node.type!;
    if (type is NeverType ||
        type is VoidType ||
        type is DynamicType ||
        type is TypeParameterType ||
        type.getDisplayString(withNullability: false).startsWith('_')) {
      // Above dart:core types, type parameter, private types never to be imported
      return;
    }

    assert(
      type.element != null || type.alias?.element != null,
      "DartType.element of '$node'(${node.runtimeType}) ->"
      "'$type'(${type.runtimeType}), "
      "alias:'${type.alias}' is null.",
    );

    final completer = _beginAsync();
    _recordTypeIdAsync(type.element ?? type.alias!.element, node.name)
        .then((_) async {
      completer.complete();
    }).catchError(
      // ignore: avoid_types_on_closure_parameters
      (Object e, StackTrace s) async {
        completer.completeError(e, s);
      },
    );
  }
}
