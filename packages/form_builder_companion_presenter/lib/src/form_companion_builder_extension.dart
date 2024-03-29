import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

/// Defines convinient extension methods for [PropertyDescriptorsBuilder]
/// when you use [FormCompanion] annotation and `flutter_form_builder`.
extension FormCompanionBuilderCompanionPropertyDescriptorsBuilderExtension
    on PropertyDescriptorsBuilder {
  /// Defines a new property with [List] of enum type [T] for both of
  /// property value type and form field value type,
  /// and preferred form field type [TField].
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  ///
  /// [TField] affects `FormFieldFactory` generation by `form_companion_generator`.
  ///
  /// Use `values` static property of [T] for [enumValues] parameter like
  /// [Brightness.values].
  void enumeratedListWithField<T extends Enum,
          TField extends FormField<List<T>>>({
    required String name,
    List<T>? initialValues,
    PropertyValueTraits? valueTraits,
    required Iterable<T> enumValues,
  }) =>
      addWithField<List<T>, List<T>, TField>(
        name: name,
        initialValue: initialValues,
        valueTraits: valueTraits,
        restorableValueFactory: enumListRestorableValueFactory(enumValues),
      );
}
