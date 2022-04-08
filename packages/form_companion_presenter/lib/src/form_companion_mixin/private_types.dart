// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Represents a node of "async validation context" state automaton.
enum _ValidationContext {
  unspecified,
  doValidationOnSubmit,
  confirmingResult,
}

/// A function which is an entry of an async validation chain.
typedef _ChainedAsyncValidation<T extends Object> = String? Function(
  T? value,
  String? result,
  AsyncError? error, {
  required bool isSync,
});

/// A function which returns appropriate error message from [AsyncError].
typedef _AsyncValidationFailureMessageProvider = String Function(
  AsyncError error,
  Locale locale,
);

/// A function which returns current [_ValidationContext] from appropriate storage.
typedef _ValidationContextProvider = _ValidationContext Function();

/// A function which stores specified [_ValidationContext] to appropriate storage.
typedef _ValidationContextSupplier = void Function(_ValidationContext context);
