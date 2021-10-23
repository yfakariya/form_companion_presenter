// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_companion_presenter/src/async_validator_executor.dart';

void main() {
  group('AsyncValidatorExecutor', () {
    group('constructor', () {
      test('default equality', () async {
        final target = AsyncValidatorExecutor<int>();
        const result = 'DUMMY';
        final completer1 = Completer<String>();
        expect(
          target.validate(
            validator: (value, options) => Future.delayed(
              Duration.zero,
              () => result,
            ),
            value: 1,
            locale: const Locale('en', 'US'),
            onCompleted: (v, e) => completer1.complete(v),
          ),
          isNull,
        );

        expect(target.validating, isTrue);

        expect(await completer1.future, equals(result));

        final completer2 = Completer<String>();
        expect(
          target.validate(
            validator: (value, options) => Future.delayed(
              Duration.zero,
              // Returns different result here.
              () => result + result,
            ),
            value: 1,
            locale: const Locale('en', 'US'),
            onCompleted: (v, e) => completer2.complete(v),
          ),
          // Cached result
          equals(result),
        );

        expect(target.validating, isFalse);

        final completer3 = Completer<String>();
        expect(
          target.validate(
            validator: (value, options) => Future.delayed(
              Duration.zero,
              // Returns different result here.
              () => result + result,
            ),
            // Different value
            value: 2,
            locale: const Locale('en', 'US'),
            onCompleted: (v, e) => completer3.complete(v),
          ),
          isNull,
        );

        expect(target.validating, isTrue);

        expect(await completer3.future, equals(result + result));
      });
    });

    group('override', () {
      // Note: onCompleted is automatically tested by many cases :)
      test('locale and onProgress are passed to validator', () async {
        final target = AsyncValidatorExecutor<int>();
        const result = 'DUMMY';
        final completer = Completer<String>();
        const theValue = 123;
        const theLocale = Locale('en', 'US');

        expect(
          target.validate(
            validator: (value, options) {
              expect(value, equals(theValue));
              expect(options.locale, same(theLocale));
              return Future.delayed(
                Duration.zero,
                () => result,
              );
            },
            value: theValue,
            locale: theLocale,
            onCompleted: (v, e) => completer.complete(v),
          ),
          isNull,
        );

        expect(target.validating, isTrue);

        expect(await completer.future, equals(result));
      });
      test('onFailed handler is used when specified', () async {
        final target = AsyncValidatorExecutor<int>();
        final theError = Exception('DUMMY');
        final completer = Completer<String>();

        expect(
          target.validate(
            validator: (value, options) {
              return Future.delayed(
                Duration.zero,
                () {
                  throw theError;
                },
              );
            },
            value: 1,
            locale: const Locale('en', 'US'),
            onCompleted: (v, e) =>
                e == null ? completer.complete(v) : completer.completeError(e),
          ),
          isNull,
        );

        expect(target.validating, isTrue);

        try {
          await completer.future;
          fail('Not thrown');
        }
        // ignore: avoid_catching_errors
        on AsyncError catch (e) {
          expect(e.error.toString(), equals(theError.toString()));
        }
      });
    });

    group('scenario', () {
      Future<void> doTest<V extends Object>({
        required AsyncValidator<V> validator,
        required AsyncValidationCompletionCallback onCompleted,
        required V value,
      }) async {
        final target = AsyncValidatorExecutor<V>();
        final completer = Completer<String?>();

        try {
          expect(
            target.validate(
              validator: validator,
              value: value,
              locale: const Locale('en', 'US'),
              onCompleted: (r, e) {
                onCompleted(r, e);
                if (e == null) {
                  completer.complete(r);
                } else {
                  completer.completeError(e);
                }
              },
            ),
            isNull,
          );

          expect(target.validating, isTrue);

          await completer.future;
        }
        // ignore: avoid_catching_errors
        on AsyncError catch (_) {
          // swallow
        }

        try {
          // Drain pending errors for synchronous error
          await completer.future;
        }
        // ignore: avoid_catching_errors
        on AsyncError catch (_) {
          // swallow
        }

        // caller should assert with onCompleted callback.
      }

      test(
        'Immediately success',
        () async => doTest<int>(
          validator: (value, options) {
            return Future.value(null);
          },
          onCompleted: (r, e) {
            expect(r, isNull);
            expect(e, isNull);
          },
          value: 123,
        ),
      );

      test(
        'Immediately validation failure',
        () async {
          const result = 'required.';
          await doTest<int>(
            validator: (value, options) {
              return Future.value(result);
            },
            onCompleted: (r, e) {
              expect(r, equals(result));
              expect(e, isNull);
            },
            value: 123,
          );
        },
      );

      test(
        'Immediately error',
        () async {
          final theError = Exception('DUMMY');
          var onCompletedCalled = false;
          await doTest<int>(
            validator: (value, options) {
              throw theError;
            },
            onCompleted: (r, e) {
              expect(r, equals(e.toString()));
              expect(e, isNotNull);
              expect(e!.error.toString(), equals(theError.toString()));
              onCompletedCalled = true;
            },
            value: 123,
          );
          expect(onCompletedCalled, isTrue);
        },
      );

      test(
        'Asynchronously success',
        () async => doTest<int>(
          validator: (value, options) {
            return Future.delayed(Duration.zero, () => null);
          },
          onCompleted: (r, e) {
            expect(r, isNull);
            expect(e, isNull);
          },
          value: 123,
        ),
      );

      test(
        'Asynchronously validation failure',
        () async {
          const result = 'required.';
          await doTest<int>(
            validator: (value, options) {
              return Future.delayed(Duration.zero, () => result);
            },
            onCompleted: (r, e) {
              expect(r, equals(result));
              expect(e, isNull);
            },
            value: 123,
          );
        },
      );

      test(
        'Asynchronous error',
        () async {
          final theError = Exception('DUMMY');
          var onCompletedCalled = false;
          await doTest<int>(
            validator: (value, options) {
              return Future.delayed(Duration.zero, () => throw theError);
            },
            onCompleted: (r, e) {
              expect(r, equals(e.toString()));
              expect(e, isNotNull);
              expect(e!.error.toString(), equals(theError.toString()));
              onCompletedCalled = true;
            },
            value: 123,
          );
          expect(onCompletedCalled, isTrue);
        },
      );
    });
  });

  group('ValidationInvocation', () {
    group('Constructor', () {
      test('Specified callbacks are used.', () {
        // ignore: avoid_types_on_closure_parameters, prefer_function_declarations_over_variables
        final onCompleted = (String? value) {};
        // ignore: avoid_types_on_closure_parameters, prefer_function_declarations_over_variables
        final onFailed = (AsyncError? error) {};

        final target = ValidationInvocation<int>(
          validator: (value, options) {
            return Future.delayed(Duration.zero, () => null);
          },
          value: 1,
          locale: const Locale('en', 'US'),
          onCompleted: onCompleted,
          onFailed: onFailed,
        );

        expect(target.onCompleted, same(onCompleted));
        expect(target.onFailed, same(onFailed));
      });

      test('Optional parameter replaced with empty.', () {
        final target = ValidationInvocation<int>(
          validator: (value, options) {
            return Future.delayed(Duration.zero, null);
          },
          value: 1,
          locale: const Locale('en', 'US'),
          onCompleted: (value) {
            // nop
          },
        );

        expect(target.onFailed, isNotNull);
        // no effect
        target.onFailed(AsyncError(Object(), null));

        // ignore: deprecated_member_use_from_same_package
        expect(target.onProgress, isNotNull);
        // no effect
        // ignore: deprecated_member_use_from_same_package
        target.onProgress(null);
      });
    });
  });
}
