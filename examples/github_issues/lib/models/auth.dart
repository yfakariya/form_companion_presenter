// See LICENCE file in the root.

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:oauth2_client/github_oauth2_client.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'credential.dart';

part 'auth.freezed.dart';
part 'auth.g.dart';

// TODO: Use OAuth2 client to support windows seemlessly.
const _customUriScheme = 'github.issues.app';
const _redirectUri = '$_customUriScheme:/oauth2redirect';

/// Tokens of OAuth.
@freezed
class AuthTokens with _$AuthTokens {
  factory AuthTokens({
    required String accessToken,
  }) = _AuthTokens;
}

/// Notifies [AuthTokens] change.
@riverpod
class AuthTokenNotifier extends AutoDisposeAsyncNotifier<AuthTokens> {
  @override
  FutureOr<AuthTokens> build() async {
    final credential =
        await ref.watch(oAuthCredentialRepositoryProvider.future);
    final helper = OAuth2Helper(
      GitHubOAuth2Client(
        customUriScheme: _customUriScheme,
        redirectUri: _redirectUri,
      ),
      clientId: credential.clientId,
      clientSecret: credential.clientSecret,
    );

    final token = await helper.getToken();

    if (!token!.isValid()) {
      throw Exception('Failed to login. ${token.toString()}');
    }

    final expiresInSeconds = token.expiresIn;
    if (expiresInSeconds != null) {
      Future.delayed(
        Duration(seconds: expiresInSeconds),
        () => ref.invalidateSelf(),
      );
    }

    return AuthTokens(accessToken: token.accessToken!);
  }
}
