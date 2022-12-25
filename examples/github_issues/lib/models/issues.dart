// See LICENCE file in the root.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:github/github.dart';

import 'auth.dart';

part 'issues.freezed.dart';

/// A state of an issue.
enum IssueState {
  open,
  closed,
  all,
}

/// Represents direction of an issues list.
enum ListDirection {
  asc,
  desc,
}

/// Represents sort key of an issues list.
enum IssueListSortKey {
  created,
  updated,
  comments,
}

/// Encapsulates issues search conditions.
@freezed
class IssuesSearchCondition with _$IssuesSearchCondition {
  const factory IssuesSearchCondition({
    /// Repository slug for issues.
    RepositorySlug? repository,

    /// Count of issues per each API call.
    @Default(30) int? issuesPerPage,

    /// A number of milestone to filter issues.
    int? milestoneNumber,

    /// A state of issues to filter issues.
    @Default(IssueState.open) IssueState? state,

    /// Direction of returned issues list.
    @Default(ListDirection.desc) ListDirection? direction,

    /// A sort key of returned issues list.
    @Default(IssueListSortKey.created) IssueListSortKey? sort,

    /// Oldest date time to filter issues.
    DateTime? since,

    /// List of labels to filter issues.
    @Default(const <String>[]) List<String> labels,
  }) = _IssuesSearchCondition;
}

/// Gets a page of issue list.
/// Note that [page] is 1-based instead of 0-based.
Future<List<Issue>> getIssues({
  required AuthTokens token,
  IssuesSearchCondition condition = const IssuesSearchCondition(),
  int page = 1,
}) async {
  final path = condition.repository == null
      ? '/issues'
      : '/repos/${condition.repository!.fullName}/issues';
  final parameters = {
    'page': page.toStringAsFixed(0),
  };

  if (condition.issuesPerPage != null) {
    parameters['per_page'] = condition.issuesPerPage!.toStringAsFixed(0);
  }

  if (condition.state != null) {
    parameters['state'] = condition.state!.name;
  }

  if (condition.direction != null) {
    parameters['direction'] = condition.direction!.name;
  }

  if (condition.sort != null) {
    parameters['sort'] = condition.sort!.name;
  }

  if (condition.milestoneNumber != null) {
    parameters['milestone'] = condition.milestoneNumber!.toStringAsFixed(0);
  }

  if (condition.since != null) {
    parameters['since'] = condition.since!.toUtc().toIso8601String();
  }

  if (condition.labels.isNotEmpty) {
    parameters['labels'] = condition.labels.join(',');
  }

  final github = GitHub(auth: Authentication.withToken(token.accessToken));
  return github.getJSON<List<Object?>?, List<Issue>>(
    path,
    convert: (json) =>
        json?.whereType<Map<String, dynamic>>().map(Issue.fromJson).toList() ??
        [],
    params: parameters,
  );
}
