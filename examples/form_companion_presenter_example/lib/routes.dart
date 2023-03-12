// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auto_validation_form_builder_account.dart';
import 'auto_validation_form_builder_booking.dart';
import 'auto_validation_vanilla_form.dart';
import 'bulk_auto_validation_form_builder_account.dart';
import 'bulk_auto_validation_form_builder_booking.dart';
import 'bulk_auto_validation_vanilla_form.dart';
import 'home.dart';
import 'manual_validation_form_builder_account.dart';
import 'manual_validation_form_builder_booking.dart';
import 'manual_validation_vanilla_form.dart';
import 'simple_form.dart';

// We use pageBuilder due to go-router state retoration issue:
//   https://github.com/flutter/flutter/issues/117683
// (It is because internally created Page object have restoration ID with hashCode of GoRoute!)
GoRoute _route({
  required String path,
  required String name,
  required Widget Function(BuildContext, GoRouterState) builder,
}) =>
    GoRoute(
      path: path,
      name: name,
      pageBuilder: (context, state) => MaterialPage<void>(
        name: name,
        restorationId: path,
        child: builder(context, state),
      ),
    );

final routes = [
  _route(
    path: '/',
    name: 'home',
    builder: (context, state) => HomePage(),
  ),
  _route(
    path: '/vanilla/manual/account',
    name: 'manual.vanilla',
    builder: (context, state) => ManualValidationVanillaFormAccountPage(),
  ),
  _route(
    path: '/vanilla/bulk-auto/account',
    name: 'bulk_auto.vanilla',
    builder: (context, state) => BulkAutoValidationVanillaFormAccountPage(),
  ),
  _route(
    path: '/vanilla/auto/account',
    name: 'auto.vanilla',
    builder: (context, state) => AutoValidationVanillaFormAccountPage(),
  ),
  _route(
    path: '/form-builder/manual/account',
    name: 'manual.flutterFormBuilderAccount',
    builder: (context, state) => ManualValidationFormBuilderAccountPage(),
  ),
  _route(
    path: '/form-builder/manual/booking',
    name: 'manual.flutterFormBuilderBooking',
    builder: (context, state) => ManualValidationFormBuilderBookingPage(),
  ),
  _route(
    path: '/form-builder/bulk-auto/account',
    name: 'bulk_auto.flutterFormBuilderAccount',
    builder: (context, state) => BulkAutoValidationFormBuilderAccountPage(),
  ),
  _route(
    path: '/form-builder/bulk-auto/booking',
    name: 'bulk_auto.flutterFormBuilderBooking',
    builder: (context, state) => BulkAutoValidationFormBuilderBookingPage(),
  ),
  _route(
    path: '/form-builder/auto/account',
    name: 'auto.flutterFormBuilderAccount',
    builder: (context, state) => AutoValidationFormBuilderAccountPage(),
  ),
  _route(
    path: '/form-builder/auto/booking',
    name: 'auto.flutterFormBuilderBooking',
    builder: (context, state) => AutoValidationFormBuilderBookingPage(),
  ),
  _route(
    path: '/simple',
    name: 'simple',
    builder: (context, state) => SimpleAccountPage(),
  ),
];

final router = GoRouter(routes: routes, restorationScopeId: 'route');
