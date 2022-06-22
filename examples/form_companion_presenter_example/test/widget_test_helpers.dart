// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter_examples/models.dart';
import 'package:form_companion_presenter_examples/routes.dart';
import 'package:form_companion_presenter_examples/validators.dart';

const invalidEmail = 'invalidEmailAddress';
const validEmail = 'test@example.com';
const registeredEmail = 'jane@example.com';
const causingErrorEmail = 'john@example.com';

// helpers

enum PageId {
  home('/'),
  autoVanilla('/vanilla/auto/account'),
  bulkAutoVanilla('/vanilla/bulk-auto/account'),
  manualVanilla('/vanilla/manual/account'),
  autoAccount('/form-builder/auto/account'),
  bulkAutoAccount('/form-builder/bulk-auto/account'),
  manualAccount('/form-builder/manual/account'),
  autoBooking('/form-builder/auto/booking'),
  bulkAutoBooking('/form-builder/bulk-auto/booking'),
  manualBooking('/form-builder/manual/booking');

  const PageId(this.path);

  final String path;
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
      expect(router.location, '/');
    } else {
      // check validation error
      expect(
        findField(tester, fieldPredicate).hasError,
        isTrue,
      );
    }
  }
}

final Map<String, PageId> pageIds = {
  for (final e in PageId.values.map((e) => MapEntry(e.name, e))) e.key: e.value
};

/// Transits to specified screen.
void transitToScreen(PageId page) => router.go(page.path);

BuildContext getBuildContext(WidgetTester tester) => tester.element(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_App',
      ),
    );

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
    tester.state(
      find.byWidgetPredicate(
        (widget) => widget is FormField<T> && predicate(widget),
      ),
    );

void setAsyncValidationFutureFactory(
  WidgetTester tester,
  Future<String?> Function(Duration, String? Function()) factory,
) {
  readStateControllerFromProvider(tester, asyncValidationFutureFactory).state =
      Waiter(factory);
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
  String fieldName,
) =>
    (widget) => (widget as FormBuilderField).name == fieldName;
