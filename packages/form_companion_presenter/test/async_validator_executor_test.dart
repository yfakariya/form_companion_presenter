// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_companion_presenter/src/async_validator_executor.dart';

void main() {
  group('AsyncValidatorExecutor', () {
    group('constructor', () {
      test('default equality', () async {
        final target = AsyncValidatorExecutor<int, void>();
        const result = 'DUMMY';
        final completer1 = Completer<String>();
        expect(
          target.validate(
            validator: (value, locale, onProgress) => Future.delayed(
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
            validator: (value, locale, onProgress) => Future.delayed(
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
            validator: (value, locale, onProgress) => Future.delayed(
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
        final target = AsyncValidatorExecutor<int, String>();
        const result = 'DUMMY';
        final completer = Completer<String>();
        const theValue = 123;
        const theLocale = Locale('en', 'US');
        // ignore: prefer_function_declarations_over_variables, avoid_types_on_closure_parameters
        final theOnProgress = (String p) {};

        expect(
          target.validate(
            validator: (value, locale, onProgress) {
              expect(value, equals(theValue));
              expect(locale, same(theLocale));
              expect(onProgress, same(theOnProgress));
              return Future.delayed(
                Duration.zero,
                () => result,
              );
            },
            value: theValue,
            locale: theLocale,
            onCompleted: (v, e) => completer.complete(v),
            onProgress: theOnProgress,
          ),
          isNull,
        );

        expect(target.validating, isTrue);

        expect(await completer.future, equals(result));
      });
      test('onFailed handler is used when specified', () async {
        final target = AsyncValidatorExecutor<int, String>();
        final theError = Exception('DUMMY');
        final completer = Completer<String>();
        // ignore: prefer_function_declarations_over_variables, avoid_types_on_closure_parameters
        final theOnProgress = (String p) {};

        expect(
          target.validate(
            validator: (value, locale, onProgress) {
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
            onProgress: theOnProgress,
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
      Future<void> doTest<V, P>({
        required AsyncValidator<V, P> validator,
        required AsyncValidationCompletionCallback onCompleted,
        required V value,
      }) async {
        final target = AsyncValidatorExecutor<V, P>();
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
        () async => doTest<int, void>(
          validator: (v, l, p) {
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
          await doTest<int, void>(
            validator: (v, l, p) {
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
          await doTest<int, void>(
            validator: (v, l, p) {
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
        () async => doTest<int, void>(
          validator: (v, l, p) {
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
          await doTest<int, void>(
            validator: (v, l, p) {
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
          await doTest<int, void>(
            validator: (v, l, p) {
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
}
