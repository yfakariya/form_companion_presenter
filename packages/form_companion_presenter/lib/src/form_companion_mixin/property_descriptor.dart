// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Represents "property" of view model which uses [CompanionPresenterMixin].
///
/// This is advanced feature, so normal users should not concern this object.
///
/// You can use this descriptor indirectly to:
/// * Setup [FormField] or simluar widgets. [FormFieldValidator] is provided
///   via [CompanionPresenterMixinExtension.getPropertyValidator] (it internally
///   calls [getValidator]), which sequentially run validators including
///   asynchronous ones and they should be set to [FormField.validator]
///   parameters.
///   For vanilla [FormField], it is required to bind [FormField.onSaved]
///   parameters and callbacks returned from
///   [CompanionPresenterMixinExtension.savePropertyValue] methods to work
///   the mixin correctly. The callback internally calls [setFieldValue] method.
///   [name] property which should be set to name for some form frameworks.
/// * Checking whether asynchronous validation via
///   [CompanionPresenterMixinExtension.hasPendingAsyncValidations] to show some
///   indicator. It internally calls [hasPendingAsyncValidations].
/// * Get saved valid value for this property via
///   [CompanionPresenterMixinExtension.getSavedPropertyValue] which internally
///   calls [value] property.
///
/// Conversely, you must use this object to setup form fields to work
/// [CompanionPresenterMixin] logics correctly.
///
/// This object is built with [PropertyDescriptorsBuilder] which is passed to
/// [CompanionPresenterMixin.initializeCompanionMixin].
@sealed
class PropertyDescriptor<P extends Object, F extends Object> {
  /// Unique name of this property.
  final String name;

  /// Connected presenter object which implements [CompanionPresenterMixin].
  final CompanionPresenterMixin presenter;

  // The reason of using factories instead of validators theirselves is some
  // validator framework requires BuildContext to localize their messages.
  // In addition, it is good for the sake of injection of Completer to await
  // async validation from FormCompanionMixin.

  /// Factories of [FormFieldValidator].
  final List<FormFieldValidatorFactory<F>> _validatorFactories;

  /// Entries to build [AsyncValidator].
  final List<_AsyncValidatorFactoryEntry<F>> _asynvValidatorEntries;

  final ValueConverter<P, F> _valueConverter;

  /// Saved property value. This value can be `null`.
  P? _value;

  /// Gets a saved or initial value of this property.
  P? get value => _value;

  /// [Completer] to notify [CompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<bool>? _asyncValidationCompletion;

  /// State automaton node of validation.
  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Gets a field value (rather than property value) for form field.
  ///
  /// This value calls [ValueConverter.toFieldValue] with [value] and [locale].
  F? getFieldValue(Locale locale) =>
      _valueConverter.toFieldValue(_value, locale);

  /// Set a field value (rather than property value) from form field.
  ///
  /// This setter eventually set [value].
  ///
  /// This value calls [ValueConverter.toPropertyValue] with [value]
  /// and [locale].
  void setFieldValue(F? value, Locale locale) {
    final result = _valueConverter.toPropertyValue(value, locale);
    if (result is! ConversionResult<P>) {
      throw ArgumentError.value(value, 'value', result.toString());
    }

    _value = result.value;
  }

  /// State of pending async validations.
  final _PendingAsyncValidations _pendingAsyncValidations;

  /// Whether any asynchronous validations is running now.
  bool get hasPendingAsyncValidations => _pendingAsyncValidations.value;

  /// Constructor.
  ///
  /// [equality] will be used to constructor parameter of [AsyncValidator] for
  /// asynchronous validatiors created by [asyncValidatorFactories].
  PropertyDescriptor._({
    required this.name,
    required this.presenter,
    required List<FormFieldValidatorFactory<F>> validatorFactories,
    required List<AsyncValidatorFactory<F>> asyncValidatorFactories,
    required P? initialValue,
    required Equality<F?>? equality,
    required ValueConverter<P, F>? valueConverter,
  })  : _value = initialValue,
        _valueConverter = valueConverter ?? DefaultValueConverter<P, F>(),
        _validatorFactories = [...validatorFactories],
        _asynvValidatorEntries = asyncValidatorFactories
            .map(
              (v) => _AsyncValidatorFactoryEntry<F>(
                v,
                equality,
                presenter.handleCanceledAsyncValidationError,
              ),
            )
            .toList(),
        _pendingAsyncValidations = _PendingAsyncValidations() {
    if (valueConverter != null) {
      _validatorFactories.add(
        createValidatorFactoryFromConverter<P, F>(valueConverter),
      );
    }
  }

  /// Returns a composite validator which contains synchronous (normal)
  /// validators and asynchronous validators.
  FormFieldValidator<F> getValidator(BuildContext context) =>
      _PropertyValidator<F>(
        [
          ..._validatorFactories.map((f) => f(context)),
        ],
        [
          ..._asynvValidatorEntries.map((e) =>
              _AsyncValidatorEntry(e._executor, e.createValidator(context))),
        ],
        presenter.getLocale(context),
        presenter.buildOnAsyncValidationCompleted(name, context),
        _pendingAsyncValidations.increment,
        _pendingAsyncValidations.decrement,
        () => _asyncValidationCompletion,
        presenter.getAsyncValidationFailureMessage,
        () => presenter._validationContext,
        () => _validationContext,
        (v) => _validationContext = v,
      ).asValidtor();
}

/// Represents state of pending async validations.
///
/// [value] indicates whether any async operations are in progress or not.
class _PendingAsyncValidations extends ValueNotifier<bool> {
  int _count = 0;
  _PendingAsyncValidations() : super(false);

  /// Increments pending operation count.
  void increment() {
    _count++;
    value = true;
  }

  /// Decrement pending operation count.
  void decrement() {
    value = --_count > 0;
    assert(_count >= 0);
  }
}
