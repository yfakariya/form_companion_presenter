// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'app.dart';

// ignore: avoid_void_async
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(const App());
}
