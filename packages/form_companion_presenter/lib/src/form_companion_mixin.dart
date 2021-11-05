// See LICENCE file in the root.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'async_validator_executor.dart';
import 'future_invoker.dart';

/// Signature for factory of [FormFieldValidator].
typedef FormFieldValidatorFactory<T> = FormFieldValidator<T> Function(
    BuildContext context);

/// Signature for factory of [AsyncValidator].
typedef AsyncValidatorFactory<T> = AsyncValidator<T> Function(
  BuildContext context,
);

enum _ValidationContext {
  unspecified,
  doValidationOnSubmit,
  confirmingResult,
}

/// Defines interface between [CompanionPresenterMixin] and actual state of `Form`.
abstract class FormStateAdapter {
  /// Gets a current [AutovalidateMode] of the `Form`.
  ///
  /// [CompanionPresenterMixin] behaves respecting to [AutovalidateMode].
  AutovalidateMode get autovalidateMode;

  /// Do validation of all form's fields and then returns the value whether
  /// all fields are valid or not.
  bool validate();

  /// Do save of all form's fields. `save()` effectively just call `onSaved`
  /// callbacks set to the fields, and some derived implementation do some extra
  /// work to prepare values for fields' consumer.
  void save();
}

/// Provides base implementation of presenters which cooporate with correspond
/// [Form] and [FormField]s to handle user inputs, their transitive states,
/// validations, and submission.
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
mixin CompanionPresenterMixin {
  late final Map<String, PropertyDescriptor<Object>> _properties;
  late final bool _hasAsyncValidators;
  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Map of [PropertyDescriptor]. Key is [PropertyDescriptor.name].
  @nonVirtual
  @protected
  @visibleForTesting
  Map<String, PropertyDescriptor<Object>> get properties => _properties;

  /// Initializes [CompanionPresenterMixin].
  ///
  /// [properties] must be [PropertyDescriptorsBuilder] instance which
  /// have all properties which will be input via correspond [FormField]s.
  /// You can define properties in the presenter constructor as following:
  /// ```dart
  /// MyPresenter() : super(MyState()) {
  ///   initializeFormCompanionMixin(
  ///     PropertyDescriptorsBuilder()
  ///     ..add<String>(
  ///       name: 'name',
  ///       validatorFactories: [
  ///         MyValidatorLibrary.required,
  ///         (context) => MyValidatorLibrary.minmumLength(context, 1),
  ///       ],
  ///       asyncValidatorFactories: [
  ///         (_) => MyLogic.checkValidNameOnServer,
  ///       ]
  ///     )
  ///     ..add<int>(
  ///       name: 'age',
  ///       validatorFactories: [
  ///         MyValidatorLibrary.nonNegativeInteger,
  ///       ],
  ///     ),
  ///   );
  /// }
  /// ```
  @protected
  void initializeCompanionMixin(
    PropertyDescriptorsBuilder properties,
  ) {
    _properties = properties._build(this);
    _hasAsyncValidators =
        _properties.values.any((p) => p._asynvValidatorEntries.isNotEmpty);
  }

  /// This method will be called when pending async validation is canceled
  /// but the operation throws [AsyncError].
  ///
  /// You can handles the error by overriding this method. For example, you
  /// record the error with your logger or APM library.
  ///
  /// Default implementation just calls [print] to log the error.
  @protected
  @visibleForOverriding
  void handleCanceledAsyncValidationError(AsyncError error) {
    // ignore: avoid_print
    print(error);
  }

  PropertyDescriptor<Object> _getProperty(String name) {
    final property = properties[name];
    if (property == null) {
      throw ArgumentError.value(
        name,
        'name',
        'Specified property is not registered.',
      );
    }

    return property;
  }

  /// Gets a [PropertyDescriptor] for the specified [name],
  /// which was registered via constrcutor.
  ///
  /// This method throws [ArgumentError] if the property named [name] does not
  /// exist, and throws [StateError] if [T] is not compatible with the `T` of
  /// getting [PropertyDescriptor].
  ///
  /// You should defined wrapper getter in your presenter class to avoid typo
  /// and repeated input for the name and value type error:
  /// ```dart
  /// PropertyDescriptor<String> get name => getProperty<String>('name');
  /// PropertyDescriptor<int> get age => getProperty<int>('age');
  /// ```
  @nonVirtual
  @protected
  @visibleForTesting
  PropertyDescriptor<T> getProperty<T extends Object>(String name) {
    final property = _getProperty(name);

    if (property is! PropertyDescriptor<T>) {
      throw StateError(
        'A type of \'$name\' property is ${property.runtimeType} instead of PropertyDescriptor<$T>.',
      );
    }

    return property;
  }

  /// Gets a saved property value of specified name.
  ///
  /// The value should be set from `FormField` via [savePropertyValue].
  /// This getter should be called in [doSubmit] implementation to get saved
  /// valid values.
  @nonVirtual
  @protected
  @visibleForTesting
  T? getSavedPropertyValue<T extends Object>(String name) =>
      getProperty<T>(name).savedValue;

  /// Gets a setter to set a proprty value with validated form field input.
  ///
  /// The result should be bound to [FormField.onSaved] for vanilla [Form].
  @nonVirtual
  void Function(T?) savePropertyValue<T extends Object>(String name) =>
      (v) => getProperty<T>(name).saveValue(v);

  /// Gets a validator to validate form field input.
  ///
  /// The result should be bound to [FormField.validator].
  @nonVirtual
  FormFieldValidator<T> getPropertyValidator<T extends Object>(
    String name,
    BuildContext context,
  ) =>
      getProperty<T>(name).getValidator(context);

  /// Gets a value which indicates that specified property has pencing
  /// asynchronous validation or not.
  ///
  /// Note that pencing validation complection causes re-evaluation of validity
  /// of the form field, so rebuild will be caused from the field.
  @nonVirtual
  bool hasPendingAsyncValidations(String name) =>
      _getProperty(name).hasPendingAsyncValidations;

  // TODO(yfakariya): converter: ConversionResult Function(T? inputValue) ; class ConversionResult { final String? error; final dynamic value; }; PropertyDescriptor<T, P>.getConvertedValue()
  //       The converter should be "final" validator of validator chain because it is convinient and general that conversion error indicates validation error.

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method returns `null` when there is no ancestor [Form] like widget.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  @protected
  FormStateAdapter? maybeFormStateOf(BuildContext context);

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method throws [StateError] when there is no ancestor [Form] like widget.
  /// Indeed, this method just calls [maybeFormStateOf] and check its result.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  @nonVirtual
  @protected
  @visibleForTesting
  FormStateAdapter formStateOf(BuildContext context) {
    final state = maybeFormStateOf(context);
    if (state == null) {
      throw StateError('Ancestor Form is required.');
    }

    return state;
  }

  /// Returns whether the state of this presenter is "completed" or not.
  ///
  /// "Completed" means that:
  /// * There are no validation errors in the fields of the bound form.
  /// * There are no pending async validations in the fields of the bound form.
  /// * Previous async submit logic is not pending.
  ///
  /// If [Form.autovalidateMode] is [AutovalidateMode.disabled], or there is no
  /// ancestor [Form] in [BuildContext], this method returns `true` without
  /// any validities and pendings because any validation should not be started.
  ///
  /// This implementation calls [FormState.validate], so it might cause
  /// performance issue. So, if you use more clever form helper library which
  /// supports validation result checking without repeated validation calls,
  /// you should override this method.
  @protected
  @visibleForOverriding
  @visibleForTesting
  bool canSubmit(BuildContext context);

  /// Returns submit callback suitable for `onClick` callback of button
  /// which represents `submit` of form.
  ///
  /// This proeprty returns `null` when [canSubmit] is `false`;
  /// otherwise, this returns [doSubmit] as function type result.
  /// So, the button will be disabled when [canSubmit] is `false`,
  /// and will be enabled otherwise.
  @nonVirtual
  VoidCallback? submit(BuildContext context) {
    if (!canSubmit(context)) {
      return null;
    }

    return _buildDoSubmit(context);
  }

  /// Gets current [Locale] for current [BuildContext].
  ///
  /// This implementation uses [Localizations.maybeLocaleOf]. If it fails,
  /// returns `en-US` locale.
  /// You can change this behavior with overriding this method.
  @protected
  @visibleForOverriding
  @visibleForTesting
  Locale getLocale(BuildContext context) =>
      Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US');

  /// Returns completion logic when any async validation is completed.
  ///
  /// This implementation just call [FormStateAdapter.validate] to re-evaluate
  /// all fields validity.
  @protected
  @visibleForOverriding
  @visibleForTesting
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) =>
      (result, error) => maybeFormStateOf(context)?.validate();

  /// Returns a validation error message which is shown when the async validator
  /// failed to complete with an exception or an error.
  ///
  /// This implementation just return an English message
  /// "Failed to check value. Try input again later."
  /// You can override this method and provide your preferred message such as
  /// user friendly, localized message with [error] parameter which is actual
  /// [AsyncError].
  @visibleForOverriding
  @visibleForTesting
  String getAsyncValidationFailureMessage(AsyncError error) =>
      'Failed to check value. Try input again later.';

  /// Builds and returns [VoidCallback] which prepares and calls [doSubmit].
  ///
  /// This implementation prepares with calling [FormStateAdapter.save] iff
  /// [FormStateAdapter.autovalidateMode] is NOT [AutovalidateMode.disabled].
  /// Note that if [FormStateAdapter.autovalidateMode] is
  /// [AutovalidateMode.disabled], that means you choose manual validation and
  /// saving within [doSubmit] or you omitted creating [Form] or simular widgets
  /// to coordinate [FormField]s. If so, this method effectively returns a
  /// closure which just call and await [doSubmit].
  VoidCallback _buildDoSubmit(BuildContext context) {
    final formState = formStateOf(context);

    return () async {
      _validationContext = _ValidationContext.doValidationOnSubmit;
      try {
        if (!await validateAndSave(formState)) {
          return;
        }
      } finally {
        _validationContext = _ValidationContext.unspecified;
      }
      await doSubmit();
    };
  }

  /// Performs saving of form fields.
  @protected
  @visibleForOverriding
  @visibleForTesting
  void saveFields(FormStateAdapter formState) {
    formState.save();
  }

  /// Do validation for all fields with their all validators including
  /// asynchronous ones, and returns [FutureOr] to await asynchronous
  /// validations.
  ///
  /// Note that [FutureOr] will be [bool] if no asynchronous validations are
  /// registered.
  @nonVirtual
  FutureOr<bool> validateAll(FormStateAdapter formState) {
    if (!_hasAsyncValidators) {
      // just validate.
      return formState.validate();
    }

    return _validateAllWithAsync(formState);
  }

  Future<bool> _validateAllWithAsync(FormStateAdapter formState) async {
    // Kick async validators.
    final allSynchronousValidationsAreSucceeded = formState.validate();

    // Creates completers to wait pending async validations.
    final completers = properties.values
        .where((property) => property._asynvValidatorEntries.any(
              (entry) => entry._executor.validating,
            ))
        .map(
      (property) {
        final completer = Completer<bool>();
        property._asyncValidationCompletion = completer;
        return completer;
      },
    ).toList();

    late List<bool> asyncValidationResults;
    try {
      // wait completions of asynchronous validations.
      asyncValidationResults =
          await Future.wait(completers.map((f) => f.future));
    } finally {
      for (final property in properties.values) {
        property._asyncValidationCompletion = null;
      }
    }

    return allSynchronousValidationsAreSucceeded &&
        asyncValidationResults.every((element) => element);
  }

  /// Validates all fields' values and then saves them if there is no validation
  /// errors.
  ///
  /// This is just a convinience method to call [validateAll] and [saveFields]
  /// respectively for manual validate & save from [doSubmit] when
  /// [AutovalidateMode] of the form is not set or is set to
  /// [AutovalidateMode.disabled].
  @nonVirtual
  Future<bool> validateAndSave(FormStateAdapter formState) async {
    if (!await validateAll(formState)) {
      return false;
    }

    saveFields(formState);
    return true;
  }

  /// Execute "submit" action.
  ///
  /// For example:
  /// * Stores validated value to state of view model, and then call server API.
  /// * Save settings to local storage for future use.
  /// * If success, navigate to another screen.
  ///
  /// Note that this method can be `async`, but you have to do following:
  /// * You must get widget to use after asynchronous operation like server API
  ///   call before any `await` expression. Such widgets includes `Navigator`.
  /// * You must handle asynchronous operation's error, usually with `try-catch`
  ///   clause. In general, the error will be logged to future improvement and
  ///   the view model will build user friendly error message and set it to its
  ///   state to display for users.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  @protected
  @visibleForOverriding
  FutureOr<void> doSubmit();
}

/// [FormStateAdapter] implementation for [FormState].
class _FormStateAdapter implements FormStateAdapter {
  final FormState _state;

  @override
  AutovalidateMode get autovalidateMode => _state.widget.autovalidateMode;

  _FormStateAdapter(this._state);

  @override
  bool validate() => _state.validate();

  @override
  void save() => _state.save();
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
  void initializeCompanionMixin(
    PropertyDescriptorsBuilder properties,
  ) {
    super.initializeCompanionMixin(properties);
    _fieldKeys = {for (final name in properties._properties.keys) name: null};
  }

  @override
  @nonVirtual
  FormStateAdapter? maybeFormStateOf(BuildContext context) {
    final state = Form.of(context);
    return state == null ? null : _FormStateAdapter(state);
  }

  @override
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) {
    final state = formStateOf(context);
    if (state.autovalidateMode == AutovalidateMode.disabled) {
      // Only re-evaluate target field.
      return (result, error) => _fieldKeys[name]?.currentState?.validate();
    } else {
      // Re-evaluate all fields including submit button availability.
      return (result, error) => state.validate();
    }
  }

  @override
  @nonVirtual
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
        properties.values.every((p) => !p.hasPendingAsyncValidations);
  }
}

class _AsyncValidatorEntry<T extends Object> {
  final AsyncValidatorFactory<T> _factory;
  final AsyncValidatorExecutor<T> _executor;

  bool get validating => _executor.validating;

  _AsyncValidatorEntry(
    this._factory,
    Equality<T?>? equality,
    AsyncErrorHandler? canceledValidationErrorHandler,
  ) : _executor = AsyncValidatorExecutor(
          equality: equality,
          canceledValidationErrorHandler: canceledValidationErrorHandler,
        );

  AsyncValidator<T> createValidator(BuildContext context) => _factory(context);
}

typedef _ChainedAsyncValidation<T extends Object> = String? Function(
  T? value,
  String? result,
  AsyncError? error, {
  required bool isSync,
});

class _AsyncPropertyValidator<T extends Object> {
  final AsyncValidatorExecutor<T> executor;
  final AsyncValidator<T> validator;

  _AsyncPropertyValidator(this.executor, this.validator);
}

typedef _AsyncValidationFailureMessageProvider = String Function(
    AsyncError error);

typedef _ValidationContextProvider = _ValidationContext Function();
typedef _ValidationContextSupplier = void Function(_ValidationContext context);

class _AsyncValidatorChain<T extends Object> {
  final Locale _locale;
  final AsyncValidationCompletionCallback _transitToAsyncValidationConfirmation;
  final Completer<bool>? _asyncValidationChainCompletionNotifier;
  final _AsyncValidationFailureMessageProvider
      _asyncValidationFailureMessageProvider;
  final _ValidationContextProvider _presenterValidationContextProvider;
  final _ValidationContextProvider _propertyValidationContextProvider;
  final _ValidationContextSupplier _propertyValidationContextSupplier;

  late final FormFieldValidator<T> _first;

  _ValidationContext get _validationContext =>
      _propertyValidationContextProvider();
  set _validationContext(_ValidationContext value) =>
      _propertyValidationContextSupplier(value);

  _AsyncValidatorChain(
    this._locale,
    List<_AsyncPropertyValidator<T>> validators,
    this._transitToAsyncValidationConfirmation,
    this._asyncValidationChainCompletionNotifier,
    this._asyncValidationFailureMessageProvider,
    this._presenterValidationContextProvider,
    this._propertyValidationContextProvider,
    this._propertyValidationContextSupplier,
  ) {
    _first = _buildChain(validators);
  }

  FormFieldValidator<T> _buildChain(
    List<_AsyncPropertyValidator<T>> validators,
  ) {
    // ignore: omit_local_variable_types
    _ChainedAsyncValidation<T> callNext =
        (_, result, error, {required isSync}) {
      _notifyOnChainCompleted(result, error, isSync: isSync);
      return result;
    };

    for (final current in validators.reversed.take(validators.length - 1)) {
      final theCurrent = current;
      final theCallNext = callNext;
      callNext = (value, result, error, {required isSync}) {
        if (result != null) {
          // report validation error and abort chain with error.
          _notifyOnChainCompleted(result, error, isSync: isSync);
          return result;
        }

        // chain to next.
        return _callAsyncValidator(
          value,
          theCurrent.executor,
          theCurrent.validator,
          theCallNext,
        );
      };
    }

    final firstExecutor = validators.first.executor;
    final firstValidator = validators.first.validator;
    return (value) => _callAsyncValidator(
          value,
          firstExecutor,
          firstValidator,
          callNext,
        );
  }

  void _notifyOnChainCompleted(
    String? result,
    AsyncError? error, {
    required bool isSync,
  }) {
    if (_validationContext == _ValidationContext.confirmingResult) {
      // This line refers current late initialized field rather than the field value when getValidator is called.
      // Note that "error" is not handled here -- error handling should be implemented in the handler
      // returned from buildOnAsyncValidationCompleted (thus, notifyCompletion variable).
      _asyncValidationChainCompletionNotifier?.complete(result == null);
      _validationContext = _ValidationContext.unspecified;
      // Do not call notifyCompletion here to avoid recusrive call.
    } else {
      // Transit to confirmingResultOnSubmit and call notifyCompletion
      _validationContext = _ValidationContext.confirmingResult;

      if (!isSync) {
        // Async only -- it may cause validate() on widget tree build,
        // which eventually leads assertion error.
        _transitToAsyncValidationConfirmation(result, error);
      }
    }
  }

  void _handleFailure(AsyncInvocationFailureContext<String?> context) {
    // Converts async validator failure to error message when submitting.
    // Else, ignore failure to avoid user's dead end caused by transient
    // error such as temporary bad network condition.
    final message =
        _presenterValidationContextProvider() != _ValidationContext.unspecified
            ? _asyncValidationFailureMessageProvider(context.error)
            : null;
    context.overrideError(message);
  }

  String? _callAsyncValidator(
    T? value,
    AsyncValidatorExecutor<T> executor,
    AsyncValidator<T> validator,
    _ChainedAsyncValidation<T> callNext,
  ) {
    // Cancels previous validation -- it might be hanged-up
    executor.cancel();

    if (_validationContext == _ValidationContext.doValidationOnSubmit) {
      // Clears cached error to ensure new async invocation is initiated.
      executor.reset(null);
    }
    // invoke next validator
    final validationResult = executor.validate(
      validator: validator,
      value: value,
      locale: _locale,
      onCompleted: (r, e) => callNext(value, r, e, isSync: false),
      failureHandler: _handleFailure,
    );

    if (validationResult != null) {
      // synchrnous failure
      _notifyOnChainCompleted(validationResult, null, isSync: true);
      return validationResult;
    }

    if (!executor.validating) {
      // synchronous success
      return callNext(value, null, null, isSync: true);
    }

    // return default 'null', which means that async invocation is in-progress.
    return null;
  }

  String? callValidator(T? value) {
    final presenterContext = _presenterValidationContextProvider();
    if (presenterContext == _ValidationContext.doValidationOnSubmit &&
        _validationContext == _ValidationContext.unspecified) {
      _validationContext = _ValidationContext.doValidationOnSubmit;
    }

    return _first(value);
  }
}

class _PropertyValidator<T extends Object> {
  final List<FormFieldValidator<T>> _validators;
  final _AsyncValidatorChain<T>? _asyncValidatorChain;

  _PropertyValidator(
    this._validators,
    List<_AsyncPropertyValidator<T>> asyncValidators,
    Locale locale,
    AsyncValidationCompletionCallback transitToAsyncValidationConfirmation,
    Completer<bool>? asyncValidationChainCompletionNotifier,
    _AsyncValidationFailureMessageProvider
        asyncValidationFailureMessageProvider,
    _ValidationContextProvider presenterValidationContextProvider,
    _ValidationContextProvider propertyValidationContextProvider,
    _ValidationContextSupplier propertyValidationContextSupplier,
  ) : _asyncValidatorChain = asyncValidators.isNotEmpty
            ? _AsyncValidatorChain(
                locale,
                asyncValidators,
                transitToAsyncValidationConfirmation,
                asyncValidationChainCompletionNotifier,
                asyncValidationFailureMessageProvider,
                presenterValidationContextProvider,
                propertyValidationContextProvider,
                propertyValidationContextSupplier,
              )
            : null;

  FormFieldValidator<T> asValidtor() => (value) {
        // The idea is borrowed from FormBuilderValidators.composite()
        for (final validator in _validators) {
          final validationError = validator(value);
          if (validationError != null) {
            return validationError;
          }
        }

        return _asyncValidatorChain?.callValidator(value);
      };
}

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
  final List<_AsyncValidatorEntry<T>> _asynvValidatorEntries;

  /// Saved property value. This value can be `null`.
  T? _value;

  var _isValueSet = false;

  /// [Completer] to notify [CompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<bool>? _asyncValidationCompletion;

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
              (v) => _AsyncValidatorEntry<T>(
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
              _AsyncPropertyValidator(e._executor, e.createValidator(context))),
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

/// Required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<T extends Object> {
  final String name;
  final List<FormFieldValidatorFactory<T>> validatorFactories;
  final List<AsyncValidatorFactory<T>> asyncValidatorFactories;

  _PropertyDescriptorSource({
    required this.name,
    required this.validatorFactories,
    required this.asyncValidatorFactories,
  });

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  PropertyDescriptor<T> build(
    CompanionPresenterMixin presenter,
  ) =>
      PropertyDescriptor<T>._(
        name: name,
        presenter: presenter,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
      );
}

/// Builder object to build [PropertyDescriptor].
@sealed
class PropertyDescriptorsBuilder {
  final Map<String, _PropertyDescriptorSource<Object>> _properties = {};

  /// Defines new property without asynchronous validation progress reporting.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void add<T extends Object>({
    required String name,
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T>>? asyncValidatorFactories,
  }) {
    final descriptor = _PropertyDescriptorSource<T>(
      name: name,
      validatorFactories: validatorFactories ?? [],
      asyncValidatorFactories: asyncValidatorFactories ?? [],
    );
    final oldOrNew = _properties.putIfAbsent(name, () => descriptor);
    assert(oldOrNew == descriptor, '$name is already registered.');
  }

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  Map<String, PropertyDescriptor<Object>> _build(
    CompanionPresenterMixin presenter,
  ) =>
      _properties.map(
        (key, value) => MapEntry(
          key,
          // Delegates actual build to (typed) _PropertyDescriptorSource to
          // handle generic type arguments of them.
          value.build(presenter),
        ),
      );
}
