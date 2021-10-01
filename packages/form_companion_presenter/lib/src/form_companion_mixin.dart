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
typedef AsyncValidatorFactory<T, P> = AsyncValidator<T, P> Function(
  BuildContext context,
);

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
  late final Map<String, PropertyDescriptor<Object, dynamic>> _properties;

  /// Map of [PropertyDescriptor]. Key is [PropertyDescriptor.name].
  @nonVirtual
  @protected
  @visibleForTesting
  Map<String, PropertyDescriptor<Object, dynamic>> get properties =>
      _properties;

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
  void initializeFormCompanionMixin(
    PropertyDescriptorsBuilder properties,
  ) {
    _properties = properties._build(this);
  }

  /// This method will be called when pending async validation is canceled
  /// but the operation throws [AsyncError].
  ///
  /// You can handles the error by overriding this method. For example, you
  /// record the error with your logger or APM library.
  ///
  /// Default implementation delegates the error handling to
  /// [Zone.handleUncaughtError] method by throwing the error.
  @protected
  @visibleForOverriding
  void handleCanceledAsyncValidationError(AsyncError error) => throw error;

  PropertyDescriptor<Object, dynamic> _getProperty(String name) {
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
  PropertyDescriptor<T, dynamic> getProperty<T extends Object>(String name) {
    final property = _getProperty(name);

    if (property is! PropertyDescriptor<T, dynamic>) {
      throw StateError(
        'A type of \'$name\' property is ${property.runtimeType} instead of PropertyDescriptor<$T, ?>.',
      );
    }

    return property;
  }

  /// Gets a saved property value of specified name.
  ///
  /// The value should be set from `FormField` via [savePropertyValue].
  /// This getter should be called in [doSubmit] implementation to get saved
  /// valid values.
  @protected
  @nonVirtual
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
    BuildContext context,
  ) =>
      (_result, _error) => maybeFormStateOf(context)?.validate();

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
  @protected
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
    if (properties.values.every((p) => p._asynvValidatorEntries.isEmpty)) {
      // just validate.
      return formState.validate();
    }

    return _validateAllWithAsync(formState);
  }

  Future<bool> _validateAllWithAsync(FormStateAdapter formState) async {
    // Kick async validators.
    formState.validate();

    // Creates completers to wait pending async validations.
    final completers = properties.values
        .where((property) => property._asynvValidatorEntries.any(
              (entry) => entry._executor.validating,
            ))
        .map(
      (property) {
        final completer = Completer<void>();
        property._asyncValidationCompletion = completer;
        return completer;
      },
    ).toList();

    try {
      // wait completions of asynchronous validations.
      await Future.wait(completers.map((f) => f.future));

      // Returns result.
      return formState.validate();
    } finally {
      for (final property in properties.values) {
        property._asyncValidationCompletion = null;
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
  FutureOr<void> doSubmit(
    BuildContext context,
  );
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

    return key = _fieldKeys[name] = GlobalObjectKey(context);
  }

  @override
  @nonVirtual
  void initializeFormCompanionMixin(
    PropertyDescriptorsBuilder properties,
  ) {
    super.initializeFormCompanionMixin(properties);
    _fieldKeys = {for (final name in properties._properties.keys) name: null};
  }

  @override
  @nonVirtual
  FormStateAdapter? maybeFormStateOf(BuildContext context) {
    final state = Form.of(context);
    return state == null ? null : _FormStateAdapter(state);
  }

  @override
  @nonVirtual
  bool canSubmit(BuildContext context) {
    final formState = maybeFormStateOf(context);
    if (formState == null ||
        formState.autovalidateMode == AutovalidateMode.disabled) {
      // Should be manual validation in doSubmit(), so returns true here.
      return true;
    }

    return _fieldKeys.values
            .every((f) => !(f?.currentState?.hasError ?? false)) &&
        properties.values.every((p) => !p.hasPendingAsyncValidations);
  }
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
/// [CompanionPresenterMixin.initializeFormCompanionMixin].
@sealed
class PropertyDescriptor<T extends Object, P> {
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
  final List<_AsyncValidatorEntry<T, P>> _asynvValidatorEntries;

  /// Saved property value. This value can be `null`.
  T? _value;

  bool _isValueSet = false;

  /// [Completer] to notify [CompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<void>? _asyncValidationCompletion;

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
    final onCompleted = (String? result, AsyncError? error) {
      // This line refers lates field instead of the time when getValidator is called.
      if (error == null) {
        _asyncValidationCompletion?.complete();
      } else {
        _asyncValidationCompletion?.completeError(error);
      }

      notifyCompletion(result, error);
    };
    return _chainValidators([
      ..._validatorFactories.map((f) => f(context)),
      ..._asynvValidatorEntries.map(
        (e) {
          final asyncValidator = e.createValidator(context);
          final executor = e._executor;

          return (v) {
            // Cancels previous validation -- it might hang
            executor.cancel();
            return executor.validate(
              validator: asyncValidator,
              value: v,
              locale: locale,
              onCompleted: onCompleted,
            );
          };
        },
      ),
    ]);
  }
}

/// Required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<T extends Object, P> {
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
    CompanionPresenterMixin presenter,
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
  final Map<String, _PropertyDescriptorSource<Object, dynamic>> _properties =
      {};

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
  void addWithProgressReport<T extends Object, P>({
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
  Map<String, PropertyDescriptor<Object, dynamic>> _build(
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
