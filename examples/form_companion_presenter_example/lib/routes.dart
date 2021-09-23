// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'manual_validation_vanilla_form.dart';

final _pages = [
  MaterialPage<dynamic>(child: ManualValidationVanillaFormPage())
];

final pagesProvider = StateProvider((_) => _pages);
