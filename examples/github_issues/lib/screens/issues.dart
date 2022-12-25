// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:github/github.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../components/screen.dart';
import '../l10n/locale_keys.g.dart';
import '../models/auth.dart';
import '../models/issues.dart';
import 'issues.fcp.dart';

part 'issues.g.dart';

class IssuesPage extends Screen {
  const IssuesPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(issuesPresenterProvider.notifier);

    return Column(
      children: [
        // TODO: labels, milestone
        presenter.fields.repository(context),
        // TODO: expand-collapse
        presenter.fields.issueState(context),
        presenter.fields.since(context),
        presenter.fields.sortKey(context),
        presenter.fields.direction(context),
        presenter.fields.issuesPerPages(context),
        ElevatedButton(
          onPressed: presenter.submit(context),
          child: Text('Search'),
        ),
        // List
        IssuesListPane(),
        Row(
          children: [
            // Previous
            ElevatedButton(
              onPressed: presenter.previousPage,
              child: Text('Previous'),
            ),
            // Next
            ElevatedButton(
              onPressed: presenter.nextPage,
              child: Text('Next'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  String get title => LocaleKeys.issues_title.tr();
}

@formCompanion
@Riverpod(keepAlive: true)
class IssuesPresenter extends Notifier<IssuesSearchCondition>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  IssuesPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(name: 'repository')
        ..enumerated<IssueListSortKey>(name: 'sortKey')
        ..enumerated<IssueState>(name: 'issueState')
        ..enumerated<ListDirection>(name: 'direction')
        ..dateTime(name: 'since')
        ..integerText(
          name: 'issuesPerPages',
          initialValue: 20,
        ),
    );
  }

  @override
  IssuesSearchCondition build() => IssuesSearchCondition();

  @override
  FutureOr<void> doSubmit() {
    state = IssuesSearchCondition(
      repository: repository.value == null
          ? null
          : RepositorySlug.full(repository.value!),
      // milestoneNumber: ,
      since: since.value,
      sort: sortKey.value,
      state: issueState.value,
      direction: direction.value,
      // labels: labels.value,
      issuesPerPage: issuesPerPages.value ?? 20,
    );
  }

  // TODO: max page
  void Function()? get nextPage => () {
        ref.read(pageProvider.state).state++;
      };

  void Function()? get previousPage {
    final old = ref.read(pageProvider);
    if (old == 1) {
      return null;
    } else {
      return () => ref.read(pageProvider.state).state = old - 1;
    }
  }
}

class IssuesListPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final issues = ref.watch(issuesProvider);
    // TODO: implement build
    throw UnimplementedError();
  }
}

final pageProvider = StateProvider<int>((_) => 1);

@riverpod
Future<List<Issue>> issues(IssuesRef ref) async => getIssues(
      condition: ref.watch(issuesPresenterProvider),
      page: ref.watch(pageProvider),
      token: await ref.watch(authTokenNotifierProvider.future),
    );
