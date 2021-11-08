// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home.dart';

const home = [MaterialPage<dynamic>(child: HomePage())];

/// Provider to control page stack of navigator.
final pagesProvider = StateProvider((_) => home);
