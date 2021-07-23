// See LICENCE file in the root.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'async_validator_executor.dart';
import 'future_invoker.dart';
import 'internal_utils.dart';

/// Signature for factory of [FormFieldValidator].
typedef FormFieldValidatorFactory<T> = FormFieldValidator<T> Function(
    BuildContext context);

/// Signature for factory of [AsyncValidator].
typedef AsyncValidatorFactory<T, P> = AsyncValidator<T, P> Function(
  BuildContext context,
);

/// Defines interface between [FormCompanionPresenterMixin] and actual state of `Form`.
abstract class FormStateAdapter {
  /// Gets a current [AutovalidateMode] of the `Form`.
  ///
  /// [FormCompanionPresenterMixin] behaves respecting to [AutovalidateMode].
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
mixin FormCompanionPresenterMixin {
  late Map<String, PropertyDescriptor> _properties;

  /// Map of [PropertyDescriptor]. Key is [PropertyDescriptor.name].
  Map<String, PropertyDescriptor> get properties {
    // ignore: unnecessary_null_comparison
    assert(_properties != null, 'initializeProperties must be called.');
    return _properties;
  }

  /// Initializes [FormCompanionPresenterMixin].
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
  void initializeFormCompanionMixin(
    PropertyDescriptorsBuilder properties,
  ) {
    // ignore: unnecessary_null_comparison
    assert(_properties == null, 'initializeProperty can be called only once.');
    _properties = properties._build(this);
  }

  /// This method will be called when pending async validation is canceled
  /// but the operation throws [AsyncError].
  ///
  /// You can handles the error by overriding this method. For example, you
  /// record the error with your logger or APM library.
  ///
  /// Default implementation delegates the error handling to
  /// [async.Zone.current] and its [async.Zone.handleUncaughtError] method.
  @visibleForOverriding
  void handleCanceledAsyncValidationError(AsyncError error) =>
      Zone.current.handleUncaughtError(error, error.stackTrace);

  /// Get a [PropertyDescriptor] for the specified [name],
  /// which was registered via constrcutor.
  ///
  /// You should defined wrapper getter in your presenter class to avoid typo
  /// and repeated input for the name and value type error:
  /// ```dart
  /// PropertyDescriptor<String> get name => getProperty<String>('name');
  /// PropertyDescriptor<int> get age => getProperty<int>('age');
  /// ```
  PropertyDescriptor<P, void> getProperty<P>(String name) =>
      properties[name]! as PropertyDescriptor<P, void>;

  /// Get the ancestor [FormState] like state from specified [BuildContext],
  /// and wraps it to [FormStateAdapter].
  ///
  /// This method returns `null` when there is no ancestor [Form] like widget.
  ///
  /// This method shall be implemented in the concrete class which is mix-ined
  /// [FormCompanionPresenterMixin].
  FormStateAdapter? maybeFormStateOf(BuildContext context);

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
  bool canSubmit(BuildContext context) {
    final formState = maybeFormStateOf(context);
    if (formState == null ||
        formState.autovalidateMode == AutovalidateMode.disabled) {
      // Should be manual validation in doSubmit(), so returns true here.
      return true;
    }

    return formState.validate() &&
        properties.values.every((p) => !p.hasPendingAsyncValidations);
  }

  /// Returns submit callback suitable for `onClick` callback of button
  /// which represents `submit` of form.
  ///
  /// This proeprty returns `null` when [canSubmit] is `false`;
  /// otherwise, this returns [doSubmit] as function type result.
  /// So, the button will be disabled when [canSubmit] is `false`,
  /// and will be enabled otherwise.
  VoidCallback? submit(BuildContext context) {
    if (!canSubmit(context)) {
      return null;
    }

    return buildDoSubmit(context);
  }

  /// Gets current [Locale] for current [BuildContext].
  ///
  /// This implementation uses [Localizations.maybeLocaleOf]. If it fails,
  /// returns `en-US` locale.
  /// You can change this behavior with overriding this method.
  @visibleForOverriding
  Locale getLocale(BuildContext context) =>
      Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US');

  /// Returns completion logic when any async validation is completed.
  ///
  /// This implementation just call [FormStateAdapter.validate] to re-evaluate
  /// all fields validity.
  @visibleForOverriding
  AsyncOperationCompletedCallback<String?> buildOnAsyncValidationCompleted(
    BuildContext context,
  ) =>
      (_) => maybeFormStateOf(context)?.validate();

  /// Builds and returns [VoidCallback] which prepares and calls [doSubmit].
  ///
  /// This implementation prepares with calling [FormStateAdapter.save] iff
  /// [FormStateAdapter.autovalidateMode] is NOT [AutovalidateMode.disabled].
  /// Note that if [FormStateAdapter.autovalidateMode] is
  /// [AutovalidateMode.disabled], that means you choose manual validation and
  /// saving within [doSubmit] or you omitted creating [Form] or simular widgets
  /// to coordinate [FormField]s. If so, this method effectively returns a
  /// closure which just call and await [doSubmit].
  @protected
  @visibleForOverriding
  VoidCallback buildDoSubmit(BuildContext context) {
    final formState = maybeFormStateOf(context);

    return () async {
      if (formState != null) {
        if (formState.autovalidateMode != AutovalidateMode.disabled) {
          saveFields(formState);
        }
      }

      await doSubmit(context);
    };
  }

  /// Performs saving of form fields.
  void saveFields(FormStateAdapter formState) {
    formState.save();
  }

  /// Do validation for all fields with their all validators including
  /// asynchronous ones, and returns [FutureOr] to await asynchronous
  /// validations.
  ///
  /// Note that [FutureOr] will be [bool] if no asynchronous validations are
  /// registered.
  FutureOr<bool> validateAll(FormStateAdapter formState) {
    if (properties.values.every((p) => p._asynvValidatorEntries.isEmpty)) {
      // just validate.
      return formState.validate();
    }

    return _validateAllWithAsync(formState);
  }

  Future<bool> _validateAllWithAsync(FormStateAdapter formState) async {
    final completers = <Completer<void>>[];

    // Set Completers and stores to list for bulk awaiting.
    for (final property in properties.values) {
      if (property._asynvValidatorEntries.isNotEmpty) {
        final completer = Completer<void>();
        property._completer = completer;
        completers.add(completer);
      }
    }

    try {
      // Kick async validators.
      formState.validate();

      // wait completions of asynchronous validations.
      await Future.wait(completers.map((f) => f.future));

      // Returns result.
      return formState.validate();
    } finally {
      for (final property in properties.values) {
        property._completer = null;
      }
    }
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
  /// [FormCompanionPresenterMixin].
  @protected
  @visibleForOverriding
  FutureOr<void> doSubmit(
    BuildContext context,
  );
}

class _AsyncValidatorEntry<T, P> {
  final AsyncValidatorFactory<T, P> _factory;
  final AsyncValidatorExecutor<T, P> _executor;

  bool get validating => _executor.validating;

  _AsyncValidatorEntry(
    this._factory,
    Equality<T?>? equality,
    AsyncErrorHandler? canceledValidationErrorHandler,
  ) : _executor = AsyncValidatorExecutor(
          equality: equality,
          canceledValidationErrorHandler: canceledValidationErrorHandler,
        );

  AsyncValidator<T, P> createValidator(BuildContext context) =>
      _factory(context);
}

// The idea is borrowed from FormBuilderValidators.composite()
FormFieldValidator<T> _chainValidators<T>(
  List<FormFieldValidator<T?>> validators,
) =>
    (value) {
      for (final validator in validators) {
        final validationError = validator(value);
        if (validationError != null) {
          return validationError;
        }
      }

      return null;
    };

/// Represents "property" of view model which uses [FormCompanionPresenterMixin].
///
/// You can use this descriptor to:
/// * Setup [FormField] or simluar widgets such as [getValidator] method to get
///   [FormFieldValidator] which sequentially run validators including
///   asynchronous ones, which should be set as [FormField.validator] parameter,
///   [value] setter which should be set as [FormField.onSaved] parameter,
///   [name] property which should be set to name for some form frameworks.
/// * Get whether asynchronous validation is executing to show some indicator
///   with [hasPendingAsyncValidations].
/// * Get saved valid value for this property.
///
/// Conversely, you must use this object to setup form fields to work
/// [FormCompanionPresenterMixin] logics correctly.
///
/// This object is built with [PropertyDescriptorsBuilder] which is passed to
/// [FormCompanionPresenterMixin.initializeFormCompanionMixin].
@sealed
class PropertyDescriptor<T, P> {
  /// Unique name of this property.
  final String name;

  /// Connected presenter object which implements [FormCompanionPresenterMixin].
  final FormCompanionPresenterMixin presenter;

  // The reason of using factories instead of validators theirselves is some
  // validator framework requires BuildContext to localize their messages.
  // In addition, it is good for the sake of injection of Completer to await
  // async validation from FormCompanionMixin.

  /// Factories of [FormFieldValidator].
  final List<FormFieldValidatorFactory<T>> _validatorFactories;

  /// Entries to build [AsyncValidator].
  final List<_AsyncValidatorEntry<T, P>> _asynvValidatorEntries;

  /// Saved value which can be null.
  // ignore: use_late_for_private_fields_and_variables
  NullableValueHolder<T>? _value;

  /// [Completer] to notify [FormCompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<void>? _completer;

  /// Saved value.
  T get value => _value!.value;

  /// Save value from form field or simular widget.
  set value(T value) => _value = NullableValueHolder(value);

  /// Save value from logic which handles this [PropertyDescriptor] without
  /// strong typing.
  void setDynamicValue(dynamic value) => this.value = value as T;

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
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T, P>>? asyncValidatorFactories,
    Equality<T?>? equality,
  })  : _validatorFactories = validatorFactories ?? [],
        _asynvValidatorEntries = (asyncValidatorFactories ?? [])
            .map(
              (v) => _AsyncValidatorEntry<T, P>(
                v,
                equality,
                presenter.handleCanceledAsyncValidationError,
              ),
            )
            .toList();

  /// Returns a composite validator which contains synchronous (normal)
  /// validators and asynchronous validators.
  FormFieldValidator<T> getValidator(BuildContext context) {
    final locale = presenter.getLocale(context);
    final notifyCompletion = presenter.buildOnAsyncValidationCompleted(context);
    // ignore: prefer_function_declarations_over_variables, avoid_types_on_closure_parameters
    final onCompleted = (String? result) {
      // This line refers lates field instead of the time when getValidator is called.
      _completer?.complete();
      notifyCompletion(result);
    };
    return _chainValidators([
      ..._validatorFactories.map((f) => f(context)),
      ..._asynvValidatorEntries.map(
        (e) {
          final asyncValidator = e.createValidator(context);
          final executor = e._executor;
          return (v) => executor.validate(
                validator: asyncValidator,
                value: v,
                locale: locale,
                onCompleted: onCompleted,
              );
        },
      ),
    ]);
  }
}

/// Required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<T, P> {
  final String name;
  final List<FormFieldValidatorFactory<T>> validatorFactories;
  final List<AsyncValidatorFactory<T, P>> asyncValidatorFactories;

  _PropertyDescriptorSource({
    required this.name,
    required this.validatorFactories,
    required this.asyncValidatorFactories,
  });

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  PropertyDescriptor<T, P> build(
    FormCompanionPresenterMixin presenter,
  ) =>
      PropertyDescriptor<T, P>._(
        name: name,
        presenter: presenter,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
      );
}

/// Builder object to build [PropertyDescriptor].
@sealed
class PropertyDescriptorsBuilder {
  final Map<String, _PropertyDescriptorSource> _properties = {};

  /// Defines new property without asynchronous validation progress reporting.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void add<T>({
    required String name,
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T, void>>? asyncValidatorFactories,
  }) =>
      addWithProgressReport(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
      );

  /// Defines new property with asynchronous validation progress reporting.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addWithProgressReport<T, P>({
    required String name,
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T, P>>? asyncValidatorFactories,
  }) {
    final descriptor = _PropertyDescriptorSource<T, P>(
      name: name,
      validatorFactories: validatorFactories ?? [],
      asyncValidatorFactories: asyncValidatorFactories ?? [],
    );
    final oldOrNew = _properties.putIfAbsent(name, () => descriptor);
    assert(oldOrNew == descriptor, '$name is already registered.');
  }

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  Map<String, PropertyDescriptor> _build(
    FormCompanionPresenterMixin presenter,
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
