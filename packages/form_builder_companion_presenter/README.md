# form_builder_companion_presenter

Ease and simplify your `FormBuilder` related work with fine application structure.

If you don't use [Flutter FormBuilder](https://pub.dev/packages/flutter_form_builder)? Check [form_companion_presenter](https://pub.dev/packages/form_companion_presenter), which is a brother of this package.

## Features

* Separete "presentation logic" from your `Widget` and make them testable.
  * Easily and simply bind properties and event-handlers to form fields.
* Remove boring works from your form usage code.
  * Enable "submit" button if there are no validation errors.
  * Combine multiple validators for single `FormBuilderField`.
* Asynchronous validation support with throttling and canceling.
* Provide a best practice to fetch validated value. You don't have to think about `onSave` or `onChange` or `TextController` or `Key`...

## Getting Started

### Installation

Do you read this section in pub.dev? Check above and click "Installing" tab!

* Write a dependency to `form_builder_companion_presenter` in your `pubspec.yaml` and run `flutter pub get`
* Or, run `flutter pub add form_builder_companion_presenter`.

### Usage

1. Declare presenter class. It is recommended to use [state notifier](https://pub.dev/packages/state_notifier) and [freezed](https://pub.dev/packages/freezed).

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

2. Declare `with` in your presenter for `CompanionPresenterMixin` and `FormBuilderCompanionMixin` in this order:

```dart
class MyPresenter extends StateNotifier<MyViewState>
  with CompanionPresenterMixin, FormBuilderCompanionMixin {
  MyPresenter(MyViewState initialState)
    : super(initialState) {
  }
}
```

3. Add `initializeCompanionMixin()` call with property declaration in the constructor of the presenter. Properties represents values of states which will be input via form fields. They have names and validators, and their type must be same as `FormBuilderField`'s type rather than type of state object property:

```dart
  MyPresenter(MyViewState initialState)
    : super(initialState) {
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

4. Implement `doSubmit` override method in your presenter. It handle 'submit' action of the entire form.

```dart
  @override
  FutureOr<void> doSutmit(BuildContext context) async {
    // Gets a validated input values
    String name = getSavedPropertyValue('name');
    int age = int.parse(getSavedPropertyValue('age'));
    // Calls your business logic here. You can use await here.
    ...
    // Set state to expose for other components of your app.
    state = MyState(name: name, age: age);
  }
```

5. Register your presenter to provider. This example uses [riverpod](https://pub.dev/packages/riverpod):

```dart
final _presenter = StateNotifierProvider<MyPresenter>(
  (ref) => MyPresenter(),
);
```

6. Create widget. We use `ConsumerWidget` here. Note that you must place `FormBuilder` and `FormBuilderFields` to separate widget:

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FormBuilder(
    child: MyFormFields(),
  );
}

class MyFormFields extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Column(children: [
      FormBuilderTextField(
        name: 'name',
        decoration: InputDecoration(
          labelText: 'Name',
        ),
      ),
      FormBuilderTextField(
        name: 'age',
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

7. Set `FormBuilder`'s `autovalidateMode`. `AutovalidateMode.onUserInteraction` is recommended.

```dart
class MyForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) => FormBuilder(
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
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(_presenter);
    final presenter = watch(_presenter.notifier);
    return Column(children: [
      FormBuilderTextField(
        name: 'name',
        initialValue: state.name,
        validator: presenter.getPropertyValidator('name', context),
        onSave: presenter.savePropertyValue('name'),
        decoration: InputDecoration(
          labelText: 'Name',
        ),
      ),
      FormBuilderTextField(
        name: 'age',
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
    ]);
  }
```

That's it!

### More examples?

See [repository](https://github.com/yfakariya/form_companion_presenter/examples/). `*_form_builder_*.dart` files use `form_builder_companion_presenter`. Note that `*_vanilla_form_*.dart` files use [form_companion_presenter](https://pub.dev/packages/form_companion_presenter) instead.
