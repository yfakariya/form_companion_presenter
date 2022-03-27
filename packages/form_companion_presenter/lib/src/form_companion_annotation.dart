// See LICENCE file in the root.

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
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
  const FormCompanion({
    this.autovalidate = true,
  });

  /// If `true`, generating code set `AutovalidateMode.onUserInteraction` for
  /// each `FormField`s' `autovalidateMode` named argument.
  ///
  /// Default is `true`.
  final bool autovalidate;
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
    Equality<F>? equality,
    ValueConverter<P, F>? valueConverter,
  }) =>
      // NOTE: TField is not used in runtime.
      //       The parameter will be interpreted in form_companion_generator.
      add<P, F>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        equality: equality,
        valueConverter: valueConverter,
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
  }) =>
      addWithField<P, String, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter,
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
  }) =>
      addWithField<bool, bool, TField>(
        name: name,
        initialValue: initialValue,
      );

  /// Defines a new property with enum type [T] for both of property value type
  /// and form field value type, and preferred form field type [TField].
  ///
  /// {@macro pdb_add_remarks}
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  void enumeratedWithField<T extends Enum, TField extends FormField<T>>({
    required String name,
    T? initialValue,
  }) =>
      addWithField<T, T, TField>(
        name: name,
        initialValue: initialValue,
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
  }) =>
      addWithField<int, int, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
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
  }) =>
      addWithField<double, double, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
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
  }) =>
      addWithField<BigInt, BigInt, TField>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
      );
}
