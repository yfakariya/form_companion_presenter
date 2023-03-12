# form_builder_companion_presenter

Ease and simplify your `FormBuilder` related work with fine application structure.

With [form_companion_generator](https://pub.dev/packages/form_companion_generator), your boilerplate code will be gone!

If you don't use [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder), check out [form_companion_presenter](https://pub.dev/packages/form_companion_presenter), which is a brother of this package for flutter's built-in `Form`.

## Features

* With [form_companion_generator](https://pub.dev/packages/form_companion_generator), your boilerplate code will be gone!
* Separete "presentation logic" from your `Widget` and make them testable.
  * Easily and simply bind properties and event-handlers to form fields.
* Remove boring works from your form usage code.
  * Enable "submit" button if there are no validation errors.
  * Combine multiple validators for single `FormBuilderField`.
* Asynchronous validation support with throttling and canceling.
* Provide a best practice to fetch validated value. You don't have to think about `onSave` or `onChange` or `TextController` or `Key`...
* [State restoration](https://api.flutter.dev/flutter/services/RestorationManager-class.html).

## Getting Started

### Installation

Do you read this section in pub.dev? Check above and click "Installing" tab!

* Write a dependency to `form_builder_companion_presenter` in your `pubspec.yaml` and run `flutter pub get`
* Or, run `flutter pub add form_builder_companion_presenter`.

### Usage

#### Prerequisite

Note that this example uses [riverpod](https://pub.dev/packages/riverpod) and [form_companion_generator](https://pub.dev/packages/form_companion_generator), and it is recommended approach.

1. Ensure following packages are added to  `dependencies` of your `pubspec.yaml`

* `riverpod`
* `riverpod_annotation`
* `form_builder_companion_presenter`

2. Ensure following packages are added to `dev_dependencies` of your `pubspec.yaml`

* `build_runner`
* `riverpod_generator`
* `form_companion_generator`

Example:

```yaml
dependencies:
  riverpod: # put favorite version above 2.0.0 here
  riverpod_annotation: # put favorite version here
  form_builder_companion_presenter: # put favorite version here
  ...

dev_dependencies:
  build_runner: # put favorite version above 2.0.0 here
  riverpod_generator: # put favorite version here
  form_companion_generator: # put favorite version here
```

3. (Optional) Add `build.yaml` in your project's package root (next to `pubspec.yaml`) and configure it (see [documentation of build_config](https://pub.dev/packages/build_config) and [form_companion_generator docs](https://github.com/yfakariya/form_companion_presenter/blob/main/packages/form_companion_generator/README.md).

#### Steps

1. Declare presenter class.

```dart
@riverpod
@formCompanion
class MyPresenter extends _$MyPresenter {
  MyPresenter() {
  }

  @override
  FutureOr<$MyPresenterFormProperties> build() async {
  }
}
```

2. Declare `with` in your presenter for `CompanionPresenterMixin` and `FormBuilderCompanionMixin` in this order:

```dart
@riverpod
@formCompanion
class MyPresenter extends _$MyPresenter
  with CompanionPresenterMixin, FormBuilderCompanionMixin {
  MyPresenter() {
  }

  @override
  FutureOr<$MyPresenterFormProperties> build() async {
  }
}
```

3. Add `initializeCompanionMixin()` call with property declaration in the constructor of the presenter. Properties represents values of states which will be input via form fields. They have names and validators, and their type must be same as `FormBuilderField`'s type rather than type of state object property:

```dart
  MyPresenter() {
      initializeCompanionMixin(
        PropertyDescriptorBuilder()
        ..add<String>(
          name: 'name',
          validatorFactories: [
            (context) => FormBuilderValidators.required,
          ],
        )
        ..add<String>(
          name: 'age',
          validatorFactories: [
            (context) => FormBuilderValidators.required,
            (context) => (value) => int.parse(value!) < 0 ? 'Age must not be negative.' : null,
          ],
        )
      );
  }
```

Note that there are various extension methods of `PropertyDescriptorBuilder` to implement initialization easily. In addition, you can specify form field types for generated form factories with extension methods of `PropertyDescriptorBuilder` which have `WithField` suffixes.

4. Implement `build` to fetch upstream state and fill it as properties' initial state.

```dart
  @override
  FutureOr<$MyPresenterFormProperties> build() async {
    final upstreamState = await ref.watch(upstreamStateProvider.future);
    return resetProperties(
      (properties.copyWith()
      ..name(upstreamState.name)
      ..age(upstreamState.age)
      ).build()
    )
  }
```

5. Add `part` directive near top of the file where `example.dart` is the file name of this code.

```dart
part 'example.fcp.dart';
part 'example.g.dart';
```

6. Run `build_runner` (for example, run `flutter pub run build_runner build -d`). Provider global property and related types will be created by `riverpod_generator`, and `$MyPresenterFormStates` and related extensions will be created by `form_companion_generator`.

7. Implement `doSubmit` override method in your presenter. It handle 'submit' action of the entire form.

```dart
  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    // Gets a validated input values
    String name = properties.values.name;
    int age = properties.values.age;
    // Calls your business logic here. You can use await here.
    ...
    // Set state to expose for other components of your app.
    ref.read(anotherStateProvider).state = AsyncData(MyState(name: name, age: age));
    // and more...
  }
```

8. Create a widget. We use `ConsumerWidget` here. Note that you must place `FormBuilder` and `FormBuilderFields` to separate widget. Note that `state.fields` have form field factories generated by `form_companion_generator` and their type can be controlled in the presenter:

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FormBuilder(
    child: MyFormFields(),
  );
}

class MyFormFields extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        state.value.fields.name(
          context,
        ),
        state.value.fields.age(
          context,
        ),
        ElevatedButton(
          onTap: state.value.submit(context),
          child: Text('Submit'),
        ),
      ],
    );
  }
}
```

If you set `AutovalidateMode.disabled` (default value), you can execute validation in head of your `doSubmit()` as following:

```dart
  @override
  FutureOr<void> doSubmit(BuildContext context) async{
    if (!await validateAndSave(context)) {
      return;
    }

    ..rest of code..
  }
```

That's it!

### Enable State Restoration

[State restoration](https://api.flutter.dev/flutter/services/RestorationManager-class.html) improves form input experience because it restores inputting data for the form when the app was killed on background by mobile operating systems. Is it very frustrated if you lose inputting data during open browser to find how to fill the form fields correctly? The browser tends to use large memory, so your app could be terminated frequently.

To enable state restoration, just put `FormPropertiesRestorationScope` under your `FormBuilder` like following:

```dart
class MyForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(myPresenterProvider.notifier);
    return FormBuilder(
      child: FormPropertiesRestorationScope(
        presenter: presenter,
        child: MyFormFields(),
      ),
    );
  }
}
```

Note that if you omit (or specify `null` for) `restorationId` of `FormPropertiesRestorationScope`, string representation of `runtimeType` of `presenter` will be used. If you avoid restoration in whole fields, just remove `FormPropertiesRestorationScope` your widget tree.

### More examples?

See [repository](https://github.com/yfakariya/form_companion_presenter/tree/main/examples/form_companion_presenter_example). `*_form_builder_*.dart` files use `form_builder_companion_presenter`. Note that `*_vanilla_form_*.dart` files use [form_companion_presenter](https://pub.dev/packages/form_companion_presenter) instead.

## Components

This package includes one main construct:

* `FormBuilderCompanionMixin`, which connects flutter's built-in `FormBuilder` and `CompanionPresenterMixIn`.

You can use components from `form_companion_presenter`. See [documents](https://github.com/yfakariya/form_companion_presenter/blob/main/packages/form_companion_presenter/README.md) for details.

## Localization

Of course, you can localize texts and messages to be shown for users!

For localize built-in validators' messages, you can use `.copyWith()` method and `ParseFailureMessageProvider<T>` function to plug in the localization code.

For `AsyncValidatorExecutor`'s text, just specify the localized label via `text` named parameter of the constructor.

For `FormField`s which are created in form field factory (`.fields` in previous example), you can add your localization logic with configuring "templates" in your `build.yaml`. See [form_companion_generator docs](https://github.com/yfakariya/form_companion_presenter/blob/main/packages/form_companion_generator/README.md) for details.

## PropertyDescriptor details

You can customize `PropertyDescriptor` via optional named parameters of `PropertyDescriptorsBuilder`'s `add` method or its extension methods. Following table shows parameters of the `add` method. Note that some of them are common in other (extension) methods.

name | summary | type | default | note
--|--|--|--|--
`P` | Type of the property to be stored. | `extends Object` | (required) | Can be accessed via `PropertyDescriptor<P, F>.value` getter.
`F` | Type of the value in `FormField`. | `extends Object` | (required) | Can be accessed via `getFieldValue` and `setFieldValue`.
`name` | Name of the property. | `String` | (required) | Name will be 1) getter names generated by `form_companion_generator`, 2) keys to get `PropertyDescriptor`
`validatorFactories` | Factories for normal validations. | `List<FormFieldValidatorFactory<F>>?` | `[]` | See below for details.
`asyncValidatorFactories` | Factories for asynchronous validations. | `List<AsyncValidatorFactory<F>>?` | `[]` | See below for details.
`initialValue` | An initial value of the property. | `P?` | `null` |
`equality` | Custom equality comparer for `F`. | `Equality<F>?` | `null` | If `null`, values for `FormField` will be compared with `equals()` method.
`valueConverter` | Value conversion between `P` and `F`. | `ValueConverter<P, F>?` | `null` | If `null`, internal default converters will be used. Note that value conversion will be treated as normal validation implicitly. See below for details.
`enumValues` | (introduced in 0.5) Tells values of the specified enum for [state restoration](https://api.flutter.dev/flutter/services/RestorationManager-class.html). | `Iterable<T>` | (required) | In most cases, `E.values` static member like `Brightness.values`.
`valueTraits` | (introduced in 0.5) Specifies additional traits of the value. | `PropertyValueTraits?` | `null` | `null` means uses `PropertyValueTraits.none`. For details, see "Value Traits" section bellow.
`restorableValueFactory` | (introduced in 0.5) Factory to produce [`RestorableValue<F>`](https://api.flutter.dev/flutter/widgets/RestorableValue-class.html) for the property. | `RestorableValueFactory<F>?` | `null` | If `null`, restoration will not work. There are some out-of-box built-in factories: `stringRestorableValueFactory`, `intRestorableValueFactory`, `doubleRestorableValueFactory`, `boolRestorableValueFactory`, `bigIntRestorableValueFactory`, `enumRestorableValueFactory()`, `enumListRestorableValueFactory()`, `dateTimeRestorableValueFactory`, `dateTimeRangeRestorableValueFactory`, and `rangeValuesRestorableValueFactory`.

### Normal Validations

Normal validations are done by normal validators, and the validators will be constructed via validator factories which are specified in `validatorFactories` parameter.

`validatorFactories` parameter's type is `List<FormFieldValidatorFactory<F>>?`, and `FormFieldValidatorFactory<F>` is alias of `FormFieldValidator<T> Function(ValidatorCreationOptions)` function type, where `FormFieldValidator<T>` is alias of `String? Function(T?)` function type, which is defined in `flutter/widgets.dart` library.

The `ValidatorCreationOptions` contains `BuildContext` and `Locale`, which are determined when `PropertyDescriptor<P, F>.getValidator()` method is called. The validator factories can use these parameters to build their validators, a main use-cases including error message localization and format (such as decimal number or currency) localization.

The contract of `FormFieldValidator<T>` is same as normal flutter's validators. So, you return `null` for valid input, or return non-`null` validation error message for invalid input.

Note that tail of normal validators chain is always implicit validator which try to convert from `F` to `P`. It will return conversion failure message as validation result when it will fail to convert value from `F` to `P`.

### Asynchronous Validation

Asynchronoous validations are done by asynchronous validators, and the validators will be constructed via validator factories which are specified in `asyncValidatorFactories` parameter.

`asyncValidatorFactories` parameter's type is `List<AsyncValidatorFactory<F>>?`, and `AsyncValidatorFactory<F>` is alias of `AsyncValidator<T> Function(ValidatorCreationOptions)` function type. The `AsyncValidator<T>` is alias of `FutureOr<String?> Function(T?, AsyncValidatorOptions)` function type.

The `ValidatorCreationOptions` contains `BuildContext` and `Locale`, which are determined when `PropertyDescriptor<P, F>.getValidator()` method is called. This is same as normal validator factories, so see previous description for it. More importantly, all async validation logics take a second parameter, whih type is `AsyncValidatorOptions`. The `AsyncValidatorOptions` object also contains `Locale`, which is guaranteed to be available when the async validation is called. So, async validators should always use this value instead of the value passed via `ValidatorCreationOptions` as long as possible.

The contract of `AsyncValidator<T>` is same as normal flutter's validators except it is wrapped with `FutureOr<T>`. So, you declare the async validation logic as `async`, and you return `null` for valid input, or return non-`null` validation error message for invalid input.

Note that asynchronous validators chain will be invoked after all normal validators including an implicit validator which try to convert from `F` to `P`.

### Value Conversion

Sometimes, a type of stored property value (`P`) and a type of the value which is edited via `FormField<T>` (`F`) are different. For example, if a numeric value is input in text box (such as `TextFormField`), `P` should be `int` (or one of the other numeric types). To handle such cases, `valueConverter` parameter takes `ValueConverter<P, F>` object.

`ValueConverter<P, F>` defines two conversion methods, `F? toFieldValue(P? value, Locale locale)` and `SomeConversionResult<P> toPropertyValue(F? value, Locale locale)`. For most cases, you just use `ValueConverter.fromCallbacks` factory method, which takes two functions, `PropertyToFieldConverter<P, F>` and `FieldToPropertyConverter<P, F>`, they are conpatible with `toFieldValue` method and `toPropertyValue` methods respectively. Furthermore, you should use `StringConverter<P>.fromCallbacks` when `F` is `String`, it provides basic implementation for `String` conversion.

There are some built-in `StringConverter`s are available:

* `intStringConverter` for `int` and `String` conversion.
* `doubleStringConverter` for `double` and `String` conversion.
* `bigIntStringConverter` for `BigInt` and `String` conversion.
* `dateTimeStringConverter` for `DateTime` and `String` conversion.
* `uriStringConverter` for `Uri` and `String` conversion.

You can use `StringConverter.copyWith` method when you only customize any combination of:

* Conversion failure message.
  * It is usually done for message localization.
* Default conversion result for `null` input from `FormField`.
* Default `String` result for `null` input (`initialValue` of the property).

So, it is advanced scenario to call `StringConverter.fromCallbacks` directly, and it is more advanced scenario to call `ValueConverter.fromCallbacks` directory or extends their converter types. `StringConverter.copyWith` should cover most cases.

Note that tail of normal validators chain (described above) is always implicit validator which try to convert from `F` to `P`. This means that value conversion should be done twice for field value to property value conversion propcess. In addition, when you use text form like field, validation and conversion pipeline should be fired in every charactor input. So, you should implement value convertor that it is light weight and idempotent.

### Value Traits

From 0.5, you can specify `PropertyValueTraits` for each properties. It affects runtime behavior as following:

member | effect
--|--
`doNotRestore` | If this value is specified, state restoration with `form_companion_presenter` is disabled for the form field. This is useful the field which input is trivial for users but it can occupy restoration state data.
`sensitive` | If this value is specified, state restoration with `form_companion_presenter` is disabled for the form field to avoid persist sensitive data in the local device. In addition, form factories which will be generated by `form_companion_generator` uses `true` for default values for `obscureText` parameters of text field based form fields.

### Extension methods

#### `PropertyDescriptorsBuilder`

As described above, there are some extension methods for `PropertyDescriptorsBuilder` to provide convinient way to define property with commonly used parameters.

(from `form_companion_presenter`)

name | summary | parameters | package | defined in | note
--|--|--|--|--|--
`string` | Short hand for `add<String, String>`. | Mostly same as `add` but no `valueConverter`. | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | For text field based form fields and `String` property.
`boolean` | Short hand for `add<bool, bool>`. | Only `name` and `initialValue`. | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | For check box like form fields and `bool` property. Note that default initial value is defined as `false` rather than `null`. Use `enumerated<T>` for tri-state value.
`enumerated<T>` | Short hand for `add<T, T>` and `T` is `enum`. | Only `name` and `initialValue`. | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | For drop down or single selection form fields for `enum` value.
`integerText` | Short hand for `add<int, String>`. | Mostly same as `add` but there is a `stringConverter` instead of `valueConverter` (default is `intStringConverter`). | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`realText` | Short hand for `add<double, String>`. | Mostly same as `add` but there is a `stringConverter` instead of `valueConverter` (default is `doubleStringConverter`). | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`bigIntText` | Short hand for `add<BigInt, String>`. | Mostly same as `add` but there is a `stringConverter` instead of `valueConverter` (default is `bigIntStringConverter`). | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`uriText` | Short hand for `add<Uri, String>`. | Mostly same as `add` but there is a `stringConverter` instead of `valueConverter` (default is `uriStringConverter`). | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`stringConvertible<P>` | Short hand for `add<P, String>`. | Mostly same as `add` but `stringConverter` (instead of `valueConverter`) is required. | `form_companion_presenter/form_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | Use other extension (`xxxText`) if you can.

(from this `form_builder_companion_presenter`)

name | summary | parameters | package | defined in | note
--|--|--|--|--|--
`booleanList` | Short hand for `add<List<bool>, List<bool>>`. | Only `name` and `initialValue`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormBuilderCompanionPropertyDescriptorsBuilderExtension` | For check box list like form fields and list of `bool` property. Typically, each labels correspond to options' indexes.
`enumeratedList<T>` | Short hand for `add<List<T>, List<T>>` and `T` is `enum`. | Only `name` and `initialValue`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormBuilderCompanionPropertyDescriptorsBuilderExtension` | For multiple selection form fields for `enum` value. Typically, each labels correspond to enum members (that is, option names).
`dateTime` | Short hand for `add<DateTime, DateTime>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormBuilderCompanionPropertyDescriptorsBuilderExtension` |
`dateTimeRange` | Short hand for `add<DateTimeRange, DateTimeRange>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormBuilderCompanionPropertyDescriptorsBuilderExtension` |
`rangeValues` | Short hand for `add<RangeValues, RangeValues>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormBuilderCompanionPropertyDescriptorsBuilderExtension` |

See [API doc](https://pub.dev/documentation/form_companion_presener/latest/form_companion_presener/FormCompanionPropertyDescriptorsBuilderExtension.html) of `FormCompanionPropertyDescriptorsBuilderExtension` and  [API doc](https://pub.dev/documentation/form_builder_companion_presener/latest/form_builder_companion_presener/FormBuilderCompanionPropertyDescriptorsBuilderExtension.html) of `FormBuilderCompanionPropertyDescriptorsBuilderExtension` for details.

##### `WithField` extension methods

There are some `WithField` variations for above extension methods. There methods accept additional type parameter `TField`, which asks for `form_companion_generator` to use the specified `FormField` class for the property. So, notice that `TField` does no effect when you do not use `form_companion_generator`.

> **Question** Why some extension methods rack of `xxxWithField` companion?
>
> A: Because there are no out-of-box alternative form fields for them, and you can use `addWithField<P, F, TField>` anyway. If you find that there is a new out-of-box or popular alternative form fields, please file the issue.

#### `PropertyDescriptor`

There are also extension methods for `PropertyDescriptor`, to provide convinient access when you do not use `form_companion_generator`. These extension methods are defined in `CompanionPresenterMixinPropertiesExtension` in `form_companion_presenter/form_companion_extension.dart` library.

See API docs of `CompanionPresenterMixinPropertiesExtension` for details.

### State Restoration in Detail

As mentioned above, [state restoration](https://api.flutter.dev/flutter/services/RestorationManager-class.html) improves form input experience because it restores inputting data for the form when the app was killed on background by mobile operating systems. Is it very frustrated if you lose inputting data during open browser to find how to fill the form fields correctly? The browser tends to use large memory, so your app could be terminated frequently.

So, every form fields should support restoration, but it is hard to expect all fields implement it. To resolve this problem, `form_builder_companion_presenter` uses following strategy:

* `PropertyDescriptor.initialValue` remembers "initial value", which is the "field value" of the property if the restored value does not exist.
* The validator returned from `PropertyDescriptor.getValidator()` remembers validation result.
* When there is a restored value, `PropertyDescriptor.initialValue` returns the restored value and it eventually set to `initialValue` of the form field. In addition, it schedules validation invocation if the form field had validation error before app termination and is not configured to use auto-validation.

Note that state restoration does not work in Web nand Desktop platforms by Flutter's design.

## Breaking Changes

See [https://github.com/yfakariya/form_companion_presenter/blob/main/BREAKING_CHANGES.md] to check breaking changes.
