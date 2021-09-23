// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_validation_form_builder.dart';
import 'auto_validation_vanilla_form.dart';
import 'l10n/locale_keys.g.dart';
import 'manual_validation_form_builder.dart';
import 'manual_validation_vanilla_form.dart';
import 'routes.dart';

abstract class Screen extends ConsumerWidget {
  String get title;

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
                  LocaleKeys.manual_vanilla_title.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: ManualValidationVanillaFormPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_vanilla_title.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: AutoValidationVanillaFormPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.manual_flutterFormBuilder_title.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: ManualValidationFormBuilderPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.auto_flutterFormBuilder_title.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: AutoValidationFormBuilderPage(),
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
