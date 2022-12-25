// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:go_router/go_router.dart';

import '../components/screen.dart';
import '../l10n/locale_keys.g.dart';
import '../models/credential.dart';
import '../routes.dart';
import 'login.fcp.dart';

class LoginPage extends Screen {
  const LoginPage({super.key});

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final credential = ref.watch(oAuthCredentialRepositoryProvider);
    final presenter = ref.watch(loginPresenterProvider);

    return Column(
      children: [
        // ignore: unnecessary_parenthesis
        ...(credential.hasError
            ? [
                Text(
                  credential.error?.toString() ?? 'ERROR',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).errorColor),
                ),
              ]
            : []),
        Text(
          
          LocaleKeys.login_credentialDescription.tr()
          'Input GitHub client ID and client secret you registered. See https://docs.github.com/developers/apps/building-oauth-apps/creating-an-oauth-app for details.',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        // Forms
        presenter.fields.clientId(context),
        presenter.fields.clientSecret(context),
        ElevatedButton(
          onPressed: presenter.submit(context),
          child: Text(
            LocaleKeys.login_loginButtonLabel.tr(),
          ),
        ),
      ],
    );
  }

  @override
  String get title => LocaleKeys.login_title.tr();
}

@formCompanion
class LoginPresenter with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final OAuthCredentialRepository _oAuthCredentialRepository;
  final GoRouter _router;
  LoginPresenter(
    this._oAuthCredentialRepository,
    this._router,
    OAuthCredential? initialValue,
  ) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'clientId',
          initialValue: initialValue?.clientId,
        )
        ..string(
          name: 'clientSecret',
          initialValue: initialValue?.clientSecret,
        )
        ..booleanWithField<FormBuilderCheckbox>(
          name: 'doPersist',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    if (await _oAuthCredentialRepository.store(
      OAuthCredential(
        clientId: clientId.value!,
        clientSecret: clientSecret.value!,
      ),
      doPersist: doPersist.value!,
    )) {
      _router.go(homeRoute);
    }
  }
}

final loginPresenterProvider = Provider.autoDispose(
  (ref) => LoginPresenter(
    ref.watch(oAuthCredentialRepositoryProvider.notifier),
    ref.watch(routerProvider),
    ref.watch(oAuthCredentialRepositoryProvider).valueOrNull,
  ),
);
