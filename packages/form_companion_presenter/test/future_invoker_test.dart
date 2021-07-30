// See LICENCE file in the root.

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/future_invoker.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';

class Parameter<T, P> implements AsyncOperationNotifier<T, P> {
  final String value;
  final Completer<T> completer = Completer();

  bool isOnCompletedCalled = false;
  final AsyncOperationCompletedCallback<T> _onCompleted;

  @override
  AsyncOperationCompletedCallback<T> get onCompleted => (r) {
        isOnCompletedCalled = true;
        _onCompleted(r);
      };

  bool isOnFailedCalled = false;
  final AsyncOperationFailedCallback _onFailed;

  @override
  AsyncOperationFailedCallback get onFailed => (e) {
        isOnFailedCalled = true;
        _onFailed(e);
      };

  bool isOnProgressCalled = false;
  final AsyncOperationProgressCallback<P> _onProgress;

  @override
  AsyncOperationProgressCallback<P> get onProgress => (p) {
        isOnProgressCalled = true;
        _onProgress(p);
      };

  Parameter({
    required this.value,
    AsyncOperationCompletedCallback<T>? onCompleted,
    AsyncOperationFailedCallback? onFailed,
    AsyncOperationProgressCallback<P>? onProgress,
  })  : _onCompleted = onCompleted ?? ((_) {}),
        _onFailed = onFailed ?? print,
        _onProgress = onProgress ?? ((_) {});

  @override
  String toString() => value;
}

class TestTarget<R, P> extends FutureInvoker<Parameter<R, P>, R, P> {
  final Future<R> Function(Parameter<R, P>) _callback;

  TestTarget({
    required Future<R> Function(Parameter<R, P>) callback,
    required R defaultResult,
    AsyncErrorHandler? canceledOperationErrorHandler,
    Equality<Parameter<R, P>>? parameterEquality,
    String? debugLabel,
  })  : _callback = callback,
        super(
          defaultResult: defaultResult,
          canceledOperationErrorHandler: canceledOperationErrorHandler,
          parameterEquality: parameterEquality ?? EqualityBy((p) => p.value),
          debugLabel: debugLabel,
        );

  @override
  Future<R> executeAsync(Parameter<R, P> parameter) {
    // This method is NOT async method to simulate synchronous error flow.
    Future<R> future;
    try {
      future = _callback(parameter);
    }
    // ignore: avoid_catches_without_on_clauses
    catch (error, stackTrace) {
      parameter.completer.completeError(error, stackTrace);
      rethrow;
    }

    // Use classic then to avoid async/await it postpones catch block even if
    // the exception is thrown synchronously from the target async method.
    return future.then((value) {
      parameter.completer.complete(value);
      return value;
    }).onError((error, stackTrace) {
      parameter.completer.completeError(error!, stackTrace);
      // rethrow.
      // ignore: only_throw_errors
      throw error;
    });
  }
}

void main() {
  // For debugging
  loggerSink = (
    name,
    level,
    message,
    zone,
    error,
    stackTrace,
  ) {
    String messageString;
    if (message is String Function()) {
      messageString = message();
    } else if (message is String) {
      messageString = message;
    } else {
      messageString = message?.toString() ?? '';
    }

    String errorString;
    if (error != null) {
      if (stackTrace != null) {
        errorString = ' $error\n$stackTrace';
      } else {
        errorString = ' $error';
      }
    } else {
      errorString = '';
    }

    printOnFailure('[${level.name}] $name: $messageString$errorString');
  };

  group(
    'FutureInvoker',
    () {
      group('execute', () {
        group('success', () {
          group('1 request is executed asynchronously and set to result.', () {
            Future doTest(Future<String> Function(String) future) async {
              String? result1;
              final parameter = Parameter<String, void>(
                  value: 'input', onCompleted: (r) => result1 = r);
              const expected = 'output';
              const defaultResult = 'default';

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  passed = p;
                  return future(expected);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              // Assert before the future
              expect(target.execute(parameter), equals(defaultResult));
              expect(target.status, equals(AsyncOperationStatus.inProgress));

              await parameter.completer.future;

              // Assert mock
              expect(passed, same(parameter));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.completed));

              // Assert callback behaviors
              expect(parameter.isOnCompletedCalled, isTrue);
              expect(parameter.isOnFailedCalled, isFalse);
              expect(parameter.isOnProgressCalled, isFalse);

              expect(result1, equals(expected));

              // We can get cached result.
              expect(target.execute(parameter), equals(expected));
              expect(target.status, equals(AsyncOperationStatus.completed));
            }

            test(
              'async',
              () => doTest(
                (r) => Future.delayed(Duration.zero, () => r),
              ),
            );

            test(
              'sync',
              () => doTest(
                (r) => Future.value(r),
              ),
            );
          });

          group(
              '2 request with diffrent parameter overrides and set to result.',
              () {
            Future doTest(Future<String> Function(String) future) async {
              String? result1;
              String? result2;
              final parameter1 = Parameter<String, void>(
                  value: 'input1', onCompleted: (r) => result1 = r);
              final parameter2 = Parameter<String, void>(
                  value: 'input2', onCompleted: (r) => result2 = r);
              const expected = 'output';
              const defaultResult = 'default';

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  printOnFailure('future called with $p');
                  passed = p;
                  return future(expected + p.value);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              // Assert before the future
              expect(target.execute(parameter1), equals(defaultResult));
              expect(target.status, equals(AsyncOperationStatus.inProgress));
              expect(target.execute(parameter2), equals(defaultResult));
              expect(target.status, equals(AsyncOperationStatus.inProgress));

              // Assert mock
              expect(passed, same(parameter1));

              printOnFailure('await parameter1.completer');
              await parameter1.completer.future;

              // Assert mock
              expect(passed, same(parameter2));

              printOnFailure('await parameter2.completer');
              await parameter2.completer.future;

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.completed));

              // Assert callback behaviors
              expect(parameter1.isOnCompletedCalled, isFalse);
              expect(parameter1.isOnFailedCalled, isFalse);
              expect(parameter1.isOnProgressCalled, isFalse);
              expect(parameter2.isOnCompletedCalled, isTrue);
              expect(parameter2.isOnFailedCalled, isFalse);
              expect(parameter2.isOnProgressCalled, isFalse);

              expect(result1, isNull);
              expect(result2, equals('$expected${parameter2.value}'));

              // We can get cached result.
              expect(target.execute(parameter2),
                  equals('$expected${parameter2.value}'));
              expect(target.status, equals(AsyncOperationStatus.completed));
            }

            test(
              'async',
              () => doTest(
                (r) => Future.delayed(
                  Duration.zero,
                  () => r,
                ),
              ),
            );
            test(
              'sync',
              () => doTest(
                (r) => Future.value(r),
              ),
            );
          });

          group(
              '2 request with same parameter only early one is executed and set to result.',
              () {
            Future doTest(Future<String> Function(String) future) async {
              String? result1;
              String? result2;
              String? result3;

              final parameter1 = Parameter<String, void>(
                  value: 'input1', onCompleted: (r) => result1 = r);
              final parameter2 = Parameter<String, void>(
                  value: 'input1', onCompleted: (r) => result2 = r);
              final parameter3 = Parameter<String, void>(
                  value: 'input2', onCompleted: (r) => result3 = r);
              const expected = 'output';
              const defaultResult = 'default';

              var called = 0;
              final target = TestTarget<String, void>(
                callback: (p) {
                  printOnFailure('future called with $p');
                  called++;
                  return future(expected + p.value);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              // Assert before the future
              expect(target.execute(parameter1), equals(defaultResult));
              expect(target.status, equals(AsyncOperationStatus.inProgress));
              expect(target.execute(parameter2), equals(defaultResult));
              expect(target.status, equals(AsyncOperationStatus.inProgress));

              printOnFailure('await parameter1.completer');
              await parameter1.completer.future;

              // Note that parameter2.completer should never signaled.
              // Assert counter -- 1 rather than 2 because parameter2 was ignored.
              expect(called, equals(1));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.completed));

              // Assert callback behaviors
              expect(parameter1.isOnCompletedCalled, isTrue);
              expect(parameter1.isOnFailedCalled, isFalse);
              expect(parameter1.isOnProgressCalled, isFalse);
              expect(parameter2.isOnCompletedCalled, isFalse);
              expect(parameter2.isOnFailedCalled, isFalse);
              expect(parameter2.isOnProgressCalled, isFalse);

              expect(result1, equals('$expected${parameter1.value}'));
              expect(result2, isNull);

              // We can get cached result.
              expect(target.execute(parameter2),
                  equals('$expected${parameter2.value}'));

              // These extra invocation actually 2 cases
              // 1) parameter2 is not executed rather than just waited to be
              //    called by assert that parameter3 is called.
              // 2) the FutureInvoker can handle additional execute() call,
              //    inProgress -> completed state transition.

              expect(target.execute(parameter3),
                  equals('$expected${parameter2.value}'));
              expect(target.status, equals(AsyncOperationStatus.inProgress));

              printOnFailure('await parameter3.completer');
              await parameter3.completer.future;

              // Assert counter -- 2 rather than 3 because parameter2 was ignored.
              expect(called, equals(2));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.completed));

              // Assert callback behaviors
              expect(parameter1.isOnCompletedCalled, isTrue);
              expect(parameter1.isOnFailedCalled, isFalse);
              expect(parameter1.isOnProgressCalled, isFalse);
              expect(parameter2.isOnCompletedCalled, isFalse);
              expect(parameter2.isOnFailedCalled, isFalse);
              expect(parameter2.isOnProgressCalled, isFalse);
              expect(parameter3.isOnCompletedCalled, isTrue);
              expect(parameter3.isOnFailedCalled, isFalse);
              expect(parameter3.isOnProgressCalled, isFalse);

              expect(result3, equals('$expected${parameter3.value}'));

              // We can get cached result.
              expect(target.execute(parameter3),
                  equals('$expected${parameter3.value}'));
              expect(target.status, equals(AsyncOperationStatus.completed));
            }

            test(
              'async',
              () => doTest(
                (r) => Future.delayed(
                  Duration.zero,
                  () => r,
                ),
              ),
            );
            test(
              'sync',
              () => doTest(
                (r) => Future.value(r),
              ),
            );
          });
        });

        group('failure', () {
          group('1 request is executed asynchronously and remember exception.',
              () {
            Future doTest(Future<String> Function(Exception) future) async {
              AsyncError? failure1;
              final parameter = Parameter<String, void>(
                  value: 'input', onFailed: (f) => failure1 = f);
              const defaultResult = 'default';
              final error = Exception('DUMMY');

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  passed = p;
                  return future(error);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              // Assert before the future
              try {
                expect(target.execute(parameter), equals(defaultResult));
                // in async error, this try should not throw any exception here.
                expect(target.status, equals(AsyncOperationStatus.inProgress));
              }
              // ignore: avoid_catching_errors
              on AsyncError catch (e) {
                // in sync error, this catch will be fired.
                expect(e.error, same(error));
                expect(target.status, equals(AsyncOperationStatus.failed));
              }

              printOnFailure('${target.status}');
              try {
                await parameter.completer.future;
                fail('No exception thrown.');
              } on Exception catch (e) {
                expect(e, same(error));
              }

              // Assert mock
              expect(passed, same(parameter));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.failed));

              // Assert callback behaviors
              expect(parameter.isOnCompletedCalled, isFalse);
              expect(parameter.isOnFailedCalled, isTrue);
              expect(parameter.isOnProgressCalled, isFalse);

              expect(failure1, isNotNull);
              expect(failure1?.error, isNotNull);
              expect(failure1?.stackTrace, isNotNull);
              expect(failure1?.error, same(error));

              // We can get cached exception.

              try {
                target.execute(parameter);
              }
              // ignore: avoid_catching_errors
              on AsyncError catch (e) {
                expect(e, isA<AsyncError>());
                expect(e.error, same(error));
                expect(e.stackTrace, isNotNull);
              }

              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            test(
              'async',
              () => doTest(
                (e) async {
                  await Future<void>.delayed(Duration.zero, () => throw e);
                  return 'ERROR';
                },
              ),
            );

            test(
              'sync',
              () => doTest(
                (e) {
                  throw e;
                },
              ),
            );
          });
        });

        // TODO(yfakariya): failed -> failed -> throw
        // TODO(yfakariya): failed -> throw
        // TODO(yfakariya): failed -> inprogress

        // TODO(yfakariya): equality

        // TODO(yfakariya): reset
        //   cases
        // TODO(yfakariya): cancel
        //   cases
        //   canceledErrorHandler
      });
    },
  );
}
