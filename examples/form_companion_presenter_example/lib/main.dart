// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auto_validation_form_builder.dart';
import 'auto_validation_vanilla_form.dart';
import 'l10n/codegen_loader.g.dart';
import 'l10n/locale_keys.g.dart';
import 'manual_validation_form_builder.dart';
import 'manual_validation_vanilla_form.dart';

final _pages = [
  MaterialPage<dynamic>(child: ManualValidationVanillaFormPage())
];

final _pagesProvider = StateProvider((_) => _pages);

class _Screen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final pages = watch(_pagesProvider);
    return MaterialApp(
      localizationsDelegates: [
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      home: Scaffold(
        appBar: AppBar(
          title: Text(LocaleKeys.title.tr()),
        ),
        drawer: Drawer(
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  LocaleKeys.drawer_item_manual_vanilla.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: ManualValidationVanillaFormPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.drawer_item_auto_vanilla.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: AutoValidationVanillaFormPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.drawer_item_manual_flutterFormBuilder.tr(),
                ),
                onTap: () => pages.state = [
                  MaterialPage<dynamic>(
                    child: ManualValidationFormBuilderPage(),
                  )
                ],
              ),
              ListTile(
                title: Text(
                  LocaleKeys.drawer_item_auto_flutterFormBuilder.tr(),
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
        body: Navigator(
          pages: pages.state,
          onPopPage: (route, dynamic result) {
            if (!route.didPop(result)) {
              return false;
            }

            pages.state.clear();
            pages.state.add(
              MaterialPage<dynamic>(
                child: ManualValidationVanillaFormPage(),
              ),
            );
            return true;
          },
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ProviderScope(
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ja')],
          path: 'resources/langs',
          fallbackLocale: const Locale('en'),
          assetLoader: const CodegenLoader(),
          child: _Screen(),
        ),
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(MyApp());
}
