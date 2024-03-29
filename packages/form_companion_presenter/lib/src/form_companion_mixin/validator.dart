// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// An entry for storage which holds a list of [AsyncValidatorFactory]
/// and their executors.
///
/// This object is required to postpone validator instantiation to build time.
/// It enables retrieval of current localization settings from the build context, etc.
class _AsyncValidatorFactoryEntry<T extends Object> {
  final AsyncValidatorFactory<T> _factory;
  final AsyncValidatorExecutor<T> _executor;

  _AsyncValidatorFactoryEntry(
    this._factory,
    Equality<T?>? equality,
    AsyncErrorHandler? canceledValidationErrorHandler,
  ) : _executor = AsyncValidatorExecutor(
          equality: equality,
          canceledValidationErrorHandler: canceledValidationErrorHandler,
        );

  AsyncValidator<T> createValidator(BuildContext context) => _factory(
        createValidatorCreationOptions(
          context,
          Localizations.maybeLocaleOf(context),
        ),
      );
}

/// An entry for storage which holds a list of [AsyncValidator]
/// and their executors.
///
/// This object is just a helper for [_AsyncValidatorChain].
class _AsyncValidatorEntry<T extends Object> {
  final AsyncValidatorExecutor<T> executor;
  final AsyncValidator<T> validator;

  _AsyncValidatorEntry(this.executor, this.validator);
}

/// An aggregated [FormFieldValidator] facade of sync validators and an async
/// validator chain.
class _PropertyValidator<T extends Object> {
  final List<FormFieldValidator<T>> _validators;
  final _AsyncValidatorChain<T>? _asyncValidatorChain;
  final PropertyDescriptor<dynamic, T> _property;

  _PropertyValidator(
    this._validators,
    List<_AsyncValidatorEntry<T>> asyncValidators,
    Locale locale,
    AsyncValidationCompletionCallback transitToAsyncValidationConfirmation,
    VoidCallback onAsyncValidationStarted,
    VoidCallback onAsyncValidationCompleted,
    Completer<bool>? Function() asyncValidationChainCompletionNotifierProvider,
    _AsyncValidationFailureMessageProvider
        asyncValidationFailureMessageProvider,
    _ValidationContextProvider presenterValidationContextProvider,
    _ValidationContextProvider propertyValidationContextProvider,
    _ValidationContextSupplier propertyValidationContextSupplier,
    this._property,
  ) : _asyncValidatorChain = asyncValidators.isNotEmpty
            ? _AsyncValidatorChain(
                locale,
                asyncValidators,
                transitToAsyncValidationConfirmation,
                onAsyncValidationStarted,
                onAsyncValidationCompleted,
                asyncValidationChainCompletionNotifierProvider,
                asyncValidationFailureMessageProvider,
                presenterValidationContextProvider,
                propertyValidationContextProvider,
                propertyValidationContextSupplier,
              )
            : null;

  String? _rememberError(String? validationError) {
    if (validationError != null) {
      _property._restorableFieldValue?.setHasError(true);
    }
    return validationError;
  }

  FormFieldValidator<T> asValidtor() => (value) {
        _asyncValidatorChain?._log.fine('Start validation.');
        // The idea is borrowed from FormBuilderValidators.composite()
        for (final validator in _validators) {
          final validationError = validator(value);
          if (validationError != null) {
            _asyncValidatorChain?._log.fine(
              'Validation completed due to sync validator detected error: "$validationError".',
            );
            return _rememberError(validationError);
          }
        }

        // Error remembering will be done in async validation chain.
        return _rememberError(_asyncValidatorChain?.callValidator(value));
      };
}

/// A chain of one or more async validators which are linked with their completion
/// callbacks.
///
/// This class assumes that the tail of the chain is presenter's completion handler.
class _AsyncValidatorChain<T extends Object> {
  late final Logger _log;
  final Locale _locale;
  final AsyncValidationCompletionCallback _transitToAsyncValidationConfirmation;
  final VoidCallback _onAsyncValidationStarted;
  final VoidCallback _onAsyncValidationCompleted;
  final Completer<bool>? Function()
      _asyncValidationChainCompletionNotifierProvider;
  final _AsyncValidationFailureMessageProvider
      _asyncValidationFailureMessageProvider;
  final _ValidationContextProvider _presenterValidationContextProvider;
  final _ValidationContextProvider _propertyValidationContextProvider;
  final _ValidationContextSupplier _propertyValidationContextSupplier;

  late final FormFieldValidator<T> _first;

  var _isAsyncStarted = false;

  _ValidationContext get _validationContext =>
      _propertyValidationContextProvider();
  set _validationContext(_ValidationContext value) =>
      _propertyValidationContextSupplier(value);

  _AsyncValidatorChain(
    this._locale,
    List<_AsyncValidatorEntry<T>> validators,
    this._transitToAsyncValidationConfirmation,
    this._onAsyncValidationStarted,
    this._onAsyncValidationCompleted,
    this._asyncValidationChainCompletionNotifierProvider,
    this._asyncValidationFailureMessageProvider,
    this._presenterValidationContextProvider,
    this._propertyValidationContextProvider,
    this._propertyValidationContextSupplier,
  ) {
    _log = Logger(name: 'AsyncValidatorChain<$T>');
    _first = _buildChain(validators);
  }

  /// Builds async validator chain.
  FormFieldValidator<T> _buildChain(
    List<_AsyncValidatorEntry<T>> validators,
  ) {
    // ignore: omit_local_variable_types
    _ChainedAsyncValidation<T> callNext =
        (_, result, error, {required isSync}) {
      _log.fine('Reached to tail of async validators chain.');
      _notifyOnChainCompleted(result, error, isSync: isSync);
      return result;
    };

    for (final current in validators.reversed.take(validators.length - 1)) {
      final theCurrent = current;
      final theCallNext = callNext;
      callNext = (value, result, error, {required isSync}) {
        if (result != null) {
          // report validation error and abort chain with error.
          _log.fine(
            'Async validation chain is intruppeted with error: "$result".',
          );
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

  /// A sink of the chain, invokes appropriate callbacks which are supplied by
  /// the presenter.
  void _notifyOnChainCompleted(
    String? result,
    AsyncError? error, {
    required bool isSync,
  }) {
    _log.info(
      'Complete async validation with result: "$result", error: "$error", '
      'isSync: $isSync, context: ${_validationContext.name})',
    );
    if (_validationContext == _ValidationContext.confirmingResult) {
      // This line refers current late initialized field rather than the field value when getValidator is called.
      // Note that "error" is not handled here -- error handling should be implemented in the handler
      // returned from buildOnAsyncValidationCompleted (thus, notifyCompletion variable).
      _asyncValidationChainCompletionNotifierProvider()
          ?.complete(result == null);
      _validationContext = _ValidationContext.unspecified;
      // Do not call notifyCompletion here to avoid recusrive call.
    } else {
      if (!isSync) {
        // Async only -- it may cause validate() on widget tree build,
        // which eventually leads assertion error.

        // Transit to confirmingResultOnSubmit and call notifyCompletion
        _validationContext = _ValidationContext.confirmingResult;
        _transitToAsyncValidationConfirmation(result, error);
      }
    }

    if (!isSync) {
      _onAsyncValidationCompleted();
    }
  }

  /// Handles failures(exceptions) of async validators in this chain.
  ///
  /// This handler respects validation context to translate the failure to
  /// appropriate validation result to maximize usability as well as input validity.
  void _handleFailure(AsyncInvocationFailureContext<String?> context) {
    // Converts async validator failure to error message when submitting.
    // Else, ignore failure to avoid user's dead end caused by transient
    // error such as temporary bad network condition.
    final message =
        _presenterValidationContextProvider() != _ValidationContext.unspecified
            ? _asyncValidationFailureMessageProvider(context.error, _locale)
            : null;
    context.overrideError(message);
  }

  /// Handles async validator invocation.
  ///
  /// [callNext] points to next node of this chain.
  String? _callAsyncValidator(
    T? value,
    AsyncValidatorExecutor<T> executor,
    AsyncValidator<T> validator,
    _ChainedAsyncValidation<T> callNext,
  ) {
    // Cancels previous validation -- it might be hanged-up
    if (executor.validating) {
      _log.fine('Cancels previous validation.');
      executor.cancel();
      _onAsyncValidationCompleted();
    }

    if (_validationContext == _ValidationContext.doValidationOnSubmit) {
      // Clears cached error to ensure new async invocation is initiated.
      _log.fine('Resets previous validation cache.');
      executor.reset(null);
    }
    // invoke next validator
    final validationResult = executor.validate(
      validator: validator,
      value: value,
      locale: _locale,
      onCompleted: (r, e) => callNext(value, r, e, isSync: !_isAsyncStarted),
      failureHandler: _handleFailure,
    );

    if (validationResult != null) {
      // Synchrnous failure -- stop chaining and notify it as final result,
      // and then return the error.
      _log.fine('Cached validation result is used: "$validationResult".');
      _notifyOnChainCompleted(validationResult, null, isSync: true);
      return validationResult;
    }

    if (!executor.validating) {
      // Synchronous success -- go to next chain.
      _log.fine('Cached validation success is used.');
      return callNext(value, null, null, isSync: true);
    }

    assert(executor.validating);
    _onAsyncValidationStarted();
    _isAsyncStarted = true;
    // Return default 'null', which means that async invocation is in-progress.
    // The async invocation should call "onCompleted" callback in future.
    _log.fine('Returns null because async validation is pending.');
    return null;
  }

  /// Invoke this validator chain for specified value.
  String? callValidator(T? value) {
    final presenterContext = _presenterValidationContextProvider();
    _log.info(
      'Start async validation chain. '
      'PresenterContext: ${presenterContext.name}, '
      'CurrentContext: ${_validationContext.name}',
    );
    if (presenterContext == _ValidationContext.doValidationOnSubmit &&
        _validationContext == _ValidationContext.unspecified) {
      _validationContext = _ValidationContext.doValidationOnSubmit;
    }

    return _first(value);
  }
}

/// Creates [FormFieldValidatorFactory] from [ValueConverter].
@internal
@visibleForTesting
FormFieldValidatorFactory<F>
    createValidatorFactoryFromConverter<P extends Object, F extends Object>(
  ValueConverter<P, F> converter,
) =>
        (o) => (v) {
              final result = v == null
                  ? ConversionResult<P>(null)
                  : converter.toPropertyValue(v, o.locale);
              if (result is FailureResult<P>) {
                return result.message;
              }

              assert(result is ConversionResult<P>);
              return null;
            };
