// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'models.freezed.dart';

/// Gender based on ISO 5218.
enum Gender {
  notKnown,
  male,
  female,
  notApplicable,
}

/// Example regions.
enum Region {
  afurika,
  asia,
  australia,
  europe,
  northAmelica,
  southAmelica,
}

/// User account object.
@freezed
class Account with _$Account {
  Account._();

  factory Account.empty() = AccountEmpty;

  factory Account.registered({
    required String id,
    required String name,
    required Gender gender,
    required int age,
    required List<Region> preferredRegions,
  }) = AccountRegistered;

  // These getters are convinience to assign initialValues of fields.

  String? get id => maybeMap(
        registered: (x) => x.id,
        orElse: () => null,
      );

  String? get name => maybeMap(
        registered: (x) => x.name,
        orElse: () => null,
      );

  Gender get gender => maybeMap(
        registered: (x) => x.gender,
        orElse: () => Gender.notKnown,
      );

  int get age => maybeMap(
        registered: (x) => x.age,
        orElse: () => 18,
      );

  List<Region> get preferredRegsions => maybeMap(
        registered: (x) => x.preferredRegions,
        orElse: () => [],
      );
}

/// Meal types to be offered.
enum MealType {
  vegan,
  halal,
}

/// Room type.
enum RoomType {
  standard,
  delux,
  suite,
}

/// Booking object.
///
/// This is reverse designed from built-in FormBuilderFields, so it is nonsense
/// to discuess this object model's quality.
@freezed
class Booking with _$Booking {
  Booking._();

  factory Booking.empty() = BookingEmpty;

  factory Booking.registered({
    required String bookingId,
    required String userId,
    required DateTimeRange stay,
    required DateTime specialOfferDate,
    required RoomType roomType,
    required List<MealType> mealOffers,
    required int persons,
    required int babyBeds,
    required bool smoking,
    required double price,
    required String note,
  }) = BookingRegistered;

  // These getters are convinience to assign initialValues of fields.

  DateTimeRange get stay => maybeMap(
        registered: (x) => x.stay,
        orElse: () {
          final now = DateTime.now();
          return DateTimeRange(
            start: now.add(const Duration(days: 3)),
            end: now.add(const Duration(days: 90)),
          );
        },
      );

  DateTime get specialOfferDate => maybeMap(
        registered: (x) => x.specialOfferDate,
        orElse: () => stay.start,
      );

  RoomType get roomType => maybeMap(
        registered: (x) => x.roomType,
        orElse: () => RoomType.standard,
      );

  List<MealType> get mealOffers => maybeMap(
        registered: (x) => x.mealOffers,
        orElse: () => [],
      );

  int get persons => maybeMap(
        registered: (x) => x.persons,
        orElse: () => 1,
      );

  int get babyBeds => maybeMap(
        registered: (x) => x.babyBeds,
        orElse: () => 0,
      );

  bool? get smoking => maybeMap(
        registered: (x) => x.smoking,
        orElse: () => null,
      );

  double? get price => maybeMap(
        registered: (x) => x.price,
        orElse: () => null,
      );

  String? get note => maybeMap(
        registered: (x) => x.note,
        orElse: () => null,
      );
}

/// Application wide state of [Account].
final account = StateProvider((_) => Account.empty());

/// Application wide state of [Booking].
final booking = StateProvider((_) => Booking.empty());

// TODO(yfakariya): validators, dummy async submits
