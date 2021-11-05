// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Represents "property" of view model which uses [CompanionPresenterMixin].
///
/// This is advanced feature, so normal users should not concern this object.
///
/// You can use this descriptor indirectly to:
/// * Setup [FormField] or simluar widgets. [FormFieldValidator] is provided
///   via [CompanionPresenterMixin.getPropertyValidator] (it internally calls
///   [getValidator]), which sequentially run validators including asynchronous
///   ones and they should be set to [FormField.validator] parameters.
///   For vanilla [FormField], it is required to bind [FormField.onSaved]
///   parameters and callbacks returned from
///   [CompanionPresenterMixin.savePropertyValue] methods to work the mixin
///   correctly. The callback internally calls [saveValue] method.
///   [name] property which should be set to name for some form frameworks.
/// * Checking whether asynchronous validation via
///   [CompanionPresenterMixin.hasPendingAsyncValidations] to show some
///   indicator. It internally calls [hasPendingAsyncValidations].
/// * Get saved valid value for this property via
///   [CompanionPresenterMixin.getSavedPropertyValue] which internally calls
///   [savedValue] property.
///
/// Conversely, you must use this object to setup form fields to work
/// [CompanionPresenterMixin] logics correctly.
///
/// This object is built with [PropertyDescriptorsBuilder] which is passed to
/// [CompanionPresenterMixin.initializeCompanionMixin].
@sealed
class PropertyDescriptor<T extends Object> {
  /// Unique name of this property.
  final String name;

  /// Connected presenter object which implements [CompanionPresenterMixin].
  final CompanionPresenterMixin presenter;

  // The reason of using factories instead of validators theirselves is some
  // validator framework requires BuildContext to localize their messages.
  // In addition, it is good for the sake of injection of Completer to await
  // async validation from FormCompanionMixin.

  /// Factories of [FormFieldValidator].
  final List<FormFieldValidatorFactory<T>> _validatorFactories;

  /// Entries to build [AsyncValidator].
  final List<_AsyncValidatorFactoryEntry<T>> _asynvValidatorEntries;

  /// Saved property value. This value can be `null`.
  T? _value;

  /// Indicates whether this property value is set (saved).
  var _isValueSet = false;

  /// [Completer] to notify [CompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<bool>? _asyncValidationCompletion;

  /// State automaton node of validation.
  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Saved property value. This value can be `null`.
  ///
  /// Note that this property should not be used for initial value of [FormField].,
  T? get savedValue {
    assert(
      _isValueSet,
      'value has not been set yet via saveValue(). Note that this property should not be used for initial value of FormField.',
    );

    return _value;
  }

  /// Save value from logic which handles this [PropertyDescriptor] without
  /// strong typing.
  ///
  /// This method throws [ArgumentError] if [value] is not compatible [T].
  void saveValue(dynamic value) {
    if (value is! T?) {
      throw ArgumentError.value(
        value,
        'value',
        '${value.runtimeType} is not compatible with $T.',
      );
    }

    _value = value;
    _isValueSet = true;
  }

  /// Whether any asynchronous validations is running now.
  bool get hasPendingAsyncValidations =>
      _asynvValidatorEntries.any((e) => e.validating);

  /// Constructor.
  ///
  /// [equality] will be used to constructor parameter of [AsyncValidator] for
  /// asynchronous validatiors created by [asyncValidatorFactories].
  PropertyDescriptor._({
    required this.name,
    required this.presenter,
    required List<FormFieldValidatorFactory<T>> validatorFactories,
    required List<AsyncValidatorFactory<T>> asyncValidatorFactories,
    Equality<T?>? equality,
  })  : _validatorFactories = validatorFactories,
        _asynvValidatorEntries = asyncValidatorFactories
            .map(
              (v) => _AsyncValidatorFactoryEntry<T>(
                v,
                equality,
                presenter.handleCanceledAsyncValidationError,
              ),
            )
            .toList();

  /// Returns a composite validator which contains synchronous (normal)
  /// validators and asynchronous validators.
  FormFieldValidator<T> getValidator(BuildContext context) =>
      _PropertyValidator<T>(
        [
          ..._validatorFactories.map((f) => f(context)),
        ],
        [
          ..._asynvValidatorEntries.map((e) =>
              _AsyncValidatorEntry(e._executor, e.createValidator(context))),
        ],
        presenter.getLocale(context),
        presenter.buildOnAsyncValidationCompleted(name, context),
        _asyncValidationCompletion,
        presenter.getAsyncValidationFailureMessage,
        () => presenter._validationContext,
        () => _validationContext,
        (v) => _validationContext = v,
      ).asValidtor();
}
