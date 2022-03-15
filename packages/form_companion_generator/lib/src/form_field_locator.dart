// See LICENCE file in the root.

import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

const _vanillaFormUri = 'package:flutter/material.dart';
const _formBuilderUri =
    'package:flutter_form_builder/flutter_form_builder.dart';

/// Locates `FormField` class from known or user supplied extra libraries.
@sealed
class FormFieldLocator {
  final List<String> _packages;
  final Map<String, LibraryElement> _libraries;

  FormFieldLocator._(this._packages, this._libraries);

  /// Creats a new [FormFieldLocator] instance from specified [AnalysisSession]
  /// with specified extra libraries which are specified as 'package:` format URI.
  static Future<FormFieldLocator> createAsync(
    Resolver resolver,
    List<String> extraLibraries,
    Logger logger,
  ) async {
    final packages = <String>[];
    final libraries = <String, LibraryElement>{};

    await _resolveLibraryByUriAsync(
      resolver,
      _vanillaFormUri,
      packages,
      libraries,
    );
    await _resolveLibraryByUriAsync(
      resolver,
      _formBuilderUri,
      packages,
      libraries,
    );
    for (final extraLibrary in extraLibraries) {
      final library = await _resolveLibraryByUriAsync(
        resolver,
        extraLibrary,
        packages,
        libraries,
      );
      logger.fine(
        "'$extraLibrary' is resolved from '${library.source.fullName}'",
      );
    }

    return FormFieldLocator._(packages, libraries);
  }

  static Future<LibraryElement> _resolveLibraryByUriAsync(
    Resolver resolver,
    String packageUri,
    List<String> packages,
    Map<String, LibraryElement> libraries,
  ) async {
    final element =
        await resolver.libraryFor(AssetId.resolve(Uri.parse(packageUri)));
    packages.add(packageUri);
    return libraries[packageUri] = element;
  }

  /// Resolves specified `FormField` type from dependent libraries.
  ///
  /// This method returns `null` when [typeName] cannot be resolved.
  InterfaceType? resolveFormFieldType(String typeName) {
    for (final package in _packages) {
      final library = _libraries[package]!;
      final candidate = _getTypeFromLibrary(library, typeName);
      if (candidate != null) {
        return candidate.thisType;
      }
    }

    return null;
  }

  ClassElement? _getTypeFromLibrary(
    LibraryElement library,
    String typeName,
  ) {
    final directCandidate = library.getType(typeName);
    if (directCandidate != null) {
      return directCandidate;
    }

    for (final exported in library.exportedLibraries) {
      final exportedCandiate = _getTypeFromLibrary(exported, typeName);
      if (exportedCandiate != null) {
        return exportedCandiate;
      }
    }

    return null;
  }
}
