# form_companion_generator

Code generator for `form_companion_presenter` and `form_builder_companion_presetner`

## Usage

(1) Add package reference in `dev_dependencies` in your `pubspec.yaml`:

```yaml
  dev_dependencies:
    form_companion_generator: ^x.y.z
```

(2) Add `build.yaml` in your package, next to `pubspec.yaml`:

```yaml
targets:
  $default:
    builders:
      form_companion_generator:
        enabled: true
        # Bellow generate_for entry is optional, but it is recommended
        # to set exclude/include filters which filter out only target
        # sources which have classes decorated with `@FormCompanion`.
        # This trick improves your build_runner execution time drastically.
        generate_for:
          exclude:
            - to/be/excluded/globs/*.dart
          include:
            - to/be/included/globs/*.dart
```

(3) Run following command on the top directory of your package sources.

```shell
# For one time
dart pub run build_runner build form_companion_generator
# ..or for continuous back-ground execution
dart pub run build_runner watch form_companion_generator
```

(4) You can find `*.fcp.dart` files next to your sources which have classes decorated with `@FormCompanion` annotation.

## Features

* Generates easy and type-safe accessors for `PropertyDescritor`s and their saved values.
* Generates customizable `FormField` (or `FormBuilderField`) factories for each `PropertyDescritor`.

## Spec

### Prereqs

* Decorate your companion with `@formCompanion` annotation.
  * If you use `FormBuilderCompanionPresenterMixin`, then the generator creates codes using `FormBuilder`; otherwise, it generates sources which only use vanilla `Form`.
* You can specify validation mode for the annotation.
* The generator will read property definitions from a **single expression** which is passed to `initializeCompanionMixin` method call in the constructor body. The single expression must be one of the following:
  * Inline `PropertyDescritorBuilder` construction.
  * Local variable reference, which is `PropertyDescritorBuilder` type. Note that the generator only tracks its initialization expression.
  * Static field, which is `PropertyDescritorBuilder` type. Note that the generator only tracks its initialization expression

### L10N Support

You can get L10N support via templating feature, described below.
For most cases, you can localize form fields with writing your `build.yaml` to modify three pre-defined `named_templates` entries: `label_template`, `hint_template`, and `item_widget_template`. For example, you can write your templates with macros (desribed lator) to generate code which retrieve L10N strings via your favorit I18N libraries such as `intl`, `easy_localization`, etc.

For example:

```yaml
# In your build.yaml
builders:
  form_companion_generator:
    enabled: true
    options:
      named_templates:
        # This template assumes easy_localization usage.
        label_template: 'LocaleKeys.#PRESENTER#_#PROPERTY#_label.tr()'
        # This template assumes intl usage (with gen-l10n).
        hint_template: 'L10n.of(#BUILD_CONTEXT#).#PRESENTER#_#PROPERTY#_hint'
```

### Templating

Although form companion generator make out of box code to create `FormField` from presenter's properties, sometimes you might want to customize generated code. For example, you want to localize label and hint text, or want to customize dropdown items. In many cases, you can do it via optional parameters of generated form field factories, but this method is bother when you customize all or many of fields you use.
To solve this case, you can add or replace **templates** of the generator. Templates can be configured in `build.yaml` which can be located next to the `pubspec.yaml` in your application or package.

There are two types of templates -- `named_templates` and `argument_templates`, and both of them can be configured as `options` property in `build.yaml`.

#### Argument Templates

Argument templates are map of templates for each arguments for constructors of instanciating `FormField`s. Its key is name of insntanciating `FormField` class (note that this name is case sensitive), and this entries' values are also map, the keys of the inner maps are name of parameters of the constructor.

The values are either string or map.

If you specify string value for the parameter, the specified string value will be simple template string, so it will be emitted as the constructor parameter assignment expression. Note that you can use macros for the template string. The macro can be written in `#MACRO_NAME#` format, where `MACRO_NAME` is macro name.

If you specify map for the parameter, you can specify following properties:

* `template` string. This is same as specify string instead of the map.
* `item_template` string, described below.
* `imports`, described below.

Note that either `template` or `item_template` properties are required.

When you not configure any template for the parameter, default template (`#ARGUMENT#`) will be used.

To specify argument template for specific constructor parameter for all `FormField` subclasses, you can use `default` key for the outer map's key (they normally represent class name of `FormField` subclass).

##### Item Template

As described before, each entries under properties in `argument_templates` may have `item_template` property instead of `template` property. The value of `item_template` is referred as Item Template.

The `item_template` represents a tempalte for each item of collection, and it is only available in properties which have "collection-like" field value types, which are one of following:

* `Iterable<E>` or its subtypes (including `List<E>`). Item template should be applied for each items of the `Iterable<E>` value (thus, the item value type is `E`).
* Any enum type. Item template should be applied for each members of the enum type (thus, the item value type is the enum type). Note that if the type is nullable, then `null` is also included in head of the members.
* `bool`. Item template should be applied for `[true, false]`. Note that if the type is nullable, then `null` is also included in head, that is the list will be `[null, true, false]`.

If the field value type of the property is not a "collection-like" type, the item template is ignored, so the parameter uses default template.

In addition, some macro keys are only available in Item Templates. See below for details of macro keys.

##### Example of Argument Templates

The following code list shows sample `argument_templates` in `build.yaml`:

```yaml
builders:
  form_companion_generator:
    options:
      argument_templates:
        default:
          autovalidateMode: '#ARGUMENT# ?? #AUTO_VALIDATE_MODE#'
          decoration:
            template: '#ARGUMENT# ?? #DEFAULT_VALUE_COPY_OR_NEW#(labelText: #LABEL_TEMPLATE#, hintText: #HINT_TEMPLATE#)'
            imports: 'package:myapp/src/locale/l10n.dart'

        DropdownButtonFormField:
          items:
            item_template: 'DropdownMenuItem<#ITEM_VALUE_TYPE#>(value: #ITEM_VALUE#, child: #ITEM_WIDGET_TEMPLATE#)'
          hint: '#ARGUMENT# ?? #HINT_TEMPLATE#'
          onChanged:
            template: '#ARGUMENT# ?? c.onChangedCommon'
            imports:
              'c.onChangedCommon': 'package:myapp/src/utils/common_functions.dart'
          hint: '#ARGUMENT# ?? (_) {}'
```

Note that you can find default template configuration with inspecting `build.yaml` file which is located next to this readme file.

#### Named Templates

Named templates are essentially user-defined macros which can be used in `argument_templates`.
Note that keys of named templates must be referred from `argument_templates` with `UPPER_SNEAK_CASING` even if the key is defined with `lower_sneak_cases`.

As you notice, keys of `named_templates` are case insensitive when they defined.

NOTE: Another `named_templates` entry reference in `named_templates` are NOT supported.

##### Predefined Named Templates

There are three predefined named templates as following table. Note that some of them use macros described later.

**key** | **value** | **description**
--|--|--
label_template | `#PROPERTY#.name` | Default template to be used for `labalText` of `InputDecorator` for `decorator` parameter of `FormField`.
hint_template | `null` | Default template to be used for `hintText` of `InputDecorator` for `decorator` parameter of `FormField`.
item_widget_template | `Text(#ITEM_VALUE_STRING#)` | Default template to be used in predefined item templates for `items` and `options` to specify `widget` parameter for widgets of field items like `DropdownMenuItem<T>` or `FormBuilderOption<T>`.

Tip: If you specify `hint_template`, it is recommended to specify `hint` argument template for `DropdownButtonFormField` and `FormBuilderDropdown` with value `'#ARGUMENT# ?? #HINT_TEMPLATE#'`.

##### Example of Named Templates

The following code list shows sample `named_templates` in `build.yaml`:

```yaml
builders:
  form_companion_generator:
    options:
      named_templates:
          label_template:
            template: 'L10n.#PRESENTER#_#PROPERTY#_label'
            imports:
              - 'package:intl/intl.dart`
              - 'package:myapp/src/locale/l10n.dart'
          hint_template: 'L10n.#PRESENTER#_#PROPERTY#_hint'
            imports:
              - 'package:intl/intl.dart`
              - 'package:myapp/src/locale/l10n.dart'

```

#### Imports in Templates

You can specify `import` directive in `imports` property of the each argument templates and named templates. `imports` property can be string or map.

If you specify string value for `imports`, the string will be treated as a single import URI such as `package:intl/intl.dart`.

If you specify map, the keys and values must be string. The keys and values will be treated as following:

* If the key has only ASCII identifier letters (`[A-Za-z$][A-Za-z_$0-9]*` in regex), then the key represents the type name should be written after `show` keyword of the `import` directive.
* If the key has ASCII lower alpha-numeric letters (`[a-z$][a-z_$0-9]*` in regex), following 1 dot (`.`), and ASCII identifier letters (`[A-Za-z$][A-Za-z_$0-9]*` in regex), then the key represents prefix and the type name. The prefix should be written after `as` keyword, and the type name should be written after `show` keyword, of the `import` directive respectively.
* The key which has any other format is not allowed.
* The value is URI of the importing package.

It is recommended to use map format to avoid unepxected name confliction in generated code. Simple (string format) import should be used for localization related import only (names `L10n` or `LocaleKeys` should not be conflicted).

Note that if you specify duplicated `imports` entries in the `build.yaml`, they are just merged.

#### Macro

For values under `argument_templates` and `named_templates`, you can use following macros, which will be replaced with appropriate values in code generation. Macros can be specfieid with `#MACRO_NAME#` format in your template values. Note that `MACRO_NAME` is case sensitive and must be defined in following table. Macro name must be upper sneak casing string, and only ASCII uppercase letters, ASCII numbers, and an underscore are allowed.  If the specified macro name is not defined, the code generator will end with error.

See following `build.yaml` spec for available macros.

## `build.yaml` Spec

You can specify various options via your `build.yaml` file, which is located to next to `pubspec.yaml`.

```yaml
# In your build.yaml
builders:
  form_companion_generator:
    enabled: true
    options:
      # Put options here
```

> **Note**
> You can refer general specification of `build.yaml` in [build_package documentation](https://pub.dev/packages/build_config).

### Available Options

**key** | **type** | **default** | **description**
--|--|--|--
`autovalidate_by_default`| bool | `true` | If `true`, default value of `autovalidateMode` of form fields will be `AutovalidateMode.onUserInteraction`. Otherwise, the value will be `AutovalidateMode.disabled`.
`as_part` | bool | `false` | If `true`, generated `*.fcp.dart` file will be part of original files (files without `.fcp` suffix), shares namespaces and imports. This is convinient if you use many 3rd party imports in your properties, but it leads member name conflicts and might lead poor code completion (intellisense) experience.
`extra_libraries` | String, or list of string | empty | Specify package uri with `package:...` format which adds hint for generator to find importing libraries. Note that if the library is not referenced actually, the import entry will not be emitted.
`uses_enum_name` | bool or null | `null` | If `true`, `#ITEM_VALUE_STRING#` for enum will be emitted as `#ITEM_VALUE#.name`. If `false`, it will be emitted as `#ITEM_VALUE#.toString()`, which will write enum type name prefix with separator dot (`.`) like `MyEnum.memberOne`. If `null`, it depends on the language version of source file; if the language version (`sdk` of `environment` in `pubspec.yaml`) is gerator than or equal to `2.15`, `.name` will be used.
`named_templates` | map of string | (see previous `named_templates` section) | Defines or overrides named templates. All values are string.
`argument_templates` | (see previous `argument_templates` section) | (see previous `argument_templates` section) | Defines or overrides argument templates. All values are string, or map of string (for item templates).

### Macros Available in Tempaltes

In template values, you can use defined named templates or following context specific macros as `#MACRO_NAME#` format.

**key** | **available in** | **description**
--|--|--
`PROPERTY_NAME` | any | Replaced with static token which is name of the property.
`PROPERTY_VALUE_TYPE` | any | Replaced with static token which is `P` of `PropertyDescriptor<P, F>` for the property.
`FIELD_VALUE_TYPE` | any | Replaced with static token which is `P` of `PropertyDescriptor<P, F>` for the property.
`PROPERTY` | any | Replaced with static token which is local variable identifier of `PropertyDescriptor<P, F>` for the property.
`LABEL_TEMPLATE` | `itemTemplates` | Replaced with expression resolved for `labelTemplate`.
`HINT_TEMPLATE` | `itemTemplates` | Replaced with expression resolved for `hintTemplate`.
`ITEM_VALUE` | `itemTemplates` | Replaced with static token which is local variable identifier which holds current enum member, bool value, or collection item.
`ITEM_VALUE_TYPE` | `itemTemplates` | Replaced with static token which is a type of the `#ITEM_VALUE`.
`ITEM_VALUE_STRING` | `itemTemplates` | See below "About `#ITEM_VALUE_STRING#`.

#### About `#ITEM_VALUE_STRING#`

`#ITEM_VALUE_STRING#` macro will be replaced with string representation of `#ITEM_VALUE#`. This value will vary on the type of items type as following:

**item type** | **other condition** | **replacement result**
--|--|--
`String` | - | `#ITEM_VALUE#`
`String?` | - | `#ITEM_VALUE# ?? ''`
enum | Dart SDK version >= 2.15 or `uses_enum_name` option is set to `true` | `#ITEM_VALUE#.name`
enum | Dart SDK version < 2.15 or `uses_enum_name` option is set to `false` | `#ITEM_VALUE#.toString()`
enum (nullable) | Dart SDK version >= 2.15 or `uses_enum_name` option is set to `true` | `#ITEM_VALUE#?.name ?? ''`
enum (nullable) | Dart SDK version < 2.15 or `uses_enum_name` option is set to `false` | `#ITEM_VALUE#?.toString() ?? ''`
other types | - | `#IETM_VALUE#.toString()`
other types (nullable) | - | `#IETM_VALUE#?.toString() ?? ''`
