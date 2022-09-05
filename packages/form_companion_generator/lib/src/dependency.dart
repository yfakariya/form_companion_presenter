// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'model.dart' show GenericType;
import 'node_provider.dart';

/// Represents library import.
@sealed
class LibraryImport {
  /// A library ID to be imported.
  ///
  /// Note that this ID is logical library ID, that is, directly under `lib/`
  /// rather than `lib/src/`.
  final String library;

  final _types = <String>{};

  var _importsAllTypes = false;

  /// `true` if non-prefixed `import` directive without `show` namespace
  /// combinator should be emitted.
  bool get shouldEmitSimpleImports =>
      _importsAllTypes || (_types.isEmpty && _prefixes.isEmpty);

  final _allTypesImportedPrefixes = <String>{};

  /// A collection of type names which should be specified in `show`
  /// namespace combinator of a non-prefixed `import` directive.
  ///
  /// Note that this value will be empty if the `import` directive should not
  /// have `show` namespace combinator.
  Iterable<String> get showingTypes => _importsAllTypes ? [] : _types.toList()
    ..sort();

  final Map<String, Set<String>> _prefixes = {};

  /// A collection of prefixes to emit prefixed `import` directives.
  Iterable<MapEntry<String, Iterable<String>>> get prefixes sync* {
    for (final key in [..._prefixes.keys]..sort()) {
      if (_allTypesImportedPrefixes.contains(key)) {
        yield MapEntry(key, []);
      } else {
        yield MapEntry(key, _prefixes[key]!.toList()..sort());
      }
    }
  }

  /// Creates a new [LibraryImport] instance.
  LibraryImport(this.library);

  /// Adds a specified [Identifier] as imported from this [library].
  void addType(Identifier identifier) {
    if (identifier is PrefixedIdentifier) {
      addTypeNameToPrefixed(identifier.prefix.name, identifier.identifier.name);
    } else {
      assert(identifier is SimpleIdentifier);
      addTypeName(identifier.name);
    }
  }

  /// Adds a specified named type as imported from this [library].
  void addTypeName(String typeName) {
    _types.add(typeName);
  }

  /// Adds a specified named type as imported from this [library] with specified [prefix].
  void addTypeNameToPrefixed(String prefix, String typeName) {
    final prefixed = _prefixes[prefix];
    if (prefixed == null) {
      _prefixes[prefix] = {typeName};
    } else {
      prefixed.add(typeName);
    }
  }

  /// Marks this library should not have `show` namespace combinator.
  void markImport() {
    _importsAllTypes = true;
  }

  /// Marks this library should not have `show` namespace combinator
  /// for specified [prefix].
  void markImportAsPrefixed(String prefix) {
    _allTypesImportedPrefixes.add(prefix);
  }
}

/// A visitor for [AstNode] tree to collect dependent libraries.
@sealed
class DependentLibraryCollector extends RecursiveAstVisitor<void> {
  static final _dartCoreLibraryId = 'dart:core';

  final NodeProvider _nodeProvider;
  final List<LibraryElement> _allLibraries;
  final Logger _logger;

  /// `null` if `asPart` is false.
  final String? _presenterLibraryId;
  final Map<String, LibraryImport> _imports = {};
  final Map<String, String> _librarySourceMap = {};
  final Map<String, List<LibraryElement>> _librariesCache = {};

  final Map<String, String> _relativeImportIdentityMap = {};

  /// Context class of current traversal.
  late InterfaceElement _contextClass;

  late List<String> _warnings;

  /// Collected information as unordered collection of [LibraryElement].
  Iterable<LibraryImport> get imports => _imports.values;

  final List<Future<void>> _pendingAsyncOperations = [];

  /// Initializes a new [DependentLibraryCollector] instance.
  ///
  /// [presenterLibrary] is the library itself to be scanned.
  /// References to this library will not be collected.
  DependentLibraryCollector(
    this._nodeProvider,
    this._allLibraries,
    this._logger,
    LibraryElement presenterLibrary,
  ) : _presenterLibraryId = presenterLibrary.identifier {
    for (final import in presenterLibrary.libraryImports) {
      final importedLibraryIdentifier = import.importedLibrary?.identifier;
      final importUri = import.uri;
      if (importUri is! DirectiveUriWithSource) {
        throw Exception(
          'Unexpected import directive : ${importUri.runtimeType}',
        );
      }

      if (importedLibraryIdentifier != null &&
          importUri.source.shortName != importedLibraryIdentifier) {
        _relativeImportIdentityMap[importedLibraryIdentifier] =
            importUri.relativeUriString;
      }
    }

    _relativeImportIdentityMap[presenterLibrary.identifier] =
        presenterLibrary.source.shortName;
    _imports[presenterLibrary.source.shortName] =
        LibraryImport(presenterLibrary.source.shortName);
  }

  /// Resets internal state with specified information for new session.
  ///
  /// [contextClass] is [InterfaceElement] for class which declares the target
  /// which will be traversed by this visitor.
  /// [warnings] are list to record warnings found in new session.
  void reset(InterfaceElement contextClass, List<String> warnings) {
    // check endAsync() has been called.
    assert(_pendingAsyncOperations.isEmpty);
    _contextClass = contextClass;
    _warnings = warnings;
  }

  /// Bookkeeps internal pending asynchronous information records and
  /// returns [Completer] to notify completion to [endAsync] caller.
  Completer<void> _beginAsync() {
    final completer = Completer<void>();
    _pendingAsyncOperations.add(completer.future);
    return completer;
  }

  /// Awaits pending asynchronous operations.
  Future<void> endAsync() async {
    await Future.wait(_pendingAsyncOperations);
    _pendingAsyncOperations.clear();
  }

  LibraryImport? _getLibraryImportEntry(Element element) {
    assert(element.library != null);

    final library = element.library!;
    return _getLibraryImportEntryDirect(
      library.identifier,
      () => _findLogicalLibraryId(
        library.identifier,
        library.source.fullName,
        element,
      ),
    );
  }

  LibraryImport? _getLibraryImportEntryDirect(
    String libraryIdentifier,
    String Function()? logicalLibraryIdFinder,
  ) {
    if (libraryIdentifier == _presenterLibraryId) {
      // Current library, so import is not necessary.
      return null;
    }

    if (libraryIdentifier == _dartCoreLibraryId) {
      // dart:core have not been imported, so ignore it.
      return null;
    }

    // First check relative identifier map.
    // Relative identifier (in same package) can be physical (direct) identifier
    // for src in the first place.
    final relativeIdentifier = _relativeImportIdentityMap[libraryIdentifier];
    if (relativeIdentifier != null) {
      return _imports[relativeIdentifier] ??= LibraryImport(relativeIdentifier);
    }

    var logicalLibraryId = _librarySourceMap[libraryIdentifier];
    if (logicalLibraryIdFinder != null) {
      logicalLibraryId ??=
          _librarySourceMap[libraryIdentifier] = logicalLibraryIdFinder();
    } else {
      // Should be logical identifier (not src/) is specified.
      logicalLibraryId = libraryIdentifier;
    }

    return _imports[logicalLibraryId] ??= LibraryImport(logicalLibraryId);
  }

  static final _src = RegExp(r'src[/\\].+\.dart$');

  String _findLogicalLibraryId(
    String sourceLibraryId,
    String sourceLibraryLocation,
    Element targetElement,
  ) {
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
    libraries ??= _librariesCache[libraryDirectory] = _allLibraries
        .where(
          (l) =>
              !_src.hasMatch(l.source.fullName) &&
              l.source.fullName.startsWith(libraryDirectory),
        )
        .toList();

    final candidates = libraries
        .where(
          (l) =>
              l.exportedLibraries.any((e) => e.identifier == sourceLibraryId),
        )
        .toList();

    if (candidates.isEmpty) {
      throw AnalysisException(
        "Failed to resolve logical library for source library '$sourceLibraryId'"
        " for '$targetElement' in the directory '$libraryDirectory'. ",
      );
    }

    final result = candidates.first.identifier;
    if (candidates.length > 1) {
      final message = "Library import '$result' may be incorrect because "
          'the locator failed to uniquely locate importing library for '
          "'$sourceLibraryId' for '$targetElement' in directory '$libraryDirectory'. "
          'Found libraries are: [${candidates.map((e) => e.identifier).join(', ')}]';
      _logger.warning(message);
      _warnings.add(message);
    }

    _logger.fine('Found $result for $targetElement');
    return result;
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

  /// Records import for specified [Identifier] which is imported from
  /// the library which declares [holderElement].
  void recordTypeId(Element holderElement, Identifier id) =>
      _getLibraryImportEntry(holderElement)?.addType(id);

  /// Records import for specified non-qualified [typeName] which is imported from
  /// the library which declares [holderElement].
  void recordTypeName(Element holderElement, String typeName) =>
      _getLibraryImportEntry(holderElement)?.addTypeName(typeName);

  /// Records import for specified [Identifier] which is imported from
  /// the library specified as [libraryIdentifier].
  void recordTypeIdDirect(String libraryIdentifier, String typeName) =>
      _getLibraryImportEntryDirect(libraryIdentifier, null)
          ?.addTypeName(typeName);

  /// Records import for specified [Identifier] which is imported from
  /// the library specified as [libraryIdentifier] with [libraryPrefix].
  void recordTypeIdDirectWithLibraryPrefix(
    String libraryIdentifier,
    String libraryPrefix,
    String typeName,
  ) =>
      _getLibraryImportEntryDirect(libraryIdentifier, null)
          ?.addTypeNameToPrefixed(libraryPrefix, typeName);

  /// Records non resitricted import for the library specified as [libraryIdentifier].
  void recordLibraryImport(String libraryIdentifier) =>
      _getLibraryImportEntryDirect(libraryIdentifier, null)?.markImport();

  /// Records non resitricted import for
  /// the library specified as [libraryIdentifier] with [libraryPrefix].
  void recordLibraryImportWithPrefix(
    String libraryIdentifier,
    String libraryPrefix,
  ) =>
      _getLibraryImportEntryDirect(libraryIdentifier, null)
          ?.markImportAsPrefixed(libraryPrefix);

  Future<AstNode> _beginGetElementDeclaration(String fieldName) async =>
      _nodeProvider
          .getElementDeclarationAsync(_contextClass.getField(fieldName)!);

  @override
  void visitFieldFormalParameter(FieldFormalParameter node) {
    super.visitFieldFormalParameter(node);

    if (node.type == null) {
      // Process field here.
      final element = node.declaredElement;
      assert(element is FieldFormalParameterElement);

      // We must get field declaration to get declared type
      // instead of resolved type here.
      // For example, we want to get alias of function type.
      final completer = _beginAsync();
      unawaited(
        _beginGetElementDeclaration(node.name.lexeme).then((field) {
          try {
            // Because we get node from FieldFormalParameterElement,
            // so the node should be VariableDeclaration
            // rather than FieldDeclaration which may contain multiple declarations.
            assert(field is VariableDeclaration);
            final declaration = field.parent! as VariableDeclarationList;
            final fieldType = declaration.type;
            if (fieldType != null) {
              _processTypeAnnotation(fieldType);
            } else {
              // Like `var i = 0;` case, we use element here.
              _processType(element!.type);
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
        ),
      );
    }
  }

  @override
  void visitDefaultFormalParameter(DefaultFormalParameter node) {
    super.visitDefaultFormalParameter(node);
    final defaultValue = node.defaultValue;
    if (defaultValue != null) {
      defaultValue.accept(this);
    }
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    final type = node.staticType;
    if (type != null) {
      _logger.finer(
        'Identifier $node should be constant. Element is ${node.staticElement}.',
      );
      recordTypeId(node.staticElement!, node);
    }
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (node.staticType != null) {
      _logger.finer(
        'Identifier $node should be static or enum member reference. '
        'Element is ${node.staticElement}.',
      );
      // Prefix is type name of static const member reference
      // or enum member reference.
      // So type ID is just prefix.
      // Note that prefix.name does not match to static type name
      // for static constants like 'Foos.bar' like following:
      // class Foos { const static final Foo bar = const Foo(...); }
      // So, this should be in 'else' clause rather than 'if' clause.
      recordTypeId(node.staticElement!, node.prefix);
    } else if (node.staticElement != null) {
      final element = node.staticElement!;
      if (node.identifier.name == element.name) {
        _logger.finer(
          'Identifier $node should be prefixed library and the type. '
          'Element is $element.',
        );
        // Prefix is library prefix,
        // because lib.Type.member is interpreted as
        // PropertyAcess(target: PrefixedIdentifier, propertyName: SimpleIdentifier)
        // so identifier is type name.
        // In addition, lib.FunctionAlias should be here.
        recordTypeId(element, node);
      }
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final target = node.target;
    if (target != null) {
      _logger.finer(
        "Target '$target' of property access '$node' may be type reference.",
      );
      // target may be type, which is library prefixed or simple type name,
      // so travarse them as PrefixedIdentifier or SimpleIdentifier above.
      target.accept(this);
    }
  }

  @override
  void visitNamedType(NamedType node) {
    assert(node.type != null);

    final type = node.type!;

    final element = type.element2 ?? type.alias?.element;
    if (type is NeverType ||
        type is VoidType ||
        type is DynamicType ||
        type is TypeParameterType ||
        element!.isPrivate) {
      // Above dart:core types, type parameter, private types never to be imported
      return;
    }

    recordTypeId(element, node.name);

    // Process type arguments
    super.visitNamedType(node);
  }

  /// Process specified [DartType] and records its and its type arguments imports.
  void _processType(DartType type) {
    if (type is InterfaceType) {
      if (type.element2.isPrivate) {
        return;
      }

      recordTypeName(
        type.element2,
        type.getDisplayString(withNullability: false),
      );
      type.typeArguments.forEach(_processType);
    } else if (type is FunctionType) {
      _processType(type.returnType);
      type.parameters.map((e) => e.type).forEach(_processType);
    }
  }

  /// Process specified [GenericType]
  /// and records its and its type arguments imports.
  void processGenericType(GenericType type) {
    _processType(type.rawType);
    type.typeArguments.forEach(processGenericType);
  }
}
