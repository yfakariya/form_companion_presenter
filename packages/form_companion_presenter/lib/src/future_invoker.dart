// See LICENCE file in the root.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'internal_utils.dart';

/// Helps distinction between "set" null-value and "not set" any value for
/// nullable type.
@sealed
class _NullableValueHolder<T> {
  /// Value itself.
  ///
  /// Note that [value] can be `null` when [T] is nullable.
  final T value;

  /// Creates new [_NullableValueHolder].
  ///
  /// Note that [value] can be `null` when [T] is nullable.
  _NullableValueHolder(this.value);
}

/// Represents status of asynchronous operation.
enum AsyncOperationStatus {
  /// [FutureInvoker] is initialized, but any asynchronous operations have not
  /// been started yet.
  initial,

  /// The asynchronous operation is in progress.
  /// Note that there may be pending additional request on queue.
  inProgress,

  /// Some asynchronous operations have been completed, and last one was
  /// completed successfully, so the [FutureInvoker] will return cached
  /// last operation result for identical parameter value.
  completed,

  /// Some asynchronous operations have been completed, and last one was
  /// failed with error, so the [FutureInvoker] will throw [AsyncError] which
  /// was thrown by last operation for identical parameter value.
  failed,
}

/// Holds last async operation states.
class _AsyncOperationState<P, R> {
  /// Cached parameter. `null` when no last execution, that is, [status] is
  /// [AsyncOperationStatus.initial].
  final _NullableValueHolder<P>? parameter;

  /// Last result. This value only valid iff [parameter] is not `null` and
  /// [error] is `null`, that is, [status] is [AsyncOperationStatus.completed]
  /// or [AsyncOperationStatus.inProgress].
  /// This value will be "default result" if [status] is not
  /// [AsyncOperationStatus.completed].
  final R? result;

  /// Last execution error. `null` when succeeded or not executed at all,
  /// that is, [status] is not [AsyncOperationStatus.failed].
  final AsyncError? error;

  /// [AsyncOperationStatus] describes the status of this state.
  final AsyncOperationStatus status;

  _AsyncOperationState(
    this.result,
    this.error,
    this.parameter,
    this.status,
  );

  factory _AsyncOperationState.completed(
    P parameter,
    R? result,
  ) =>
      _AsyncOperationState(
        result,
        null,
        _NullableValueHolder(parameter),
        AsyncOperationStatus.completed,
      );

  factory _AsyncOperationState.failed(
    P parameter,
    AsyncError error,
  ) =>
      _AsyncOperationState(
        null,
        error,
        _NullableValueHolder(parameter),
        AsyncOperationStatus.failed,
      );

  factory _AsyncOperationState.initial(
    R? defaultResult,
  ) =>
      _AsyncOperationState(
        defaultResult,
        null,
        null,
        AsyncOperationStatus.initial,
      );

  factory _AsyncOperationState.inProgress(
    P parameter,
    R? lastResultOrDefault,
  ) =>
      _AsyncOperationState(
        lastResultOrDefault,
        null,
        _NullableValueHolder(parameter),
        AsyncOperationStatus.inProgress,
      );
}

/// Context information of [AsyncOperationFailedCallback] to handle failed
/// asynchronous execution result.
@sealed
class AsyncInvocationFailureContext<T> {
  /// An [AsyncError] caused asynchronously.
  final AsyncError error;
  bool _isReplaced = false;
  late T _replacedResult;

  AsyncInvocationFailureContext._(this.error);

  /// Initializes a new instance of [AsyncInvocationFailureContext] with
  /// actually thrown [AsyncError].
  factory AsyncInvocationFailureContext.withError(AsyncError error) =>
      AsyncInvocationFailureContext._(error);

  /// Overrides this asynchronous error result with specified result.
  void overrideError(T result) {
    _isReplaced = true;
    _replacedResult = result;
  }
}

/// Callback for [AsyncError] handling.
/// The parameter is [AsyncError] which is thrown by asynchronous operation.
typedef AsyncErrorHandler = void Function(AsyncError error);

/// Callback which called when async operation is completed successfully
/// The parameter is [T] which is asynchronous operation result.
@optionalTypeArgs
typedef AsyncOperationCompletedCallback<T> = void Function(T result);

/// Callback which called when async operation is failed with error.
typedef AsyncOperationFailedCallback = void Function(AsyncError failure);

/// Callback which called periodically in the implementation specific frequency
/// when async operation is progress some degree.
/// The parameter is [P] which represents some object to represent the progress.
/// It may tell degree of progress with percentage [int], [double] representing
/// completion ratio, or [String] describing qualitative status.
/// It might have additional information to help to discrimination among
/// concurrent operations by caller.
@optionalTypeArgs
typedef AsyncOperationProgressCallback<P> = void Function(P progress);

/// Callback which called when async operation is failed with error.
/// The parameter is [AsyncInvocationFailureContext] to handle the error.
typedef AsyncOperationFailureHandler<T> = void Function(
    AsyncInvocationFailureContext<T> failure);

/// Defines interface which is the parameter of [FutureInvoker.execute] method
/// must implement to notify asynchronous operation status.
@optionalTypeArgs
abstract class AsyncOperationNotifier<R, P> {
  /// Called when the asynchronous operation completed successfully.
  /// This call back will be called by [FutureInvoker],
  /// so the asynchronous operation should not call this callback.
  AsyncOperationCompletedCallback<R> get onCompleted;

  /// Called when the asynchronous operation completed with failure.
  /// This call back will be called by [FutureInvoker],
  /// so the asynchronous operation should not call this callback.
  AsyncOperationFailedCallback get onFailed;

  /// Called when the asynchronous operation have some progress.
  /// This call back will not be called by [FutureInvoker],
  /// so the asynchronous operation should call this callback its own timings,
  /// and it is OK to avoid calling this callback at all.
  /// The parameter type and its values are determined by asynchronous
  /// operation, it should tells progress degreen in quantitive or qualitative,
  /// and any extra information including the label to distinguish among
  /// concurrent asynchronous operations by caller (that is, callback receiver).
  AsyncOperationProgressCallback<P> get onProgress;

  /// Called when the asynchronous operation failed with error.
  /// This call back will be called by [FutureInvoker],
  /// so the asynchronous operation should not call this callback.
  ///
  /// This handler can override the error with complemental result via
  /// [AsyncInvocationFailureContext.overrideError].
  AsyncOperationFailureHandler<R> get failureHandler;
}

/// A simple pair of parameter and result.
class _ParameterAndResult<T, R> {
  final T parameter;
  final R result;

  _ParameterAndResult(this.parameter, this.result);
}

/// Turns [Future] based async operation to callback based state machine.
///
/// [T] is type of a parameter for [execute], which must implement
/// [AsyncOperationNotifier] with [R] and [P].
/// [R] is result type of the asynchronous operation.
/// [P] is type of progress report.
///
/// Most of widget does not handle [Future] gracefully,
/// so, this class helps translated [Future] based asynchronous operation
/// to callback based notification.
abstract class FutureInvoker<T extends AsyncOperationNotifier<R, P>, R, P> {
  /// Internal logger facade.
  late Logger _log;

  /// Callback for error in canceled operation.
  final AsyncErrorHandler? _canceledOperationErrorHandler;

  /// [Equality] to determine cache hit logic.
  final Equality<T?> _parameterEquality;

  /// Default result for initial (including after reset),
  /// and in-progress immediate after the failed result.
  final R _defaultResult;

  /// "Queued" next operation request. `null` for no pending request.
  _NullableValueHolder<T>? _nextValue;

  /// Processing operation. `null` means:
  /// * This "thread" should call asynchronous operation in before execution.
  /// * The asynchronous operation was canceled in after execution.
  _NullableValueHolder<T>? _processingValue;

  /// Last state for cancellation.
  late _AsyncOperationState<T, R> _lastState;

  /// Overall state.
  _AsyncOperationState<T, R> _state;

  /// [AsyncOperationStatus] of this invoker.
  AsyncOperationStatus get status => _state.status;

  /// Creates new [FutureInvoker].
  ///
  /// The [defaultResult] is logical default result of this operation.
  /// This value will be returned from [execute]
  /// until the async operation completion.
  ///
  /// The [canceledOperationErrorHandler] is a callback which is called
  /// when the pending operation is canceled via [cancel] or [reset] and
  /// the operation failed with error.
  /// You can use the handler to handle error such as error logging to improve
  /// product quality.
  ///
  /// [debugLabel] will be used as internal logger name, it will be passed as
  /// `name` parameter of [loggerSink]. Default is a string representation of
  /// [runtimeType].
  FutureInvoker({
    required R defaultResult,
    AsyncErrorHandler? canceledOperationErrorHandler,
    Equality<T> parameterEquality = const Equality(),
    String? debugLabel,
  })  : _defaultResult = defaultResult,
        _canceledOperationErrorHandler = canceledOperationErrorHandler,
        _parameterEquality = parameterEquality,
        _state = _AsyncOperationState.initial(defaultResult) {
    _log = Logger(name: debugLabel ?? runtimeType.toString());
    _lastState = _state;
  }

  bool _isAlreadyHandled(T? parameter) {
    final lastParameter = _state.parameter;
    if (lastParameter == null) {
      // first
      return false;
    }

    return _parameterEquality.equals(lastParameter.value, parameter);
  }

  /// Execute the asynchronous operation.
  ///
  /// This method behaves differently for past [execute] call and its result.
  /// If the past operation with same [parameter] was completed successfully,
  /// this method returns its result.
  /// If the past operation with same [parameter] was failed with error,
  /// this method throws it as [AsyncError].
  /// If the past operation with same [parameter] is still in-progress,
  /// this method do nothing and returns "initial value".
  /// Else, this method initiate async operation (call [executeAsync]),
  /// and returns "initial value".
  ///
  /// Note that you can change the state with [reset] or [cancel] method.
  /// In addition, this method debounces continous execution. Specifically,
  /// it logically holds deque of requests and pops only the last one.
  ///
  /// Note that the result of [executeAsync] is always spawn asynchronously.
  /// That means even if the [executeAsync] itself throws exception before any
  /// await expression, [status] property will be changed to
  /// [AsyncOperationStatus.failed] in next event loop. So, the result never
  /// be observed before any awaiting.
  @nonVirtual
  R? execute(T parameter) {
    switch (_state.status) {
      case AsyncOperationStatus.completed:
        if (_isAlreadyHandled(parameter)) {
          _log.fine(() =>
              'Async operation result for parameter $parameter is cached.');
          return _state.result;
        }
        break;
      case AsyncOperationStatus.failed:
        if (_isAlreadyHandled(parameter)) {
          _log.fine(() =>
              'Async operation error for parameter $parameter is cached.');
          throw _state.error!;
        }
        break;
      case AsyncOperationStatus.initial:
        break;
      case AsyncOperationStatus.inProgress:
        if (_isAlreadyHandled(parameter)) {
          _log.fine(() =>
              'Async operation result for parameter $parameter is in progress, returns cached value.');
          // Do nothing
          return _state.result;
        }

        break;
    }

    final shouldInvoke = _processingValue == null;
    _nextValue = _NullableValueHolder(parameter);
    if (shouldInvoke) {
      _log.fine(() => 'Begin async operation.');
      _executeAsync();
    }

    final synchronousError = _state.error;
    if (synchronousError != null) {
      // If executeAsync() throws exception synchronously,
      // the thrown error is catched and cached.
      // So throw it now.
      throw synchronousError;
    }

    _log.fine(() => 'Returns default result.');
    // Returns "initial value".
    return _state.result;
  }

  /// Resets this operation state to initial state
  /// with specified new initial value.
  ///
  /// Note that this method cancels pending operation.
  /// If the pending operation fails in the future,
  /// `canceledOperationErrorHandler`, which was passed in constructor,
  /// will be called.
  ///
  /// This method causes value change notification.
  @nonVirtual
  void reset(R? newDefaultResult) {
    _processingValue = null;
    _nextValue = null;
    _state = _AsyncOperationState.initial(newDefaultResult);
    _lastState = _state;
    _log.fine(() => 'Reset with new default result "$newDefaultResult".');
  }

  /// Cancels pending operation.
  ///
  /// If the pending operation fails in the future,
  /// `canceledOperationErrorHandler`, which was passed in constructor,
  /// will be called.
  /// This method do nothing when the pending operation does not exist.
  ///
  /// This method causes value change notification.
  void cancel() {
    _processingValue = null;
    _state = _lastState;
    _log.fine(() => 'Cancel asynchronous operation.');
  }

  // The catch clause should catch every exception.
  // ignore: avoid_void_async
  void _executeAsync() async {
    _ParameterAndResult<T, R>? finalSuccessfulState;
    for (var parameter = _processingValue = _nextValue;
        parameter != null;
        parameter = _processingValue = _nextValue) {
      try {
        finalSuccessfulState = null;
        _state = _AsyncOperationState.inProgress(
          parameter.value,
          _defaultResult,
        );
        _nextValue = null;
        _log.fine(
            () => 'Executing asynchronous operation with ${parameter?.value}.');

        final result = await executeAsync(parameter.value);

        if (_processingValue != parameter) {
          _log.fine(() =>
              'Executed asynchronous operation with parameter "${parameter?.value}" but it was canceled, so discard result "$result".');
          return;
        }

        finalSuccessfulState = _ParameterAndResult(parameter.value, result);
        _log.fine(() =>
            'Executed asynchronous operation with parameter "${parameter?.value}", result is "$result", check next request.');
      }
      // "executeAsync" may throw any exception, so catch-all is required here.
      // ignore: avoid_catches_without_on_clauses
      catch (error, stackTrace) {
        // CAUTION: This catch clause ALWAYS executed in next event of the
        //          eventloop even if `executeAsync` threw an exception
        //          synchronously.

        final asyncError = AsyncError(error, stackTrace);
        // _processingValue may be set to null before "await executeAsync" line
        // returns.
        // ignore: invariant_booleans
        if (_processingValue == null) {
          _log.warning(
            () =>
                'Asynchronous operation with parameter "${parameter?.value}" failed but it was canceled, so try to call canceled operation error handler.',
            error: error,
            stackTrace: stackTrace,
          );
          _canceledOperationErrorHandler?.call(asyncError);
          return;
        } else {
          _log.warning(
            () =>
                'Asynchronous operation with parameter "${parameter?.value}" failed.',
            error: error,
            stackTrace: stackTrace,
          );

          final context =
              AsyncInvocationFailureContext<R>.withError(asyncError);
          parameter.value.failureHandler(context);
          if (context._isReplaced) {
            _log.fine(
              () =>
                  'Asynchronous failure has been overriden: ${context._replacedResult}',
            );
            _state = _AsyncOperationState.completed(
              parameter.value,
              context._replacedResult,
            );
          } else {
            _state = _AsyncOperationState.failed(
              parameter.value,
              asyncError,
            );
          }
          _lastState = _state;

          if (context._isReplaced) {
            parameter.value.onCompleted(context._replacedResult);
          } else {
            parameter.value.onFailed(asyncError);
          }
        }
      }
    }

    // Below lines should not throw anything except fatal runtime errors.
    if (finalSuccessfulState != null) {
      _log.fine(() =>
          'All requested asynchronous operations are done. Last result with parameter "${finalSuccessfulState?.parameter}" is "${finalSuccessfulState?.result}".');

      _state = _AsyncOperationState.completed(
        finalSuccessfulState.parameter,
        finalSuccessfulState.result,
      );
      _lastState = _state;
      // This line may throw exception, but it should be treated as "unhandled"
      // rather than be treated as an async error.
      finalSuccessfulState.parameter.onCompleted(finalSuccessfulState.result);
    }
  }

  /// Do actual asynchronous operation.
  /// Note that the override can call [AsyncOperationNotifier.onProgress] in
  /// arbitrary timings and frequrencies.
  @protected
  @visibleForOverriding
  FutureOr<R> executeAsync(T parameter);
}
