// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Represents "property" of view model which uses [CompanionPresenterMixin].
///
/// This is advanced feature, so normal users should not concern this object.
///
/// You can use this descriptor indirectly to:
/// * Setup [FormField] or simular widgets. [FormFieldValidator] is provided
///   via [FormPropertiesExtension.getFieldValidator]
///   (it internally calls [getValidator]), which sequentially run validators
///   including asynchronous ones and they should be set to [FormField.validator]
///   parameters.
///   For vanilla [FormField], it is required to bind [FormField.onSaved]
///   parameters and callbacks returned from
///   [FormPropertiesExtension.savePropertyValue] methods to
///   work the mixin correctly. The callback internally calls [setFieldValue]
///   method. [name] property which should be set to name for some form
///   frameworks.
/// * Get saved valid value for this property via
///   [FormProperties.getValue].
/// * Checking whether asynchronous validation via
///   [FormPropertiesExtension.hasPendingAsyncValidations]
///   to show some indicator. It internally calls [hasPendingAsyncValidations].
///
/// Note that first 2 items can be also handled with form field factories
/// which are generated by `form_companion_generator`.
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

  /// Represents traits of [PropertyDescriptor] this property's value.
  final PropertyValueTraits valueTraits;

  // The reason of using factories instead of validators theirselves is some
  // validator framework requires BuildContext to localize their messages.
  // In addition, it is good for the sake of injection of Completer to await
  // async validation from FormCompanionMixin.

  /// Factories of [FormFieldValidator].
  final List<FormFieldValidatorFactory<F>> _validatorFactories;

  /// Entries to build [AsyncValidator].
  final List<_AsyncValidatorFactoryEntry<F>> _asynvValidatorEntries;

  final void Function(String name, Object? value) _onPropertyChanged;

  final ValueConverter<P, F> _valueConverter;

  final Equality<P?> _propertyValueEquality;

  final RestorableValueFactory<F>? _restorableFieldValueFactory;

  RestorableFieldValues<F>? _restorableFieldValue;

  /// Gets a field value type.
  Type get _fieldValueType => F;

  /// [Completer] to notify [CompanionPresenterMixin] with
  /// non-autovalidation mode which should run and wait asynchronous validators
  /// in its submit method.
  Completer<bool>? _asyncValidationCompletion;

  /// State automaton node of validation.
  _ValidationContext _validationContext = _ValidationContext.unspecified;

  /// Resets async validator status, namely invalidates caches.
  void _resetAsyncValidators() {
    _asynvValidatorEntries.forEach((e) {
      e._executor.reset(null);
    });
  }

  RestorableFieldValues<F> _createRestorableFieldValues() {
    assert(
      _restorableFieldValueFactory != null,
      'Called when F is not primitive.', // coverage:ignore-line
    );

    return RestorableFieldValues(
      _restorableFieldValueFactory!,
      _restorableFieldValue,
    );
  }

  /// Wraps specified [onChanged], which takes nullable value,
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `onChanged` like following:
  ///
  /// ```dart
  /// DropdownButtonFormField(
  ///   ...
  ///   onChanged: property.onChanged(context, yourOnChangedArgument);
  /// )
  /// ```
  ValueSetter<F?> onChanged(
    BuildContext context, // reserved for future use
    ValueSetter<F?>? onChanged,
  ) =>
      (v) {
        _restorableFieldValue?.setValue(v);
        onChanged?.call(v);
      };

  /// Wraps specified [onChanged], which takes non-nullable value,
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `onChanged` like following:
  ///
  /// ```dart
  /// TextFormField(
  ///   ...
  ///   onChanged: property.onChangedNonNull(context, yourOnChangedArgument);
  /// )
  /// ```
  ValueSetter<F> onChangedNonNull(
    BuildContext context, // reserved for future use
    ValueSetter<F>? onChanged,
  ) =>
      (v) {
        _restorableFieldValue?.setValue(v);
        onChanged?.call(v);
      };

  /// Wraps `initialValue`, which is taken from [getFieldValue],
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `initialValue` like following:
  ///
  /// ```dart
  /// TextFormField(
  ///   ...
  ///   initialValue: property.getInitialValue(context);
  /// )
  /// ```
  F? getInitialValue(BuildContext context) {
    final initialValue = getFieldValue(
      Localizations.maybeLocaleOf(context) ?? const Locale('en-US'),
    );
    _restorableFieldValue?.tryScheduleRestoration(
      initialValue,
      (restoredValue, hasError) {
        presenter.presenterFeatures.restoreField(
          context,
          name,
          restoredValue,
          hasError: hasError,
        );
      },
    );

    return initialValue;
  }

  /// Gets a field value (rather than property value) for form field.
  ///
  /// This value calls [ValueConverter.toFieldValue]
  /// with the property value and [locale].
  F? getFieldValue(Locale locale) {
    final value = _valueConverter.toFieldValue(
      presenter._properties.getValue(name) as P?,
      locale,
    );
    return value;
  }

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

    setPropertyValue(result.value);
  }

  /// Sets a property value directly.
  ///
  /// For user input, use [setFieldValue] or generated form field factory instead.
  ///
  /// **This method is designed to be used from presenter's logic**
  /// including response for dependency update like `build()` method of
  /// riverpod notifiers.
  // ignore: use_setters_to_change_properties
  void setPropertyValue(P? value) {
    _onPropertyChanged(name, value);
  }

  /// State of pending async validations.
  final _PendingAsyncValidations _pendingAsyncValidations =
      _PendingAsyncValidations();

  /// Whether any asynchronous validations is running now.
  bool get hasPendingAsyncValidations => _pendingAsyncValidations.value;

  /// Constructor.
  ///
  /// [fieldValueEquality] will be used to constructor parameter of [AsyncValidator] for
  /// asynchronous validatiors created by [asyncValidatorFactories].
  PropertyDescriptor._({
    required this.name,
    required this.presenter,
    required List<FormFieldValidatorFactory<F>> validatorFactories,
    required List<AsyncValidatorFactory<F>> asyncValidatorFactories,
    required void Function(String name, Object? value) onPropertyChanged,
    required Equality<F?>? fieldValueEquality,
    required Equality<P?>? propertyValueEquality,
    required ValueConverter<P, F>? valueConverter,
    required this.valueTraits,
    required RestorableValueFactory<F>? restorableValueFactory,
  })  : _propertyValueEquality = propertyValueEquality ?? Equality<P?>(),
        _onPropertyChanged = onPropertyChanged,
        _valueConverter = valueConverter ?? DefaultValueConverter<P, F>(),
        _validatorFactories = [...validatorFactories],
        _asynvValidatorEntries = asyncValidatorFactories
            .map(
              (v) => _AsyncValidatorFactoryEntry<F>(
                v,
                fieldValueEquality,
                presenter.handleCanceledAsyncValidationError,
              ),
            )
            .toList(),
        _restorableFieldValueFactory = restorableValueFactory {
    _validatorFactories.add(
      createValidatorFactoryFromConverter<P, F>(_valueConverter),
    );
  }

  /// Returns a composite validator which contains synchronous (normal)
  /// validators and asynchronous validators.
  FormFieldValidator<F> getValidator(BuildContext context) =>
      _PropertyValidator<F>(
        [
          ..._validatorFactories.map(
            (f) => f(
              createValidatorCreationOptions(
                context,
                Localizations.maybeLocaleOf(context),
              ),
            ),
          ),
        ],
        [
          ..._asynvValidatorEntries.map(
            (e) =>
                _AsyncValidatorEntry(e._executor, e.createValidator(context)),
          ),
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
        this,
      ).asValidtor();
}

/// **For testing.** Returns value converter of the [PropertyDescriptor].
@visibleForTesting
ValueConverter<Object, Object> getValueConverter(PropertyDescriptor property) =>
    property._valueConverter;

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

@immutable
class _PropertyState {
  final PropertyDescriptor descriptor;
  final Object? valueSnapshot;

  _PropertyState(this.descriptor, this.valueSnapshot);

  _PropertyState reincarnateIfNeeded(Object? newValue) {
    if (descriptor._propertyValueEquality.equals(valueSnapshot, newValue)) {
      // ignore: avoid_returning_this
      return this;
    }

    return _PropertyState(descriptor, newValue);
  }

  @override
  int get hashCode => Object.hash(descriptor, valueSnapshot);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _PropertyState &&
          identical(descriptor, other.descriptor) &&
          // We do not call identical() here because the optimization should be
          // responsiblity of Equality() implementation.
          (descriptor._propertyValueEquality
              .equals(valueSnapshot, other.valueSnapshot)));
}

/// Represents properties of the form bound to the presenter.
///
/// This object is immutable and equatable, so you can use this object for
/// state management mechanism well.
@immutable
class FormProperties {
  final CompanionPresenterMixin _presenter;
  final Map<String, _PropertyState> _states;

  /// Gets a [CompanionPresenterMixin] instance which holds this properties state.
  CompanionPresenterMixin get presenter => _presenter;

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(_states) ^ _presenter.hashCode;

  FormProperties._(this._presenter, this._states);

  /// Calls bound presenter's [CompanionPresenterMixin.canSubmit].
  ///
  /// {@macro canSubmit}
  bool canSubmit(BuildContext context) => _presenter.canSubmit(context);

  /// Calls bound presenter's [CompanionPresenterMixin.submit].
  ///
  /// {@macro submit}
  void Function()? submit(BuildContext context) => _presenter.submit(context);

  /// Gets a value of specified property.
  ///
  /// If the property is not registered, [ArgumentError] will be thrown.
  Object? getValue(String name) => _getState(name).valueSnapshot;

  /// Gets a [PropertyDescriptor] for the specified [name],
  /// which was registered via [CompanionPresenterMixin.initializeCompanionMixin].
  ///
  /// This method throws [ArgumentError] if the property named [name] does not
  /// exist, and throws [StateError] if [P] or [F] is not compatible with
  /// the `P` or `F` of getting [PropertyDescriptor].
  ///
  /// It is recommended to use type property accessors which are generated by
  /// `form_companion_generator` tool instead of using this method. It helps to
  /// avoid name and type arguments mismatch, and provides developer tools'
  /// input auto completion friendly syntax.
  PropertyDescriptor<P, F> getDescriptor<P extends Object, F extends Object>(
    String name,
  ) {
    final property = _getState(name).descriptor;

    if (property is! PropertyDescriptor<P, F>) {
      throw StateError(
        'A type of \'$name\' property is ${property.runtimeType} instead of PropertyDescriptor<$P, $F>.',
      );
    }

    return property;
  }

  /// Tries to get a [PropertyDescriptor] for the specified [name],
  /// which was registered via [CompanionPresenterMixin.initializeCompanionMixin].
  ///
  /// This method does not throws even if the property named [name] does not
  /// exist, but throws [StateError] if [P] or [F] is not compatible with
  /// the `P` or `F` of getting [PropertyDescriptor].
  PropertyDescriptor<P, F>?
      tryGetDescriptor<P extends Object, F extends Object>(
    String name,
  ) {
    final property = _states[name]?.descriptor;

    if (property is! PropertyDescriptor<P, F>?) {
      throw StateError(
        'A type of \'$name\' property is ${property.runtimeType} instead of PropertyDescriptor<$P, $F>.',
      );
    }

    return property;
  }

  @protected
  _PropertyState _getState(String name) {
    final state = _states[name];
    if (state == null) {
      throw ArgumentError.value(
        name,
        'name',
        'Specified property is not registered.',
      );
    }

    return state;
  }

  /// Gets all registered [PropertyDescriptor]s.
  Iterable<PropertyDescriptor> getAllDescriptors() =>
      _states.values.map((s) => s.descriptor);

  /// Returns a copy of this instance with a specified new property.
  ///
  /// Note that this method may return this instance itself if [newValue]
  /// is same as current value.
  FormProperties copyWithProperty(String name, Object? newValue) {
    final newState = _tryCopyWithProperty(name, newValue);
    if (newState == null) {
      // ignore: avoid_returning_this
      return this;
    }

    final newStates = Map<String, _PropertyState>.from(_states);
    newStates[name] = newState;
    return FormProperties._(_presenter, newStates);
  }

  /// Returns a copy of this instance with specified new properties.
  ///
  /// If [newValues] contains `null` value, the property will be set to `null`.
  /// Properties which are not added to [newValues] map will not be changed
  /// (that is, they will be just copied).
  ///
  /// Note that this method may return this instance itself if [newValues]
  /// are all same as current values.
  FormProperties copyWithProperties(Map<String, Object?> newValues) {
    if (newValues.isEmpty) {
      // ignore: avoid_returning_this
      return this;
    }

    final newStates = Map<String, _PropertyState>.from(_states);

    var anyUpdateExists = false;
    for (final entry in newValues.entries) {
      final newState = _tryCopyWithProperty(entry.key, entry.value);
      if (newState == null) {
        continue;
      }

      newStates[entry.key] = newState;
      anyUpdateExists = true;
    }

    if (!anyUpdateExists) {
      return this;
    }

    return FormProperties._(_presenter, newStates);
  }

  _PropertyState? _tryCopyWithProperty(String name, Object? newValue) {
    if (!_states.containsKey(name)) {
      return null;
    }

    final state = _states[name]!;
    final newState = state.reincarnateIfNeeded(newValue);

    if (identical(state, newState)) {
      return null;
    }

    return newState;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormProperties &&
          identical(_presenter, other._presenter) &&
          const DeepCollectionEquality().equals(_states, other._states));
}

/// Provides convinient members to access properties.
extension FormPropertiesExtension on FormProperties {
  /// Gets a setter to set a proprty value with validated form field input.
  ///
  /// The result should be bound to [FormField.onSaved] for vanilla [Form].
  ///
  /// It is recommended to use form field factories which are generated by
  /// `form_companion_generator` tool instead of using this method. It provides
  /// boilerplates between [PropertyDescriptor] and [FormField] binding
  /// including [FormField.initialValue] setting with the return value of
  /// [FormProperties.getValue], [FormField.onSaved] handling with
  /// calling [PropertyDescriptor.setFieldValue], and [FormField.validator]
  /// settings with [PropertyDescriptor.getValidator].
  void Function(dynamic) savePropertyValue(String name, BuildContext context) =>
      (dynamic v) =>
          getDescriptor(name).setFieldValue(v, _presenter.getLocale(context));

  /// Gets a validator to validate form field input.
  ///
  /// The result should be bound to [FormField.validator].
  ///
  /// It is recommended to use form field factories which are generated by
  /// `form_companion_generator` tool instead of using this method. It provides
  /// boilerplates between [PropertyDescriptor] and [FormField] binding
  /// including [FormField.initialValue] setting with the return value of
  /// [FormProperties.getValue], [FormField.onSaved] handling with
  /// calling [PropertyDescriptor.setFieldValue], and [FormField.validator]
  /// settings with [PropertyDescriptor.getValidator].
  FormFieldValidator<F> getFieldValidator<F extends Object>(
    String name,
    BuildContext context,
  ) =>
      (getDescriptor(name) as PropertyDescriptor<Object, F>)
          .getValidator(context);

  /// Gets a value which indicates that specified property has pencing
  /// asynchronous validation or not.
  ///
  /// Note that pending validation complection causes re-evaluation of validity
  /// of the form field, so rebuild will be caused from the field.
  ///
  /// It is recommended to use type property accessors which are generated by
  /// `form_companion_generator` tool instead of using this method. It helps to
  /// avoid name and type arguments mismatch, and provides developer tools'
  /// input auto completion friendly syntax.
  bool hasPendingAsyncValidations(String name) =>
      getDescriptor(name).hasPendingAsyncValidations;

  /// Wraps specified [onChanged], which takes nullable value,
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `onChanged` like following:
  ///
  /// ```dart
  /// DropdownButtonFormField(
  ///   ...
  ///   onChanged: presenter.propertiesState.onChanged(context, 'property-name', yourOnChangedArgument);
  /// )
  /// ```
  ValueSetter<F?> onChanged<F extends Object>(
    BuildContext context,
    String name, [
    ValueSetter<F?>? onChanged,
  ]) =>
      getDescriptor<Object, F>(name).onChanged(context, onChanged);

  /// Wraps specified [onChanged], which takes non-nullable value,
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `onChanged` like following:
  ///
  /// ```dart
  /// TextFormField(
  ///   ...
  ///   onChanged: presenter.propertiesState.onChangedNonNull('property', yourOnChangedArgument);
  /// )
  /// ```
  ValueSetter<F> onChangedNonNull<F extends Object>(
    BuildContext context,
    String name, [
    ValueSetter<F>? onChanged,
  ]) =>
      getDescriptor<Object, F>(name).onChangedNonNull(context, onChanged);

  /// Wraps specified `initialValue`,
  /// which is taken from [PropertyDescriptor.getFieldValue],
  /// with infrastructure support logic for state restoration.
  ///
  /// This is usually used in `form_companion_generator` to support restoration,
  /// but you can use this even if you write [FormField] creation code by hand.
  /// When you write yourself, use this method to wrap your argument for
  /// `initialValue` like following:
  ///
  /// ```dart
  /// TextFormField(
  ///   ...
  ///   initialValue: presenter.propertiesState.getInitialValue(context, 'property-name');
  /// )
  /// ```
  F? getInitialValue<F extends Object>(
    BuildContext context,
    String name,
  ) =>
      getDescriptor<Object, F>(name).getInitialValue(context);
}

/// **DO NOT EXPORT** Internal extensions of [FormProperties].
@internal
extension FormPropertiesInternalExtension on FormProperties {
  /// Gets a field value type of specified [PropertyDescriptor].
  Type getFieldValueType(String name) => getDescriptor(name)._fieldValueType;

  /// Resets async validator status, namely invalidates caches.
  void resetAsyncValidators(String name) =>
      getDescriptor(name)._resetAsyncValidators();
}
