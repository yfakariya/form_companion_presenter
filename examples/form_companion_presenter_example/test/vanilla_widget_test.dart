// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter_examples/app.dart';

import 'widget_test_helpers.dart';

Future<void> main() async {
  await EasyLocalization.ensureInitialized();

  const fieldPredicate = formFieldPredicate;

  for (final validationType in {
    'Manual': 'manual',
    'Auto': 'auto',
    'Bulk-auto': 'bulkAuto'
  }.entries) {
    group(validationType.key, () {
      final page = pageIds['${validationType.value}Vanilla']!;
      testWidgets(
        'Initial state -- no validation error',
        (tester) async {
          final fieldValidationErrors = {
            'id': false,
            'name': false,
            'age': false,
            'gender': false
          };
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          for (final fieldName in fieldValidationErrors.keys) {
            final field =
                findField<dynamic>(tester, fieldPredicate<dynamic>(fieldName));
            printOnFailure(
              'verify $fieldName.hasError == ${fieldValidationErrors[fieldName]}',
            );
            expect(field.hasError, equals(fieldValidationErrors[fieldName]));
          }
        },
      );

      testWidgets(
        'Input invalid -- validation error',
        (tester) async {
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          final fieldState =
              findField<dynamic>(tester, fieldPredicate<dynamic>('id'));
          await tester.enterText(
              find.byWidget(fieldState.widget), invalidEmail);
          await tester.pump();
          expect(fieldState.hasError, validationType.value != 'manual');
        },
      );

      testWidgets(
        'Input invalid -- does not affect others',
        (tester) async {
          final fieldValidationErrors = {
            'id': validationType.value != 'manual',
            'name': validationType.value == 'bulkAuto',
            'age': false,
            'gender': false
          };
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('id')).widget,
            ),
            invalidEmail,
          );
          await tester.pump();

          for (final fieldName in fieldValidationErrors.keys) {
            final field =
                findField<dynamic>(tester, fieldPredicate<dynamic>(fieldName));
            printOnFailure(
              'verify $fieldName.hasError == ${fieldValidationErrors[fieldName]}',
            );
            expect(field.hasError, equals(fieldValidationErrors[fieldName]));
          }
        },
      );

      testWidgets(
        validationType.value == 'manual'
            ? 'Validation error does not affect submit button'
            : 'Validation error disables submit button',
        (tester) async {
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('id')).widget,
            ),
            invalidEmail,
          );
          await tester.pump();

          verifySubmitButtonIsEnabled(
            tester,
            enabled: validationType.value != 'bulkAuto',
          );
        },
      );

      testWidgets(
        'Async validation indicator is shown when async validation is in progress',
        (tester) async {
          final completer = Completer<String?>();
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          setAsyncValidationFutureFactory(
            tester,
            (duration, validation) async {
              await completer.future;
              return validation();
            },
          );

          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('id')).widget,
            ),
            'test@example.com',
          );
          await tester.pump();

          verifyAsyncIndicatorIsShown(
            tester,
            shown: validationType.value != 'manual',
          );

          completer.complete(null);
        },
      );

      testWidgets(
        'Async validation indicator is disappered when async validation is completed',
        (tester) async {
          final completer = Completer<String?>();
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          setAsyncValidationFutureFactory(
            tester,
            (duration, validation) async {
              await completer.future;
              return validation();
            },
          );

          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('id')).widget,
            ),
            validEmail,
          );
          await tester.pump();

          completer.complete(null);

          await tester.pump();

          verifyAsyncIndicatorIsShown(tester, shown: false);
        },
      );

      testWidgets(
        validationType.value == 'bulkAuto'
            ? 'Async validation disables submit button'
            : 'Async validation does not disable submit button even if it is invalid',
        (tester) async {
          final completer = Completer<String?>();
          await tester.pumpWidget(const App());
          transitToScreen(tester, page);
          await tester.pump();

          setAsyncValidationFutureFactory(
            tester,
            (duration, validation) async {
              await completer.future;
              return validation();
            },
          );

          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('name'))
                  .widget,
            ),
            'John', // any non empty value
          );
          await tester.enterText(
            find.byWidget(
              findField<dynamic>(tester, fieldPredicate<dynamic>('id')).widget,
            ),
            registeredEmail, // causes async validation error
          );

          await tester.pump();

          verifySubmitButtonIsEnabled(
            tester,
            enabled: validationType.value != 'bulkAuto',
          );

          completer.complete(null);
        },
      );

      if (validationType.value != 'bulkAuto') {
        // Note: we cannot tap submit button when bulkAuto and any sync validation error.
        testWidgets(
          'Submit button re-validates and shows validation error when any sync validation error exist',
          (tester) async {
            final completer = Completer<String?>();
            await tester.pumpWidget(const App());
            transitToScreen(tester, page);
            await tester.pump();

            setAsyncValidationFutureFactory(
              tester,
              (duration, validation) async {
                await completer.future;
                return validation();
              },
            );

            await tester.enterText(
              find.byWidget(
                findField<dynamic>(tester, fieldPredicate<dynamic>('name'))
                    .widget,
              ),
              'John', // any non empty value
            );

            // No id input here -- causes required validation error.

            await tester.pump();
            await tester.tap(find.byType(ElevatedButton));
            completer.complete(null);
            await tester.pump();

            expect(
              findField<dynamic>(
                tester,
                fieldPredicate<dynamic>('id'),
              ).hasError,
              isTrue,
            );
          },
        );
      } // not bulkAuto

      if (validationType.value != 'manual') {
        // There are no cases for manual validation
        // loop for behavior of auto async validation
        for (final pattern in [
          const InputPatternDescription(
            email: validEmail,
            description: 'no effect for valid data',
            shouldSuccess: true,
          ),
          InputPatternDescription(
            email: registeredEmail,
            description: validationType.value == 'bulkAuto'
                ? 'shows async validation error and submit button is disabled for invalid data'
                : 'shows async validation error for invalid data',
            shouldSuccess: false,
          ),
          const InputPatternDescription(
            email: causingErrorEmail,
            description: 'no effect for failure',
            shouldSuccess: true,
          ),
        ]) {
          testWidgets(
            'Input causes async validation and then ${pattern.description}',
            (tester) async {
              final completer = Completer<String?>();
              await tester.pumpWidget(const App());
              transitToScreen(tester, page);
              await tester.pump();

              setAsyncValidationFutureFactory(
                tester,
                (duration, validation) async {
                  await completer.future;
                  final result = validation();
                  return result;
                },
              );

              await tester.enterText(
                find.byWidget(
                  findField<dynamic>(tester, fieldPredicate<dynamic>('name'))
                      .widget,
                ),
                'John', // any non empty value
              );
              await tester.enterText(
                find.byWidget(
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
                ),
                pattern.email,
              );

              completer.complete();

              // There are 2 pumps are needed
              //  1. complete async
              //  2. do re-validation for re-eval
              await tester.pump();
              await tester.pump();

              verifySubmitButtonIsEnabled(tester,
                  enabled: validationType.value != 'bulkAuto' ||
                      pattern.shouldSuccess);

              verifyAsyncIndicatorIsShown(tester, shown: false);
              final state =
                  findField<String?>(tester, fieldPredicate<dynamic>('id'));
              expect(state.hasError, equals(!pattern.shouldSuccess));
            },
          );
        } // end of loop for behavior of auto async validation
      } // end of if for behavior of auto async validation

      // loop for submit button behavior of async validation
      for (final pattern in [
        const InputPatternDescription(
          email: validEmail,
          description: 'finishes successfully',
          shouldSuccess: true,
        ),
        const InputPatternDescription(
          email: registeredEmail,
          description: 'shows async validation error when happened',
          shouldSuccess: false,
        ),
        const InputPatternDescription(
          email: causingErrorEmail,
          description: 'shows async validation failure when happened',
          shouldSuccess: false,
        ),
      ]) {
        if (validationType.value == 'bulkAuto' &&
            pattern.email == registeredEmail) {
          // Skip because async validation error case never allows
          // tapping submit button because the button will not be enabled.
          continue;
        }

        testWidgets(
          'Submit button waits for async validation completion and then ${pattern.description}',
          (tester) async {
            var completer = Completer<String?>();
            await tester.pumpWidget(const App());
            transitToScreen(tester, page);
            await tester.pump();

            setAsyncValidationFutureFactory(
              tester,
              (duration, validation) async {
                await completer.future;
                final result = validation();
                return result;
              },
            );

            await tester.enterText(
              find.byWidget(
                findField<dynamic>(tester, fieldPredicate<dynamic>('name'))
                    .widget,
              ),
              'John', // any non empty value
            );
            await tester.enterText(
              find.byWidget(
                findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                    .widget,
              ),
              pattern.email,
            );

            if (validationType.value == 'bulkAuto') {
              // Complete async validation to enable submit button
              completer.complete();
            }

            // There are 2 pumps are needed
            //  1. complete async
            //  2. do re-validation for re-eval
            await tester.pump();
            await tester.pump();

            verifySubmitButtonIsEnabled(tester, enabled: true);
            // Note: We do not check async validation indicator here
            //       because it is not a matter in this test case.

            if (validationType.value == 'bulkAuto') {
              // Recycle completer for async validation control
              completer = Completer<String?>();
            }

            await tester.tap(find.byType(ElevatedButton));

            completer.complete(null);

            // Do async validation.
            await tester.pump();

            await pattern.verifySubmitResult<dynamic>(
              tester,
              fieldPredicate<dynamic>('id'),
            );
          },
        );
      } // end of loop for submit button behavior of async validation

      if (validationType.value == 'auto') {
        // In bulk-auto, submit button cannot be tapped when async validation is in-progress
        // In manual, async validation should not be in-progress before tapping submit button

        // loop for submit button behavior when async validation is in-progress
        for (final pattern in [
          const InputPatternDescription(
            email: validEmail,
            description: 'finishes successfully',
            shouldSuccess: true,
          ),
          const InputPatternDescription(
            email: registeredEmail,
            description: 'shows async validation error when happened',
            shouldSuccess: false,
          ),
          const InputPatternDescription(
            email: causingErrorEmail,
            description: 'shows async validation failure when happened',
            shouldSuccess: false,
          ),
        ]) {
          testWidgets(
            'Submit button waits for async validation completion when already in-progress and then ${pattern.description}',
            (tester) async {
              final completer = Completer<String?>();
              await tester.pumpWidget(const App());
              transitToScreen(tester, page);
              await tester.pump();

              setAsyncValidationFutureFactory(
                tester,
                (duration, validation) async {
                  await completer.future;
                  final result = validation();
                  return result;
                },
              );

              await tester.enterText(
                find.byWidget(
                  findField<dynamic>(tester, fieldPredicate<dynamic>('name'))
                      .widget,
                ),
                'John', // any non empty value
              );
              await tester.enterText(
                find.byWidget(
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
                ),
                pattern.email,
              );

              await tester.pump();

              verifySubmitButtonIsEnabled(tester, enabled: true);
              verifyAsyncIndicatorIsShown(tester, shown: true);

              await tester.tap(find.byType(ElevatedButton));

              completer.complete(null);

              // Do async validation.
              await tester.pump();

              await pattern.verifySubmitResult<dynamic>(
                tester,
                fieldPredicate<dynamic>('id'),
              );
            },
          );
        } // end of loop for submit button behavior when async validation is in-progress
      } // end if for submit button behavior when async validation is in-progress
    });
  }
}
