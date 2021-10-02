# form_companion_presenter

Form companion presenter helps your annoying Form related coding.
This project includes three packages:

* `form_companion_presenter`: Core package, main modules are `CompanionPresenterMixin` and `FormCompanionMixin`. If you don't want to use [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder), try use it.
* `form_builder_companion_presenter`: Provides convinient implementation utilizing [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder) package. It is recommended package as long as you don't have any requirement for library usages (there are many form helper packages in pub.dev).

## Features

* `CompanionPresenterMixin` provides "propeties" of the presenter. The properties are represented as list of `PropertyDescriptor`s, which have `name` , `validator`, etc. You can use the properties in your presenter as well as in your `Widget`. It enables simple unit testing of validation logics.
  * If you use it with [FormBuilder], `name` can be used as a value for `FormBuilderField.name`.
  * A validator of `PropertyDescriptor` can contain one or more asynchronous validators as well as one or more validators. Asynchronous validator is useful for validation logics which need to call remote APIs.
  * You can bind `PropertyDescriptor` to `FormField` with convinient methods like `getPropertyValidator`, `getKey`, or `savePropertyValue`.
* Additional mixins, namely `FormCompanionMixin` and `FormBuilderCompanionMixin` connects between `CompanionPresenterMixin` and correspond form library.
  * `FormCompanionMixin` for flutter's built-in `Form`.
  * `FormBuilderCompanionMixin` for [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder).
* Auto-validation support. The companion detects `autoValidateMode` of `Form` or `FormBuilder` and respect it in its behaviors.
* `submit` property which is suitable for `onTap` of buttons. `submit` property will be `null` if the `Form` is auto-validate mode and not all validation logics have not been completed successfully, so the button will be disabled until validations initiated by auto-validation will be completed.
* Supports localization of validation error messages.

## Usage

See individual `README.md` for packages. [form_builder_companion_presenter](./package/form_builder_companion_presenter/README.md) is recommended.

## Related packages

* [riverpod](https://pub.dev/packages/riverpod)
* [state notifier](https://pub.dev/packages/state_notifier)
* [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder)
