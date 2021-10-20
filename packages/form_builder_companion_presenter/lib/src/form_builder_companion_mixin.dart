// See LICENCE file in the root.

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

/// [FormStateAdapter] implementation for [FormBuilderState].
class _FormBuilderStateAdapter implements FormStateAdapter {
  final FormBuilderState _state;

  @override
  AutovalidateMode get autovalidateMode =>
      _state.widget.autovalidateMode ?? AutovalidateMode.disabled;

  _FormBuilderStateAdapter(this._state);

  @override
  bool validate() => _state.validate();

  @override
  void save() => _state.save();
}

/// Another [FormCompanionMixin] for [FormBuilder] instead of [Form].
///
/// **It is required for [submit] method that there is a [FormBuilder] widget as
/// an ancestor in [BuildContext].**
mixin FormBuilderCompanionMixin on CompanionPresenterMixin {
  @override
  @nonVirtual
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _maybeFormStateOf(context);

  _FormBuilderStateAdapter? _maybeFormStateOf(BuildContext context) {
    final state = FormBuilder.of(context);
    if (state == null) {
      return null;
    }

    // This is required to register this BuildContext source is depending
    // Form. Note that FormBuilder internally uses Form to set _FormScope.
    final formState = Form.of(context);
    assert(formState != null);
    return _FormBuilderStateAdapter(state);
  }

  @override
  @protected
  @nonVirtual
  @visibleForOverriding
  @visibleForTesting
  bool canSubmit(BuildContext context) {
    final formState = _maybeFormStateOf(context);
    if (formState == null ||
        formState.autovalidateMode == AutovalidateMode.disabled) {
      // submit button re-evaluation is only done in Form wide auto validation
      // is enabled, so if Form-wide auto validation is not enabled we always
      // enables submit button.
      return true;
    }

    // More efficient than base implementation.
    return formState._state.fields.values.every((f) => !f.hasError) &&
        properties.values.every((p) => !p.hasPendingAsyncValidations);
  }

  @override
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) {
    final formState = formStateOf(context);
    if (formState.autovalidateMode == AutovalidateMode.disabled) {
      // Only re-evaluate target field.
      final fieldState = _maybeFormStateOf(context)?._state.fields[name];
      return (result, error) => fieldState?.validate();
    } else {
      // Re-evaluate all fields including submit button availability.
      return (result, error) => formState.validate();
    }
  }

  @override
  @protected
  @nonVirtual
  @visibleForTesting
  void saveFields(FormStateAdapter formState) {
    if (formState is _FormBuilderStateAdapter) {
      formState.save();
      for (final field in formState._state.value.entries) {
        properties[field.key]?.saveValue(field.value);
      }
    } else {
      assert(
        false,
        'formState should be _FormBuilderStateAdapter but ${formState.runtimeType}',
      );
      super.saveFields(formState);
    }
  }
}
