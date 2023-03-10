// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

/// Defines convinient extension methos for [PropertyDescriptorsBuilder] to
/// define typical type combinations with `flutter_form_builder`.
extension FormBuilderCompanionPropertyDescriptorsBuilderExtension
    on PropertyDescriptorsBuilder {
  // TODO: breaking! REMOVE booleanList

  /// Defines a new property with [List] of enum type [Enum] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  ///
  /// Use `values` static property of [T] for [enumValues] parameter like
  /// [Brightness.values].
  void enumeratedList<T extends Enum>({
    required String name,
    List<T>? initialValues,
    PropertyValueTraits? valueTraits,
    // TODO: breaking!
    required Iterable<T> enumValues,
  }) =>
      add<List<T>, List<T>>(
        name: name,
        initialValue: initialValues,
        valueTraits: valueTraits,
        restorableValueFactory: enumListRestorableValueFactory(enumValues),
      );

  /// Defines a new property with [DateTime] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void dateTime({
    required String name,
    List<FormFieldValidatorFactory<DateTime>>? validatorFactories,
    List<AsyncValidatorFactory<DateTime>>? asyncValidatorFactories,
    DateTime? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      add<DateTime, DateTime>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: dateTimeRestorableValueFactory,
      );

  /// Defines a new property with [DateTimeRange] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void dateTimeRange({
    required String name,
    List<FormFieldValidatorFactory<DateTimeRange>>? validatorFactories,
    List<AsyncValidatorFactory<DateTimeRange>>? asyncValidatorFactories,
    DateTimeRange? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      add<DateTimeRange, DateTimeRange>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: dateTimeRangeRestorableValueFactory,
      );

  /// Defines a new property with [RangeValues] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void rangeValues({
    required String name,
    List<FormFieldValidatorFactory<RangeValues>>? validatorFactories,
    List<AsyncValidatorFactory<RangeValues>>? asyncValidatorFactories,
    RangeValues? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      add<RangeValues, RangeValues>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: rangeValuesRestorableValueFactory,
      );
}
