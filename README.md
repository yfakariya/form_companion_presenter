# form_companion_presenter

Form companion presenter helps your annoying Form related coding.
This project includes three packages:

* `form_companion_presenter`: Core package, main modules are `CompanionPresenterMixin` and `FormCompanionMixin`. If you don't want to use [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder), try use it.
* `form_builder_companion_presenter`: Provides convinient implementation utilizing [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder) package. It is recommended package as long as you don't have any requirement for library usages (there are many form helper packages in pub.dev).
* `form_companion_generator`: Helper tool running with `build_runner`. This tool generates typed property accessors and form field factories for presenters which are marked with `@formCompanion` (or parameterized `@FormCompanion`) annotation. This tool also provides some customize points. See [ReadMe](packages/form_companion_generator/README.md) for details.

## Features

* `CompanionPresenterMixin` provides "properties" of the presenter. The properties are represented as list of `PropertyDescriptor`s, which have `name` , `validator`, etc. You can use the properties in your presenter as well as in your `Widget`. It enables simple unit testing of validation logics.
  * If you use it with [FormBuilder], `name` can be used as a value for `FormBuilderField.name`.
  * A validator of `PropertyDescriptor` can contain one or more asynchronous validators as well as one or more validators. Asynchronous validator is useful for validation logics which need to call remote APIs.
  * You can bind `PropertyDescriptor` to `FormField` with convinient methods like `getPropertyValidator`, `getKey`, or `savePropertyValue`.
* Additional mixins, namely `FormCompanionMixin` and `FormBuilderCompanionMixin` connects between `CompanionPresenterMixin` and correspond form library.
  * `FormCompanionMixin` for flutter's built-in `Form`.
  * `FormBuilderCompanionMixin` for [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder).
* Auto-validation support. The companion detects `autoValidateMode` of `Form` or `FormBuilder` and respect it in its behaviors.
* `submit` property which is suitable for `onTap` of buttons. `submit` property will be `null` if the `Form` is auto-validate mode and not all validation logics have not been completed successfully, so the button will be disabled until validations initiated by auto-validation will be completed.
* Supports localization of validation error messages.
* Helper tool `form_companion_generator`, which generates typed property accessors and form field factories for presenters which are marked with `@formCompanion` (or parameterized `@FormCompanion`) annotation. This tool also provides some customize points. See [ReadMe](packages/form_companion_generator/README.md) for details.

## Usage

### Basic Usage

```dart
// Declare presenter for the widget which holds transitive presentation state.
// Of course, you may name it as controller or notifier if you like,
// and you can use any base class which is required by your faviorite library or framework.
class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  Presenter(/* parameter to initialize state here */) {
    initializeCompanion(
      PropertyDescriptorsBuilder()
        ..string(name: 'name')
        ..integerText(name: 'age'),
    );
  }

  @override
  void doSubmit() {
    final name = getSavedPropertyValue<String>('name');
    final age = getSavedPropertyValue<int>('age');
    // Put presentation layer's logic when "submit" button is tapped/clicked here.
  }
}

// In your widget
Widget build(BuildContext context) {
  final presenter = /* get presenter here */
  final name = presenter.getProperty<String, String>('name');
  final age = presenter.getProperty<int, String>('age');
  return Row(
    children: [
      TextFormField(
        key: presenter.getKey('name'),
        onSaved: name.savePropertyValue,
        validator: name.getValidator(context),
      ),
      TextFormField(
        key: presenter.getKey('age'),
        onSaved: age.savePropertyValue,
        validator: age.getValidator(context),
      ),
      ActionButton(
        onTap: presenter.submit(context),
      )
    ],
  )
}
```

I know that above code is not so simple. So, you can utilize `form_companion_generator`, then the above code can be following:

```dart
// Add an annotation to tell the `form_companion_generator` that
// this class should be handled.
@formCompanion
class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  Presenter(/* parameter to initialize state here */) {
    initializeCompanion(
      PropertyDescriptorsBuilder()
        ..string(name: 'name')
        ..integerText(name: 'age'),
    );
  }

  @override
  void doSubmit() {
    final name = this.name.value;
    final age = this.age.value;
    // Put presentation layer's logic when "submit" button is tapped/clicked here.
  }
}

// In your widget
Widget build(BuildContext context) {
  final presenter = /* get presenter here */
  return Row(
    children: [
      // Auto-generated FormField factories here.
      presenter.fields.name,
      presenter.fields.age,
      ActionButton(
        onTap: presenter.submit(context),
      )
    ],
  )
}
```

See individual `README.md` for packages for details. We recommend to use [form_builder_companion_presenter](./package/form_builder_companion_presenter/README.md) as long as you have any reason to avoid `flutter_form_builder` package. Also, it is highly recommended to run `form_companion_generator` on `build_runner` for your projects.

### Customization

#### Customize Property Behavior

You can customize property behavior with `PropertyDescriptorsBuilder`'s method parameter including:

* A custom value converter which converts between property type in presenter logic and field type in `FormField`.
* One or more validators. Validators can be synchronous or asynchronous.
  * For localization, actual parameters are `validatorFactories` and `asyncValidatorFactories`, which are list of factory functions which accept `BuildContext` and returns (async)validator function.

```dart
PropertyDescriptorsBuilder()
  ..add(
    name: 'myProperty',
    validatorFactories: [
      // Functions which accepts BuildContext, and then returns `String? Function(String?)`
      (context) => ...,
      // This is same signature for FormBuilderValidators.
      FormBuilderValidators.required,
    ],
    asyncValidatorFactories: [
      // Functions which accepts BuildContext, and then returns `Future<String?> Function(String?, AsyncValidationOptions)`
      (context) => ...,
    ]
  )
```

#### Using flutter_form_builder

You can utilize `flutter_form_builder` as helper library by mixing `FormBuilderCompanionMixin` instead of `FormCompanionMixin`.
You also be able to use your preferred library by implementing custom mixin.

```dart
class Presenter with CompanionPresenterMixin, FormBuilderCompanionMixin {
  ...
}
```

#### AsyncValidationIndicator

`AsyncValidationIndicator` is helper widget to indicate asynchronous validation is in progress.

TODO: sample code

#### Helper extensions

There are many helper extensions to define properties including `string`, `integerText`, `boolean`, etc. And you can specify `FormField` class as generic argument with extension methods end with `WithField` suffix.

```dart
PropertyDescriptorsBuilder()
  // String typed property suitable for String typed FormField.
  // Actual form field type depends for which companion you can use (`FormCompanionMixin` or `FormBuilderCompanionMixin`)
  ..string(name: 'name')
  // int typed property suitable for String typed FormField.
  // Actual form field type depends for which companion you can use (`FormCompanionMixin` or `FormBuilderCompanionMixin`)
  ..integerText(name: 'age')
  // If you use form_builder_companion_presenter, you can use `DateTime` (`FormBuilderDatePicker` will be used).
  // Note that you must mix `FormBuilderCompanionMixin`.
  ..dateTime(name: 'birthDay')
  // Customize form field type for enum (default is `DropdownButtonFormField` or `FormBuilderDropdown`)
  ..enumeratedWithField<Sex, Sex, FormBuilderChoiceChip<Sex>>(name: 'sex'),
```

## Related packages

This project assumes that you use following packages to build your form and logic. Note that an original author of this project does not relates to these packages.

* [riverpod](https://pub.dev/packages/riverpod)
* [state notifier](https://pub.dev/packages/state_notifier)
* [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder)

See [example](./examples/form_companion_presenter_example) for example sources which utilize above packages.
