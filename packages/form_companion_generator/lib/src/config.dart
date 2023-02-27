// See LICENCE file in the root.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:meta/meta.dart';

import 'macro_keys.dart';

const _autovalidateByDefaultKey = 'autovalidate_by_default';
const _extraLibrariesKey = 'extra_libraries';
const _usesEnumNameKey = 'uses_enum_name';

const _namedTemplatesKey = 'named_templates';
const _argumentTemplatesKey = 'argument_templates';

const _importsKey = 'imports';
const _templateKey = 'template';
const _itemTemplateKey = 'item_template';

// custom_namings:
//   {presenterName}:
//     form_properties_builder:
//       build:
const _customNamingsKey = 'custom_namings';

/// Represents configuration.
/// A configuration is specified through builder option,
/// but they can be overriden via annotation.
///
/// ## About overriding
///
/// Currently, only `autovalidate` can be overriden by the annotation because:
///
/// * Templates override is not necessary because form field factory takes
///   most of `FormField`'s constructor parameters which allows the developer
///   specifying custom parameters like property specifiec `items`.
/// * Extra libraries is just an escaping hatch. So we cannot justify API
///   complexity of the annotation now.
/// * As part should be controled globally rather than presenter-locally.
class Config {
  /// Key of [asPart] in config.
  static const asPartKey = 'as_part';

  final Map<String, dynamic> _underlying;

  /// Whether autovalidate for each `FormField` should be `true` when each
  /// applications of `@FormCompanion` annotations do not specify their own
  /// configuration.
  /// The default is `true`, so each `FormField` will do auto-validation as
  /// `AutovalidateMode.onUserInteraction` when form field factory callers
  /// do not specify `AutovalidateMode`.
  ///
  /// Note that this configuration and `@FormCompanion` setting do **NOT**
  /// affect `autovalidateMode` of `Form` (or `FormBuilder`) itself.
  /// You must specify it when you want to validate all fields at once rather
  /// than auto-validating each field individually.
  bool get autovalidateByDefault =>
      _underlying[_autovalidateByDefaultKey] != false;

  /// Whether the file should be generated as part of target library
  /// rather than individual library file.
  /// This means the generated source will share import directives and
  /// namespaces with input library source.
  ///
  /// Part file is convinient for users of the presenter library because they
  /// just import the presenter library only.
  /// However, it is hard for developers of the presenter library because it
  /// requires them to describe many imports with avoiding name conflicts.
  bool get asPart => _underlying[asPartKey] == true;

  /// Whether the [ContextValueKeys.itemValueString] macro uses
  /// [EnumName.name] extension property instead of [Enum.toString()] method
  /// for enum items.
  ///
  /// [version] must be version of target library to be processed.
  bool getUsesEnumName(LibraryLanguageVersion version) {
    final value = _verifyScalarType<bool?>(
      _underlying[_usesEnumNameKey],
      "'$_usesEnumNameKey'",
    );
    if (value is bool) {
      return value;
    } else {
      assert(value == null);

      // >= 2.15
      if (version.effective.major < 2 || version.effective.minor < 15) {
        return false;
      }

      if (version.effective.major == 2 &&
          version.effective.minor == 15 &&
          version.effective.patch == 0) {
        // 2.15.0-xxx is not allowed, but 2.15.1-xxx is allowed.
        return !version.effective.isPreRelease;
      }

      return true;
    }
  }

  /// Ordered list of extra libraries to resolve `preferredFieldType`s.
  /// Each entries must be specified as 'package:` form URI.
  ///
  /// Dependencies in generating source is basically resolved from depdency
  /// resolution for source file, which declares presenter(s) decorated with
  /// `@formCompanion` annotation. In some situations, this stragety does not
  /// work, so resolution of `FormField` can be failed. If so, you specify this
  /// property to help generator.
  List<String> get extraLibraries {
    final dynamic rawNode = _underlying[_extraLibrariesKey];
    if (rawNode is String) {
      return [rawNode];
    } else if (rawNode == null) {
      return const [];
    } else {
      return _verifySequenceType<String>(rawNode, "'$_extraLibrariesKey'");
    }
  }

  String? _namedTemplatesError;
  NamedTemplates? _materializedNamedTemplates;

  /// `named_templates` in config.
  ///
  /// Note that each templates can contain any context macros.
  ///
  /// See build.yaml in package root directory for built-in named templates.
  NamedTemplates get namedTemplates {
    if (_namedTemplatesError != null) {
      throw AnalysisException(_namedTemplatesError!);
    }

    if (_materializedNamedTemplates == null) {
      final dynamic rawNamedTemplates = _underlying[_namedTemplatesKey];
      if (rawNamedTemplates != null) {
        try {
          _materializedNamedTemplates = NamedTemplates(
            _verifyMappingType<String, NamedTemplate>(
              rawNamedTemplates,
              "'$_namedTemplatesKey'",
              NamedTemplate.parse,
            ),
          );
        } on AnalysisException catch (e) {
          _namedTemplatesError = e.message;
          rethrow;
        }
      } else {
        _materializedNamedTemplates = const NamedTemplates({});
      }
    }

    return _materializedNamedTemplates!;
  }

  String? _argumentTemplatesError;
  ArgumentTemplates? _materializedArgumentTemplates;

  /// `argument_templates` in config.
  ///
  /// Note that each templates can contain any context macros and named templates.
  ///
  /// See build.yaml in package root directory for built-in argument templates.
  ArgumentTemplates get argumentTemplates {
    if (_argumentTemplatesError != null) {
      throw AnalysisException(_argumentTemplatesError!);
    }

    if (_materializedArgumentTemplates == null) {
      final dynamic rawArgumentTemplates = _underlying[_argumentTemplatesKey];
      if (rawArgumentTemplates != null) {
        try {
          _materializedArgumentTemplates = ArgumentTemplates(
            _verifyMappingType<String, Map<String, ArgumentTemplate>>(
              rawArgumentTemplates,
              "'$_argumentTemplatesKey'",
              (k, dynamic v, x) => MapEntry(
                k,
                _verifyMappingType(
                  v,
                  "'$k' property of $x",
                  ArgumentTemplate.parse,
                ),
              ),
            ),
          );
        } on AnalysisException catch (e) {
          _argumentTemplatesError = e.message;
          rethrow;
        }
      } else {
        _materializedArgumentTemplates = const ArgumentTemplates({});
      }
    }

    return _materializedArgumentTemplates!;
  }

  String? _customNamingsError;
  CustomNamings? _materializedCustomNamings;

  /// `custom_namings` in config.
  ///
  /// Note that each templates can contain any context macros and named templates.
  ///
  /// See build.yaml in package root directory for built-in argument templates.
  CustomNamings get customNamings {
    if (_customNamingsError != null) {
      throw AnalysisException(_customNamingsError!);
    }

    if (_materializedCustomNamings == null) {
      final dynamic rawCustomNamings = _underlying[_customNamingsKey];
      if (rawCustomNamings != null) {
        try {
          _materializedCustomNamings = CustomNamings(
            _verifyMappingType<String, PresenterCustomNamings>(
              rawCustomNamings,
              "'$_customNamingsKey'",
              (k, dynamic v, x) => MapEntry(
                k,
                PresenterCustomNamings.parse(
                  v,
                  "'$k' property of $x",
                ),
              ),
            ),
          );
        } on AnalysisException catch (e) {
          _customNamingsError = e.message;
          rethrow;
        }
      } else {
        _materializedCustomNamings = const CustomNamings({});
      }
    }

    return _materializedCustomNamings!;
  }

  /// Initializes a new instance with values from builder options.
  Config(this._underlying);
}

String _stringifyType(Object? value) {
  final typeName =
      value is Type ? value.toString() : value.runtimeType.toString();
  switch (typeName) {
    case 'String':
      return 'string';
    case 'Null':
      return 'null';
    case 'bool?':
      return 'bool or null';
    case 'String?':
      return 'string or null';
    case 'List<String>':
      return 'sequence of string';
    case 'dynamic':
    case 'ArgumentTemplate':
      return 'mapping';
    default:
      return typeName;
  }
}

T _verifyScalarType<T>(dynamic rawNode, String context) {
  if (rawNode is! T) {
    throw AnalysisException(
      'Unexpected value type of $context. '
      // ignore: avoid_dynamic_calls
      'Value must be ${_stringifyType(T)}, but ${_stringifyType(rawNode)}.',
    );
  }

  return rawNode;
}

List<T> _verifySequenceType<T>(dynamic rawNode, String context) {
  if (rawNode is! List) {
    throw AnalysisException(
      'Unexpected value type of $context. '
      // ignore: avoid_dynamic_calls
      'Value must be list of ${_stringifyType(T)}, but ${_stringifyType(rawNode)}.',
    );
  }

  final result = <T>[];
  final error = StringBuffer();
  for (var i = 0; i < rawNode.length; i++) {
    final dynamic item = rawNode[i];
    if (item is T) {
      result.add(item);
    } else {
      if (error.isNotEmpty) {
        error.write('\n');
      }

      error.write(
        'Unexpected item type at index $i in $context. '
        // ignore: avoid_dynamic_calls
        'Items must be ${_stringifyType(T)}, but ${_stringifyType(item)}.',
      );
    }
  }

  if (error.length > 0) {
    throw AnalysisException(error.toString());
  }

  return result;
}

class _DefaultValueParser<K, V> {
  MapEntry<K, V> _parse(K key, dynamic value, String context) {
    if (value is! V) {
      throw AnalysisException(
        "Unexpected value type of '$key' property of $context. "
        // ignore: avoid_dynamic_calls
        'Values must be ${_stringifyType(V)}, but ${_stringifyType(value)}.',
      );
    }

    return MapEntry(key, value);
  }
}

Map<K, V> _verifyMappingType<K, V>(
  dynamic rawNode,
  String context,
  MapEntry<K, V> Function(K, dynamic, String)? entryParser,
) {
  if (rawNode is! Map) {
    throw AnalysisException(
      'Unexpected value type of $context. '
      // ignore: avoid_dynamic_calls
      'Value must be mapping of ${_stringifyType(K)} key and ${_stringifyType(V)} value, '
      'but ${_stringifyType(rawNode)}.',
    );
  }

  final result = <K, V>{};
  final realEntryParser = entryParser ?? _DefaultValueParser<K, V>()._parse;

  for (final entry in rawNode.entries) {
    final dynamic key = entry.key;
    if (key is! K) {
      throw AnalysisException(
        "Unexpected key type of '$key' property of $context. "
        // ignore: avoid_dynamic_calls
        'Keys must be ${_stringifyType(K)}, but ${_stringifyType(key)}.',
      );
    }

    final parsedEntry = realEntryParser(key, entry.value, context);
    result[parsedEntry.key] = parsedEntry.value;
  }

  return result;
}

/// Represents `named_templates` configuration property.
class NamedTemplates {
  final Map<String, NamedTemplate> _namedTemplates;

  /// Returns `true` when this template is empty.
  @visibleForTesting
  bool get isEmpty => _namedTemplates.isEmpty;

  /// Initializes a new instance from [Map] of [String].
  ///
  /// Keys are names of templates.
  const NamedTemplates(this._namedTemplates);

  /// Gets a specified template.
  ///
  /// This method returns `null` when the specified template is not defined.
  NamedTemplate? operator [](String name) => _namedTemplates[name];
}

/// Represents `argument_templates` configuration property.
class ArgumentTemplates {
  // class -> property
  final Map<String, Map<String, ArgumentTemplate>> _argumentTemplates;

  /// Returns `true` when this template is empty.
  @visibleForTesting
  bool get isEmpty => _argumentTemplates.isEmpty;

  /// Initializes a new instance from [Map] of [ArgumentTemplate].
  ///
  /// 1st level keys are class names of target form fields,
  /// and 2nd level keys are parameter names of the target form field.
  const ArgumentTemplates(this._argumentTemplates);

  /// Gets a [ArgumentTemplate] for specified parameter which is specified
  /// by pair of [className] and [parameterName].
  ArgumentTemplate get(String className, String parameterName) =>
      _argumentTemplates[className]?[parameterName] ??
      _argumentTemplates['default']?[parameterName] ??
      const ArgumentTemplate('#${ContextValueKeys.argument}#', null, []);

  /// Determines whether a template for specified pair of [className] and
  /// [parameterName], or `default` template for specified [parameterName],
  /// is defined or not.
  bool contains(String className, String parameterName) =>
      (_argumentTemplates[className]?[parameterName] ??
          _argumentTemplates['default']?[parameterName]) !=
      null;
}

/// Represents each item of `named_templates`.
class NamedTemplate {
  /// Value of this template.
  final String? value;

  /// Collection of related imports. This value can be empty.
  final Iterable<TemplateImports> imports;

  /// Initializes a new instance with [value] and [imports].
  const NamedTemplate(this.value, this.imports);

  /// Parses raw yaml property entry ([MapEntry]) to [MapEntry] of [String]
  /// (template name) and [NamedTemplate].
  ///
  /// This method also change case of key to upper case.
  ///
  /// For any type error, [ArgumentError] will be thrown.
  static MapEntry<String, NamedTemplate> parse(
    String key,
    dynamic simpleOrStructuredTemplate,
    String context,
  ) {
    if (simpleOrStructuredTemplate is String) {
      return MapEntry(
        key.toUpperCase(),
        NamedTemplate(
          simpleOrStructuredTemplate,
          [],
        ),
      );
    } else if (simpleOrStructuredTemplate is Map) {
      final dynamic templateValue = simpleOrStructuredTemplate[_templateKey];
      if (templateValue is String) {
        return MapEntry(
          key.toUpperCase(),
          NamedTemplate(
            templateValue,
            TemplateImports.parse(
              simpleOrStructuredTemplate['$_importsKey'],
              "'$_importsKey' property of $context",
            ),
          ),
        );
      }

      throw AnalysisException(
        "'$key' property of $context must have "
        "String '$_templateKey' property, but the type of '$_templateKey' is "
        '${_stringifyType(templateValue)}.',
      );
    } else {
      throw AnalysisException(
        "Unexpected value type of '${key}' property of $context. "
        'Value must be String or mapping, '
        'but ${_stringifyType(simpleOrStructuredTemplate)}.',
      );
    }
  }
}

/// Represents each item of `argument_templates`.
class ArgumentTemplate {
  /// Value of template, if this template is NOT an item template.
  final String? value;

  /// Value of item template, if this template is an item template.
  final String? itemTemplate;

  /// Collection of related imports. This value can be empty.
  final Iterable<TemplateImports> imports;

  /// Initializes a new instance with [value], [itemTemplate], and [imports].
  /// You cannot specify both of [value] and [itemTemplate] are `null` or
  /// non-`null` -- either of them must be `null`.
  const ArgumentTemplate(this.value, this.itemTemplate, this.imports);

  /// Parses raw yaml property entry ([MapEntry]) to [MapEntry] of [String]
  /// (property name) and [ArgumentTemplate].
  ///
  /// This method also parses the property key, then determines the template
  /// is item template or not. The determination result will be reflected
  /// for each [ArgumentTemplate], namely, if the template is item template
  /// (that is, the key ends with `_item_template` suffix),
  /// [ArgumentTemplate.value] will be `null` and [ArgumentTemplate.itemTemplate]
  /// will be non-`null`. Otherwise, [ArgumentTemplate.value] will be not-`null`,
  /// and [ArgumentTemplate.itemTemplate] will be `null`.
  ///
  /// For any type error, [ArgumentError] will be thrown.
  static MapEntry<String, ArgumentTemplate> parse(
    String key,
    dynamic simpleOrStructuredTemplate,
    String context,
  ) {
    if (simpleOrStructuredTemplate is String) {
      return MapEntry(
        key,
        ArgumentTemplate(
          simpleOrStructuredTemplate,
          null,
          [],
        ),
      );
    } else if (simpleOrStructuredTemplate is Map) {
      final dynamic itemTemplateValue =
          simpleOrStructuredTemplate[_itemTemplateKey];
      if (itemTemplateValue is String) {
        return MapEntry(
          key,
          ArgumentTemplate(
            null,
            itemTemplateValue,
            TemplateImports.parse(
              simpleOrStructuredTemplate[_importsKey],
              "'$_importsKey' property of '$key' property of $context",
            ),
          ),
        );
      }

      final dynamic templateValue = simpleOrStructuredTemplate[_templateKey];
      if (templateValue is String) {
        return MapEntry(
          key,
          ArgumentTemplate(
            templateValue,
            null,
            TemplateImports.parse(
              simpleOrStructuredTemplate[_importsKey],
              "'$_importsKey' property of '$key' property of $context",
            ),
          ),
        );
      }

      if (templateValue == null && itemTemplateValue == null) {
        return MapEntry(
          key,
          ArgumentTemplate(
            null,
            null,
            TemplateImports.parse(
              simpleOrStructuredTemplate[_importsKey],
              "'$_importsKey' property of '$key' property of $context",
            ),
          ),
        );
      }

      throw AnalysisException(
        "'$key' property of $context must have "
        "string '$_templateKey' or '$_itemTemplateKey' "
        'property, or needs that both of them are not specified, '
        "but the type of '$_templateKey' is ${_stringifyType(templateValue)}, "
        "and the type of '$_itemTemplateKey' is ${_stringifyType(itemTemplateValue)}.",
      );
    } else {
      throw AnalysisException(
        "Unexpected value type of '$key' property of $context. "
        'Value must be string or mapping, '
        'but ${_stringifyType(simpleOrStructuredTemplate)}.',
      );
    }
  }
}

/// Represents `imports` property of the template.
///
/// This class can represents shorthand String typed template,
/// which represents import without any type restrictions and a prefix.
class TemplateImports {
  static final RegExp _prefixedTypePattern = RegExp(
    r'^((?<Prefix>[a-z$][a-z_$0-9]*)?\.)?(?<Type>[A-Za-z$][A-Za-z_$0-9]*)$',
  );

  /// URI for importing package.
  final String uri;

  /// Prefix for import if any. If not prefixed, this value will be empty string.
  final String prefix;

  /// Type to be showed from the package.
  /// This value can be empty for "import everything".
  final Iterable<String> types;

  /// Initializes new instance from [uri], nullable [prefix], and [types]
  /// which can be empty.
  const TemplateImports(this.uri, this.prefix, this.types);

  /// Parse specified object (yaml property value) to collection of [TemplateImports].
  ///
  /// * If [imports] is `null`, then returns empty collection.
  /// * If [imports] is [String], then returns a [TemplateImports] with URI which
  ///   is equal to [imports]. This is convinience to specify the package URI
  ///   which defines application specific widgets.
  /// * If [imports] is [Map], its keys are treated as `prefix.Type` or
  ///   `Type` and its values are treated as URI of packages, then the parsed
  ///   collection of their key-value pair is returned.
  /// * Otherwise, [ArgumentError] will be thrown.
  static Iterable<TemplateImports> parse(dynamic imports, String context) {
    if (imports == null) {
      return [];
    } else if (imports is String) {
      return [TemplateImports(imports, '', [])];
    } else if (imports is! Map) {
      throw AnalysisException(
        'Unexpected value type of $context. '
        'Value must be string or mapping, but ${_stringifyType(imports)}.',
      );
    }

    final foundImports = <String, Map<String, Set<String>>>{};

    for (final typeMayBePrefixed in imports.keys) {
      if (typeMayBePrefixed is! String) {
        throw AnalysisException(
          "Unexpected key '$typeMayBePrefixed' type of $context. "
          'Keys must be string, but ${_stringifyType(typeMayBePrefixed)}.',
        );
      }

      final dynamic mayBeUri = imports[typeMayBePrefixed];
      if (mayBeUri is! String) {
        throw AnalysisException(
          "Unexpected value '$mayBeUri' type of '$typeMayBePrefixed' property of $context. "
          'Values must be URI string, but ${_stringifyType(mayBeUri)}.',
        );
      }

      final matches =
          _prefixedTypePattern.allMatches(typeMayBePrefixed).toList();
      if (matches.isEmpty) {
        throw AnalysisException(
          'Unexpected key format of $context. '
          "Keys must be '[{prefix}.]{typeName}', but '$typeMayBePrefixed'.",
        );
      }

      final match = matches.single;

      final prefix = match.namedGroup('Prefix') ?? '';
      final type = match.namedGroup('Type')!;

      final existingImports = foundImports[mayBeUri] ??= {};
      (existingImports[prefix] ??= {}).add(type);
    }

    final uris = foundImports.keys.toList()..sort();
    return uris.expand((uri) {
      final prefixedTypes = foundImports[uri]!;
      final prefixes = prefixedTypes.keys.toList()..sort();
      return prefixes.map(
        (p) => TemplateImports(uri, p, prefixedTypes[p]!.toList()..sort()),
      );
    });
  }
}

/// Represents custom namings configuration.
/// Custom namings handles identifier confliction.
class CustomNamings {
  final Map<String, PresenterCustomNamings> _customNamings;

  /// Initializes a new [CustomNamings].
  const CustomNamings(this._customNamings);

  /// Gets a [PresenterCustomNamings] by presenter type name.
  ///
  /// If not configured for specified presenter, `null` will be returned.
  PresenterCustomNamings? operator [](String presenterName) =>
      _customNamings[presenterName];
}

/// Represents per presenter types custom namings.
class PresenterCustomNamings {
  static const _formPropertiesBuilderKey = 'form_properties_builder';

  /// Custom naming configuration for typed form properties builder type.
  ///
  /// If not configured, `null` will be returned.
  final FormPropertiesBuilderCustomNamings? formPropertiesBuilder;

  PresenterCustomNamings._({
    required this.formPropertiesBuilder,
  });

  /// Parses YAML node and creates [PresenterCustomNamings] instance.
  factory PresenterCustomNamings.parse(
    dynamic rawNode,
    String context,
  ) {
    FormPropertiesBuilderCustomNamings? formPropertiesBuilder;

    for (final entry
        in _verifyMappingType<String, dynamic>(rawNode, context, null)
            .entries) {
      switch (entry.key) {
        case _formPropertiesBuilderKey:
          formPropertiesBuilder = FormPropertiesBuilderCustomNamings(
            _verifyMappingType<String, String?>(
              entry.value,
              "'$_formPropertiesBuilderKey' property of $context",
              null,
            ),
          );

          break;
      }
    }

    return PresenterCustomNamings._(
      formPropertiesBuilder: formPropertiesBuilder,
    );
  }
}

/// Represents custom naming configuration for typed form properties builder type.
class FormPropertiesBuilderCustomNamings {
  final Map<String, String?> _customNamings;

  /// Initializes a new [FormPropertiesBuilderCustomNamings] object
  /// with string map, which has key for member identifier and value for
  /// alternative custom name of it.
  FormPropertiesBuilderCustomNamings(this._customNamings);

  /// Gets a custom naming for `build` method.
  /// If not configured, `null` will be returned.
  String? get build => _customNamings['build'];
}
