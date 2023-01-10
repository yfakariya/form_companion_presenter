// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manual_validation_form_builder_account.dart';

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

String _$ManualValidationFormBuilderAccountPresenterHash() =>
    r'5b18a4fbabc7dcf760fb3918a8b88ec56b43a692';

/// Presenter which holds form properties.
///
/// Copied from [ManualValidationFormBuilderAccountPresenter].
final manualValidationFormBuilderAccountPresenterProvider =
    AutoDisposeAsyncNotifierProvider<
        ManualValidationFormBuilderAccountPresenter,
        $ManualValidationFormBuilderAccountPresenterFormProperties>(
  ManualValidationFormBuilderAccountPresenter.new,
  name: r'manualValidationFormBuilderAccountPresenterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ManualValidationFormBuilderAccountPresenterHash,
);
typedef ManualValidationFormBuilderAccountPresenterRef
    = AutoDisposeAsyncNotifierProviderRef<
        $ManualValidationFormBuilderAccountPresenterFormProperties>;

abstract class _$ManualValidationFormBuilderAccountPresenter
    extends AutoDisposeAsyncNotifier<
        $ManualValidationFormBuilderAccountPresenterFormProperties> {
  @override
  FutureOr<$ManualValidationFormBuilderAccountPresenterFormProperties> build();
}
