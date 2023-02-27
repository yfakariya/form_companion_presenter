// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$accountStateHash() => r'09d375327090a1b22de95a5dbb5b3ef9d1c99a41';

/// Application wide state of [Account].
///
/// Copied from [AccountState].
@ProviderFor(AccountState)
final accountStateProvider =
    AsyncNotifierProvider<AccountState, Account>.internal(
  AccountState.new,
  name: r'accountStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$accountStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountState = AsyncNotifier<Account>;
String _$bookingStateHash() => r'4a43a0f42772b6b7d3b2f56555d7f18bbb32fbcf';

/// Application wide state of [Booking].
///
/// Copied from [BookingState].
@ProviderFor(BookingState)
final bookingStateProvider =
    AsyncNotifierProvider<BookingState, Booking>.internal(
  BookingState.new,
  name: r'bookingStateProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$bookingStateHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$BookingState = AsyncNotifier<Booking>;
// ignore_for_file: unnecessary_raw_strings, subtype_of_sealed_class, invalid_use_of_internal_member, do_not_use_environment, prefer_const_constructors, public_member_api_docs, avoid_private_typedef_functions
