// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/codegen_loader.g.dart';
import 'manual_validation_vanilla_form.dart';
import 'routes.dart';

class _MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final pages = watch(pagesProvider);
    return MaterialApp(
      localizationsDelegates: [
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      home: Navigator(
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
          child: _MyApp(),
        ),
      );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(MyApp());
}
