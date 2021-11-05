// See LICENCE file in the root.

import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'future_invoker.dart';

/// Options for asyncronous validators.
@sealed
class AsyncValidatorOptions {
  /// [Locale] which is used to localize validation message.
  /// Caller must specify valid locale.
  /// You can get current [Locale] via
  /// [Localizations.mayBeLocaleOf([BuildContext])]. If the returned [Locale] is
  /// `null`, you must specify appropriate locale like `Locale('en', 'US')` or
  /// your primary users' locale.
  final Locale locale;

  AsyncValidatorOptions._({required this.locale});
}

/// A function represents async validation invocation.
///
/// It takes target [value], which may be `null`,
/// and then returns validation error message if the value is not valid,
/// or returns `null` if the value is valid.
///
/// [options] is [AsyncValidatorOptions] which has options for validators
/// such as [Locale] to localize error message.
typedef AsyncValidator<T> = FutureOr<String?> Function(
  T? value,
  AsyncValidatorOptions options,
);

/// Represents asynchronous validation invocation.
///
/// This class defines callbacks to compliant with [AsyncOperationNotifier]
/// which is required from [FutureInvoker].
class ValidationInvocation<T> implements AsyncOperationNotifier<String?, void> {
  /// Actual validating value.
  final T value;

  /// Validation logic, which accepts value and `onProgress` callback.
  ///
  /// Note that the validator may be needed to instantiated within widget build
  /// process because some validators depend on build context for message
  /// localization (current locale is often stored in build context).
  /// So, [ValidationInvocation] also holds current [validator] as parameter
  /// for [FutureInvoker.execute] method instead of storing [validator] in
  /// field of [AsyncValidatorExecutor] instance.
  final AsyncValidator<T> validator;

  /// Current [Locale] to localize validation message.
  final Locale locale;

  @override
  final AsyncOperationCompletedCallback<String?> onCompleted;

  @override
  final AsyncOperationFailedCallback onFailed;

  @override
  final AsyncOperationFailureHandler<String?> failureHandler;

  @Deprecated('ValidationInvocation does not support onProgress')
  @nonVirtual
  @override
  @protected
  @visibleForTesting
  final AsyncOperationProgressCallback<void> onProgress;

  /// Creates a new [ValidationInvocation].
  ///
  /// You can avoid explicit instantiation with
  /// [AsyncValidatorExecutor.validate].
  ValidationInvocation({
    required this.validator,
    required this.value,
    required this.locale,
    required this.onCompleted,
    required this.onFailed,
    required this.failureHandler,
  }) :
        // ignore: deprecated_member_use_from_same_package
        onProgress = ((_) {});

  @override
  String toString() => "Instance of 'ValidationInvocation<$T>' ($value)";
}

/// Callback of completion of [AsyncValidator].
typedef AsyncValidationCompletionCallback = void Function(
  String? result,
  AsyncError? error,
);

/// Callback of exceptional completion of [AsyncValidatorExecutor.validate].
/// You can change the exception or error via [AsyncInvocationFailureContext.overrideError].
typedef AsyncValidationFailureHandler = void Function(
  AsyncInvocationFailureContext<String?> context,
);

/// Handles asynchronous ([Future] based) validation logic.
class AsyncValidatorExecutor<T extends Object>
    extends FutureInvoker<ValidationInvocation<T?>, String?, void> {
  /// Indicates that whether this executor validating asynchronously or not.
  @nonVirtual
  bool get validating => status == AsyncOperationStatus.inProgress;

  /// Creates a new [AsyncValidatorExecutor].
  ///
  /// [equality] is equality comparison logic for validating value.
  /// Default is the result of [Equality()] const constructor.
  ///
  /// [canceledValidationErrorHandler] is optional handler which handles
  /// [AsyncError] thrown by "canceled" operation.
  /// The handler should do application specific error handling like error
  /// logging or reporting. Note that most users do not have any interest about
  /// error for canceled validation.
  ///
  /// [debugLabel] will be used as internal logger name, it will be passed as
  /// `name` parameter of `loggerSink`. Default is a string representation of
  /// [runtimeType].
  AsyncValidatorExecutor({
    Equality<T?>? equality,
    AsyncErrorHandler? canceledValidationErrorHandler,
    String? debugLabel,
  }) : super(
          defaultResult: null,
          parameterEquality: EqualityBy<ValidationInvocation<T?>, T?>(
            (x) => x.value,
            equality ?? const Equality(),
          ),
          canceledOperationErrorHandler: canceledValidationErrorHandler,
          debugLabel: debugLabel,
        );

  @override
  FutureOr<String?> executeAsync(ValidationInvocation<T?> parameter) =>
      parameter.validator(
        parameter.value,
        AsyncValidatorOptions._(locale: parameter.locale),
      );

  /// Validates specified value with specified [AsyncValidator] and [Locale].
  ///
  /// [locale] should be retrieved from [BuildContext] with appropriate way
  /// depends on localization framework which you use.
  /// Unfortunately, [AsyncValidatorExecutor] cannot guess your default locale.
  ///
  /// [onCompleted] will be called when the validation will be done.
  /// The parameter is validation message, which will be `null` if there will
  /// be no validation errors.
  /// Note that this callback will be called when the validation is NOT
  /// completed with unexpected error. In the case, the `error` parameter will
  /// not be `null`, and the value of `result` parameter will be string
  /// representation of the `error`.
  ///
  /// This method just calls [execute].
  @nonVirtual
  String? validate({
    required AsyncValidator<T> validator,
    required T? value,
    required Locale locale,
    required AsyncValidationCompletionCallback onCompleted,
    required AsyncValidationFailureHandler failureHandler,
  }) =>
      execute(
        ValidationInvocation<T?>(
          validator: validator,
          value: value,
          locale: locale,
          onCompleted: (v) => onCompleted(v, null),
          onFailed: (e) => onCompleted(null, e),
          failureHandler: failureHandler,
        ),
      );
}
