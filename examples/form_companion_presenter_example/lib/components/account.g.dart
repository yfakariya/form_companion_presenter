// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

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

String _$AccountPresenterTemplateHash() =>
    r'1850bac842a98a039a0edbda530d6abd752b50be';

/// Presenter which holds form properties.
///
/// Copied from [AccountPresenterTemplate].
final accountPresenterTemplateProvider = AutoDisposeAsyncNotifierProvider<
    AccountPresenterTemplate, $AccountPresenterTemplateFormProperties>(
  AccountPresenterTemplate.new,
  name: r'accountPresenterTemplateProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$AccountPresenterTemplateHash,
);
typedef AccountPresenterTemplateRef = AutoDisposeAsyncNotifierProviderRef<
    $AccountPresenterTemplateFormProperties>;

abstract class _$AccountPresenterTemplate
    extends AutoDisposeAsyncNotifier<$AccountPresenterTemplateFormProperties> {
  @override
  FutureOr<$AccountPresenterTemplateFormProperties> build();
}
