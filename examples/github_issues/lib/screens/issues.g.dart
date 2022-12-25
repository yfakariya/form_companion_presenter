// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issues.dart';

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

String $IssuesPresenterHash() => r'b8e4d3619f653b2a24168a788034581f186b38d8';

/// See also [IssuesPresenter].
final issuesPresenterProvider =
    NotifierProvider<IssuesPresenter, IssuesSearchCondition>(
  IssuesPresenter.new,
  name: r'issuesPresenterProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : $IssuesPresenterHash,
);
typedef IssuesPresenterRef = NotifierProviderRef<IssuesSearchCondition>;

abstract class _$IssuesPresenter extends Notifier<IssuesSearchCondition> {
  @override
  IssuesSearchCondition build();
}

String $issuesHash() => r'148238ce913c5d9524efbdf6d935d9c1f236e9a4';

/// See also [issues].
final issuesProvider = AutoDisposeFutureProvider<List<Issue>>(
  issues,
  name: r'issuesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : $issuesHash,
);
typedef IssuesRef = AutoDisposeFutureProviderRef<List<Issue>>;
