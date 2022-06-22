// See LICENCE file in the root.

import 'package:go_router/go_router.dart';

import 'auto_validation_form_builder_account.dart';
import 'auto_validation_form_builder_booking.dart';
import 'bulk_auto_validation_form_builder_account.dart';
import 'bulk_auto_validation_form_builder_booking.dart';
import 'home.dart';
import 'manual_validation_form_builder_account.dart';
import 'manual_validation_form_builder_booking.dart';

final routes = [
  GoRoute(
    path: '/',
    name: 'home',
    builder: (context, state) => HomePage(),
  ),
  GoRoute(
    path: '/form-builder/manual/account',
    name: 'manual.flutterFormBuilderAccount',
    builder: (context, state) => ManualValidationFormBuilderAccountPage(),
  ),
  GoRoute(
    path: '/form-builder/manual/booking',
    name: 'manual.flutterFormBuilderBooking',
    builder: (context, state) => ManualValidationFormBuilderBookingPage(),
  ),
  GoRoute(
    path: '/form-builder/bulk-auto/account',
    name: 'bulk_auto.flutterFormBuilderAccount',
    builder: (context, state) => BulkAutoValidationFormBuilderAccountPage(),
  ),
  GoRoute(
    path: '/form-builder/bulk-auto/booking',
    name: 'bulk_auto.flutterFormBuilderBooking',
    builder: (context, state) => BulkAutoValidationFormBuilderBookingPage(),
  ),
  GoRoute(
    path: '/form-builder/auto/account',
    name: 'auto.flutterFormBuilderAccount',
    builder: (context, state) => AutoValidationFormBuilderAccountPage(),
  ),
  GoRoute(
    path: '/form-builder/auto/booking',
    name: 'auto.flutterFormBuilderBooking',
    builder: (context, state) => AutoValidationFormBuilderBookingPage(),
  ),
];

final router = GoRouter(routes: routes);
