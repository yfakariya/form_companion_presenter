// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

// TODO(yfakariya): declare "final CompanionPresenterMixinVirtuals virtual" to ensure API backward compatibility in future -- only allowed public API should be properties, submit, canSubmit. All other APIs should be in "virtuals" or should belong to an extension.

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
  /// Do not use this.
  @internal
  late final CompanionPresenterMixinInternals internals;

  late final Map<String, PropertyDescriptor<Object, Object>> _properties;

  late final bool _hasAsyncValidators;

  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Map of [PropertyDescriptor]. Key is [PropertyDescriptor.name].
  @nonVirtual
  @protected
  @visibleForTesting
  Map<String, PropertyDescriptor<Object, Object>> get properties => _properties;

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
    internals = CompanionPresenterMixinInternals(this);
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
  // TODO(yfakariya): API reorganization
  void handleCanceledAsyncValidationError(AsyncError error) {
    // ignore: avoid_print
    print(error);
  }

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method returns `null` when there is no ancestor [Form] like widget.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  @protected
  @visibleForOverriding
  // TODO(yfakariya): API reorganization
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
  // TODO(yfakariya): API reorganization
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
  // TODO(yfakariya): API reorganization
  Locale getLocale(BuildContext context) =>
      Localizations.maybeLocaleOf(context) ?? defaultLocale;

  /// Returns completion logic when any async validation is completed.
  ///
  /// This implementation just call [FormStateAdapter.validate] to re-evaluate
  /// all fields validity.
  @protected
  @visibleForOverriding
  @visibleForTesting
  // TODO(yfakariya): API reorganization
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
  // TODO(yfakariya): API reorganization
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
  // TODO(yfakariya): API reorganization
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
  // TODO(yfakariya): API reorganization
  void saveFields(FormStateAdapter formState) {
    formState.save();
  }

  /// Do validation for all fields with their all validators including
  /// asynchronous ones, and returns [FutureOr] to await asynchronous
  /// validations.
  ///
  /// Note that [FutureOr] will be [bool] if no asynchronous validations are
  /// registered.
  @protected
  @nonVirtual
  @visibleForTesting
  // TODO(yfakariya): API reorganization
  FutureOr<bool> validateAll(FormStateAdapter formState) {
    if (!_hasAsyncValidators) {
      // just validate.
      return formState.validate();
    }

    return _validateAllWithAsync(formState);
  }

  // TODO(yfakariya): API reorganization
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
  @protected
  @nonVirtual
  @visibleForTesting
  // TODO(yfakariya): API reorganization
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

/// Internal helper methos of [CompanionPresenterMixin].
///
/// The API in this class subject to change without any notification,
/// so users should not use this class.
@internal
@sealed
class CompanionPresenterMixinInternals {
  final CompanionPresenterMixin _presenter;

  /// Initializes a new [CompanionPresenterMixinInternals] instance.
  CompanionPresenterMixinInternals(this._presenter);

  /// Returns an untyped [PropertyDescriptor] with specified [name].
  PropertyDescriptor<Object, Object> getProperty(String name) {
    final property = _presenter.properties[name];
    if (property == null) {
      throw ArgumentError.value(
        name,
        'name',
        'Specified property is not registered.',
      );
    }

    return property;
  }

  /// Gets a [ValueListenable] which indicates there are any pending async
  /// validations in a property specified by [name].
  @nonVirtual
  @internal
  ValueListenable<bool> getPropertyPendingAsyncValidationsListener(
    String name,
  ) =>
      getProperty(name)._pendingAsyncValidations;
}
