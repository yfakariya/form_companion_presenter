# form_companion_presenter

Ease and simplify your `Form` related work with fine application structure.

If you use [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder)? Check [form_builder_companion_presenter](https://pub.dev/packages/form_builder_companion_presenter), which is a brother of this package.

## Features

* Separete "presentation logic" from your `Widget` and make them testable.
  * Easily and simply bind properties and event-handlers to form fields.
* Remove boring works from your form usage code.
  * Enable "submit" button if there are no validation errors.
  * Combine multiple validators for single `FormField`.
* Asynchronous validation support with throttling and canceling.
* Provide a best practice to fetch validated value. You don't have to think about `onSave` or `onChange` or `TextController` or `Key`...

## Getting Started

### Installation

Do you read this section in pub.dev? Check above and click "Installing" tab!

* Write a dependency to `form_companion_presenter` in your `pubspec.yaml` and run `flutter pub get`
* Or, run `flutter pub add form_companion_presenter`.

### Usage

1. Declare presenter class. Note that this example uses [state notifier](https://pub.dev/packages/state_notifier) and [freezed](https://pub.dev/packages/freezed).

```dart
@freezed
class MyViewState with _$MyViewState {
  factory MyViewState({
    required String name,
    required int age,
  }) = _MyViewState;
}

class MyPresenter extends StateNotifier<MyViewState> {
  MyPresenter(MyViewState initialState)
    : super(initialState) {
  }
}
```

2. Declare `with` in your presenter for `CompanionPresenterMixin` and `FormCompanionMixin` in this order:

```dart
class MyPresenter extends StateNotifier<MyViewState>
  with CompanionPresenterMixin, FormCompanionMixin {
  MyPresenter(MyViewState initialState)
    : super(initialState) {
  }
}
```

3. Add `initializeCompanionMixin()` call with property declaration in the constructor of the presenter. Properties represents values of states which will be input via form fields. They have names and validators, and their type must be same as `FormField`'s type rather than type of state object property:

```dart
  MyPresenter(MyViewState initialState)
    : super(initialState) {
      initializeCompanionMixin(
        PropertyDescriptorBuilder()
        ..string(
          name: 'name',
          validatorFactories: [
            (context) => (value) => (value ?? '').isEmpty ? 'Name is required.' : null,
          ],
        )
        ..integerText(
          name: 'age',
          validatorFactories: [
            (context) => (value) => (value ?? '').isEmpty ? 'Age is required.' : null,
            (context) => (value) => int.parse(value!) < 0 ? 'Age must not be negative.' : null,
          ],
        )
      );
  }
```

4. Implement `doSubmit` override method in your presenter. It handle 'submit' action of the entire form.

```dart
  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    // Gets a validated input values
    String name = getProperty('name').value! as String;
    int age = getProperty('age').value! as int;
    // Calls your business logic here. You can use await here.
    ...
    // Set state to expose for other components of your app.
    state = MyState(name: name, age: age);
  }
```

5. Register your presenter to provider. This example uses [riverpod](https://pub.dev/packages/riverpod):

```dart
final _presenter = StateNotifierProvider<MyPresenter, MyViewState>(
  (ref) => MyPresenter(),
);
```

6. Create widget. We use `ConsumerWidget` here. Note that you must place `Form` and `FormFields` to separate widget:

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Form(
    child: MyFormFields(),
  );
}

class MyFormFields extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextFormField(
          decoration: InputDecoration(
            labelText: 'Age',
          ),
        ),
        ElevatedButton(
          child: Text('Submit'),
        ),
      ],
    );
  }
}
```

7. Set `Form`'s `autovalidateMode`. `AutovalidateMode.onUserInteraction` is recommended.

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: MyFormFields(),
  );
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

8. Get presenter and state in your form field widget, and bind them to the field and 'submit' button:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_presenter);
    final presenter = ref.watch(_presenter.notifier);
    return Column(
      children: [
        TextFormField(
          key: presenter.getKey('name', context),
          initialValue: state.name,
          validator: presenter.getPropertyValidator('name', context),
          onSave: presenter.savePropertyValue('name'),
          decoration: InputDecoration(
            labelText: 'Name',
          ),
        ),
        TextFormField(
          key: presenter.getKey('age', context),
          initialValue: state.age,
          validator: presenter.getPropertyValidator('age', context),
          onSave: presenter.savePropertyValue('age'),
          decoration: InputDecoration(
            labelText: 'Age',
          ),
        ),
        ElevatedButton(
          child: Text('Submit'),
          onTap: presenter.submit(context),
        ),
      ],
    );
  }
```

That's it!

### More examples?

See [repository](https://github.com/yfakariya/form_companion_presenter/examples/). `*_vanilla_form_*.dart` files use `form_companion_presenter`. Note that `*_form_builder_*.dart` files use [form_builder_companion_presenter](https://pub.dev/packages/form_builder_companion_presenter) instead.

## Uses `form_companion_generator` to reduce boiler plate code

You can use [form_companion_generator](../form_companion_generator/README.md) to reduce boiler plate code from previous examples.

To use the generator, follow steps below (see [form_companion_generator docs](../form_companion_generator/README.md) for details):

4. After step 3 of previous examples, qualify your presenter class with `@formCompanion` (or `@FormCompanion()`) annotation:

```dart
@formComapnion
class MyPresenter extends StateNotifier<MyViewState>
  with CompanionPresenterMixin, FormCompanionMixin {
    ...
```

5. Add following packages to `dev_dependencies` of your `pubspec.yaml`

* `build_runner`
* `form_companion_generator`

6. (Optional) Add `build.yaml` in your project's package root (next to `pubspec.yaml`) and configure it (see [documentation of build_config](https://pub.dev/packages/build_config) and [form_companion_generator docs](../form_companion_generator/README.md) for details).

7. Run `flutter pub run build_runner` in your project. Some `.fcp.dart` files will be generated.

8. (Altered from step 4 of previous example ) Implement `doSubmit` override method in your presenter. It handle 'submit' action of the entire form. Note that you can use typed and named getters to access property values.

```dart
  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    // Gets a validated input values
    String name = this.name.value!;
    int age = this.age.value!;
    // Calls your business logic here. You can use await here.
    ...
    // Set state to expose for other components of your app.
    state = MyState(name: name, age: age);
  }
```

9. (Same as step 5 of previous example) Register your presenter to provider. This example uses [riverpod](https://pub.dev/packages/riverpod):

```dart
final _presenter = StateNotifierProvider<MyPresenter, MyViewState>(
  (ref) => MyPresenter(),
);
```

10. (Same as step 6 of previous example) Create widget. We use `ConsumerWidget` here. Note that you must place `Form` and `FormFields` to separate widget:

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Form(
    child: MyFormFields(),
  );
}

class MyFormFields extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: [
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Name',
        ),
      ),
      TextFormField(
        decoration: InputDecoration(
          labelText: 'Age',
        ),
      ),
      ElevatedButton(
        child: Text('Submit'),
      ),
    ]);
  }
}
```

11. (Same as step 7 of previous example) Set `Form`'s `autovalidateMode`. `AutovalidateMode.onUserInteraction` is recommended.

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Form(
    autovalidateMode: AutovalidateMode.onUserInteraction,
    child: MyFormFields(),
  );
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

12. (Altered from step 8 of previous example) Get presenter and state in your form field widget, and bind them to the field and 'submit' button. Note that there are much less code than previous example:

```dart
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(_presenter.notifier);
    return Column(
      children: [
        presenter.fields.name(context),
        presenter.fields.age(context),
        ElevatedButton(
          child: Text('Submit'),
          onTap: presenter.submit(context),
        ),
      ],
    );
  }
```

## Components

This package includes two main constructs:

* `CompanionPresenterMixIn`, which is main entry point of this `form_companion_presenter`.
* `FormCompanionMixin`, which connects flutter's built-in `Form` and `CompanionPresenterMixIn`.

There are advanced constructs for you:

* `AsyncValidatorExecutor`, which is helper of asynchronous validation.
  * This is a helper of `FormCompanionPresenterMixIn`, but you can utilize alone.
* `FutureInvoker`, which translates `Future` based async to completion callback based async.
  * This is base class of `AsyncValidatorExecutor`, and you can use it as you like.

## Localization

Of course, you can localize texts and messages to be shown for users!

For localize built-in validators' messages, you can use `.copyWith()` method and `ParseFailureMessasgeProvider<T>` function to plug in the localization code.

For `AsyncValidatorExecutor`'s text, just specify the localized label via `text` named parameter of the constructor.

For `FormField`s which are created in form field factory (`.fields` in previous example), you can add your localization logic with configuring "templates" in your `build.yaml`. See [form_companion_generator docs](../form_companion_generator/README.md) for details.

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

### Extension methods

#### `PropertyDescriptorsBuilder`

As described above, there are some extension methods for `PropertyDescriptorsBuilder` to provide convinient way to define property with commonly used parameters.

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

`booleanList` | Short hand for `add<List<bool>, List<bool>>`. | Only `name` and `initialValue`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | For check box list like form fields and list of `bool` property. Typically, each labels correspond to options' indexes.
`enumeratedList<T>` | Short hand for `add<List<T>, List<T>>` and `T` is `enum`. | Only `name` and `initialValue`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` | For multiple selection form fields for `enum` value. Typically, each labels correspond to enum members (that is, option names).
`dateTime` | Short hand for `add<DateTime, DateTime>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`dateTimeRange` | Short hand for `add<DateTimeRange, DateTimeRange>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |
`rangeValues` | Short hand for `add<RangeValues, RangeValues>`. | Mostly same as `add` but no `valueConverter`. | `form_builder_companion_presenter/form_builder_companion_presenter.dart` | `FormCompanionPropertyDescriptorsBuilderExtension` |

See API docs of `FormCompanionPropertyDescriptorsBuilderExtension` and `FormBuilderCompanionPropertyDescriptorsBuilderExtension` for details.

##### `WithField` extension methods

There are some `WithField` variations for above extension methods. There methods accept additional type parameter `TField`, which asks for `form_companion_generator` to use the specified `FormField` class for the property. So, notice that `TField` does no effect when you do not use `form_companion_generator`.

> **Question** Why some extension methods rack of `xxxWithField` companion?
> A: Because there are no out-of-box alternative form fields for them, and you can use `addWithField<P, F, TField>` anyway. If you find that there is a new out-of-box or popular alternative form fields, please file the issue.

#### `PropertyDescriptor`

There are also extension methods for `PropertyDescriptor`, to provide convinient access when you do not use `form_companion_generator`. These extension methods are defined in `CompanionPresenterMixinPropertiesExtension` in `form_companion_presenter/form_companion_extension.dart` library.

See API docs of `CompanionPresenterMixinPropertiesExtension` for details.

## Implementing Your Own Mixin

You can implement own mixin for your favorite form field framework. To do so, you should implement following:

* Your `CompanionPresenterFeatures` subtype, which implements actual behavior of the mixin. Override methods which you must to do.
* Your `FormStateAdapter` subtype, which wraps actual `State` of your favorite form field framework. You just implement the class to wrap the actual state.
* Your `CompanionPresenterMixin` subtype as follows:
  * Declare a field which hold your `CompanionPresenterFeatures` subtype. It should be declared as `late final` because it will be initialized in `initializeCompanionMixin` method override.
  * Override `presenterFeatures` getter to return the field which is typed as the `CompanionPresenterFeatures` subtype.
  * Override `initializeCompanionMixin` to initialize the field and call `super.initializeCompanionMixin()` with a `properties` argument.
  * Override other methods if and only if you should do.

For better understand, see source codes of `FormCompanionFeatures`, `FormStateAdapter`, `FormCompanionPresneter`, `FormBuilderCompanionFeatures`, `FormBuilderStateAdapter`, and `FormBuilderCompanionPresenter`.

### `CompanionPresenterMixin`

This extension defines helper methods to implement your own mixin related types which were described above. See API docs of `CompanionPresenterMixinExtension` for details.
