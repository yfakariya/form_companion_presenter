// See LICENCE file in the root.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:path/path.dart' as path;

const _sourceDirectory = '../form_companion_generator_test/lib';

final _contextCollection = AnalysisContextCollection(
  includedPaths: [
    ...Directory(_sourceDirectory)
        .listSync(recursive: true, followLinks: false)
        .where((e) => e.existsSync() && e.path.toLowerCase().endsWith('.dart'))
        .map((e) => path.canonicalize(e.path)),
  ],
);

FutureOr<ResolvedLibraryResult> getElement(String fileName) =>
    _getElement(path.canonicalize('$_sourceDirectory/$fileName'));

FutureOr<ResolvedLibraryResult> _getElement(String filePath) async {
  final result = await _contextCollection
      .contextFor(filePath)
      .currentSession
      .getResolvedLibrary(filePath);
  if (result is! ResolvedLibraryResult) {
    throw Exception('Failed to resolve "$filePath": ${result.runtimeType}');
  }

  return result;
}

LibraryElement? _flutterFormBuilder;

FutureOr<LibraryElement> _getFlutterFormBuilder() async {
  if (_flutterFormBuilder != null) {
    return _flutterFormBuilder!;
  }

  final formFields = await getElement('form_fields.dart');
  final importResult = await formFields.session.getResolvedLibraryByElement(
    formFields.element.importedLibraries
        .singleWhere((e) => e.name == 'flutter_form_builder'),
  );

  if (importResult is! ResolvedLibraryResult) {
    throw Exception('Failed to resolve "flutter_form_builder": $importResult}');
  }

  return importResult.element;
}

LibraryElement? _propertiesLibrary;

FutureOr<LibraryElement> _getPropertiesLibrary() async {
  if (_propertiesLibrary != null) {
    return _propertiesLibrary!;
  }

  return _propertiesLibrary = (await getElement('properties.dart')).element;
}

FutureOr<InterfaceType> getMyEnumType() async =>
    (await _getPropertiesLibrary()).lookupType('MyEnum');

LibraryElement? _parametersLibrary;

FutureOr<LibraryElement> getParametersLibrary() async {
  if (_parametersLibrary != null) {
    return _parametersLibrary!;
  }

  return _parametersLibrary = (await getElement('parameters.dart')).element;
}

LibraryElement? _formFieldsLibrary;

FutureOr<LibraryElement> getFormFieldsLibrary() async {
  if (_formFieldsLibrary != null) {
    return _formFieldsLibrary!;
  }

  return _formFieldsLibrary = (await getElement('form_fields.dart')).element;
}

FutureOr<InterfaceType> getDateTimeType() async =>
    (await getFormFieldsLibrary()).lookupType('DateTime');
FutureOr<InterfaceType> getDateTimeRangeType() async =>
    (await getFormFieldsLibrary()).lookupType('DateTimeRange');
FutureOr<InterfaceType> getRangeValuesType() async =>
    (await getFormFieldsLibrary()).lookupType('RangeValues');

ClassElement lookupExportedClass(LibraryElement library, String name) {
  {
    final result = library.getType(name);
    if (result != null) {
      return result;
    }
  }

  for (final exported in library.exportedLibraries) {
    final result = exported.getType(name);
    if (result != null) {
      return result;
    }
  }

  throw Exception(
    "Failed to find type '$name' from '$library' and its exported src.",
  );
}

FutureOr<ClassElement> lookupFormBuilderClass(String name) async =>
    lookupExportedClass(await _getFlutterFormBuilder(), name);

extension LibraryElementExtensions on LibraryElement {
  ClassElement lookupClass(String className) =>
      scope.lookup(className).getter!.thisOrAncestorOfType<ClassElement>()!;
  InterfaceType lookupType(String className) => lookupClass(className).thisType;
}
