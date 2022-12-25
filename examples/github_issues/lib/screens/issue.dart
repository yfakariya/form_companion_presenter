// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:github_issues/models/credential.dart';

import '../components/screen.dart';
import '../l10n/locale_keys.g.dart';

class IssuePage extends Screen {
  final String issueId;
  const IssuePage({
    super.key,
    required this.issueId,
  });

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    // TODO: implement buildPage
    throw UnimplementedError();
  }

  @override
  String get title => LocaleKeys.issue_title.tr();
}
