// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// [FormStateAdapter] implementation for [FormState].
class _FormStateAdapter implements FormStateAdapter {
  final FormState _state;
  final Locale _locale;

  @override
  AutovalidateMode get autovalidateMode => _state.widget.autovalidateMode;

  @override
  Locale get locale => _locale;

  @override
  bool get mounted => _state.mounted;

  _FormStateAdapter(this._state, this._locale);

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

/// Extended mixin of [CompanionPresenterFeatures] for vanilla [Form].
class FormCompanionFeatures
    extends CompanionPresenterFeatures<_FormStateAdapter> {
  final FormCompanionMixin _presenter;

  FormCompanionFeatures._(this._presenter);

  @override
  @nonVirtual
  FormStateAdapter? maybeFormStateOf(BuildContext context) {
    final state = Form.of(context);
    return state == null ? null : _FormStateAdapter(state, getLocale(context));
  }

  @override
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) {
    final state = _presenter.formStateOf(context);
    if (state.autovalidateMode == AutovalidateMode.disabled) {
      // Only re-evaluate target field.
      return (result, error) =>
          _presenter._fieldKeys[name]?.currentState?.validate();
    } else {
      // Re-evaluate all fields including submit button availability.
      return (result, error) {
        if (state.mounted) {
          state.validate();
        }
      };
    }
  }
}

/// Extended mixin of [CompanionPresenterMixin] for vanilla [Form].
///
/// **It is required for [submit] method that there is a [Form] widget as
/// an ancestor in [BuildContext].**
///
/// This class supports following features:
/// * Decouples validation logic from view layer -- validation logic often
///   should exist in domain layer to encourage reuse.
/// * Async validation handling. This class tracks pending asynchronous
///   validation logics. The underlying validation infrastructure supports:
///   * Throttling. If continous validation requests are issued, the validation
///     will only handle last one. [FormField] often issues continous validation
///     because of such user input like fast text typing as well as repeated
///     validate() calls.
///   * Caching. Since async validation can be costly and idempotent in most
///     cases, and the result must be same for identical input, so caching
///     validation result reduces latency. It also second guard about continuous
///     validation requests.
/// * Disables "submit" action. The [submit] method returns [Function] when it
///   is ready for "submit" or `null` otherwise. This class checks validation
///   results of [FormField]s and existance of pending async validations.
mixin FormCompanionMixin on CompanionPresenterMixin {
  late final FormCompanionFeatures _presenterFeatures;

  @override
  CompanionPresenterFeatures get presenterFeatures => _presenterFeatures;

  late final Map<String, GlobalKey<FormFieldState<dynamic>>?> _fieldKeys;

  /// Gets a key for specified named field.
  ///
  /// Binding keys for each field is required to [canSubmit] works correctly.
  Key getKey(String name, BuildContext context) {
    var key = _fieldKeys[name];
    if (key != null) {
      return key;
    }

    return key = _fieldKeys[name] = GlobalObjectKey(name);
  }

  @override
  @nonVirtual
  void initializeCompanionMixin(PropertyDescriptorsBuilder properties) {
    _presenterFeatures = FormCompanionFeatures._(this);
    super.initializeCompanionMixin(
      properties,
    );
    _fieldKeys = {for (final name in properties._properties.keys) name: null};
  }

  @override
  @protected
  @visibleForOverriding
  @visibleForTesting
  bool canSubmit(BuildContext context) {
    final formState = maybeFormStateOf(context);
    if (formState == null ||
        formState.autovalidateMode == AutovalidateMode.disabled) {
      // submit button re-evaluation is only done in Form wide auto validation
      // is enabled, so if Form-wide auto validation is not enabled we always
      // enables submit button.
      return true;
    }

    return _fieldKeys.values
            .every((f) => !(f?.currentState?.hasError ?? false)) &&
        propertiesState
            .getAllDescriptors()
            .every((p) => !p.hasPendingAsyncValidations);
  }
}
