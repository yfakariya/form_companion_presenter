// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/future_invoker.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';
import 'package:meta/meta.dart';

class Parameter<T, P> implements AsyncOperationNotifier<T, P> {
  final String value;
  final Completer<T> completer = Completer();
  final Completer<void> waiter = Completer();

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

  @override
  AsyncOperationFailureHandler<T> failureHandler;

  Parameter({
    required this.value,
    AsyncOperationCompletedCallback<T>? onCompleted,
    AsyncOperationFailedCallback? onFailed,
    AsyncOperationProgressCallback<P>? onProgress,
    AsyncOperationFailureHandler<T>? failureHandler,
  })  : _onCompleted = onCompleted ?? ((_) {}),
        _onFailed = onFailed ?? print,
        _onProgress = onProgress ?? ((_) {}),
        failureHandler = failureHandler ?? ((_) {});

  @override
  String toString() => value;
}

@optionalTypeArgs
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

class CustomEquality<T> implements Equality<T> {
  final bool Function(T l, T r) _equals;

  CustomEquality(this._equals);

  @override
  bool equals(T e1, T e2) => _equals(e1, e2);

  @override
  int hash(T e) {
    throw UnimplementedError();
  }

  @override
  bool isValidKey(Object? o) {
    throw UnimplementedError();
  }
}

typedef TestEpilogue = Future<void> Function(
  TestTarget target,
  Parameter<String, void> parameter,
  String initialExpected,
  String finalExpected,
  Parameter<String, void>? Function() refPassed,
);

typedef TestBody = Future<void> Function(
  TestEpilogue,
  Parameter<String, void>,
  String?,
  Exception?,
);

Future<void> doSuccessCase(
  TestTarget target,
  Parameter<String, void> parameter, {
  required String initialExpected,
  required String finalExpected,
  required Parameter<String, void>? Function() refPassed,
  required String? Function() refResult,
}) async {
  // Assert before the future
  expect(target.execute(parameter), equals(initialExpected));
  expect(target.status, equals(AsyncOperationStatus.inProgress));

  await parameter.completer.future;

  // Assert mock
  expect(refPassed(), same(parameter));

  // Assert status after the future
  expect(target.status, equals(AsyncOperationStatus.completed));

  // Assert callback behaviors
  expect(parameter.isOnCompletedCalled, isTrue);
  expect(parameter.isOnFailedCalled, isFalse);
  expect(parameter.isOnProgressCalled, isFalse);

  expect(refResult(), equals(finalExpected));

  // We can get cached result.
  expect(target.execute(parameter), equals(finalExpected));
  expect(target.status, equals(AsyncOperationStatus.completed));
}

Future<void> doFailCase(
  TestTarget target,
  Parameter<String, void> parameter, {
  required String initialExpected,
  required Object errorToBeThrown,
  required Parameter<String, void>? Function() refPassed,
  required AsyncError? Function() refFailure,
}) async {
  // Assert before the future
  try {
    expect(target.execute(parameter), equals(initialExpected));
    // in async error, this try should not throw any exception here.
    expect(target.status, equals(AsyncOperationStatus.inProgress));
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    // in sync error, this catch will be fired.
    expect(e.error, same(errorToBeThrown));
    expect(target.status, equals(AsyncOperationStatus.failed));
  }

  printOnFailure('${target.status}');
  try {
    await parameter.completer.future;
    fail('No exception thrown.');
  } on Exception catch (e) {
    expect(e, same(errorToBeThrown));
  }

  // Assert mock
  expect(refPassed(), same(parameter));

  // Assert status after the future
  expect(target.status, equals(AsyncOperationStatus.failed));

  // Assert callback behaviors
  expect(parameter.isOnCompletedCalled, isFalse);
  expect(parameter.isOnFailedCalled, isTrue);
  expect(parameter.isOnProgressCalled, isFalse);

  final failure = refFailure();
  expect(failure, isNotNull);
  expect(failure?.error, isNotNull);
  expect(failure?.stackTrace, isNotNull);
  expect(failure?.error, same(errorToBeThrown));

  // We can get cached exception.

  try {
    target.execute(parameter);
  }
  // ignore: avoid_catching_errors
  on AsyncError catch (e) {
    expect(e, isA<AsyncError>());
    expect(e.error, same(errorToBeThrown));
    expect(e.stackTrace, isNotNull);
  }

  expect(target.status, equals(AsyncOperationStatus.failed));
}

Future<void> doThenSucceedTest(
  TestBody doTest,
) async {
  String? result;
  final parameter =
      Parameter<String, void>(value: 'SUCCESS', onCompleted: (r) => result = r);
  await doTest(
    (
      target,
      parameter,
      initialExpected,
      finalExpected,
      refPassed,
    ) =>
        doSuccessCase(
      target,
      parameter,
      initialExpected: initialExpected,
      finalExpected: finalExpected,
      refPassed: refPassed,
      refResult: () => result,
    ),
    parameter,
    'SUCCESS',
    null,
  );
}

Future<void> doThenFailTest(
  TestBody doTest,
) async {
  final error = Exception('DUMMY');
  AsyncError? failure;
  final parameter = Parameter<String, void>(
    value: 'FAIL',
    onFailed: (e) => failure = e,
  );
  await doTest(
    (
      target,
      parameter,
      initialExpected,
      finalExpected,
      refPassed,
    ) =>
        doFailCase(
      target,
      parameter,
      initialExpected: initialExpected,
      errorToBeThrown: error,
      refPassed: refPassed,
      refFailure: () => failure,
    ),
    parameter,
    null,
    error,
  );
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
            Future<void> doTest(Future<String> Function(String) future) async {
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

              await doSuccessCase(
                target,
                parameter,
                initialExpected: defaultResult,
                finalExpected: expected,
                refPassed: () => passed,
                refResult: () => result1,
              );
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
                Future.value,
              ),
            );
          });

          group(
              '2 request with diffrent parameter overrides and set to result.',
              () {
            Future<void> doTest(Future<String> Function(String) future) async {
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
              // cache will be expired because parameter1 != parameter2
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
                Future.value,
              ),
            );
          });

          group(
              '2 request with same parameter only early one is executed and set to result.',
              () {
            Future<void> doTest(Future<String> Function(String) future) async {
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

              expect(target.execute(parameter3), equals(defaultResult));
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
                Future.value,
              ),
            );
          });
        });

        group('failure', () {
          group('1 request is executed asynchronously and remember exception.',
              () {
            Future<void> doTest(
                Future<String> Function(Exception) future) async {
              AsyncError? failure1;
              final parameter = Parameter<String, void>(
                value: 'input',
                onFailed: (e) => failure1 = e,
              );
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

              await doFailCase(
                target,
                parameter,
                initialExpected: defaultResult,
                errorToBeThrown: error,
                refPassed: () => passed,
                refFailure: () => failure1,
              );
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

          group(
              '2 request is executed asynchronously and remember later exception.',
              () {
            Future<void> doTest(
                Future<String> Function(Exception) future) async {
              AsyncError? failure1;
              AsyncError? failure2;
              final parameter1 = Parameter<String, void>(
                value: 'input1',
                onFailed: (e) => failure1 = e,
              );
              final parameter2 = Parameter<String, void>(
                value: 'input2',
                onFailed: (e) => failure2 = e,
              );
              const defaultResult = 'default';
              final error1 = Exception('DUMMY1');
              final error2 = Exception('DUMMY2');

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  passed = p;
                  return future(p.value == 'input1' ? error1 : error2);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              // Assert before the future
              try {
                expect(target.execute(parameter1), equals(defaultResult));
                // in async error, this try should not throw any exception here.
                expect(target.status, equals(AsyncOperationStatus.inProgress));
              }
              // ignore: avoid_catching_errors
              on AsyncError catch (e) {
                // in sync error, this catch will be fired.
                expect(e.error, same(error1));
                expect(target.status, equals(AsyncOperationStatus.failed));
              }

              printOnFailure('${target.status}');
              try {
                await parameter1.completer.future;
                fail('No exception thrown.');
              } on Exception catch (e) {
                expect(e, same(error1));
              }

              // Assert mock
              expect(passed, same(parameter1));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.failed));

              // Assert callback behaviors
              expect(parameter1.isOnCompletedCalled, isFalse);
              expect(parameter1.isOnFailedCalled, isTrue);
              expect(parameter1.isOnProgressCalled, isFalse);

              expect(failure1, isNotNull);
              expect(failure1?.error, isNotNull);
              expect(failure1?.stackTrace, isNotNull);
              expect(failure1?.error, same(error1));

              // Assert before the future
              try {
                expect(target.execute(parameter2), equals(defaultResult));
                // in async error, this try should not throw any exception here.
                expect(target.status, equals(AsyncOperationStatus.inProgress));
              }
              // ignore: avoid_catching_errors
              on AsyncError catch (e) {
                // in sync error, this catch will be fired.
                expect(e.error, same(error2));
                expect(target.status, equals(AsyncOperationStatus.failed));
              }

              printOnFailure('${target.status}');
              try {
                await parameter2.completer.future;
                fail('No exception thrown.');
              } on Exception catch (e) {
                expect(e, same(error2));
              }

              // Assert mock
              expect(passed, same(parameter2));

              // Assert status after the future
              expect(target.status, equals(AsyncOperationStatus.failed));

              // Assert callback behaviors
              expect(parameter2.isOnCompletedCalled, isFalse);
              expect(parameter2.isOnFailedCalled, isTrue);
              expect(parameter2.isOnProgressCalled, isFalse);

              expect(failure2, isNotNull);
              expect(failure2?.error, isNotNull);
              expect(failure2?.stackTrace, isNotNull);
              expect(failure2?.error, same(error2));

              // We can get cached exception.

              try {
                target.execute(parameter2);
              }
              // ignore: avoid_catching_errors
              on AsyncError catch (e) {
                expect(e, isA<AsyncError>());
                expect(e.error, same(error2));
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

          group(
              '2 request is executed asynchronously, fail then success, later result is cached.',
              () {
            Future<void> doTest(Future<String> Function(Object) future) async {
              AsyncError? failure1;
              String? result2;
              final parameter1 = Parameter<String, void>(
                value: 'input1',
                onFailed: (e) => failure1 = e,
              );
              final parameter2 = Parameter<String, void>(
                value: 'input2',
                onCompleted: (r) => result2 = r,
              );
              const defaultResult = 'default';
              final error1 = Exception('DUMMY1');
              const expected = 'result';

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  passed = p;
                  return future(p.value == 'input1' ? error1 : expected);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              await doFailCase(
                target,
                parameter1,
                initialExpected: defaultResult,
                errorToBeThrown: error1,
                refPassed: () => passed,
                refFailure: () => failure1,
              );

              await doSuccessCase(
                target,
                parameter2,
                initialExpected: defaultResult,
                finalExpected: expected,
                refPassed: () => passed,
                refResult: () => result2,
              );
            }

            test(
              'async',
              () => doTest(
                (e) async {
                  if (e is Exception) {
                    await Future<void>.delayed(Duration.zero, () => throw e);
                  } else if (e is String) {
                    return e;
                  }

                  return 'ERROR';
                },
              ),
            );

            test(
              'sync',
              () => doTest(
                (e) {
                  if (e is Exception) {
                    throw e;
                  } else if (e is String) {
                    return Future.value(e);
                  }

                  throw AssertionError('Unexpected input');
                },
              ),
            );
          });

          group(
              '2 request is executed asynchronously, success then fail, later result is cached.',
              () {
            Future<void> doTest(Future<String> Function(Object) future) async {
              String? result1;
              AsyncError? failure2;
              final parameter1 = Parameter<String, void>(
                value: 'input1',
                onCompleted: (r) => result1 = r,
              );
              final parameter2 = Parameter<String, void>(
                value: 'input2',
                onFailed: (e) => failure2 = e,
              );
              const defaultResult = 'default';
              final error2 = Exception('DUMMY2');
              const expected = 'result';

              Parameter<String, void>? passed;
              final target = TestTarget<String, void>(
                callback: (p) {
                  passed = p;
                  return future(p.value == 'input2' ? error2 : expected);
                },
                defaultResult: defaultResult,
              );

              // Assert precondition
              expect(target.status, equals(AsyncOperationStatus.initial));

              await doSuccessCase(
                target,
                parameter1,
                initialExpected: defaultResult,
                finalExpected: expected,
                refPassed: () => passed,
                refResult: () => result1,
              );

              await doFailCase(
                target,
                parameter2,
                // cache will be expired because parameter1 != parameter2
                initialExpected: defaultResult,
                errorToBeThrown: error2,
                refPassed: () => passed,
                refFailure: () => failure2,
              );
            }

            test(
              'async',
              () => doTest(
                (e) async {
                  if (e is Exception) {
                    await Future<void>.delayed(Duration.zero, () => throw e);
                  } else if (e is String) {
                    return e;
                  }

                  return 'ERROR';
                },
              ),
            );

            test(
              'sync',
              () => doTest(
                (e) {
                  if (e is Exception) {
                    throw e;
                  } else if (e is String) {
                    return Future.value(e);
                  }

                  throw AssertionError('Unexpected input');
                },
              ),
            );
          });
        });

        test('specified equality used.', () async {
          String? result1;
          // ignore: unused_local_variable
          String? result2;
          final parameter1 = Parameter<String, void>(
              value: 'input', onCompleted: (r) => result1 = r);
          final parameter2 = Parameter<String, void>(
              value: 'INPUT', onCompleted: (r) => result2 = r);
          const defaultResult = 'default';

          Parameter<String, void>? passed;
          final target = TestTarget<String, void>(
            callback: (p) {
              passed = p;
              return Future.value(p.value);
            },
            defaultResult: defaultResult,
            parameterEquality: CustomEquality((l, r) =>
                const CaseInsensitiveEquality().equals(l.value, r.value)),
          );

          // Assert precondition
          expect(target.status, equals(AsyncOperationStatus.initial));

          // Assert before the future
          expect(target.execute(parameter1), equals(defaultResult));
          expect(target.status, equals(AsyncOperationStatus.inProgress));

          await parameter1.completer.future;

          // Assert mock
          expect(passed, same(parameter1));

          // Assert status after the future
          expect(target.status, equals(AsyncOperationStatus.completed));

          // Assert callback behaviors
          expect(parameter1.isOnCompletedCalled, isTrue);
          expect(parameter1.isOnFailedCalled, isFalse);
          expect(parameter1.isOnProgressCalled, isFalse);

          expect(result1, equals(parameter1.value));

          // We can get cached result instead of 2nd because case-insensitive
          // value comparison will be used.
          expect(target.execute(parameter2), equals(parameter1.value));
          expect(target.status, equals(AsyncOperationStatus.completed));
        });

        group('successor under in progress', () {
          Future<void> doTest(
            Future<void> Function(TestTarget<String, void>, String) doPrologue,
          ) async {
            // Do prologue
            String? result1;
            String? result2;
            final parameter1 = Parameter<String, void>(
                value: 'input1', onCompleted: (r) => result1 = r);
            final parameter2 = Parameter<String, void>(
                value: 'input2', onCompleted: (r) => result2 = r);
            const defaultResult = 'default';

            final target = TestTarget<String, void>(
              callback: (p) async {
                await p.waiter.future;
                return Future.value(p.value);
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            await doPrologue(target, defaultResult);

            // Assert before the future
            expect(target.execute(parameter1), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));
            expect(target.execute(parameter2), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            parameter1.waiter.complete();
            parameter2.waiter.complete();

            // Assert mock
            await parameter1.completer.future;
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
            expect(result2, equals(parameter2.value));

            // We can get cached result.
            expect(target.execute(parameter2), equals(parameter2.value));
            expect(target.status, equals(AsyncOperationStatus.completed));
          }

          test('initial -> ', () async {
            await doTest((target, _) async {
              expect(target.status, equals(AsyncOperationStatus.initial));
            });
          });
          test('completed -> ', () async {
            await doTest((target, defaultResult) async {
              final parameter = Parameter<String, void>(value: 'PREVIOUS');
              parameter.waiter.complete();
              expect(target.execute(parameter), equals(defaultResult));
              await parameter.completer.future;
              expect(target.execute(parameter), equals(parameter.value));
              expect(target.status, equals(AsyncOperationStatus.completed));
            });
          });
          test('failed -> ', () async {
            await doTest((target, defaultResult) async {
              final parameter = Parameter<String, void>(value: 'ERROR');
              final error = Exception('DUMMY');
              parameter.waiter.completeError(error);
              expect(target.execute(parameter), equals(defaultResult));
              try {
                await parameter.completer.future;
              }
              // ignore: avoid_catches_without_on_clauses
              catch (e) {
                expect(e, same(error));
              }
              expect(target.status, equals(AsyncOperationStatus.failed));
            });
          });

          test('inProgress (same parameter) -> defaultResult', () async {
            // Do prologue
            String? result1;
            String? result2;
            final parameter1 = Parameter<String, void>(
                value: 'input', onCompleted: (r) => result1 = r);
            final parameter2 = Parameter<String, void>(
                value: 'input', onCompleted: (r) => result2 = r);
            const defaultResult = 'default';

            final target = TestTarget<String, void>(
              callback: (p) async {
                await p.waiter.future;
                return Future.value(p.value);
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

            parameter1.waiter.complete();
            parameter2.waiter.complete();

            // Assert mock
            await Future.any([
              parameter1.completer.future,
              parameter2.completer.future,
            ]);

            // Assert status after the future
            expect(target.status, equals(AsyncOperationStatus.completed));

            // Assert callback behaviors
            // 1st is called because 2nd is not queued.
            expect(parameter1.isOnCompletedCalled, isTrue);
            expect(parameter1.isOnFailedCalled, isFalse);
            expect(parameter1.isOnProgressCalled, isFalse);
            expect(parameter2.isOnCompletedCalled, isFalse);
            expect(parameter2.isOnFailedCalled, isFalse);
            expect(parameter2.isOnProgressCalled, isFalse);

            expect(result1, equals(parameter1.value));
            expect(result2, isNull);

            // We can get cached result.
            expect(target.execute(parameter1), equals(parameter1.value));
            expect(target.status, equals(AsyncOperationStatus.completed));
          });
        });
      });

      group('cancel', () {
        group('initial -(cancel)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final completer = Completer<void>();
            const defaultResult = 'default';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                await completer.future;
                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('cancel()');
            target.cancel();

            expect(target.status, equals(AsyncOperationStatus.initial));

            completer.complete();

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('initial -> inprogress -(cancel)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final completer = Completer<void>();
            final parameter = Parameter<String, void>(value: 'ERROR');
            const defaultResult = 'default';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                await completer.future;
                if (p.value == parameter.value) {
                  return p.value;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('cancel()');
            target.cancel();

            expect(target.status, equals(AsyncOperationStatus.initial));

            completer.complete();
            await parameter.completer.future;

            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('completed -(cancel)-> completed', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final parameter = Parameter<String, void>(value: 'INITIAL');
            const defaultResult = 'default';
            const expected = 'RESULT';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                if (p.value == parameter.value) {
                  return expected;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            await parameter.completer.future;
            expect(target.status, equals(AsyncOperationStatus.completed));

            printOnFailure('cancel()');
            target.cancel();

            expect(target.status, equals(AsyncOperationStatus.completed));
            expect(target.execute(parameter), equals(expected));
            expect(target.status, equals(AsyncOperationStatus.completed));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('completed -> inProgress -(cancel)-> completed', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            Completer<void>? completer1;
            Completer<void>? completer2;
            const expected1 = 'RESULT1';
            const expected2 = 'RESULT2';
            final parameter1 = Parameter<String, void>(value: expected1);
            final parameter2 = Parameter<String, void>(value: expected2);
            const defaultResult = 'default';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                final completer = completer1 ?? completer2;
                if (completer != null) {
                  await completer.future;
                }

                if (p.value.startsWith('RESULT')) {
                  return p.value;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            completer1 = Completer<void>();
            expect(target.execute(parameter1), equals(defaultResult));
            completer1.complete();
            await parameter1.completer.future;
            expect(target.status, equals(AsyncOperationStatus.completed));

            completer2 = Completer<void>();
            expect(target.execute(parameter2), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('cancel()');
            target.cancel();

            completer2.complete();
            await parameter2.completer.future;

            expect(target.status, equals(AsyncOperationStatus.completed));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('failed -(cancel)-> failed', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final parameter = Parameter<String, void>(value: 'INITIAL');
            const defaultResult = 'default';
            final error = Exception('DUMMY');

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                if (p.value == parameter.value) {
                  throw error;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            try {
              await parameter.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            printOnFailure('cancel()');
            target.cancel();

            expect(target.status, equals(AsyncOperationStatus.failed));

            try {
              target.execute(parameter);
              fail('Never thrown');
            }
            // ignore: avoid_catching_errors
            on AsyncError catch (e) {
              expect(e.error, same(error));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('failed -> inProgress -(cancel)-> failed', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            Completer<void>? completer1;
            Completer<void>? completer2;
            final error1 = Exception('ERROR1');
            final error2 = Exception('ERROR2');
            final parameter1 = Parameter<String, void>(value: 'ERROR1');
            final parameter2 = Parameter<String, void>(value: 'ERROR2');
            const defaultResult = 'default';

            Parameter<String, void>? passed;
            AsyncError? canceledOperationError;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                final completer = completer1 ?? completer2;
                if (completer != null) {
                  await completer.future;
                }

                if (p.value == 'ERROR1') {
                  throw error1;
                }

                if (p.value == 'ERROR2') {
                  throw error2;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
              canceledOperationErrorHandler: (e) => canceledOperationError = e,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            completer1 = Completer<void>();
            expect(target.execute(parameter1), equals(defaultResult));
            completer1.complete();
            try {
              await parameter1.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error1));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            completer2 = Completer<void>();
            expect(target.execute(parameter2), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('cancel()');
            target.cancel();

            completer2.complete();
            try {
              await parameter2.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error2));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            expect(canceledOperationError, isNotNull);
            expect(canceledOperationError?.error, same(error2));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });
      });

      group('reset', () {
        group('initial -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final completer = Completer<void>();
            const defaultResult = 'default1';
            const newDefault = 'default2';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                await completer.future;
                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('reset()');
            target.reset(newDefault);

            expect(target.status, equals(AsyncOperationStatus.initial));

            completer.complete();

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('initial -> inprogress -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final completer = Completer<void>();
            final parameter = Parameter<String, void>(value: 'ERROR');
            const defaultResult = 'default1';
            const newDefault = 'default2';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                await completer.future;
                if (p.value == parameter.value) {
                  return p.value;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('reset()');
            target.reset(newDefault);

            expect(target.status, equals(AsyncOperationStatus.initial));

            completer.complete();
            await parameter.completer.future;

            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('completed -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final parameter = Parameter<String, void>(value: 'INITIAL');
            const defaultResult = 'default1';
            const newDefault = 'default2';
            const expected = 'RESULT';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                if (p.value == parameter.value) {
                  return expected;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            await parameter.completer.future;
            expect(target.status, equals(AsyncOperationStatus.completed));

            printOnFailure('reset()');
            target.reset(newDefault);

            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('completed -> inProgress -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            Completer<void>? completer1;
            Completer<void>? completer2;
            const expected1 = 'RESULT1';
            const expected2 = 'RESULT2';
            final parameter1 = Parameter<String, void>(value: expected1);
            final parameter2 = Parameter<String, void>(value: expected2);
            const defaultResult = 'default1';
            const newDefault = 'default2';

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                final completer = completer1 ?? completer2;
                if (completer != null) {
                  await completer.future;
                }

                if (p.value.startsWith('RESULT')) {
                  return p.value;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            completer1 = Completer<void>();
            expect(target.execute(parameter1), equals(defaultResult));
            completer1.complete();
            await parameter1.completer.future;
            expect(target.status, equals(AsyncOperationStatus.completed));

            completer2 = Completer<void>();
            expect(target.execute(parameter2), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('reset()');
            target.reset(newDefault);

            completer2.complete();
            await parameter2.completer.future;

            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('failed -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            final parameter = Parameter<String, void>(value: 'INITIAL');
            const defaultResult = 'default1';
            const newDefault = 'default2';
            final error = Exception('DUMMY');

            Parameter<String, void>? passed;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                if (p.value == parameter.value) {
                  throw error;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            expect(target.execute(parameter), equals(defaultResult));
            try {
              await parameter.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            printOnFailure('reset()');
            target.reset(newDefault);

            expect(target.status, equals(AsyncOperationStatus.initial));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });

        group('failed -> inProgress -(reset)-> initial', () {
          Future<void> doTest(
            TestEpilogue doAfter,
            Parameter<String, void> afterParameter,
            String? afterResult,
            Exception? afterError,
          ) async {
            Completer<void>? completer1;
            Completer<void>? completer2;
            final error1 = Exception('ERROR1');
            final error2 = Exception('ERROR2');
            final parameter1 = Parameter<String, void>(value: 'ERROR1');
            final parameter2 = Parameter<String, void>(value: 'ERROR2');
            const defaultResult = 'default1';
            const newDefault = 'default2';

            Parameter<String, void>? passed;
            AsyncError? canceledOperationError;
            final target = TestTarget<String, void>(
              callback: (p) async {
                passed = p;
                final completer = completer1 ?? completer2;
                if (completer != null) {
                  await completer.future;
                }

                if (p.value == 'ERROR1') {
                  throw error1;
                }

                if (p.value == 'ERROR2') {
                  throw error2;
                }

                if (afterError != null) {
                  throw afterError;
                }
                return afterResult!;
              },
              defaultResult: defaultResult,
              canceledOperationErrorHandler: (e) => canceledOperationError = e,
            );

            // Assert precondition
            expect(target.status, equals(AsyncOperationStatus.initial));

            completer1 = Completer<void>();
            expect(target.execute(parameter1), equals(defaultResult));
            completer1.complete();
            try {
              await parameter1.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error1));
              expect(target.status, equals(AsyncOperationStatus.failed));
            }

            completer2 = Completer<void>();
            expect(target.execute(parameter2), equals(defaultResult));
            expect(target.status, equals(AsyncOperationStatus.inProgress));

            printOnFailure('reset()');
            target.reset(newDefault);
            expect(target.status, equals(AsyncOperationStatus.initial));

            completer2.complete();
            try {
              await parameter2.completer.future;
              fail('Never thrown');
            }
            // ignore: avoid_catches_without_on_clauses
            catch (e) {
              expect(e, same(error2));
              expect(target.status, equals(AsyncOperationStatus.initial));
            }

            expect(canceledOperationError, isNotNull);
            expect(canceledOperationError?.error, same(error2));

            printOnFailure('doAfter()');
            await doAfter(
              target,
              afterParameter,
              defaultResult,
              afterResult ?? afterParameter.value,
              () => passed,
            );
          }

          test('-> success', () async => doThenSucceedTest(doTest));
          test('-> failure', () async => doThenFailTest(doTest));
        });
      });

      group('AsyncOperationNotifier callbacks', () {
        test('completed', () async {
          const defaultResult = 'DEFAULT';
          const result = 'RESULT1';

          // should be 3, 1, 2
          final reported = <int>[];
          String? onCompletedParameter;
          AsyncError? onFailedParameter;
          final parameter = Parameter<String, int>(
            value: 'VALUE1',
            onCompleted: (p) {
              onCompletedParameter = p;
            },
            onFailed: (e) {
              onFailedParameter = e;
            },
            onProgress: reported.add,
          );

          final target = TestTarget<String, int>(
            callback: (p) async {
              p.onProgress(3);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(1);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(2);
              await Future<void>.delayed(Duration.zero);
              return result;
            },
            defaultResult: defaultResult,
          );

          expect(target.execute(parameter), equals(defaultResult));
          await parameter.completer.future;
          expect(onCompletedParameter, equals(result));
          expect(onFailedParameter, isNull);
          expect(reported, orderedEquals(<int>[3, 1, 2]));
        });

        test('failed', () async {
          final error = Exception('DUMMY');
          const defaultResult = 'DEFAULT';

          // should be 3, 1, 2
          final reported = <int>[];
          String? onCompletedParameter;
          AsyncError? onFailedParameter;
          final parameter = Parameter<String, int>(
            value: 'VALUE1',
            onCompleted: (p) {
              onCompletedParameter = p;
            },
            onFailed: (e) {
              onFailedParameter = e;
            },
            onProgress: reported.add,
          );

          final target = TestTarget<String, int>(
            callback: (p) async {
              p.onProgress(3);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(1);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(2);
              await Future<void>.delayed(Duration.zero);
              throw error;
            },
            defaultResult: defaultResult,
          );

          expect(target.execute(parameter), equals(defaultResult));
          try {
            await parameter.completer.future;
          }
          // ignore: avoid_catches_without_on_clauses
          catch (e) {
            expect(e, same(error));
          }

          expect(onCompletedParameter, isNull);
          expect(onFailedParameter, isNotNull);
          expect(onFailedParameter?.error, same(error));
          expect(reported, orderedEquals(<int>[3, 1, 2]));
        });

        test('failure override', () async {
          final error = Exception('DUMMY');
          const defaultResult = 'DEFAULT';

          const replacement = 'REPLACED FAILURE';

          // should be 3, 1, 2
          final reported = <int>[];
          String? onCompletedParameter;
          AsyncError? onFailedParameter;
          final parameter = Parameter<String, int>(
            value: 'VALUE1',
            onCompleted: (p) {
              onCompletedParameter = p;
            },
            onFailed: (e) {
              onFailedParameter = e;
            },
            failureHandler: (x) {
              x.overrideError(replacement);
            },
            onProgress: reported.add,
          );

          final target = TestTarget<String, int>(
            callback: (p) async {
              p.onProgress(3);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(1);
              await Future<void>.delayed(Duration.zero);
              p.onProgress(2);
              await Future<void>.delayed(Duration.zero);
              throw error;
            },
            defaultResult: defaultResult,
          );

          expect(target.execute(parameter), equals(defaultResult));
          try {
            await parameter.completer.future;
          }
          // ignore: avoid_catches_without_on_clauses
          catch (e) {
            expect(e, same(error));
          }

          expect(target.execute(parameter), equals(replacement));

          expect(onCompletedParameter, equals(replacement));
          expect(onFailedParameter, isNull);
          expect(reported, orderedEquals(<int>[3, 1, 2]));
        });
      });
    },
  );
}
