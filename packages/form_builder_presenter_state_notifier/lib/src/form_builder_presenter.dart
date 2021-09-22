// See LICENCE file in the root.

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:meta/meta.dart';

import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_presenter_state_notifier/form_presenter_state_notifier.dart';

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

/// Base class for presenters which binds to a form using [FormBuilder].
abstract class FormBuilderPresenter<T> extends FormPresenter<T> {
  /// Creates [FormBuilderPresenter] with its initial state.
  FormBuilderPresenter({
    required T initialState,
    required PropertyDescriptorsBuilder properties,
  }) : super(
          initialState: initialState,
          properties: properties,
        );

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _maybeFormStateOf(context);

  _FormBuilderStateAdapter? _maybeFormStateOf(BuildContext context) {
    final state = FormBuilder.of(context);
    return state == null ? null : _FormBuilderStateAdapter(state);
  }

  @override
  @protected
  @visibleForOverriding
  bool canSubmit(BuildContext context) {
    final formState = _maybeFormStateOf(context);
    if (formState == null ||
        formState.autovalidateMode == AutovalidateMode.disabled) {
      // Should be manual validation in doSubmit(), so returns true here.
      return true;
    }

    // More efficient than base implementation.
    return formState._state.fields.values.every((f) => !f.hasError) &&
        properties.values.every((p) => !p.hasPendingAsyncValidations);
  }

  @override
  @protected
  @nonVirtual
  void saveFields(FormStateAdapter formState) {
    if (formState is _FormBuilderStateAdapter) {
      formState.save();
      for (final field in formState._state.value.entries) {
        properties[field.key]?.setDynamicValue(field.value);
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
