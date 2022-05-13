// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Signature for factory of [FormFieldValidator].
typedef FormFieldValidatorFactory<T> = FormFieldValidator<T> Function(
  BuildContext context,
);

/// Signature for factory of [AsyncValidator].
typedef AsyncValidatorFactory<T> = AsyncValidator<T> Function(
  BuildContext context,
);
