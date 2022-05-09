// See LICENCE file in the root.

import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

/// [FormStateAdapter] implementation for [FormBuilderState].
class _FormBuilderStateAdapter implements FormStateAdapter {
  final FormBuilderState _state;
  final Locale _locale;

  @override
  AutovalidateMode get autovalidateMode =>
      _state.widget.autovalidateMode ?? AutovalidateMode.disabled;

  @override
  Locale get locale => _locale;

  _FormBuilderStateAdapter(this._state, this._locale);

  @override
  bool validate() => _state.validate();

  @override
  void save() => _state.save();
}

/// Extends [CompanionPresenterFeatures] for [FormBuilder] instead of [Form].
class FormBuilderCompanionFeatures
    extends CompanionPresenterFeatures<_FormBuilderStateAdapter> {
  final FormBuilderCompanionMixin _presenter;

  FormBuilderCompanionFeatures._(this._presenter);

  @override
  @nonVirtual
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _presenter._maybeFormStateOf(context);

  @override
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) {
    final formState = _presenter.formStateOf(context);
    if (formState.autovalidateMode == AutovalidateMode.disabled) {
      // Only re-evaluate target field.
      final fieldState =
          _presenter._maybeFormStateOf(context)?._state.fields[name];
      return (result, error) => fieldState?.validate();
    } else {
      // Re-evaluate all fields including submit button availability.
      return (result, error) => formState.validate();
    }
  }

  @override
  @nonVirtual
  @protected
  @visibleForTesting
  void saveFields(_FormBuilderStateAdapter formState) {
    formState.save();
    for (final field in formState._state.value.entries) {
      _presenter.properties[field.key]
          ?.setFieldValue(field.value, formState.locale);
    }
  }
}

/// Another [CompanionPresenterMixin] companion mixin
/// for [FormBuilder] instead of [Form].
///
/// **It is required for [submit] method that there is a [FormBuilder] widget as
/// an ancestor in [BuildContext].**
mixin FormBuilderCompanionMixin on CompanionPresenterMixin {
  late final FormBuilderCompanionFeatures _presenterFeatures;

  @override
  CompanionPresenterFeatures get presenterFeatures => _presenterFeatures;

  @override
  void initializeCompanionMixin(PropertyDescriptorsBuilder properties) {
    _presenterFeatures = FormBuilderCompanionFeatures._(this);
    super.initializeCompanionMixin(properties);
  }

  _FormBuilderStateAdapter? _maybeFormStateOf(BuildContext context) {
    final state = FormBuilder.of(context);
    if (state == null) {
      return null;
    }

    // This is required to register this BuildContext source is depending
    // Form. Note that FormBuilder internally uses Form to set _FormScope.
    final formState = Form.of(context);
    assert(formState != null);
    return _FormBuilderStateAdapter(state, getLocale(context));
  }

  @override
  @nonVirtual
  @protected
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
}
