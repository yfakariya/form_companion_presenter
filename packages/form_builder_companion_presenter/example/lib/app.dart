// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

import 'l10n/codegen_loader.g.dart';
import 'routes.dart';

/// This is required to work
/// [BuildContextEasyLocalizationExtension.localizationDelegates] correctly.
class _App extends ConsumerWidget {
  const _App();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      routerDelegate: router.routerDelegate,
      localizationsDelegates: [
        ...context.localizationDelegates,
        FormBuilderLocalizations.delegate,
      ],
      supportedLocales: context.supportedLocales,
    );
  }
}

/// Application.
class App extends StatelessWidget {
  /// Constructor.
  const App();

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
