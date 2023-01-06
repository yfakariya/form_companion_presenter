// See LICENCE file in the root.

import 'package:go_router/go_router.dart';
import 'auto_validation_vanilla_form.dart';
import 'bulk_auto_validation_vanilla_form.dart';
import 'home.dart';
import 'manual_validation_vanilla_form.dart';
import 'simple_form.dart';

final routes = [
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: '/vanilla/manual/account',
    name: 'manual.vanilla',
    builder: (context, state) => ManualValidationVanillaFormAccountPage(),
  ),
  GoRoute(
    path: '/vanilla/bulk-auto/account',
    name: 'bulk_auto.vanilla',
    builder: (context, state) => BulkAutoValidationVanillaFormAccountPage(),
  ),
  GoRoute(
    path: '/vanilla/auto/account',
    name: 'auto.vanilla',
    builder: (context, state) => AutoValidationVanillaFormAccountPage(),
  ),
  GoRoute(
    path: '/simple',
    name: 'Simple',
    builder: (context, state) => SimpleAccountPage(),
  ),
];

final router = GoRouter(routes: routes);
