// See LICENCE file in the root.

import 'dart:async';
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

import 'future_invoker.dart';

/// A function represents async validation invocation.
///
/// It takes target [value], which may be `null`,
/// and then returns validation error message if the value is not valid,
/// or returns `null` if the value is valid.
///
/// [locale] is [Locale] which is used to localize validation message.
/// Caller must specify valid locale.
/// You can get current [Locale] via
/// [Localizations.mayBeLocaleOf([BuildContext])]. If the returned [Locale] is
/// `null`, you must specify appropriate locale like `Locale('en', 'US')` or
/// your primary users' locale.
///
/// [onProgress] is callback to be used to report progress for caller.
/// This type is application specific.
/// You can use the callback to indicate progress status of multi-step
/// asynchronous validation.
/// If you cannot report any meaningful progress, you can completely ignore
/// progress reporting and specify `dynamic`, [Null], or [void] for [P].
typedef AsyncValidator<T, P> = Future<String?> Function(
  T? value,
  Locale locale,
  AsyncOperationProgressCallback<P> onProgress,
);

/// Represents asynchronous validation invocation.
///
/// This class defines callbacks to compliant with [AsyncOperationNotifier]
/// which is required from [FutureInvoker].
class ValidationInvocation<T, P> implements AsyncOperationNotifier<String?, P> {
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
  final AsyncValidator<T, P> validator;

  /// Current [Locale] to localize validation message.
  final Locale locale;

  @override
  final AsyncOperationCompletedCallback<String?> onCompleted;

  @override
  final AsyncOperationFailedCallback onFailed;

  @override
  final AsyncOperationProgressCallback<P> onProgress;

  /// Creates a new [ValidationInvocation].
  ///
  /// You can avoid explicit instantiation with
  /// [AsyncValidatorExecutor.validate].
  ValidationInvocation({
    required this.validator,
    required this.value,
    required this.locale,
    required this.onCompleted,
    AsyncOperationFailedCallback? onFailed,
    AsyncOperationProgressCallback? onProgress,
  })  : onFailed = onFailed ?? ((_) {}),
        onProgress = onProgress ?? ((_) {});
}

/// Handles asynchronous ([Future] based) validation logic.
class AsyncValidatorExecutor<T, P>
    extends FutureInvoker<ValidationInvocation<T?, P>, String?, void> {
  /// Indicates that whether this executor validating asynchronously or not.
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
          parameterEquality: EqualityBy<ValidationInvocation<T?, P>, T?>(
            (x) => x.value,
            equality ?? const Equality(),
          ),
          canceledOperationErrorHandler: canceledValidationErrorHandler,
          debugLabel: debugLabel,
        );

  @override
  Future<String?> executeAsync(ValidationInvocation<T?, P> parameter) =>
      parameter.validator(
        parameter.value,
        parameter.locale,
        parameter.onProgress,
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
  ///
  /// This method just calls [execute].
  String? validate({
    required AsyncValidator<T, P> validator,
    required T? value,
    required Locale locale,
    required AsyncOperationCompletedCallback<String?> onCompleted,
  }) =>
      execute(
        ValidationInvocation(
          validator: validator,
          value: value,
          locale: locale,
          onCompleted: onCompleted,
        ),
      );
}
