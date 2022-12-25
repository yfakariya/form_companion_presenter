// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'credential.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$OAuthCredential {
  String get clientId => throw _privateConstructorUsedError;
  String get clientSecret => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OAuthCredentialCopyWith<OAuthCredential> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OAuthCredentialCopyWith<$Res> {
  factory $OAuthCredentialCopyWith(
          OAuthCredential value, $Res Function(OAuthCredential) then) =
      _$OAuthCredentialCopyWithImpl<$Res, OAuthCredential>;
  @useResult
  $Res call({String clientId, String clientSecret});
}

/// @nodoc
class _$OAuthCredentialCopyWithImpl<$Res, $Val extends OAuthCredential>
    implements $OAuthCredentialCopyWith<$Res> {
  _$OAuthCredentialCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientId = null,
    Object? clientSecret = null,
  }) {
    return _then(_value.copyWith(
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      clientSecret: null == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_OAuthCredentialCopyWith<$Res>
    implements $OAuthCredentialCopyWith<$Res> {
  factory _$$_OAuthCredentialCopyWith(
          _$_OAuthCredential value, $Res Function(_$_OAuthCredential) then) =
      __$$_OAuthCredentialCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String clientId, String clientSecret});
}

/// @nodoc
class __$$_OAuthCredentialCopyWithImpl<$Res>
    extends _$OAuthCredentialCopyWithImpl<$Res, _$_OAuthCredential>
    implements _$$_OAuthCredentialCopyWith<$Res> {
  __$$_OAuthCredentialCopyWithImpl(
      _$_OAuthCredential _value, $Res Function(_$_OAuthCredential) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? clientId = null,
    Object? clientSecret = null,
  }) {
    return _then(_$_OAuthCredential(
      clientId: null == clientId
          ? _value.clientId
          : clientId // ignore: cast_nullable_to_non_nullable
              as String,
      clientSecret: null == clientSecret
          ? _value.clientSecret
          : clientSecret // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$_OAuthCredential implements _OAuthCredential {
  _$_OAuthCredential({required this.clientId, required this.clientSecret});

  @override
  final String clientId;
  @override
  final String clientSecret;

  @override
  String toString() {
    return 'OAuthCredential(clientId: $clientId, clientSecret: $clientSecret)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_OAuthCredential &&
            (identical(other.clientId, clientId) ||
                other.clientId == clientId) &&
            (identical(other.clientSecret, clientSecret) ||
                other.clientSecret == clientSecret));
  }

  @override
  int get hashCode => Object.hash(runtimeType, clientId, clientSecret);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_OAuthCredentialCopyWith<_$_OAuthCredential> get copyWith =>
      __$$_OAuthCredentialCopyWithImpl<_$_OAuthCredential>(this, _$identity);
}

abstract class _OAuthCredential implements OAuthCredential {
  factory _OAuthCredential(
      {required final String clientId,
      required final String clientSecret}) = _$_OAuthCredential;

  @override
  String get clientId;
  @override
  String get clientSecret;
  @override
  @JsonKey(ignore: true)
  _$$_OAuthCredentialCopyWith<_$_OAuthCredential> get copyWith =>
      throw _privateConstructorUsedError;
}
