// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'issues.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$IssuesSearchCondition {
  /// Repository slug for issues.
  RepositorySlug? get repository => throw _privateConstructorUsedError;

  /// Count of issues per each API call.
  int? get issuesPerPage => throw _privateConstructorUsedError;

  /// A number of milestone to filter issues.
  int? get milestoneNumber => throw _privateConstructorUsedError;

  /// A state of issues to filter issues.
  IssueState? get state => throw _privateConstructorUsedError;

  /// Direction of returned issues list.
  ListDirection? get direction => throw _privateConstructorUsedError;

  /// A sort key of returned issues list.
  IssueListSortKey? get sort => throw _privateConstructorUsedError;

  /// Oldest date time to filter issues.
  DateTime? get since => throw _privateConstructorUsedError;

  /// List of labels to filter issues.
  List<String> get labels => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $IssuesSearchConditionCopyWith<IssuesSearchCondition> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $IssuesSearchConditionCopyWith<$Res> {
  factory $IssuesSearchConditionCopyWith(IssuesSearchCondition value,
          $Res Function(IssuesSearchCondition) then) =
      _$IssuesSearchConditionCopyWithImpl<$Res, IssuesSearchCondition>;
  @useResult
  $Res call(
      {RepositorySlug? repository,
      int? issuesPerPage,
      int? milestoneNumber,
      IssueState? state,
      ListDirection? direction,
      IssueListSortKey? sort,
      DateTime? since,
      List<String> labels});
}

/// @nodoc
class _$IssuesSearchConditionCopyWithImpl<$Res,
        $Val extends IssuesSearchCondition>
    implements $IssuesSearchConditionCopyWith<$Res> {
  _$IssuesSearchConditionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repository = freezed,
    Object? issuesPerPage = freezed,
    Object? milestoneNumber = freezed,
    Object? state = freezed,
    Object? direction = freezed,
    Object? sort = freezed,
    Object? since = freezed,
    Object? labels = null,
  }) {
    return _then(_value.copyWith(
      repository: freezed == repository
          ? _value.repository
          : repository // ignore: cast_nullable_to_non_nullable
              as RepositorySlug?,
      issuesPerPage: freezed == issuesPerPage
          ? _value.issuesPerPage
          : issuesPerPage // ignore: cast_nullable_to_non_nullable
              as int?,
      milestoneNumber: freezed == milestoneNumber
          ? _value.milestoneNumber
          : milestoneNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as IssueState?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as ListDirection?,
      sort: freezed == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as IssueListSortKey?,
      since: freezed == since
          ? _value.since
          : since // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      labels: null == labels
          ? _value.labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_IssuesSearchConditionCopyWith<$Res>
    implements $IssuesSearchConditionCopyWith<$Res> {
  factory _$$_IssuesSearchConditionCopyWith(_$_IssuesSearchCondition value,
          $Res Function(_$_IssuesSearchCondition) then) =
      __$$_IssuesSearchConditionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {RepositorySlug? repository,
      int? issuesPerPage,
      int? milestoneNumber,
      IssueState? state,
      ListDirection? direction,
      IssueListSortKey? sort,
      DateTime? since,
      List<String> labels});
}

/// @nodoc
class __$$_IssuesSearchConditionCopyWithImpl<$Res>
    extends _$IssuesSearchConditionCopyWithImpl<$Res, _$_IssuesSearchCondition>
    implements _$$_IssuesSearchConditionCopyWith<$Res> {
  __$$_IssuesSearchConditionCopyWithImpl(_$_IssuesSearchCondition _value,
      $Res Function(_$_IssuesSearchCondition) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? repository = freezed,
    Object? issuesPerPage = freezed,
    Object? milestoneNumber = freezed,
    Object? state = freezed,
    Object? direction = freezed,
    Object? sort = freezed,
    Object? since = freezed,
    Object? labels = null,
  }) {
    return _then(_$_IssuesSearchCondition(
      repository: freezed == repository
          ? _value.repository
          : repository // ignore: cast_nullable_to_non_nullable
              as RepositorySlug?,
      issuesPerPage: freezed == issuesPerPage
          ? _value.issuesPerPage
          : issuesPerPage // ignore: cast_nullable_to_non_nullable
              as int?,
      milestoneNumber: freezed == milestoneNumber
          ? _value.milestoneNumber
          : milestoneNumber // ignore: cast_nullable_to_non_nullable
              as int?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as IssueState?,
      direction: freezed == direction
          ? _value.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as ListDirection?,
      sort: freezed == sort
          ? _value.sort
          : sort // ignore: cast_nullable_to_non_nullable
              as IssueListSortKey?,
      since: freezed == since
          ? _value.since
          : since // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      labels: null == labels
          ? _value._labels
          : labels // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// @nodoc

class _$_IssuesSearchCondition implements _IssuesSearchCondition {
  const _$_IssuesSearchCondition(
      {this.repository,
      this.issuesPerPage = 30,
      this.milestoneNumber,
      this.state = IssueState.open,
      this.direction = ListDirection.desc,
      this.sort = IssueListSortKey.created,
      this.since,
      final List<String> labels = const <String>[]})
      : _labels = labels;

  /// Repository slug for issues.
  @override
  final RepositorySlug? repository;

  /// Count of issues per each API call.
  @override
  @JsonKey()
  final int? issuesPerPage;

  /// A number of milestone to filter issues.
  @override
  final int? milestoneNumber;

  /// A state of issues to filter issues.
  @override
  @JsonKey()
  final IssueState? state;

  /// Direction of returned issues list.
  @override
  @JsonKey()
  final ListDirection? direction;

  /// A sort key of returned issues list.
  @override
  @JsonKey()
  final IssueListSortKey? sort;

  /// Oldest date time to filter issues.
  @override
  final DateTime? since;

  /// List of labels to filter issues.
  final List<String> _labels;

  /// List of labels to filter issues.
  @override
  @JsonKey()
  List<String> get labels {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_labels);
  }

  @override
  String toString() {
    return 'IssuesSearchCondition(repository: $repository, issuesPerPage: $issuesPerPage, milestoneNumber: $milestoneNumber, state: $state, direction: $direction, sort: $sort, since: $since, labels: $labels)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_IssuesSearchCondition &&
            (identical(other.repository, repository) ||
                other.repository == repository) &&
            (identical(other.issuesPerPage, issuesPerPage) ||
                other.issuesPerPage == issuesPerPage) &&
            (identical(other.milestoneNumber, milestoneNumber) ||
                other.milestoneNumber == milestoneNumber) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.sort, sort) || other.sort == sort) &&
            (identical(other.since, since) || other.since == since) &&
            const DeepCollectionEquality().equals(other._labels, _labels));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      repository,
      issuesPerPage,
      milestoneNumber,
      state,
      direction,
      sort,
      since,
      const DeepCollectionEquality().hash(_labels));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_IssuesSearchConditionCopyWith<_$_IssuesSearchCondition> get copyWith =>
      __$$_IssuesSearchConditionCopyWithImpl<_$_IssuesSearchCondition>(
          this, _$identity);
}

abstract class _IssuesSearchCondition implements IssuesSearchCondition {
  const factory _IssuesSearchCondition(
      {final RepositorySlug? repository,
      final int? issuesPerPage,
      final int? milestoneNumber,
      final IssueState? state,
      final ListDirection? direction,
      final IssueListSortKey? sort,
      final DateTime? since,
      final List<String> labels}) = _$_IssuesSearchCondition;

  @override

  /// Repository slug for issues.
  RepositorySlug? get repository;
  @override

  /// Count of issues per each API call.
  int? get issuesPerPage;
  @override

  /// A number of milestone to filter issues.
  int? get milestoneNumber;
  @override

  /// A state of issues to filter issues.
  IssueState? get state;
  @override

  /// Direction of returned issues list.
  ListDirection? get direction;
  @override

  /// A sort key of returned issues list.
  IssueListSortKey? get sort;
  @override

  /// Oldest date time to filter issues.
  DateTime? get since;
  @override

  /// List of labels to filter issues.
  List<String> get labels;
  @override
  @JsonKey(ignore: true)
  _$$_IssuesSearchConditionCopyWith<_$_IssuesSearchCondition> get copyWith =>
      throw _privateConstructorUsedError;
}
