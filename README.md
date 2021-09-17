# form_companion_presenter

Form companion presenter helps your annoying Form related coding.
This project includes three packages:

* `form_companion_presenter`: Core package, main module is `FormCompanionPresenterMixIn`. If you don't want to use [StateNotifier](), try use it.
* `form_presenter_state_notifier`: Provides convinient implementation with flutter's genouine [Form]() and [StateNotifier]() package. If you want to use form helper library other than [FormBuilder](), try use it.
* `form_builder_presenter_state_notifier`: Provides convinient implementation utlizing [FormBuilder]() and [StateNotifier]() package. It is recommended package as long as you don't have any requirement for library usages.

## Features

* `FormCompanionPresenterMixIn` provides "propeties" of the presenter. The properties are represented as list of `PropertyDescriptor`s, which have `name` and `validator`. You can use the properties in your presenter as well as in your `Widget`. It enables simple unit testing of validation logics.
  * If you use it with [FormBuilder], `name` can be used as a value for `FormFieldBuilder.name`.
  * A validator of `PropertyDescriptor` can contain one or more asynchronous validators as well as one or more validators.
* Auto-validation support. T.B.D.
* `submit` property which is suitable for `onTap` of buttons. `submit` property will be `null` if the `Form` is auto-validate mode and not all validation logics have not been completed successfully, so the button will be disabled until validations initiated by auto-validation will be completed.
* Supports localization of validation error messages.

## Usage

See individual `README.md` for packages. [form_builder_presenter_state_notifier]() is recommended.

## Related packages

* [StateNotifier]()
* [FormBuilder]()

## Remarks

### What is "presenter" ?

T.B.D.

