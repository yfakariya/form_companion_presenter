// See LICENCE file in the root.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:meta/meta.dart';

const _vanillaFormUri = 'package:flutter/material.dart';
const _formBuilderUri =
    'package:flutter_form_builder/flutter_form_builder.dart';

/// Locates `FormField` class from known or user supplied extra libraries.
@sealed
class FormFieldLocator {
  final List<String> _packages;
  final Map<String, ResolvedLibraryResult> _libraries;

  FormFieldLocator._(this._packages, this._libraries);

  /// Creats a new [FormFieldLocator] instance from specified [AnalysisSession]
  /// with specified extra libraries which are specified as 'package:` format URI.
  static Future<FormFieldLocator> createAsync(
    AnalysisSession session,
    List<String> extraLibraries,
  ) async {
    final packages = <String>[];
    final libraries = <String, ResolvedLibraryResult>{};

    await _resolveLibraryByUriAsync(
        session, _vanillaFormUri, packages, libraries);
    await _resolveLibraryByUriAsync(
        session, _formBuilderUri, packages, libraries);
    for (final extraLibrary in extraLibraries) {
      await _resolveLibraryByUriAsync(
          session, extraLibrary, packages, libraries);
    }

    return FormFieldLocator._(packages, libraries);
  }

  static Future<void> _resolveLibraryByUriAsync(
    AnalysisSession session,
    String packageUri,
    List<String> packages,
    Map<String, ResolvedLibraryResult> libraries,
  ) async {
    final element = await session.getLibraryByUri(packageUri);
    if (element is! LibraryElementResult) {
      throw AnalysisException(
        "Failed to resolve package '$packageUri'. $element",
      );
    }

    final resolvedLibrary =
        await session.getResolvedLibraryByElement(element.element);
    if (resolvedLibrary is! ResolvedLibraryResult) {
      throw AnalysisException(
        "Failed to resolve package '$packageUri'. $resolvedLibrary",
      );
    }

    packages.add(packageUri);
    libraries[packageUri] = resolvedLibrary;
  }

  /// Resolves specified `FormField` type from dependent libraries.
  ///
  /// This method returns `null` when [typeName] cannot be resolved.
  InterfaceType? resolveFormFieldType(String typeName) {
    for (final package in _packages) {
      final library = _libraries[package]!.element;
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
