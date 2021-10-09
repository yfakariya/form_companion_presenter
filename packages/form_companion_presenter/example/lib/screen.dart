// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_validation_vanilla_form.dart';
import 'home.dart';
import 'l10n/locale_keys.g.dart';
import 'manual_validation_vanilla_form.dart';
import 'routes.dart';

/// Base class of all example widgets.
///
/// This class provides basic structure, menu, and navigation.
abstract class Screen extends ConsumerWidget {
  /// Constructor.
  const Screen({Key? key}) : super(key: key);

  /// Gets a title of the page.
  String get title;

  /// Builds page content.
  Widget buildPage(BuildContext context, ScopedReader watch);

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final pages = watch(pagesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocaleKeys.titleTemplate.tr(
            namedArgs: {
              'screenName': title,
            },
          ),
        ),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  LocaleKeys.home_title.tr(),
                ),
                onTap: () => pages.state = [
                  const MaterialPage<dynamic>(
                    child: HomePage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.manual_vanilla_title.tr(),
                ),
                onTap: () => pages.state = [
                  const MaterialPage<dynamic>(
                    child: ManualValidationVanillaFormAccountPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_vanilla_title.tr(),
                ),
                onTap: () => pages.state = [
                  const MaterialPage<dynamic>(
                    child: AutoValidationVanillaFormAccountPage(),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: buildPage(context, watch),
        ),
      ),
    );
  }
}
