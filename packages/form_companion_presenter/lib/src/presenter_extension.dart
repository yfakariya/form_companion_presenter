// See LICENCE file in the root.
// Rationale: This library is actually 'protected` member of the presenter
//            to keep API backword compability for derived types.
// ignore_for_file: invalid_use_of_visible_for_testing_member, invalid_use_of_visible_for_overriding_member, invalid_use_of_protected_member

import 'package:flutter/widgets.dart';

import 'form_companion_mixin.dart';
import 'value_converter.dart';

/// Provides convinient members to access properties.
// TODO(yfakariya): Remove it, because generator do better  work
extension CompanionPresenterMixinExtension on CompanionPresenterMixin {
  /// Gets a [PropertyDescriptor] for the specified [name],
  /// which was registered via constrcutor.
  ///
  /// This method throws [ArgumentError] if the property named [name] does not
  /// exist, and throws [StateError] if [P] or [F] is not compatible with
  /// the `P` or `F` of getting [PropertyDescriptor].
  ///
  /// You should defined wrapper getter in your presenter class to avoid typo
  /// and repeated input for the name and value type error:
  /// ```dart
  /// PropertyDescriptor<String> get name => getProperty<String>('name');
  /// PropertyDescriptor<int> get age => getProperty<int>('age');
  /// ```
  PropertyDescriptor<P, F> getProperty<P extends Object, F extends Object>(
      String name) {
    final property = internals.getProperty(name);

    if (property is! PropertyDescriptor<P, F>) {
      throw StateError(
        'A type of \'$name\' property is ${property.runtimeType} instead of PropertyDescriptor<$P, $F>.',
      );
    }

    return property;
  }

  /// Gets a saved property value of specified name.
  ///
  /// The value should be set from `FormField` via [savePropertyValue].
  /// This getter should be called in [doSubmit] implementation to get saved
  /// valid values.
  /// In addition, the value will be converted via [ValueConverter.toPropertyValue].
  P? getSavedPropertyValue<P extends Object>(String name) =>
      internals.getProperty(name).value as P?;

  /// Gets a setter to set a proprty value with validated form field input.
  ///
  /// The result should be bound to [FormField.onSaved] for vanilla [Form].
  void Function(dynamic) savePropertyValue(String name, BuildContext context) =>
      (dynamic v) =>
          internals.getProperty(name).setFieldValue(v, getLocale(context));

  /// Gets a validator to validate form field input.
  ///
  /// The result should be bound to [FormField.validator].
  FormFieldValidator<F> getPropertyValidator<F extends Object>(
    String name,
    BuildContext context,
  ) =>
      (internals.getProperty(name) as PropertyDescriptor<Object, F>)
          .getValidator(context);

  /// Gets a value which indicates that specified property has pencing
  /// asynchronous validation or not.
  ///
  /// Note that pending validation complection causes re-evaluation of validity
  /// of the form field, so rebuild will be caused from the field.
  bool hasPendingAsyncValidations(String name) =>
      getProperty(name).hasPendingAsyncValidations;
}
