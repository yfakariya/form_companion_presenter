// See LICENCE file in the root.

import 'macro_keys.dart';

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
  static const _autovalidateByDefaultKey = 'autovalidate_by_default';
  static const _extraLibrariesKey = 'extra_libraries';

  /// Key of [asPart] in config.
  static const asPartKey = 'as_part';

  static const _namedTemplatesKey = 'named_templates';
  static const _argumentTemplatesKey = 'argument_templates';

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

  /// Ordered list of extra libraries to resolve `preferredFieldType`s.
  /// Each entries must be specified as 'package:` form URI.
  ///
  /// Dependencies in generating source is basically resolved from depdency
  /// resolution for source file, which declares presenter(s) decorated with
  /// `@formCompanion` annotation. In some situations, this stragety does not
  /// work, so resolution of `FormField` can be failed. If so, you specify this
  /// property to help generator.
  List<String> get extraLibraries {
    final dynamic mayBeExtraLibraries = _underlying[_extraLibrariesKey];
    if (mayBeExtraLibraries is String) {
      return [mayBeExtraLibraries];
    } else if (mayBeExtraLibraries is List) {
      return mayBeExtraLibraries.whereType<String>().toList();
    } else {
      return [];
    }
  }

  NamedTemplates? _materializedNamedTemplates;

  /// `named_templates` in config.
  ///
  /// Note that each templates can contain any context macros.
  ///
  /// Built-in named templates are:
  /// * `label_template`. It is for `labelText` of `InputDecoration`,
  ///   and be intended to provide L10N extension point for labels.
  ///   Default is `#PROPERTY#.name`.
  /// * `hint_template`. It is for `hintText` of `InputDecoration`,
  ///   and be intended to provide L10N extension point for labels.
  ///   Default is `null`.
  /// * `item_widget_template`. It is for `child` of element of `items` or
  ///   `options, and be intended to provide L10N extension point.
  ///   Default is `Text(#ITEM_VALUE#)`.
  NamedTemplates get namedTemplates {
    if (_materializedNamedTemplates == null) {
      final dynamic rawNamedTemplates = _underlying[_namedTemplatesKey];
      if (rawNamedTemplates is Map) {
        _materializedNamedTemplates = NamedTemplates(
          Map.fromEntries(
            rawNamedTemplates.entries
                .where((x) => x.key is String && x.value is String)
                .map(
                  (e) => MapEntry(
                    e.key.toString().toUpperCase(),
                    e.value.toString(),
                  ),
                ),
          ),
        );
      } else {
        _materializedNamedTemplates = const NamedTemplates({});
      }
    }

    return _materializedNamedTemplates!;
  }

  ArgumentTemplates? _materializedItemTemplates;

  /// `argument_templates` in config.
  ///
  /// Note that each templates can contain any context macros and named templates.
  ///
  /// Built-in argument templates are:
  /// * For defaults (all form fields even if the parameter is specified in `argument_templates`):
  ///   * `autovalidateMode`:
  ///     * `#AUTO_VALIDATE_MODE#`
  ///     * It is configured `AutovalidateMode`.
  ///   * `decoration`:
  ///     * `#ARGUMENT# ?? #DEFAULT_VALUE_COPY_OR_NEW#(labelText: #LABEL_TEMPLATE#, hintText: #HINT_TEMPLATE#)`
  ///     * It enables specifying custom `InputDecoration` respecting the default
  ///       value which is defined in form field's constructor parameter.
  /// * For `DropdownButtonFormField` and `FormBuilderDropdown`:
  ///   * `items_item_template` (item template for `items`):
  ///     * 'DropdownMenuItem<#FIELD_VALUE_ITEM_TYPE#>(value: #ITEM_VALUE#, child: #ITEM_WIDGET_TEMPLATE#)`
  ///     * It enables customize `DropdownMenuItem` fully, but you can customize
  ///       partially for its widget with `item_widget_template` named template.
  ///   * `onChanged`: `#ARGUMENT# ?? (_) {}`
  /// * For `FormBuilderCheckboxGroup`, `FormBuilderFilterChip`,
  ///   `FormBuilderRadioGroup`, and `FormBuilderSegmentedControl`:
  ///   * `options_item_template` (item template for `options`):
  ///     * `FormBuilderFieldOption<#FIELD_VALUE_ITEM_TYPE#>(value: #ITEM_VALUE#, child: #ITEM_WIDGET_TEMPLATE#)`
  ///     * It enables customize `FormBuilderFieldOption` fully, but you can customize
  ///       partially for its widget with `item_widget_template` named template.
  ArgumentTemplates get argumentTemplates {
    if (_materializedItemTemplates == null) {
      final dynamic rawItemTemplates = _underlying[_argumentTemplatesKey];
      if (rawItemTemplates is Map) {
        _materializedItemTemplates = ArgumentTemplates({
          for (final e in rawItemTemplates.entries
              .where((x) => x.key is String && x.value is Map))
            e.key as String: {
              for (final t
                  in (e.value as Map).entries.map(ArgumentTemplate.parse))
                t.key: t.value
            },
        });
      } else {
        _materializedItemTemplates = ArgumentTemplates({});
      }
    }

    return _materializedItemTemplates!;
  }

  /// Initializes a new instance with values from builder options.
  Config(this._underlying);
}

/// Represents `named_templates` configuration property.
class NamedTemplates {
  final Map<String, String> _namedTemplates;

  /// Initializes a new instance from [Map] of [String].
  ///
  /// Keys are names of templates.
  const NamedTemplates(this._namedTemplates);

  /// Gets a specified template.
  ///
  /// This method returns `null` when the specified template is not defined.
  String? get(String name) => _namedTemplates[name];
}

/// Represents `argument_templates` configuration property.
class ArgumentTemplates {
  // class -> property
  final Map<String, Map<String, ArgumentTemplate>> _argumentTemplates;

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

// TODO(yfakariya): testing imports and errors

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
    MapEntry<dynamic, dynamic> rawArgumentTemplate,
  ) {
    final dynamic property = rawArgumentTemplate.key;
    if (property is! String) {
      throw ArgumentError(
        "Unexpected key type of property of 'argument_templates': "
        '${property.runtimeType}',
      );
    }

    final dynamic simpleOrStructuredTemplate = rawArgumentTemplate.value;
    if (simpleOrStructuredTemplate is String) {
      return MapEntry(
        property,
        ArgumentTemplate(
          simpleOrStructuredTemplate,
          null,
          [],
        ),
      );
    } else if (simpleOrStructuredTemplate is Map) {
      final dynamic itemTemplateValue =
          simpleOrStructuredTemplate['item_template'];
      if (itemTemplateValue is String) {
        return MapEntry(
          property,
          ArgumentTemplate(
            null,
            itemTemplateValue,
            TemplateImports.parse(simpleOrStructuredTemplate['imports']),
          ),
        );
      }

      final dynamic templateValue = simpleOrStructuredTemplate['template'];
      if (templateValue is String) {
        return MapEntry(
          property,
          ArgumentTemplate(
            null,
            templateValue,
            TemplateImports.parse(simpleOrStructuredTemplate['imports']),
          ),
        );
      }

      throw ArgumentError(
        "'$property' property of "
        "'argument_templates' must have String 'template' or 'item_template' "
        "property but the type of 'template' is: ${templateValue.runtimeType}, "
        "and the type of 'item_template' is: ${itemTemplateValue.runtimeType}.",
      );
    } else {
      throw ArgumentError(
        "Unexpected value type of '$property' property of "
        "'argument_templates': ${simpleOrStructuredTemplate.runtimeType}",
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
  static Iterable<TemplateImports> parse(dynamic imports) {
    if (imports == null) {
      return [];
    } else if (imports is String) {
      return [TemplateImports(imports, '', [])];
    } else if (imports is! Map) {
      throw ArgumentError(
        "Unexpected type of 'imports': ${imports.runtimeType}",
      );
    }

    // ignore: omit_local_variable_types
    final Map<String, Map<String, Set<String>>> foundImports = {};

    for (final typeMayBePrefixed in imports.keys) {
      if (typeMayBePrefixed is! String) {
        throw ArgumentError(
          "Unexpected property key type of 'imports': ${typeMayBePrefixed.runtimeType}",
        );
      }

      final dynamic mayBeUri = imports[typeMayBePrefixed];
      if (mayBeUri is! String) {
        throw ArgumentError(
          "Unexpected property value type of '$typeMayBePrefixed' property of "
          "'imports': ${typeMayBePrefixed.runtimeType}",
        );
      }

      final matches =
          _prefixedTypePattern.allMatches(typeMayBePrefixed).toList();
      if (matches.isEmpty) {
        throw ArgumentError(
          "Unexpected property key format of 'imports': '$typeMayBePrefixed'",
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
