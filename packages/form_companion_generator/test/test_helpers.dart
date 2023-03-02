// See LICENCE file in the root.

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build_config/build_config.dart';
import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:path/path.dart' as path;
import 'package:test/expect.dart';

const _sourceDirectory = '../form_companion_generator_test/lib';

final _contextCollection = AnalysisContextCollection(
  includedPaths: [
    ...Directory(_sourceDirectory)
        .listSync(recursive: true, followLinks: false)
        .where((e) => e.existsSync() && e.path.toLowerCase().endsWith('.dart'))
        .map((e) => path.canonicalize(e.path)),
  ],
);

FutureOr<ResolvedLibraryResult> getResolvedLibraryResult(String fileName) =>
    _getElement(path.canonicalize('$_sourceDirectory/$fileName'));

final Map<String, ResolvedLibraryResult> _resolvedLibrariesCache = {};

FutureOr<ResolvedLibraryResult> _getElement(String filePath) async {
  final cachedResult = _resolvedLibrariesCache[filePath];
  if (cachedResult != null) {
    return cachedResult;
  }

  final result = await _contextCollection
      .contextFor(filePath)
      .currentSession
      .getResolvedLibrary(filePath);
  if (result is! ResolvedLibraryResult) {
    throw Exception('Failed to resolve "$filePath": ${result.runtimeType}');
  }

  return _resolvedLibrariesCache[filePath] = result;
}

LibraryElement? _flutterFormBuilder;

FutureOr<LibraryElement> _getFlutterFormBuilder() async {
  if (_flutterFormBuilder != null) {
    return _flutterFormBuilder!;
  }

  final formFields = await getResolvedLibraryResult('form_fields.dart');
  final importResult = await formFields.session.getResolvedLibraryByElement(
    formFields.element.importedLibraries
        .singleWhere((e) => e.name == 'flutter_form_builder'),
  );

  if (importResult is! ResolvedLibraryResult) {
    throw Exception('Failed to resolve "flutter_form_builder": $importResult}');
  }

  return importResult.element;
}

InterfaceType? _myEnumType;

FutureOr<InterfaceType> getMyEnumType() async {
  if (_myEnumType != null) {
    return _myEnumType!;
  }

  final enumLibrary = (await getResolvedLibraryResult('enum.dart')).element;
  return _myEnumType = enumLibrary.lookupType('MyEnum');
}

LibraryElement? _parametersLibrary;

FutureOr<LibraryElement> getParametersLibrary() async {
  if (_parametersLibrary != null) {
    return _parametersLibrary!;
  }

  return _parametersLibrary =
      (await getResolvedLibraryResult('parameters.dart')).element;
}

LibraryElement? _formFieldsLibrary;

FutureOr<LibraryElement> getFormFieldsLibrary() async {
  if (_formFieldsLibrary != null) {
    return _formFieldsLibrary!;
  }

  return _formFieldsLibrary =
      (await getResolvedLibraryResult('form_fields.dart')).element;
}

FutureOr<InterfaceType> getDateTimeType() async =>
    (await getFormFieldsLibrary()).lookupType('DateTime');
FutureOr<InterfaceType> getDateTimeRangeType() async =>
    (await getFormFieldsLibrary()).lookupType('DateTimeRange');
FutureOr<InterfaceType> getRangeValuesType() async =>
    (await getFormFieldsLibrary()).lookupType('RangeValues');

LibraryElement? _nullablesLibrary;

FutureOr<LibraryElement> _getNullablesLibrary() async {
  if (_nullablesLibrary != null) {
    return _nullablesLibrary!;
  }

  return _nullablesLibrary =
      (await getResolvedLibraryResult('nullables.dart')).element;
}

FutureOr<InterfaceType> getNullableBoolType() async =>
    (await _getNullablesLibrary())
        .topLevelElements
        .whereType<TopLevelVariableElement>()
        .singleWhere((e) => e.name == 'nullableBool')
        .type as InterfaceType;

FutureOr<InterfaceType> getNullableMyEnumType() async =>
    (await _getNullablesLibrary())
        .topLevelElements
        .whereType<TopLevelVariableElement>()
        .singleWhere((e) => e.name == 'nullableMyEnum')
        .type as InterfaceType;

FutureOr<InterfaceType> getNullableStringType() async =>
    (await _getNullablesLibrary())
        .topLevelElements
        .whereType<TopLevelVariableElement>()
        .singleWhere((e) => e.name == 'nullableString')
        .type as InterfaceType;

FutureOr<InterfaceType> getNullableListOfStringType() async =>
    (await _getNullablesLibrary())
        .topLevelElements
        .whereType<TopLevelVariableElement>()
        .singleWhere((e) => e.name == 'nullableListOfString')
        .type as InterfaceType;

FutureOr<InterfaceType> getNullableListOfNullableStringType() async =>
    (await _getNullablesLibrary())
        .topLevelElements
        .whereType<TopLevelVariableElement>()
        .singleWhere((e) => e.name == 'nullableListOfNullableString')
        .type as InterfaceType;

ClassElement lookupExportedClass(LibraryElement library, String name) {
  {
    final result = library.getClass(name);
    if (result != null) {
      return result;
    }
  }

  for (final exported in library.exportedLibraries) {
    final result = exported.getClass(name);
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

FutureOr<InterfaceType> lookupFormFieldTypeInstance(String name) async =>
    (await getResolvedLibraryResult('form_fields.dart'))
        .element
        .lookupTypeFromTopLevelVariable(name);

extension LibraryElementExtensions on LibraryElement {
  ClassElement lookupClass(String className) =>
      scope.lookup(className).getter!.thisOrAncestorOfType<ClassElement>()!;
  InterfaceType lookupType(String typeName) => scope
      .lookup(typeName)
      .getter!
      .thisOrAncestorOfType<InterfaceElement>()!
      .thisType;
  InterfaceType lookupTypeFromTopLevelVariable(String variableName) =>
      topLevelElements
          .whereType<TopLevelVariableElement>()
          .singleWhere((e) => e.name == variableName)
          .computeConstantValue()!
          .toTypeValue()! as InterfaceType;
}

String pascalize(String value) {
  if (value.isEmpty) {
    return value;
  } else if (value.length == 1) {
    return value.toUpperCase();
  } else {
    return value.substring(0, 1).toUpperCase() + value.substring(1);
  }
}

GenericType toGenericType(DartType type) {
  final element = type.element;
  if (element == null) {
    if (type.alias != null) {
      return GenericType.fromDartType(
        type,
        type.alias?.element.aliasedElement ?? type.alias!.element,
      );
    }

    fail('$type is not completed.');
  }

  return GenericType.fromDartType(type, element);
}

Map<String, dynamic>? _defaultOptions;

FutureOr<Config> readDefaultOptions([
  Map<String, dynamic> override = const <String, dynamic>{},
]) async {
  if (_defaultOptions == null) {
    final buildConfig = await BuildConfig.fromPackageDir('.');
    _defaultOptions = buildConfig
            .builderDefinitions[
                'form_companion_generator:form_companion_generator']
            ?.defaults
            .options ??
        <String, dynamic>{};
  }

  final defaultOptions = <String, dynamic>{..._defaultOptions!};
  for (final entry in override.entries) {
    defaultOptions[entry.key] = entry.value;
  }

  return Config(defaultOptions);
}

String removeQuestion(String mayBeNullable) => mayBeNullable.endsWith('?')
    ? mayBeNullable.substring(0, mayBeNullable.length - 1)
    : mayBeNullable;
