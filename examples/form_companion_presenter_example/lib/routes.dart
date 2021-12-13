// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home.dart';

/// Home page.
const home = [MaterialPage<dynamic>(child: HomePage())];

/// Provider to control page stack of navigator.
final pagesProvider = StateProvider((_) => home);

/// Transit to home page even if there are any StateProvider's changes.
void transitToHome(Reader read) =>
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      read(pagesProvider.state).state = home;
    });
