// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Represents event data of [CompanionPresenterMixin.onPropertiesChanged].
@sealed
class OnPropertiesChangedEvent {
  /// Gets a ew [FormProperties] set to [CompanionPresenterMixin.propertiesState]
  /// (or `properties` extension property).
  final FormProperties newProperties;

  /// Initializes a new [OnPropertiesChangedEvent].
  ///
  /// You should not instantiate [OnPropertiesChangedEvent] in your code
  /// except testing code.
  ///
  /// Note that this constructor's signature is subject to change in future
  /// to enhance this class functionality.
  @visibleForTesting
  OnPropertiesChangedEvent(this.newProperties) {}
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
  /// Do not use this property directly, use methods on
  /// [CompanionPresenterMixinExtension] instead.
  ///
  /// Gets a [CompanionPresenterFeatures] which provides overriden behaviors
  /// with subtype of [CompanionPresenterMixin].
  @visibleForOverriding
  CompanionPresenterFeatures get presenterFeatures;

  /// Will become `true` if all late fields are initialized.
  bool _mounted = false;

  late FormProperties _properties;

  late final bool _hasAsyncValidators;

  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Gets a current [FormProperties] which holds properties' values and
  /// their [PropertyDescriptor]s.
  ///
  /// In most of cases, callers should use type property accessors generated
  /// by `form_companion_generator` instead.
  @nonVirtual
  FormProperties get propertiesState =>
      // Returns empty if not mounted yet to avoid complicated late initialization error.
      _mounted ? _properties : FormProperties._(this, const {});

  /// Initializes [CompanionPresenterMixin].
  /// **You must call this method (or overriden method) in your presenter's
  /// constructor to work mixins correctly.**
  ///
  /// This method also calls [onPropertiesChanged] callback in end.
  ///
  /// [properties] must be [PropertyDescriptorsBuilder] instance which
  /// have **all** properties which will be input via correspond [FormField]s.
  /// You can define properties in the presenter constructor as following, or
  /// use extension methods.:
  /// ```dart
  /// MyPresenter() : super(MyState()) {
  ///   initializeFormCompanionMixin(
  ///     PropertyDescriptorsBuilder()
  ///     ..add<String, String>( // or .addText(...) extension methods)
  ///       name: 'name',
  ///       validatorFactories: [
  ///         MyValidatorLibrary.required,
  ///         (context) => MyValidatorLibrary.minmumLength(context, 1),
  ///       ],
  ///       asyncValidatorFactories: [
  ///         (_) => MyLogic.checkValidNameOnServer,
  ///       ]
  ///     )
  ///     ..add<int, String>( // or .addInt(...) extension methods)
  ///       name: 'age',
  ///       validatorFactories: [
  ///         MyValidatorLibrary.nonNegativeInteger,
  ///       ],
  ///       valueConverter: intStringConverter,
  ///     ),
  ///   );
  /// }
  /// ```
  @protected
  void initializeCompanionMixin(PropertyDescriptorsBuilder properties) {
    _properties = properties._build(this);
    _hasAsyncValidators = _properties
        .getAllDescriptors()
        .any((p) => p._asynvValidatorEntries.isNotEmpty);
    _mounted = true;
    resetPropertiesState(_properties);
  }

  /// Resets [propertiesState] with specified new [FormProperties].
  ///
  /// This method also calls [onPropertiesChanged] callback.
  ///
  /// This method returns passed [FormProperties] for convinience.
  @nonVirtual
  FormProperties resetPropertiesState(FormProperties newProperties) {
    _properties = newProperties;
    onPropertiesChanged(OnPropertiesChangedEvent(newProperties));

    assert(identical(_properties, newProperties));
    return newProperties;
  }

  /// Called from [PropertyDescriptor].
  /// Reflect changed value as the new state.
  void _onPropertyChanged(String name, Object? newValue) {
    // If not mounted yet, 1) _properties are not initialized yet
    // 2) copyWithProperty should not work correctly, so avoid processing.
    if (_mounted) {
      resetPropertiesState(
        _properties.copyWithProperty(name, newValue),
      );
    }
  }

  /// Called when any property values are changed.
  /// [OnPropertiesChangedEvent.newProperties] stores new values of the properties.
  ///
  /// Note that [propertiesState] has been also updated
  /// with [OnPropertiesChangedEvent.newProperties].
  ///
  /// You can use this method like:
  /// * Call `notifyListeners()` on `ChangeNotifier`.
  /// * Set `state` on `StateNotifier`.
  @protected
  @visibleForOverriding
  void onPropertiesChanged(OnPropertiesChangedEvent event) {
    // do nothing
  }

  /// {@template canSubmit}
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
  /// {@endtemplate}
  bool canSubmit(BuildContext context);

  /// {@template submit}
  /// Returns submit callback suitable for `onClick` callback of button
  /// which represents `submit` of form.
  ///
  /// This proeprty returns `null` when [canSubmit] is `false`;
  /// otherwise, this returns [doSubmit] as function type result.
  /// So, the button will be disabled when [canSubmit] is `false`,
  /// and will be enabled otherwise.
  /// {@endtemplate}
  @nonVirtual
  VoidCallback? submit(BuildContext context) {
    if (!canSubmit(context)) {
      return null;
    }

    return _buildDoSubmit(context);
  }

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

/// Defines overridable [CompanionPresenterMixin] subtype specific features.
///
/// [CompanionPresenterMixin] users, mainly sub-mixin-type implementation,
/// can call methods in this class via [CompanionPresenterMixinExtension]'s
/// extension methods instead of calling methods of this class directly.
///
/// `form_companion_presenter` uses template method pattern to allow developers
/// extend features of [CompanionPresenterMixin], but in dart, this is hard to
/// avoid method conflict between methods which were added by such subtypes's
/// developers or application developers who mix-ins the mixin type, because
/// dart does not provide method overloading and method hiding either.
/// So, `form_companion_presenter` separates template methods for sub-mixin-type
/// developers to allow override the methods to change default behavior and
/// providing implementation of abstract methods like [maybeFormStateOf].
abstract class CompanionPresenterFeatures<A extends FormStateAdapter> {
  /// Initializes a new [CompanionPresenterFeatures] instance.
  @protected
  const CompanionPresenterFeatures();

  /// This method will be called when pending async validation is canceled
  /// but the operation throws [AsyncError].
  ///
  /// You can handles the error by overriding this method. For example, you
  /// record the error with your logger or APM library.
  ///
  /// Default implementation just calls [FlutterError.presentError] to log the error.
  @protected
  @visibleForOverriding
  void handleCanceledAsyncValidationError(AsyncError error) =>
      FlutterError.presentError(
        FlutterErrorDetails(
          exception: error,
          stack: error.stackTrace,
          library: 'Form Companion Presenter',
          context: ErrorSummary(
            'Asynchronous error was ocurred when the operation had been canceled.',
          ),
        ),
      );

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method returns `null` when there is no ancestor [Form] like widget.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  @protected
  @visibleForOverriding
  FormStateAdapter? maybeFormStateOf(BuildContext context);

  /// Gets current [Locale] for current [BuildContext].
  ///
  /// This implementation uses [Localizations.maybeLocaleOf]. If it fails,
  /// returns `en-US` locale.
  /// You can change this behavior with overriding this method.
  @protected
  @visibleForOverriding
  Locale getLocale(BuildContext context) =>
      Localizations.maybeLocaleOf(context) ?? defaultLocale;

  /// Returns completion logic when any async validation is completed.
  ///
  /// This implementation just call [FormStateAdapter.validate] to re-evaluate
  /// all fields validity.
  @protected
  @visibleForOverriding
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) =>
      (result, error) => maybeFormStateOf(context)?.validate();

  /// Performs saving of form fields.
  @protected
  @visibleForOverriding
  void saveFields(A formState) {
    formState.save();
  }

  /// Do validation the [FormField] for specified [name].
  @protected
  @visibleForOverriding
  void restoreField(
    BuildContext context,
    String name,
    Object? value, {
    required bool hasError,
  });

  /// Returns a validation error message which is shown when the async validator
  /// failed to complete with an exception or an error.
  ///
  /// This implementation just return an English message
  /// "Failed to check value. Try input again later."
  /// You can override this method and provide your preferred message such as
  /// user friendly, localized message with [error] parameter which is actual
  /// [AsyncError].
  @visibleForOverriding
  String getAsyncValidationFailureMessage(AsyncError error, Locale locale) =>
      'Failed to check value. Try input again later.';
}

// NOTE: Methods in CompanionPresenterMixinExtension is not marked with
//       @protected nor @visibleForTesting because "friend types" like
//       FormBuilderCompanionPresenterMixin related types access them.

/// Provides helper methods of [CompanionPresenterMixin].
///
/// By extracting helper methods as extension methods, presenter developers
/// always add their application methods regardless warrying about method
/// conflict in future which caused by version up of `form_companion_presenter`.
extension CompanionPresenterMixinExtension on CompanionPresenterMixin {
  /// This method will be called when pending async validation is canceled
  /// but the operation throws [AsyncError].
  ///
  /// You can handles the error by overriding this method. For example, you
  /// record the error with your logger or APM library.
  ///
  /// Default implementation just calls [print] to log the error.
  void handleCanceledAsyncValidationError(AsyncError error) =>
      presenterFeatures.handleCanceledAsyncValidationError(error);

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method returns `null` when there is no ancestor [Form] like widget.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      presenterFeatures.maybeFormStateOf(context);

  /// Gets the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method throws [StateError] when there is no ancestor [Form] like widget.
  /// Indeed, this method just calls [maybeFormStateOf] and check its result.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [CompanionPresenterMixin].
  FormStateAdapter formStateOf(BuildContext context) {
    final state = maybeFormStateOf(context);
    if (state == null) {
      throw StateError('Ancestor Form is required.');
    }

    return state;
  }

  /// Gets current [Locale] for current [BuildContext].
  ///
  /// This implementation uses [Localizations.maybeLocaleOf]. If it fails,
  /// returns `en-US` locale.
  /// You can change this behavior with overriding this method.
  Locale getLocale(BuildContext context) =>
      presenterFeatures.getLocale(context);

  /// Returns completion logic when any async validation is completed.
  ///
  /// This implementation just call [FormStateAdapter.validate] to re-evaluate
  /// all fields validity.
  AsyncValidationCompletionCallback buildOnAsyncValidationCompleted(
    String name,
    BuildContext context,
  ) =>
      presenterFeatures.buildOnAsyncValidationCompleted(name, context);

  /// Performs saving of form fields.
  void saveFields(FormStateAdapter formState) =>
      presenterFeatures.saveFields(formState);

  /// Do validation for all fields with their all validators including
  /// asynchronous ones, and returns [FutureOr] to await asynchronous
  /// validations.
  ///
  /// Note that [FutureOr] will be [bool] if no asynchronous validations are
  /// registered.
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
    final completers = _properties
        .getAllDescriptors()
        .where(
          (property) => property._asynvValidatorEntries.any(
            (entry) => entry._executor.validating,
          ),
        )
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
      for (final property in _properties.getAllDescriptors()) {
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
  Future<bool> validateAndSave(FormStateAdapter formState) async {
    if (!await validateAll(formState)) {
      return false;
    }

    saveFields(formState);
    return true;
  }
}

/// Internal helper methods of [CompanionPresenterMixin].
///
/// The API in this extension subject to change without any notification,
/// so users should not use this class.
@internal
@visibleForTesting
extension CompanionPresenterMixinInternalExtension on CompanionPresenterMixin {
  /// Returns a validation error message which is shown when the async validator
  /// failed to complete with an exception or an error.
  ///
  /// This implementation just return an English message
  /// "Failed to check value. Try input again later."
  /// You can override this method and provide your preferred message such as
  /// user friendly, localized message with [error] parameter which is actual
  /// [AsyncError].
  String getAsyncValidationFailureMessage(AsyncError error, Locale locale) =>
      presenterFeatures.getAsyncValidationFailureMessage(error, locale);

  /// Gets a [ValueListenable] which indicates there are any pending async
  /// validations in a property specified by [name].
  ValueListenable<bool> getPropertyPendingAsyncValidationsListener(
    String name,
  ) =>
      propertiesState.getDescriptor(name)._pendingAsyncValidations;

  /// For testing, reset async validator states, namely invalidates caches.
  @visibleForTesting
  void resetAsyncValidators() {
    this._properties.getAllDescriptors().forEach((p) {
      p._resetAsyncValidators();
    });
  }
}

/// Default class with [CompanionPresenterMixin] for testing to support
/// test coverage.
@internal
@visibleForTesting
abstract class TestCompanionPresenter with CompanionPresenterMixin {}
