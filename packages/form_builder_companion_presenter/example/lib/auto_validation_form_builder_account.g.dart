// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auto_validation_form_builder_account.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// ignore_for_file: avoid_private_typedef_functions, non_constant_identifier_names, subtype_of_sealed_class, invalid_use_of_internal_member, unused_element, constant_identifier_names, unnecessary_raw_strings, library_private_types_in_public_api

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

String _$AutoValidationFormBuilderAccountPresenterHash() =>
    r'fc52f087f86f94933b8072c12404133c76e58d2c';

/// Presenter which holds form properties.
///
/// Copied from [AutoValidationFormBuilderAccountPresenter].
final autoValidationFormBuilderAccountPresenterProvider =
    AutoDisposeAsyncNotifierProvider<AutoValidationFormBuilderAccountPresenter,
        $AutoValidationFormBuilderAccountPresenterFormProperties>(
  AutoValidationFormBuilderAccountPresenter.new,
  name: r'autoValidationFormBuilderAccountPresenterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$AutoValidationFormBuilderAccountPresenterHash,
);
typedef AutoValidationFormBuilderAccountPresenterRef
    = AutoDisposeAsyncNotifierProviderRef<
        $AutoValidationFormBuilderAccountPresenterFormProperties>;

abstract class _$AutoValidationFormBuilderAccountPresenter
    extends AutoDisposeAsyncNotifier<
        $AutoValidationFormBuilderAccountPresenterFormProperties> {
  @override
  FutureOr<$AutoValidationFormBuilderAccountPresenterFormProperties> build();
}
