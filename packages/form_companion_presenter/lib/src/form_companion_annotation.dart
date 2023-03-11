// See LICENCE file in the root.

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../form_companion_presenter.dart';

/// An annotation for presenter class.
///
/// This annotation is used from `form_companion_generator` tool,
/// which generates strongly typed property accessor sources as build tool
/// running with `build_runner`.
@sealed
class FormCompanion {
  /// Initializes a new [FormCompanion] instance.
  ///
  /// You can specify [autovalidate] if you explicitly control each form fields'
  /// `autovalidateMode` for this presenter.
  const FormCompanion({
    this.autovalidate,
  });

  /// If `true`, generating code set `AutovalidateMode.onUserInteraction` for
  /// each `FormField`s' `autovalidateMode` named argument.
  /// If `false`, the set value will be `AutovalidateMode.disabled`.
  /// If `null` (default), `autovalidate_by_default` configuration option's
  /// value will be used.
  ///
  /// Default is `null`.
  ///
  /// If you want to control per presenter (or `Form`) basis, set this property.
  /// Else, if you want to control per your team or project basis, set
  /// `autovalidate_by_default` configuration option and do not specify this
  /// property.
  /// When you want to control per field basis, specify `autovalidateMode` named
  /// argument on form field factories.
  /// In summary, priority is following:
  ///
  /// 1. Form field fatrories' `autovalidateMode` arguments.
  /// 2. This `autovalidate` property value.
  /// 3. `autovalidate_by_default` configuration option.
  final bool? autovalidate;
}

/// Marks this presenter class as auto-validated and generating field factories.
const formCompanion = FormCompanion();

/// Defines convinient extension methods for [PropertyDescriptorsBuilder]
/// when you use [FormCompanion] annotation.
extension FormCompanionPropertyDescriptorBuilderExtensions
    on PropertyDescriptorsBuilder {
  /// Defines a new property with property value type [P],
  /// form field value type [F], and preferred form field type [TField].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void addWithField<P extends Object, F extends Object,
          TField extends FormField<F>>({
    required String name,
    List<FormFieldValidatorFactory<F>>? validatorFactories,
    List<AsyncValidatorFactory<F>>? asyncValidatorFactories,
    P? initialValue,
    Equality<F>? fieldValueEquality,
    Equality<P>? propertyValueEquality,
    ValueConverter<P, F>? valueConverter,
    PropertyValueTraits? valueTraits,
    RestorableValueFactory<F>? restorableValueFactory,
  }) =>
      // NOTE: TField is not used in runtime.
      //       The parameter will be interpreted in form_companion_generator.
      add<P, F>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        fieldValueEquality: fieldValueEquality,
        propertyValueEquality: propertyValueEquality,
        valueConverter: valueConverter,
        valueTraits: valueTraits,
        restorableValueFactory: restorableValueFactory,
      );

  /// Defines a new property with property value type [P]
  /// and preferred form field type [TField] for form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void stringConvertibleWithField<P extends Object,
          TField extends FormField<String>>({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    P? initialValue,
    required StringConverter<P>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      addWithField<P, String, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter,
        valueTraits: valueTraits,
        restorableValueFactory: stringRestorableValueFactory,
      );

  /// Defines a new property with [bool] for both of property value type and
  /// form field value type, and preferred form field type [TField].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void booleanWithField<TField extends FormField<bool>>({
    required String name,
    bool initialValue = false,
    PropertyValueTraits? valueTraits,
  }) =>
      addWithField<bool, bool, TField>(
        name: name,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: boolRestorableValueFactory,
      );

  /// Defines a new property with enum type [T] for both of property value type
  /// and form field value type, and preferred form field type [TField].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  ///
  /// Use `values` static property of [T] for [enumValues] parameter like
  /// [Brightness.values].
  void enumeratedWithField<T extends Enum, TField extends FormField<T>>({
    required String name,
    T? initialValue,
    PropertyValueTraits? valueTraits,
    required Iterable<T> enumValues,
  }) =>
      addWithField<T, T, TField>(
        name: name,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: enumRestorableValueFactory(enumValues),
      );

  /// Defines a new property with property value type [int]
  /// and preferred form field type [TField] for form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void integerWithField<TField extends FormField<int>>({
    required String name,
    List<FormFieldValidatorFactory<int>>? validatorFactories,
    List<AsyncValidatorFactory<int>>? asyncValidatorFactories,
    int? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      addWithField<int, int, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: intRestorableValueFactory,
      );

  /// Defines a new property with property value type [double]
  /// and preferred form field type [TField] for form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void realWithField<TField extends FormField<double>>({
    required String name,
    List<FormFieldValidatorFactory<double>>? validatorFactories,
    List<AsyncValidatorFactory<double>>? asyncValidatorFactories,
    double? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      addWithField<double, double, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: doubleRestorableValueFactory,
      );

  /// Defines a new property with property value type [BigInt]
  /// and preferred form field type [TField] for form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void bigIntWithField<TField extends FormField<BigInt>>({
    required String name,
    List<FormFieldValidatorFactory<BigInt>>? validatorFactories,
    List<AsyncValidatorFactory<BigInt>>? asyncValidatorFactories,
    BigInt? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      addWithField<BigInt, BigInt, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
        restorableValueFactory: bigIntRestorableValueFactory,
      );
}
