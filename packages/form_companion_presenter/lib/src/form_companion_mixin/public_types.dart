// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Options for validator factories.
@sealed
class ValidatorCreationOptions {
  /// [BuildContext] which is set when validator factories are called.
  final BuildContext context;

  /// [Locale] which is set when validator factories are called.
  final Locale locale;

  ValidatorCreationOptions._(this.context, this.locale);
}

/// Creates [ValidatorCreationOptions] for testing.
@visibleForTesting
ValidatorCreationOptions createValidatorCreationOptions(
  BuildContext context,
  Locale? locale,
) =>
    ValidatorCreationOptions._(context, locale ?? defaultLocale);

/// Signature for factory of [FormFieldValidator].
typedef FormFieldValidatorFactory<T> = FormFieldValidator<T> Function(
  ValidatorCreationOptions options,
);

/// Signature for factory of [AsyncValidator].
typedef AsyncValidatorFactory<T> = AsyncValidator<T> Function(
  ValidatorCreationOptions options,
);
