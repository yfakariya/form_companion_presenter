# Ideas

Some random ideas for future implementation.

## Generator

### L10N support

Some form fields supports `label` and/or `hint` for display. These should be localized for usability, because many application users desire localized words rather than English words.

The biggest problem is that there are some L10N frameworks and they do not specify predicatable format to generate data. For example, `intl` package specifies that writing `Intl.message(name: KEY, args: [...])` format, but `easy_localization` package specifies `KEY.tr()` format. So, we must introduce flexible way to enable specyfing as your desired format.

We will introduce this as follows:

* We introduce customizable properties in `build.yaml` and parameters of `@FormCompanion` annotation.
  * We MAY omit some properties in `@FormCompanion` annotation for technical reasons.
* We introduce macros (desribed bellow) in the customizable properties, which are replaced by some predefined values in emit time.

#### Providing properties

**property** | **default** | **description**
--|--|--
`labelTemplate` | `#PROPERTY_NAME#` | Template to be used for `label` parameter of `InputDecoration` constructor.
`hintTemplate` | `null` | Template to be used for `hint` parameter of `InputDecoration` constructor.

#### Example

```dart
@FormCompanion(
  labelTemplate: 'l10n.#PROPERTY_NAME#_label.tr()',
  hintTemplate: 'l10n.#PROPERTY_NAME#_hint.tr()',
)
```

```yaml
labelTemplate: 'l10n.#PROPERTY_NAME#_label.tr()'
hintTemplate: 'l10n.#PROPERTY_NAME#_hint.tr()'
```

### DropdownItem and FormBuilderItem support

After `form_companion_generator` used, many form field construction should become as follows:

```dart
final presenter = ...
return Row(
  rows: [
    presenter.fields.id(context),
    presenter.fields.name(context),
    ActionButton(
      submit: presenter.submit(context),
    ),
  ],
);
```

However, for selective fields including `DropdownButtonFormField` or `FormBuilderFilterChip`, there are long code to specify option items specification as follows:

```dart
  presenter.fields.contry(items: [
      DropdownItem(value: Country.japan, label: localizedCountryName.japan),
      // we know there are over 100+ countries over the world, and it is hard to use for loop when we have to implement i18n/l10n, right?
  ])
```

So, we will introduce template based item generation.

#### Spec

* For parameters which are `List<DropdownMenuItem<T>>` and `List<FormBuilderOption<T>>` types are supported.
  * The list item types are specified in keys of `itemTemplates` property as described later.
* The field value type (`F` of `PropertyDescriptor<P, F>`) must be enum.
* We introduce customizable properties in `build.yaml` and parameters of `@FormCompanion` annotation.
* Format is `itemTemplates` map which key is target element type like `DropdownItem` or `FormBuilderOption`, case sensitive.
* We will support macros for itemTemplates.

#### Customize in app code

If the emitter emits item template based form factory code, it also emits `{propertyName}ItemFactory`, which type is `FormFieldOptionFactory<T, TOption>`.

```dart
typedef FormFieldOptionFactory<P, F, O> = O Function(PropertyDescriptor<P, F>, P);
```

For example, form factory for `DropdownButtonField` should be as follows:

```dart
DropdownButtonFormField myProperty(
  BuildContext context, {
  ...,
  FormFieldOptionFactory<MyEnum, MyEnum, DropdownMenuItem<MyEnum>>? itemsItemFactory,
  ...,
  }) {
    ...
    return DropdownButtonFormField(
      ...,
      items: MyEnum.values.map((p => (itemsItemFactory ?? _defaultItemsItemFactory)(property, p)).toList(),
      ...,
    )
  }

  DropdownMenuItem<MyEnum> _defaultItemsItemFactory(PropertyDescriptorBuilder<MyEnum, MyEnum> property, MyEnum value)
    => 
    // Folloing code is generated from macro and code specified as itemTemplate.DropdownOption
    DropdownMenuItem<MyEnum>(value: value, child: Text('${value}_label'.tr(),);
)
```

#### Example of `itemTemplates`

```dart
@FormCompanion(itemTemplates: const {
  'DropdownMenuItem': "DropdownMenuItem<MyEnum>(value: #ITEM_VALUE#, child: Text('\${#ITEM_VALUE#}_label'.tr(),)",
})
```

```yaml
itemTemplates:
  'DropdownMenuItem': "DropdownMenuItem<MyEnum>(value: #ITEM_VALUE#, child: Text('${#ITEM_VALUE#}_label'.tr(),)"
```

### Extra imports

Some template values requires additional import, so we supports extra imports properties.

* We introduce customizable properties in `build.yaml` and parameters of `@FormCompanion` annotation.
* Format is `extraImports` map which key is package uri (`package:` scheme) and its value is list of import type names.
  * The value can be empty list.
* We will not support macros for `extraImports`.

#### Example of `extraImports`

```dart
@FormCompanion(extraImports: const {
  'package:example/example.dart': [
    'Something',
    'Anything',
  ],
  'package:example/something.dart': [
    'Foo',
    'Bar',
  ],
})
```

```yaml
extraImports:
  'package:example/example.dart':
    - Something
    - Anything
  'package:example/something.dart':
    - Foo
    - Bar
```

### Macros

#### Syntax

In regex format, macro key must be as follows:

```regex
#[A-Z]+(_[A-Z]+)*#
```

In each template, macro key must be surrounded with '#' as follows:

```yaml
"Text('${#ITEM_VALUE#}_label'.tr()"
```

This should be translated as following dart expression (`value` is subject to change):

```dart
Text('${value}_label'.tr())
```

#### Lists

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
`ITEM_VALUE_STRING` | `itemTemplates` | String representation of `#ITEM_VALUE#`. This value will be same as `#ITEM_VALUE#` for `String`, will be `#ITEM_VALUE# ?? ''` for `String?`, will be `#ITEM_VALUE#.toString()` for non-string `T`, or will be `#ITEM_VALUE#?.toString() ?? ''` for non-string `T?`.
