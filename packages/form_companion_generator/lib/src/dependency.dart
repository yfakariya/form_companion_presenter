// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'model.dart' show GenericType, ParameterInfo;
import 'utilities.dart';

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
    yield* ([..._prefixes.keys]..sort())
        .map((k) => MapEntry(k, _prefixes[k]!.toList()..sort()));
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
}

/// Implements collection of dependent libraries.
@sealed
class DependentLibraryCollector {
  static final _dartCoreLibraryId = 'dart:core';

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

  /// Initializes a new [DependentLibraryCollector] instance.
  ///
  /// [presenterLibrary] is the library itself to be scanned.
  /// References to this library will not be collected.
  DependentLibraryCollector(
    this._allLibraries,
    this._logger,
    LibraryElement presenterLibrary,
  ) : _presenterLibraryId = presenterLibrary.identifier {
    for (final import in presenterLibrary.libraryImports) {
      final importedLibraryIdentifier = import.importedLibrary?.identifier;
      final importUri = import.uri;
      // Make map to resolve libraries as relative uri like '../x.dart'
      // It is OK to ignore importUri other than DirectiveUriWithSource
      // because they should be imports which are not specified with relative
      // uri even if they look like. For example, 'dart:ui' is relative URI
      // technically, but it is just an identifier, not a locator.
      if (importUri is DirectiveUriWithSource) {
        if (importedLibraryIdentifier != null &&
            importUri.source.shortName != importedLibraryIdentifier) {
          _relativeImportIdentityMap[importedLibraryIdentifier] =
              importUri.relativeUriString;
        }
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
    _contextClass = contextClass;
    _warnings = warnings;
  }

  LibraryImport? _getLibraryImportEntry(Element? element) {
    // HACK: workaround for dart:ui
    // Analyzer 5.x cannot resolve dart:ui, the reason is not known but
    // it is not core library from Dart SDK perspective but it has "relative" UI
    // so analyzer does not resolve it.
    // This is just a workaround.
    final libraryIdentifier = element?.library?.identifier ?? 'dart:ui';
    final librarySourceFullName =
        element?.library?.source.fullName ?? 'dart:ui';
    return _getLibraryImportEntryDirect(
      libraryIdentifier,
      () => _findLogicalLibraryId(
        libraryIdentifier,
        librarySourceFullName,
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
    Element? targetElement,
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
      // coverage:ignore-start
      final message =
          "Failed to resolve logical library for source library '$sourceLibraryId'"
          " for '$targetElement' in the directory '$libraryDirectory'. ";
      assert(false, message);
      throw AnalysisException(message);
      // coverage:ignore-end
    }

    final result = candidates.first.identifier;
    if (candidates.length > 1) {
      // coverage:ignore-start
      final message = "Library import '$result' may be incorrect because "
          'the locator failed to uniquely locate importing library for '
          "'$sourceLibraryId' for '$targetElement' in directory '$libraryDirectory'. "
          'Found libraries are: [${candidates.map((e) => e.identifier).join(', ')}]';
      _logger.warning(message);
      _warnings.add(message);
      assert(false, message);
      // coverage:ignore-end
    }

    _logger.fine('Found $result for $targetElement');
    return result;
  }

  void _processTypeAnnotation(TypeAnnotation type) {
    if (type is NamedType) {
      _handleNamedType(type);
    } else if (type is GenericFunctionType) {
      // Delegates super class implementation,
      // it should call visitNamedType() eventually.
      _handleGenericFunctionType(type);
    } else {
      // coverage:ignore-start
      final message = "Type of '$type' (${type.runtimeType}) is unexpected "
          'at ${getNodeLocation(type, _contextClass)}';
      assert(false, message);
      throw AnalysisException(message);
      // coverage:ignore-end
    }
  }

  /// Records import for specified [Identifier] which is imported from
  /// the library which declares [holderElement].
  void recordTypeId(Element? holderElement, Identifier id) =>
      _getLibraryImportEntry(holderElement)?.addType(id);

  /// Records import for specified non-qualified [typeName] which is imported from
  /// the library which declares [holderElement].
  void recordTypeName(Element? holderElement, String typeName) =>
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

  /// Collects depencendies from specified [ParameterInfo].
  void collectDependencyForParameter(ParameterInfo parameter) {
    if (parameter.typeAnnotation != null) {
      // If the node has typeAnnotation, use it because AST node has
      // package prefix.
      _processTypeAnnotation(parameter.typeAnnotation!);
    } else {
      // Otherwise, use element instead of AST node.
      _processType(parameter.type);
    }

    // Handle default value of the parameter.
    final node = parameter.node;
    if (node is DefaultFormalParameter && node.defaultValue != null) {
      _handleExpression(node.declaredElement, node.defaultValue!);
    }
  }

  void _handleExpression(Element? element, Expression expression) {
    if (expression is Literal || expression.staticType is FunctionType) {
      // Nothing to do -- we do not have to import literals and function types.
      return;
    } else if (expression is SimpleIdentifier) {
      _logger.finer(
        'Identifier $expression should be constant. Element is ${element}.',
      );
      recordTypeId(
        expression.staticType?.element ?? element!,
        expression,
      );
    } else if (expression is PrefixedIdentifier) {
      if (expression.staticType != null) {
        if (!isTypeName(expression.prefix.name)) {
          _logger.finer(
            "Identifier '$expression' should be unresolved prefixed type. "
            "Element is '${expression.staticElement}' in '$element', "
            'type is ${expression.staticType}.',
          );

          // Failed to resolve prefixed type.
          recordTypeId(expression.staticElement, expression);
        } else {
          _logger.finer(
            "Identifier '$expression' should be static or enum member reference. "
            "Element is '${expression.staticElement}' in '$element', "
            'type is ${expression.staticType}.',
          );

          // Prefix is type name of static const member reference
          // or enum member reference.
          // So type ID is just prefix.
          // Note that prefix.name does not match to static type name
          // for static constants like 'Foos.bar' like following:
          // class Foos { const static final Foo bar = const Foo(...); }
          // So, this should be in 'else' clause rather than 'if' clause.
          recordTypeId(expression.staticElement, expression.prefix);
        }
      } else if (expression.staticElement != null) {
        final typeElement = expression.staticElement!;
        if (expression.identifier.name == typeElement.name) {
          _logger.finer(
            "Identifier '$expression' should be prefixed library and the type. "
            "Element is '$typeElement'.",
          );
          // Prefix is library prefix,
          // because lib.Type.member is interpreted as
          // PropertyAcess(target: PrefixedIdentifier, propertyName: SimpleIdentifier)
          // so identifier is type name.
          // In addition, lib.FunctionAlias should be here.
          recordTypeId(typeElement, expression);
        }
      }
    } else if (expression is PropertyAccess) {
      final target = expression.target;
      if (target != null) {
        _logger.finer(
          "Target '$target' of property access '$expression' may be type reference.",
        );
        // target may be type, which is library prefixed or simple type name,
        // so travarse them as PrefixedIdentifier or SimpleIdentifier above.
        _handleExpression(element, target);
      }
    } else if (expression is InstanceCreationExpression) {
      assert(expression.isConst);
      _handleNamedType(expression.constructorName.type);
      expression.argumentList.arguments.forEach(
        (e) => _handleExpression(e.staticParameterElement, e),
      );
    } else if (expression is NamedExpression) {
      // Like 'hour: 12' of 'const TimeOfDay(hour: 12)'.
      // Parse expression ('12' in above) recursively.
      _handleExpression(expression.element, expression.expression);
    } else {
      // coverage:ignore-start
      final message =
          "Unexpected parameter default value expression '$expression' "
          'type: ${expression.runtimeType} '
          'at ${getNodeLocation(expression, _contextClass)}';
      assert(false, message);
      throw AnalysisException(message);
      // coverage:ignore-end
    }
  }

  void _handleNamedType(NamedType node) {
    assert(node.type != null);

    final type = node.type!;

    final element = type.element ?? type.alias?.element;
    if (type is NeverType ||
        type is VoidType ||
        type is TypeParameterType ||
        // We cannot use 'type is DynamicType' here because some type in some
        // library (like dart:ui in form field libraries) cannot be resolved
        // correctly, so they are 'resolved' as dynamic type.
        node.name.name == 'dynamic' ||
        element!.isPrivate) {
      // Above dart:core types, type parameter, private types never to be imported
      return;
    }

    recordTypeId(element, node.name);

    // Process type arguments
    node.typeArguments?.arguments.forEach(_processTypeAnnotation);
  }

  void _handleGenericFunctionType(GenericFunctionType type) {
    if (type.returnType != null) {
      _processTypeAnnotation(type.returnType!);
    }

    // Ignore typeParameters here...

    type.parameters.parameterElements.map((e) => e!.type).forEach(_processType);
  }

  /// Process specified [DartType] and records its and its type arguments imports.
  void _processType(DartType type) {
    if (type is InterfaceType) {
      if (type.element.isPrivate) {
        return;
      }

      recordTypeName(
        type.element,
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
