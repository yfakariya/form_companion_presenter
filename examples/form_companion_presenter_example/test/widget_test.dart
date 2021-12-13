// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter_examples/app.dart';
import 'package:form_companion_presenter_examples/auto_validation_form_builder_account.dart';
import 'package:form_companion_presenter_examples/auto_validation_form_builder_booking.dart';
import 'package:form_companion_presenter_examples/auto_validation_vanilla_form.dart';
import 'package:form_companion_presenter_examples/bulk_auto_validation_form_builder_account.dart';
import 'package:form_companion_presenter_examples/bulk_auto_validation_form_builder_booking.dart';
import 'package:form_companion_presenter_examples/bulk_auto_validation_vanilla_form.dart';
import 'package:form_companion_presenter_examples/home.dart';
import 'package:form_companion_presenter_examples/manual_validation_form_builder_account.dart';
import 'package:form_companion_presenter_examples/manual_validation_form_builder_booking.dart';
import 'package:form_companion_presenter_examples/manual_validation_vanilla_form.dart';
import 'package:form_companion_presenter_examples/models.dart';
import 'package:form_companion_presenter_examples/routes.dart';
import 'package:form_companion_presenter_examples/validators.dart';

const invalidEmail = 'invalidEmailAddress';
const validEmail = 'test@example.com';
const registeredEmail = 'jane@example.com';
const causingErrorEmail = 'john@example.com';

// helpers

enum PageId {
  home,
  autoVanilla,
  bulkAutoVanilla,
  manualVanilla,
  autoAccount,
  bulkAutoAccount,
  manualAccount,
  autoBooking,
  bulkAutoBooking,
  manualBooking,
}

class InputPatternDescription {
  final String email;
  final String description;
  final bool shouldSuccess;

  const InputPatternDescription({
    required this.email,
    required this.description,
    required this.shouldSuccess,
  });

  Future<void> verifySubmitResult<T>(
    WidgetTester tester,
    bool Function(FormField<T> widget) fieldPredicate,
  ) async {
    if (shouldSuccess) {
      // check transition
      final pageStack =
          readStateControllerFromProvider(tester, pagesProvider).state;
      expect(pageStack.length, equals(1));
      expect(pageStack[0].child, isA<HomePage>());
    } else {
      // check validation error
      expect(
        findField(tester, fieldPredicate).hasError,
        isTrue,
      );
    }
  }
}

final Map<String, PageId> _pageIds = {
  'home': PageId.home,
  'autoVanilla': PageId.autoVanilla,
  'bulkAutoVanilla': PageId.bulkAutoVanilla,
  'manualVanilla': PageId.manualVanilla,
  'autoAccount': PageId.autoAccount,
  'bulkAutoAccount': PageId.bulkAutoAccount,
  'manualAccount': PageId.manualAccount,
  'autoBooking': PageId.autoBooking,
  'bulkAutoBooking': PageId.bulkAutoBooking,
  'manualBooking': PageId.manualBooking,
};

final Map<PageId, List<MaterialPage<dynamic>>> _routeMap = {
  PageId.home: [const MaterialPage<dynamic>(child: HomePage())],
  PageId.autoAccount: [
    const MaterialPage<dynamic>(child: AutoValidationFormBuilderAccountPage())
  ],
  PageId.autoBooking: [
    const MaterialPage<dynamic>(child: AutoValidationFormBuilderBookingPage())
  ],
  PageId.autoVanilla: [
    const MaterialPage<dynamic>(child: AutoValidationVanillaFormAccountPage())
  ],
  PageId.bulkAutoAccount: [
    const MaterialPage<dynamic>(
        child: BulkAutoValidationFormBuilderAccountPage())
  ],
  PageId.bulkAutoBooking: [
    const MaterialPage<dynamic>(
        child: BulkAutoValidationFormBuilderBookingPage())
  ],
  PageId.bulkAutoVanilla: [
    const MaterialPage<dynamic>(
        child: BulkAutoValidationVanillaFormAccountPage())
  ],
  PageId.manualAccount: [
    const MaterialPage<dynamic>(child: ManualValidationFormBuilderAccountPage())
  ],
  PageId.manualBooking: [
    const MaterialPage<dynamic>(child: ManualValidationFormBuilderBookingPage())
  ],
  PageId.manualVanilla: [
    const MaterialPage<dynamic>(child: ManualValidationVanillaFormAccountPage())
  ],
};

/// Transits to specified screen.
void transitToScreen(WidgetTester tester, PageId page) {
  readStateControllerFromProvider(tester, pagesProvider).state =
      _routeMap[page]!;
}

BuildContext getBuildContext(WidgetTester tester) => tester.element(find
    .byWidgetPredicate((widget) => widget.runtimeType.toString() == '_App'));

T readStateFromProvider<T>(
  WidgetTester tester,
  StateProvider<T> provider,
) =>
    ProviderScope.containerOf(getBuildContext(tester)).read(provider);

StateController<T> readStateControllerFromProvider<T>(
  WidgetTester tester,
  StateProvider<T> provider,
) =>
    ProviderScope.containerOf(getBuildContext(tester)).read(provider.state);

FormFieldState<T> findField<T>(
  WidgetTester tester,
  bool Function(FormField<T> widget) predicate,
) =>
    tester.state(find.byWidgetPredicate(
        (widget) => widget is FormField<T> && predicate(widget)));

void setAsyncValidationFutureFactory(WidgetTester tester,
    Future<String?> Function(Duration, String? Function()) factory) {
  readStateControllerFromProvider(tester, asyncValidationFutureFactory).state =
      factory;
}

void verifyNoValidationErrors(WidgetTester tester) => expect(
      tester
          .stateList<FormFieldState<dynamic>>(find.byType(FormField))
          .every((element) => !element.hasError),
      isTrue,
    );

void verifySubmitButtonIsEnabled(
  WidgetTester tester, {
  required bool enabled,
}) {
  expect(find.byType(ElevatedButton), findsOneWidget);
  expect(
    tester.widget<ElevatedButton>(find.byType(ElevatedButton)).enabled,
    enabled,
  );
}

void verifyAsyncIndicatorIsShown(
  WidgetTester tester, {
  required bool shown,
}) {
  expect(find.byType(AsyncValidationIndicator), findsOneWidget);
  expect(
    find.byType(CircularProgressIndicator),
    shown ? findsOneWidget : findsNothing,
  );
}

void verifyPersistedAccount(
  WidgetTester tester, {
  required String id,
  required String name,
  required int age,
  required Gender gender,
  List<Region>? preferredRegsions,
}) {
  final accountState = readStateFromProvider(tester, account);

  expect(accountState, isA<AccountRegistered>());
  if (accountState is! AccountRegistered) {
    fail('never reach this line!');
  }

  expect(accountState.id, equals(id));
  expect(accountState.name, equals(name));
  expect(accountState.age, equals(age));
  expect(accountState.gender, equals(gender));
  if (preferredRegsions != null) {
    expect(accountState.preferredRegsions, equals(preferredRegsions));
  }
}

void verifyPersistedBooking(
  WidgetTester tester, {
  required String bookingId,
  required DateTimeRange stay,
  required DateTime specialOfferDate,
  required RoomType roomType,
  required List<MealType> mealOffers,
  required bool smoking,
  required int persons,
  required int babyBeds,
  required double price,
  required String note,
}) {
  final bookingState = readStateFromProvider(tester, booking);

  expect(bookingState, isA<BookingRegistered>());
  if (bookingState is! BookingRegistered) {
    fail('never reach this line!');
  }

  expect(bookingState.bookingId, equals(bookingId));
  expect(bookingState.stay, equals(stay));
  expect(bookingState.specialOfferDate, equals(specialOfferDate));
  expect(bookingState.roomType, equals(roomType));
  expect(bookingState.mealOffers, equals(mealOffers));
  expect(bookingState.smoking, equals(smoking));
  expect(bookingState.persons, equals(persons));
  expect(bookingState.babyBeds, equals(babyBeds));
  expect(bookingState.price, equals(price));
  expect(bookingState.note, equals(note));
}

bool Function(FormField<dynamic>) formFieldPredicate<T>(String fieldName) =>
    (widget) {
      final key = widget.key;
      if (key is! GlobalObjectKey) {
        return false;
      }

      return key.value == fieldName;
    };

bool Function(FormField<dynamic>) formBuilderFieldPredicate<T>(
        String fieldName) =>
    (widget) => (widget as FormBuilderField).name == fieldName;

Future<void> main() async {
  await EasyLocalization.ensureInitialized();

  for (final formType
      in {'Vanilla Form': 'Vanilla', 'FormBuilder': 'Account'}.entries) {
    final fieldPredicate = formType.value == 'Vanilla'
        ? formFieldPredicate
        : formBuilderFieldPredicate;
    group(formType.key, () {
      for (final validationType in {
        'Manual': 'manual',
        'Auto': 'auto',
        'Bulk-auto': 'bulkAuto'
      }.entries) {
        group(validationType.key, () {
          final page = _pageIds['${validationType.value}${formType.value}']!;
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
                final field = findField<dynamic>(
                    tester, fieldPredicate<dynamic>(fieldName));
                printOnFailure(
                  'verify $fieldName.hasError == ${fieldValidationErrors[fieldName]}',
                );
                expect(
                    field.hasError, equals(fieldValidationErrors[fieldName]));
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
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
                ),
                invalidEmail,
              );
              await tester.pump();

              for (final fieldName in fieldValidationErrors.keys) {
                final field = findField<dynamic>(
                    tester, fieldPredicate<dynamic>(fieldName));
                printOnFailure(
                  'verify $fieldName.hasError == ${fieldValidationErrors[fieldName]}',
                );
                expect(
                    field.hasError, equals(fieldValidationErrors[fieldName]));
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
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
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
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
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
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
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
                  findField<dynamic>(tester, fieldPredicate<dynamic>('id'))
                      .widget,
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
                      findField<dynamic>(
                              tester, fieldPredicate<dynamic>('name'))
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
                      findField<dynamic>(
                              tester, fieldPredicate<dynamic>('name'))
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
    });
  }
}
