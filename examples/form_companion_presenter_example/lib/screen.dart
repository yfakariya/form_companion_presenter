// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/locale_keys.g.dart';
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
  Widget buildPage(BuildContext context, WidgetRef ref);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(pagesProvider.state);

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
                onTap: () => pages.state = homeRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.manual_vanilla_title.tr(),
                ),
                onTap: () => pages.state = manualVanillaAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.bulk_auto_vanilla_title.tr(),
                ),
                onTap: () => pages.state = bulkAutoVanillaAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_vanilla_title.tr(),
                ),
                onTap: () => pages.state = autoVanillaAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.manual_flutterFormBuilderAccount_title.tr(),
                ),
                onTap: () => pages.state = manualFormBuilderAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.manual_flutterFormBuilderBooking_title.tr(),
                ),
                onTap: () => pages.state = manualFormBuilderBookingRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.bulk_auto_flutterFormBuilderAccount_title.tr(),
                ),
                onTap: () => pages.state = bulkAutoFormBuilderAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.bulk_auto_flutterFormBuilderBooking_title.tr(),
                ),
                onTap: () => pages.state = bulkAutoFormBuilderBookingRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_flutterFormBuilderAccount_title.tr(),
                ),
                onTap: () => pages.state = autoFormBuilderAccountRoute,
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_flutterFormBuilderBooking_title.tr(),
                ),
                onTap: () => pages.state = autoFormBuilderBookingRoute,
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: buildPage(context, ref),
        ),
      ),
    );
  }
}
