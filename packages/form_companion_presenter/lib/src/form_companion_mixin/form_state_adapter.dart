// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Defines interface between [CompanionPresenterMixin] and actual state of `Form`.
abstract class FormStateAdapter {
  /// Current [AutovalidateMode] of the `Form`.
  ///
  /// [CompanionPresenterMixin] behaves respecting to [AutovalidateMode].
  AutovalidateMode get autovalidateMode;

  /// Current [Locale] of the `Form`.
  Locale get locale;

  /// Whether the underlying state of the `Form` is mounted to the element tree.
  bool get mounted;

  /// Do validation of all form's fields and then returns the value whether
  /// all fields are valid or not.
  bool validate();

  /// Do save of all form's fields. `save()` effectively just call `onSaved`
  /// callbacks set to the fields, and some derived implementation do some extra
  /// work to prepare values for fields' consumer.
  void save();
}
