// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more informations: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
class _$TargetStateTearOff {
  const _$TargetStateTearOff();

  TargetStatePartial partial(
      {String? id, String? name, Sex? sex, int? age, String? note}) {
    return TargetStatePartial(
      id: id,
      name: name,
      sex: sex,
      age: age,
      note: note,
    );
  }

  TargetStateCompleted completed(
      {required String id,
      required String name,
      required Sex sex,
      required int age,
      required String note}) {
    return TargetStateCompleted(
      id: id,
      name: name,
      sex: sex,
      age: age,
      note: note,
    );
  }
}

/// @nodoc
const $TargetState = _$TargetStateTearOff();

/// @nodoc
mixin _$TargetState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)
        partial,
    required TResult Function(
            String id, String name, Sex sex, int age, String note)
        completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TargetStatePartial value) partial,
    required TResult Function(TargetStateCompleted value) completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TargetStateCopyWith<$Res> {
  factory $TargetStateCopyWith(
          TargetState value, $Res Function(TargetState) then) =
      _$TargetStateCopyWithImpl<$Res>;
}

/// @nodoc
class _$TargetStateCopyWithImpl<$Res> implements $TargetStateCopyWith<$Res> {
  _$TargetStateCopyWithImpl(this._value, this._then);

  final TargetState _value;
  // ignore: unused_field
  final $Res Function(TargetState) _then;
}

/// @nodoc
abstract class $TargetStatePartialCopyWith<$Res> {
  factory $TargetStatePartialCopyWith(
          TargetStatePartial value, $Res Function(TargetStatePartial) then) =
      _$TargetStatePartialCopyWithImpl<$Res>;
  $Res call({String? id, String? name, Sex? sex, int? age, String? note});
}

/// @nodoc
class _$TargetStatePartialCopyWithImpl<$Res>
    extends _$TargetStateCopyWithImpl<$Res>
    implements $TargetStatePartialCopyWith<$Res> {
  _$TargetStatePartialCopyWithImpl(
      TargetStatePartial _value, $Res Function(TargetStatePartial) _then)
      : super(_value, (v) => _then(v as TargetStatePartial));

  @override
  TargetStatePartial get _value => super._value as TargetStatePartial;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sex = freezed,
    Object? age = freezed,
    Object? note = freezed,
  }) {
    return _then(TargetStatePartial(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      sex: sex == freezed
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as Sex?,
      age: age == freezed
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int?,
      note: note == freezed
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$TargetStatePartial implements TargetStatePartial {
  _$TargetStatePartial({this.id, this.name, this.sex, this.age, this.note});

  @override
  final String? id;
  @override
  final String? name;
  @override
  final Sex? sex;
  @override
  final int? age;
  @override
  final String? note;

  @override
  String toString() {
    return 'TargetState.partial(id: $id, name: $name, sex: $sex, age: $age, note: $note)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is TargetStatePartial &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.sex, sex) ||
                const DeepCollectionEquality().equals(other.sex, sex)) &&
            (identical(other.age, age) ||
                const DeepCollectionEquality().equals(other.age, age)) &&
            (identical(other.note, note) ||
                const DeepCollectionEquality().equals(other.note, note)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(sex) ^
      const DeepCollectionEquality().hash(age) ^
      const DeepCollectionEquality().hash(note);

  @JsonKey(ignore: true)
  @override
  $TargetStatePartialCopyWith<TargetStatePartial> get copyWith =>
      _$TargetStatePartialCopyWithImpl<TargetStatePartial>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)
        partial,
    required TResult Function(
            String id, String name, Sex sex, int age, String note)
        completed,
  }) {
    return partial(id, name, sex, age, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
  }) {
    return partial?.call(id, name, sex, age, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
    required TResult orElse(),
  }) {
    if (partial != null) {
      return partial(id, name, sex, age, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TargetStatePartial value) partial,
    required TResult Function(TargetStateCompleted value) completed,
  }) {
    return partial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
  }) {
    return partial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (partial != null) {
      return partial(this);
    }
    return orElse();
  }
}

abstract class TargetStatePartial implements TargetState {
  factory TargetStatePartial(
      {String? id,
      String? name,
      Sex? sex,
      int? age,
      String? note}) = _$TargetStatePartial;

  String? get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  Sex? get sex => throw _privateConstructorUsedError;
  int? get age => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TargetStatePartialCopyWith<TargetStatePartial> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TargetStateCompletedCopyWith<$Res> {
  factory $TargetStateCompletedCopyWith(TargetStateCompleted value,
          $Res Function(TargetStateCompleted) then) =
      _$TargetStateCompletedCopyWithImpl<$Res>;
  $Res call({String id, String name, Sex sex, int age, String note});
}

/// @nodoc
class _$TargetStateCompletedCopyWithImpl<$Res>
    extends _$TargetStateCopyWithImpl<$Res>
    implements $TargetStateCompletedCopyWith<$Res> {
  _$TargetStateCompletedCopyWithImpl(
      TargetStateCompleted _value, $Res Function(TargetStateCompleted) _then)
      : super(_value, (v) => _then(v as TargetStateCompleted));

  @override
  TargetStateCompleted get _value => super._value as TargetStateCompleted;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? sex = freezed,
    Object? age = freezed,
    Object? note = freezed,
  }) {
    return _then(TargetStateCompleted(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      sex: sex == freezed
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as Sex,
      age: age == freezed
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
      note: note == freezed
          ? _value.note
          : note // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$TargetStateCompleted implements TargetStateCompleted {
  _$TargetStateCompleted(
      {required this.id,
      required this.name,
      required this.sex,
      required this.age,
      required this.note});

  @override
  final String id;
  @override
  final String name;
  @override
  final Sex sex;
  @override
  final int age;
  @override
  final String note;

  @override
  String toString() {
    return 'TargetState.completed(id: $id, name: $name, sex: $sex, age: $age, note: $note)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is TargetStateCompleted &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.name, name) ||
                const DeepCollectionEquality().equals(other.name, name)) &&
            (identical(other.sex, sex) ||
                const DeepCollectionEquality().equals(other.sex, sex)) &&
            (identical(other.age, age) ||
                const DeepCollectionEquality().equals(other.age, age)) &&
            (identical(other.note, note) ||
                const DeepCollectionEquality().equals(other.note, note)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(name) ^
      const DeepCollectionEquality().hash(sex) ^
      const DeepCollectionEquality().hash(age) ^
      const DeepCollectionEquality().hash(note);

  @JsonKey(ignore: true)
  @override
  $TargetStateCompletedCopyWith<TargetStateCompleted> get copyWith =>
      _$TargetStateCompletedCopyWithImpl<TargetStateCompleted>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)
        partial,
    required TResult Function(
            String id, String name, Sex sex, int age, String note)
        completed,
  }) {
    return completed(id, name, sex, age, note);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
  }) {
    return completed?.call(id, name, sex, age, note);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(
            String? id, String? name, Sex? sex, int? age, String? note)?
        partial,
    TResult Function(String id, String name, Sex sex, int age, String note)?
        completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(id, name, sex, age, note);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(TargetStatePartial value) partial,
    required TResult Function(TargetStateCompleted value) completed,
  }) {
    return completed(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
  }) {
    return completed?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(TargetStatePartial value)? partial,
    TResult Function(TargetStateCompleted value)? completed,
    required TResult orElse(),
  }) {
    if (completed != null) {
      return completed(this);
    }
    return orElse();
  }
}

abstract class TargetStateCompleted implements TargetState {
  factory TargetStateCompleted(
      {required String id,
      required String name,
      required Sex sex,
      required int age,
      required String note}) = _$TargetStateCompleted;

  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  Sex get sex => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;
  String get note => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TargetStateCompletedCopyWith<TargetStateCompleted> get copyWith =>
      throw _privateConstructorUsedError;
}
