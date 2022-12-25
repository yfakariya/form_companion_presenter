// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'credential.freezed.dart';
part 'credential.g.dart';

/// Credentials for OAuth.
@freezed
class OAuthCredential with _$OAuthCredential {
  factory OAuthCredential({
    required String clientId,
    required String clientSecret,
  }) = _OAuthCredential;
}

/// Repository to restore/store credentials
@riverpod
class OAuthCredentialRepository
    extends AutoDisposeAsyncNotifier<OAuthCredential> {
  final List<Completer<OAuthCredential>> _pendingBuildCompleters = [];

  bool get isPendingForUserInput => _pendingBuildCompleters.isNotEmpty;

  OAuthCredentialRepository();

  @override
  FutureOr<OAuthCredential> build() => restore();

  @visibleForTesting
  FutureOr<OAuthCredential> restore() async {
    FutureOr<OAuthCredential> waitUserInput() async {
      final completer = Completer<OAuthCredential>();
      _pendingBuildCompleters.add(completer);
      return await completer.future;
    }

    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString('clientId') ?? '';
    if (clientId.isEmpty) {
      return await waitUserInput();
    }

    final clientSecret = await const FlutterSecureStorage().read(
      key: 'GitHubIssues.Credential.$clientId',
      aOptions: const AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    );

    if (clientSecret == null) {
      return await waitUserInput();
    }

    return OAuthCredential(clientId: clientId, clientSecret: clientSecret);
  }

  FutureOr<bool> store(
    OAuthCredential credential, {
    required bool doPersist,
  }) async {
    if (credential.clientId.isEmpty || credential.clientSecret.isEmpty) {
      return false;
    }

    if (doPersist) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('clientId', credential.clientId);
      await const FlutterSecureStorage().write(
        key: 'GitHubIssues.Credential.${credential.clientId}',
        value: credential.clientSecret,
        aOptions: const AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      );
    }

    final shouldSetState = _pendingBuildCompleters.isNotEmpty;

    for (final completer in _pendingBuildCompleters) {
      completer.complete(credential);
    }

    _pendingBuildCompleters.clear();

    if (shouldSetState) {
      state = AsyncData(credential);
    }

    return true;
  }
}
