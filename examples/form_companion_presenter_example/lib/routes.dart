// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

/// Home page.
const homePage = MaterialPage<dynamic>(name: '/', child: HomePage());

const homeRoute = [homePage];

const manualVanillaAccountRoute = [
  MaterialPage<dynamic>(
    name: '/vanilla/manual/account',
    child: ManualValidationVanillaFormAccountPage(),
  )
];

const bulkAutoVanillaAccountRoute = [
  MaterialPage<dynamic>(
    name: '/vanilla/bulk-auto/account',
    child: BulkAutoValidationVanillaFormAccountPage(),
  )
];

const autoVanillaAccountRoute = [
  MaterialPage<dynamic>(
    name: '/vanilla/auto/account',
    child: AutoValidationVanillaFormAccountPage(),
  )
];

const manualFormBuilderAccountRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/manual/account',
    child: ManualValidationFormBuilderAccountPage(),
  )
];

const manualFormBuilderBookingRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/manual/booking',
    child: ManualValidationFormBuilderBookingPage(),
  )
];

const bulkAutoFormBuilderAccountRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/bulk-auto/account',
    child: BulkAutoValidationFormBuilderAccountPage(),
  )
];

const bulkAutoFormBuilderBookingRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/bulk-auto/booking',
    child: BulkAutoValidationFormBuilderBookingPage(),
  )
];

const autoFormBuilderAccountRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/auto/account',
    child: AutoValidationFormBuilderAccountPage(),
  )
];

const autoFormBuilderBookingRoute = [
  MaterialPage<dynamic>(
    name: '/form-builder/auto/booking',
    child: AutoValidationFormBuilderBookingPage(),
  )
];

/// Provider to control page stack of navigator.
final pagesProvider = StateProvider((_) => homeRoute);

/// Transit to home page even if there are any StateProvider's changes.
void transitToHome(Reader read) =>
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      read(pagesProvider.state).state = homeRoute;
    });
