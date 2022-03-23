// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n/codegen_loader.g.dart';
import 'routes.dart';

/// This is required to work
/// [BuildContextEasyLocalizationExtension.localizationDelegates] correctly.
class _App extends ConsumerWidget {
  const _App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pages = ref.watch(pagesProvider.state);
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
          pages.state.add(homePage);
          return true;
        },
      ),
    );
  }
}

/// Application.
class App extends StatelessWidget {
  /// Constructor.
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ProviderScope(
        child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ja')],
          path: 'resources/langs',
          fallbackLocale: const Locale('en'),
          assetLoader: const CodegenLoader(),
          child: const _App(),
        ),
      );
}
