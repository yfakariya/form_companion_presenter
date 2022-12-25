// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'models/auth.dart';
import 'screens/issue.dart';
import 'screens/issues.dart';
import 'screens/login.dart';

const homeRoute = '/';
const _issues = 'issues';
const issuesRoute = '/$_issues';
const _login = 'login';
const loginRoute = '/$_login';

final routerProvider = AutoDisposeProvider(
  (ref) {
    FutureOr<String?> guardRoute(BuildContext context, GoRouterState state) {
      final authToken = ref.watch(authTokenNotifierProvider);
      // Go to login page if the user is not authenticated yet.
      if (!authToken.hasValue) {
        return loginRoute;
      }

      // Go to home if it is going to login page
      if (state.subloc == loginRoute) {
        return homeRoute;
      }

      // Call `builder` otherwise.
      return null;
    }

    return GoRouter(
      routes: [
        GoRoute(
          path: homeRoute,
          name: 'home',
          redirect: (context, state) => issuesRoute,
          routes: [
            GoRoute(
              path: _issues,
              name: 'issues',
              redirect: guardRoute,
              builder: (context, state) => const IssuesPage(),
              routes: [
                GoRoute(
                  path: ':issueId',
                  redirect: guardRoute,
                  builder: (context, state) => IssuePage(
                    key: state.pageKey,
                    issueId: state.params['issueId']!,
                  ),
                ),
              ],
            ),
            GoRoute(
              path: _login,
              name: 'login',
              builder: (context, state) => const LoginPage(),
            ),
          ],
        ),
      ],
    );
  },
);
