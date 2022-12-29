// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

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

String _$AccountStateHash() => r'e41b7ba7c76fdd643563be2a7c96f07d475e5eab';

/// Application wide state of [Account].
///
/// Copied from [AccountState].
final accountStateProvider = AsyncNotifierProvider<AccountState, Account>(
  AccountState.new,
  name: r'accountStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$AccountStateHash,
);
typedef AccountStateRef = AsyncNotifierProviderRef<Account>;

abstract class _$AccountState extends AsyncNotifier<Account> {
  @override
  FutureOr<Account> build();
}

String _$BookingStateHash() => r'4f99989966c53acb55425b3a217aee428923d60c';

/// Application wide state of [Booking].
///
/// Copied from [BookingState].
final bookingStateProvider = AsyncNotifierProvider<BookingState, Booking>(
  BookingState.new,
  name: r'bookingStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$BookingStateHash,
);
typedef BookingStateRef = AsyncNotifierProviderRef<Booking>;

abstract class _$BookingState extends AsyncNotifier<Booking> {
  @override
  FutureOr<Booking> build();
}
