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
    TResult? Function()? empty,
    TResult? Function(String id, String name, Gender gender, int age,
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
    TResult? Function(AccountEmpty value)? empty,
    TResult? Function(AccountRegistered value)? registered,
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
      _$AccountCopyWithImpl<$Res, Account>;
}

/// @nodoc
class _$AccountCopyWithImpl<$Res, $Val extends Account>
    implements $AccountCopyWith<$Res> {
  _$AccountCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$AccountEmptyCopyWith<$Res> {
  factory _$$AccountEmptyCopyWith(
          _$AccountEmpty value, $Res Function(_$AccountEmpty) then) =
      __$$AccountEmptyCopyWithImpl<$Res>;
}

/// @nodoc
class __$$AccountEmptyCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountEmpty>
    implements _$$AccountEmptyCopyWith<$Res> {
  __$$AccountEmptyCopyWithImpl(
      _$AccountEmpty _value, $Res Function(_$AccountEmpty) _then)
      : super(_value, _then);
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
    TResult? Function()? empty,
    TResult? Function(String id, String name, Gender gender, int age,
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
    TResult? Function(AccountEmpty value)? empty,
    TResult? Function(AccountRegistered value)? registered,
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
  @useResult
  $Res call(
      {String id,
      String name,
      Gender gender,
      int age,
      List<Region> preferredRegions});
}

/// @nodoc
class __$$AccountRegisteredCopyWithImpl<$Res>
    extends _$AccountCopyWithImpl<$Res, _$AccountRegistered>
    implements _$$AccountRegisteredCopyWith<$Res> {
  __$$AccountRegisteredCopyWithImpl(
      _$AccountRegistered _value, $Res Function(_$AccountRegistered) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? gender = null,
    Object? age = null,
    Object? preferredRegions = null,
  }) {
    return _then(_$AccountRegistered(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      preferredRegions: null == preferredRegions
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
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.age, age) || other.age == age) &&
            const DeepCollectionEquality()
                .equals(other._preferredRegions, _preferredRegions));
  }

  @override
  int get hashCode => Object.hash(runtimeType, id, name, gender, age,
      const DeepCollectionEquality().hash(_preferredRegions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
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
    TResult? Function()? empty,
    TResult? Function(String id, String name, Gender gender, int age,
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
    TResult? Function(AccountEmpty value)? empty,
    TResult? Function(AccountRegistered value)? registered,
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

  String get id;
  String get name;
  Gender get gender;
  int get age;
  List<Region> get preferredRegions;
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
    TResult? Function()? empty,
    TResult? Function(
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
    TResult? Function(BookingEmpty value)? empty,
    TResult? Function(BookingRegistered value)? registered,
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
      _$BookingCopyWithImpl<$Res, Booking>;
}

/// @nodoc
class _$BookingCopyWithImpl<$Res, $Val extends Booking>
    implements $BookingCopyWith<$Res> {
  _$BookingCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$BookingEmptyCopyWith<$Res> {
  factory _$$BookingEmptyCopyWith(
          _$BookingEmpty value, $Res Function(_$BookingEmpty) then) =
      __$$BookingEmptyCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BookingEmptyCopyWithImpl<$Res>
    extends _$BookingCopyWithImpl<$Res, _$BookingEmpty>
    implements _$$BookingEmptyCopyWith<$Res> {
  __$$BookingEmptyCopyWithImpl(
      _$BookingEmpty _value, $Res Function(_$BookingEmpty) _then)
      : super(_value, _then);
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
    TResult? Function()? empty,
    TResult? Function(
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
    TResult? Function(BookingEmpty value)? empty,
    TResult? Function(BookingRegistered value)? registered,
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
  @useResult
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
    extends _$BookingCopyWithImpl<$Res, _$BookingRegistered>
    implements _$$BookingRegisteredCopyWith<$Res> {
  __$$BookingRegisteredCopyWithImpl(
      _$BookingRegistered _value, $Res Function(_$BookingRegistered) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bookingId = null,
    Object? userId = null,
    Object? stay = null,
    Object? specialOfferDate = null,
    Object? roomType = null,
    Object? mealOffers = null,
    Object? persons = null,
    Object? babyBeds = null,
    Object? smoking = null,
    Object? price = null,
    Object? donation = null,
    Object? note = null,
  }) {
    return _then(_$BookingRegistered(
      bookingId: null == bookingId
          ? _value.bookingId
          : bookingId // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      stay: null == stay
          ? _value.stay
          : stay // ignore: cast_nullable_to_non_nullable
              as DateTimeRange,
      specialOfferDate: null == specialOfferDate
          ? _value.specialOfferDate
          : specialOfferDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      roomType: null == roomType
          ? _value.roomType
          : roomType // ignore: cast_nullable_to_non_nullable
              as RoomType,
      mealOffers: null == mealOffers
          ? _value._mealOffers
          : mealOffers // ignore: cast_nullable_to_non_nullable
              as List<MealType>,
      persons: null == persons
          ? _value.persons
          : persons // ignore: cast_nullable_to_non_nullable
              as int,
      babyBeds: null == babyBeds
          ? _value.babyBeds
          : babyBeds // ignore: cast_nullable_to_non_nullable
              as int,
      smoking: null == smoking
          ? _value.smoking
          : smoking // ignore: cast_nullable_to_non_nullable
              as bool,
      price: null == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as double,
      donation: null == donation
          ? _value.donation
          : donation // ignore: cast_nullable_to_non_nullable
              as double,
      note: null == note
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
            (identical(other.bookingId, bookingId) ||
                other.bookingId == bookingId) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.stay, stay) || other.stay == stay) &&
            (identical(other.specialOfferDate, specialOfferDate) ||
                other.specialOfferDate == specialOfferDate) &&
            (identical(other.roomType, roomType) ||
                other.roomType == roomType) &&
            const DeepCollectionEquality()
                .equals(other._mealOffers, _mealOffers) &&
            (identical(other.persons, persons) || other.persons == persons) &&
            (identical(other.babyBeds, babyBeds) ||
                other.babyBeds == babyBeds) &&
            (identical(other.smoking, smoking) || other.smoking == smoking) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.donation, donation) ||
                other.donation == donation) &&
            (identical(other.note, note) || other.note == note));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      bookingId,
      userId,
      stay,
      specialOfferDate,
      roomType,
      const DeepCollectionEquality().hash(_mealOffers),
      persons,
      babyBeds,
      smoking,
      price,
      donation,
      note);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
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
    TResult? Function()? empty,
    TResult? Function(
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
    TResult? Function(BookingEmpty value)? empty,
    TResult? Function(BookingRegistered value)? registered,
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

  String get bookingId;
  String get userId;
  DateTimeRange get stay;
  DateTime get specialOfferDate;
  RoomType get roomType;
  List<MealType> get mealOffers;
  int get persons;
  int get babyBeds;
  bool get smoking;
  double get price;
  double get donation;
  String get note;
  @JsonKey(ignore: true)
  _$$BookingRegisteredCopyWith<_$BookingRegistered> get copyWith =>
      throw _privateConstructorUsedError;
}
