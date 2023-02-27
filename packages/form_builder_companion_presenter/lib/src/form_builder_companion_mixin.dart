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

  @override
  bool get mounted => _state.mounted;

  _FormBuilderStateAdapter(this._state, this._locale);

  @override
  bool validate() {
    if (!mounted) {
      // There are not widgets to show the validation error anyway.
      return true;
    }

    return _state.validate();
  }

  @override
  void save() {
    if (mounted) {
      _state.save();
    }
  }
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
      return (result, error) {
        if (fieldState?.mounted ?? false) {
          fieldState?.validate();
        }
      };
    } else {
      // Re-evaluate all fields including submit button availability.
      return (result, error) {
        if (formState.mounted) {
          formState.validate();
        }
      };
    }
  }

  @override
  @nonVirtual
  @protected
  @visibleForTesting
  void saveFields(_FormBuilderStateAdapter formState) {
    formState.save();
    for (final field in formState._state.value.entries) {
      _presenter.propertiesState
          .tryGetDescriptor(field.key)
          ?.setFieldValue(field.value, formState.locale);
    }
  }

  @override
  void restoreField(
    BuildContext context,
    String name,
    Object? value, {
    required bool hasError,
  }) {
    final formState = FormBuilder.of(context);
    if (formState != null) {
      final fieldState = formState.fields[name];
      assert(
        fieldState != null,
        'Failed to get $name field from FormBuilder', // Coverage:ignore-line
      );
      // This causes re-validation if auto-validation is enabled.
      fieldState!.didChange(value);

      if (hasError &&
          (formState.widget.autovalidateMode ?? AutovalidateMode.disabled) ==
              AutovalidateMode.disabled &&
          fieldState.widget.autovalidateMode == AutovalidateMode.disabled) {
        // Re-validate to reflect error.
        fieldState.validate();
      }
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
  @nonVirtual
  CompanionPresenterFeatures get presenterFeatures => _presenterFeatures;

  @override
  @nonVirtual
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
    Form.of(context);
    return _FormBuilderStateAdapter(state, getLocale(context));
  }

  @override
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
        propertiesState
            .getAllDescriptors()
            .every((p) => !p.hasPendingAsyncValidations);
  }
}
