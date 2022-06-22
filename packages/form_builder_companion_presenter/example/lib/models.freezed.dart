// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Account {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)
        registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AccountEmpty value) empty,
    required TResult Function(AccountRegistered value) registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AccountCopyWith<$Res> {
  factory $AccountCopyWith(Account value, $Res Function(Account) then) =
      _$AccountCopyWithImpl<$Res>;
}

/// @nodoc
class _$AccountCopyWithImpl<$Res> implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  final Account _value;
  // ignore: unused_field
  final $Res Function(Account) _then;
}

/// @nodoc
abstract class _$$AccountEmptyCopyWith<$Res> {
  factory _$$AccountEmptyCopyWith(
          _$AccountEmpty value, $Res Function(_$AccountEmpty) then) =
      __$$AccountEmptyCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AccountEmptyCopyWithImpl<$Res> extends _$AccountCopyWithImpl<$Res>
    implements _$$AccountEmptyCopyWith<$Res> {
  __$$AccountEmptyCopyWithImpl(
      _$AccountEmpty _value, $Res Function(_$AccountEmpty) _then)
      : super(_value, (v) => _then(v as _$AccountEmpty));

  @override
  _$AccountEmpty get _value => super._value as _$AccountEmpty;
}

/// @nodoc

class _$AccountEmpty extends AccountEmpty {
  _$AccountEmpty() : super._();

  @override
  String toString() {
    return 'Account.empty()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$AccountEmpty);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)
        registered,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AccountEmpty value) empty,
    required TResult Function(AccountRegistered value) registered,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class AccountEmpty extends Account {
  factory AccountEmpty() = _$AccountEmpty;
  AccountEmpty._() : super._();
}

/// @nodoc
abstract class _$$AccountRegisteredCopyWith<$Res> {
  factory _$$AccountRegisteredCopyWith(
          _$AccountRegistered value, $Res Function(_$AccountRegistered) then) =
      __$$AccountRegisteredCopyWithImpl<$Res>;
  $Res call(
      {String id,
      String name,
      Gender gender,
      int age,
      List<Region> preferredRegions});
}

/// @nodoc
class __$$AccountRegisteredCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res>
    implements _$$AccountRegisteredCopyWith<$Res> {
  __$$AccountRegisteredCopyWithImpl(
      _$AccountRegistered _value, $Res Function(_$AccountRegistered) _then)
      : super(_value, (v) => _then(v as _$AccountRegistered));

  @override
  _$AccountRegistered get _value => super._value as _$AccountRegistered;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? gender = freezed,
    Object? age = freezed,
    Object? preferredRegions = freezed,
  }) {
    return _then(_$AccountRegistered(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gender: gender == freezed
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      age: age == freezed
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      preferredRegions: preferredRegions == freezed
          ? _value._preferredRegions
          : preferredRegions // ignore: cast_nullable_to_non_nullable
              as List<Region>,
    ));
  }
}

/// @nodoc

class _$AccountRegistered extends AccountRegistered {
  _$AccountRegistered(
      {required this.id,
      required this.name,
      required this.gender,
      required this.age,
      required final List<Region> preferredRegions})
      : _preferredRegions = preferredRegions,
        super._();

  @override
  final String id;
  @override
  final String name;
  @override
  final Gender gender;
  @override
  final int age;
  final List<Region> _preferredRegions;
  @override
  List<Region> get preferredRegions {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredRegions);
  }

  @override
  String toString() {
    return 'Account.registered(id: $id, name: $name, gender: $gender, age: $age, preferredRegions: $preferredRegions)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AccountRegistered &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.gender, gender) &&
            const DeepCollectionEquality().equals(other.age, age) &&
            const DeepCollectionEquality()
                .equals(other._preferredRegions, _preferredRegions));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(gender),
      const DeepCollectionEquality().hash(age),
      const DeepCollectionEquality().hash(_preferredRegions));

  @JsonKey(ignore: true)
  @override
  _$$AccountRegisteredCopyWith<_$AccountRegistered> get copyWith =>
      __$$AccountRegisteredCopyWithImpl<_$AccountRegistered>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)
        registered,
  }) {
    return registered(id, name, gender, age, preferredRegions);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
  }) {
    return registered?.call(id, name, gender, age, preferredRegions);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(String id, String name, Gender gender, int age,
            List<Region> preferredRegions)?
        registered,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(id, name, gender, age, preferredRegions);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(AccountEmpty value) empty,
    required TResult Function(AccountRegistered value) registered,
  }) {
    return registered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
  }) {
    return registered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(AccountEmpty value)? empty,
    TResult Function(AccountRegistered value)? registered,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(this);
    }
    return orElse();
  }
}

abstract class AccountRegistered extends Account {
  factory AccountRegistered(
      {required final String id,
      required final String name,
      required final Gender gender,
      required final int age,
      required final List<Region> preferredRegions}) = _$AccountRegistered;
  AccountRegistered._() : super._();

  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  List<Region> get preferredRegions => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$AccountRegisteredCopyWith<_$AccountRegistered> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$Booking {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)
        registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BookingEmpty value) empty,
    required TResult Function(BookingRegistered value) registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BookingCopyWith<$Res> {
  factory $BookingCopyWith(Booking value, $Res Function(Booking) then) =
      _$BookingCopyWithImpl<$Res>;
}

/// @nodoc
class _$BookingCopyWithImpl<$Res> implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  final Booking _value;
  // ignore: unused_field
  final $Res Function(Booking) _then;
}

/// @nodoc
abstract class _$$BookingEmptyCopyWith<$Res> {
  factory _$$BookingEmptyCopyWith(
          _$BookingEmpty value, $Res Function(_$BookingEmpty) then) =
      __$$BookingEmptyCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BookingEmptyCopyWithImpl<$Res> extends _$BookingCopyWithImpl<$Res>
    implements _$$BookingEmptyCopyWith<$Res> {
  __$$BookingEmptyCopyWithImpl(
      _$BookingEmpty _value, $Res Function(_$BookingEmpty) _then)
      : super(_value, (v) => _then(v as _$BookingEmpty));

  @override
  _$BookingEmpty get _value => super._value as _$BookingEmpty;
}

/// @nodoc

class _$BookingEmpty extends BookingEmpty {
  _$BookingEmpty() : super._();

  @override
  String toString() {
    return 'Booking.empty()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BookingEmpty);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)
        registered,
  }) {
    return empty();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
  }) {
    return empty?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BookingEmpty value) empty,
    required TResult Function(BookingRegistered value) registered,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class BookingEmpty extends Booking {
  factory BookingEmpty() = _$BookingEmpty;
  BookingEmpty._() : super._();
}

/// @nodoc
abstract class _$$BookingRegisteredCopyWith<$Res> {
  factory _$$BookingRegisteredCopyWith(
          _$BookingRegistered value, $Res Function(_$BookingRegistered) then) =
      __$$BookingRegisteredCopyWithImpl<$Res>;
  $Res call(
      {String bookingId,
      String userId,
      DateTimeRange stay,
      DateTime specialOfferDate,
      RoomType roomType,
      List<MealType> mealOffers,
      int persons,
      int babyBeds,
      bool smoking,
      double price,
      double donation,
      String note});
}

/// @nodoc
class __$$BookingRegisteredCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res>
    implements _$$BookingRegisteredCopyWith<$Res> {
  __$$BookingRegisteredCopyWithImpl(
      _$BookingRegistered _value, $Res Function(_$BookingRegistered) _then)
      : super(_value, (v) => _then(v as _$BookingRegistered));

  @override
  _$BookingRegistered get _value => super._value as _$BookingRegistered;

  @override
  $Res call({
    Object? bookingId = freezed,
    Object? userId = freezed,
    Object? stay = freezed,
    Object? specialOfferDate = freezed,
    Object? roomType = freezed,
    Object? mealOffers = freezed,
    Object? persons = freezed,
    Object? babyBeds = freezed,
    Object? smoking = freezed,
    Object? price = freezed,
    Object? donation = freezed,
    Object? note = freezed,
  }) {
    return _then(_$BookingRegistered(
      bookingId: bookingId == freezed
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: userId == freezed
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      stay: stay == freezed
          ? _value.stay
          : stay // ignore: cast_nullable_to_non_nullable
              as DateTimeRange,
      specialOfferDate: specialOfferDate == freezed
          ? _value.specialOfferDate
          : specialOfferDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      roomType: roomType == freezed
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RoomType,
      mealOffers: mealOffers == freezed
          ? _value._mealOffers
          : mealOffers // ignore: cast_nullable_to_non_nullable
              as List<MealType>,
      persons: persons == freezed
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as int,
      babyBeds: babyBeds == freezed
          ? _value.babyBeds
          : babyBeds // ignore: cast_nullable_to_non_nullable
              as int,
      smoking: smoking == freezed
          ? _value.smoking
          : smoking // ignore: cast_nullable_to_non_nullable
              as bool,
      price: price == freezed
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      donation: donation == freezed
          ? _value.donation
          : donation // ignore: cast_nullable_to_non_nullable
              as double,
      note: note == freezed
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$BookingRegistered extends BookingRegistered {
  _$BookingRegistered(
      {required this.bookingId,
      required this.userId,
      required this.stay,
      required this.specialOfferDate,
      required this.roomType,
      required final List<MealType> mealOffers,
      required this.persons,
      required this.babyBeds,
      required this.smoking,
      required this.price,
      required this.donation,
      required this.note})
      : _mealOffers = mealOffers,
        super._();

  @override
  final String bookingId;
  @override
  final String userId;
  @override
  final DateTimeRange stay;
  @override
  final DateTime specialOfferDate;
  @override
  final RoomType roomType;
  final List<MealType> _mealOffers;
  @override
  List<MealType> get mealOffers {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mealOffers);
  }

  @override
  final int persons;
  @override
  final int babyBeds;
  @override
  final bool smoking;
  @override
  final double price;
  @override
  final double donation;
  @override
  final String note;

  @override
  String toString() {
    return 'Booking.registered(bookingId: $bookingId, userId: $userId, stay: $stay, specialOfferDate: $specialOfferDate, roomType: $roomType, mealOffers: $mealOffers, persons: $persons, babyBeds: $babyBeds, smoking: $smoking, price: $price, donation: $donation, note: $note)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BookingRegistered &&
            const DeepCollectionEquality().equals(other.bookingId, bookingId) &&
            const DeepCollectionEquality().equals(other.userId, userId) &&
            const DeepCollectionEquality().equals(other.stay, stay) &&
            const DeepCollectionEquality()
                .equals(other.specialOfferDate, specialOfferDate) &&
            const DeepCollectionEquality().equals(other.roomType, roomType) &&
            const DeepCollectionEquality()
                .equals(other._mealOffers, _mealOffers) &&
            const DeepCollectionEquality().equals(other.persons, persons) &&
            const DeepCollectionEquality().equals(other.babyBeds, babyBeds) &&
            const DeepCollectionEquality().equals(other.smoking, smoking) &&
            const DeepCollectionEquality().equals(other.price, price) &&
            const DeepCollectionEquality().equals(other.donation, donation) &&
            const DeepCollectionEquality().equals(other.note, note));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(bookingId),
      const DeepCollectionEquality().hash(userId),
      const DeepCollectionEquality().hash(stay),
      const DeepCollectionEquality().hash(specialOfferDate),
      const DeepCollectionEquality().hash(roomType),
      const DeepCollectionEquality().hash(_mealOffers),
      const DeepCollectionEquality().hash(persons),
      const DeepCollectionEquality().hash(babyBeds),
      const DeepCollectionEquality().hash(smoking),
      const DeepCollectionEquality().hash(price),
      const DeepCollectionEquality().hash(donation),
      const DeepCollectionEquality().hash(note));

  @JsonKey(ignore: true)
  @override
  _$$BookingRegisteredCopyWith<_$BookingRegistered> get copyWith =>
      __$$BookingRegisteredCopyWithImpl<_$BookingRegistered>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() empty,
    required TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)
        registered,
  }) {
    return registered(bookingId, userId, stay, specialOfferDate, roomType,
        mealOffers, persons, babyBeds, smoking, price, donation, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
  }) {
    return registered?.call(bookingId, userId, stay, specialOfferDate, roomType,
        mealOffers, persons, babyBeds, smoking, price, donation, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? empty,
    TResult Function(
            String bookingId,
            String userId,
            DateTimeRange stay,
            DateTime specialOfferDate,
            RoomType roomType,
            List<MealType> mealOffers,
            int persons,
            int babyBeds,
            bool smoking,
            double price,
            double donation,
            String note)?
        registered,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(bookingId, userId, stay, specialOfferDate, roomType,
          mealOffers, persons, babyBeds, smoking, price, donation, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BookingEmpty value) empty,
    required TResult Function(BookingRegistered value) registered,
  }) {
    return registered(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
  }) {
    return registered?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BookingEmpty value)? empty,
    TResult Function(BookingRegistered value)? registered,
    required TResult orElse(),
  }) {
    if (registered != null) {
      return registered(this);
    }
    return orElse();
  }
}

abstract class BookingRegistered extends Booking {
  factory BookingRegistered(
      {required final String bookingId,
      required final String userId,
      required final DateTimeRange stay,
      required final DateTime specialOfferDate,
      required final RoomType roomType,
      required final List<MealType> mealOffers,
      required final int persons,
      required final int babyBeds,
      required final bool smoking,
      required final double price,
      required final double donation,
      required final String note}) = _$BookingRegistered;
  BookingRegistered._() : super._();

  String get bookingId => throw _privateConstructorUsedError;
  String get userId => throw _privateConstructorUsedError;
  DateTimeRange get stay => throw _privateConstructorUsedError;
  DateTime get specialOfferDate => throw _privateConstructorUsedError;
  RoomType get roomType => throw _privateConstructorUsedError;
  List<MealType> get mealOffers => throw _privateConstructorUsedError;
  int get persons => throw _privateConstructorUsedError;
  int get babyBeds => throw _privateConstructorUsedError;
  bool get smoking => throw _privateConstructorUsedError;
  double get price => throw _privateConstructorUsedError;
  double get donation => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$BookingRegisteredCopyWith<_$BookingRegistered> get copyWith =>
      throw _privateConstructorUsedError;
}
