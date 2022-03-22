// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

/// Defines convinient extension methos for [PropertyDescriptorsBuilder] to
/// define typical type combinations with `flutter_form_builder`.
extension FormBuilderCompanionPropertyDescriptorsBuilderExtension
    on PropertyDescriptorsBuilder {
  /// Defines a new property with [List] of [bool] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addBoolList({
    required String name,
    List<bool>? initialValues,
  }) =>
      add<List<bool>, List<bool>>(
        name: name,
        initialValue: initialValues,
      );

  /// Defines a new property with [List] of enum type [Enum] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addEnumList<T extends Enum>({
    required String name,
    List<T>? initialValues,
  }) =>
      add<List<T>, List<T>>(name: name, initialValue: initialValues);

  /// Defines a new property with [DateTime] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addDateTime({
    required String name,
    List<FormFieldValidatorFactory<DateTime>>? validatorFactories,
    List<AsyncValidatorFactory<DateTime>>? asyncValidatorFactories,
    DateTime? initialValue,
  }) =>
      add<DateTime, DateTime>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
      );

  /// Defines a new property with [DateTimeRange] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addDateTimeRange({
    required String name,
    List<FormFieldValidatorFactory<DateTimeRange>>? validatorFactories,
    List<AsyncValidatorFactory<DateTimeRange>>? asyncValidatorFactories,
    DateTimeRange? initialValue,
  }) =>
      add<DateTimeRange, DateTimeRange>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
      );

  /// Defines a new property with [RangeValues] for both of
  /// property value type and form field value type.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addRangeValues({
    required String name,
    List<FormFieldValidatorFactory<RangeValues>>? validatorFactories,
    List<AsyncValidatorFactory<RangeValues>>? asyncValidatorFactories,
    RangeValues? initialValue,
  }) =>
      add<RangeValues, RangeValues>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
      );
}
