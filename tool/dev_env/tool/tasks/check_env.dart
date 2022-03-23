// See LICENCE file in the root.

import 'dart:convert';
import 'dart:io';

import 'package:grinder/grinder.dart';

import 'utils.dart';

Future<void> checkDevEnv() async {
  if (!await _checkCommand('fvm')) {
    fail('`fvm` is not installed.');
  }

  if (!await _checkCommand('melos')) {
    fail('`melos` is not installed.');
  }

  if (!await _checkCommand('flutter')) {
    fail('`flutter` is not set up.');
  }

  await runAsync(
    'fvm',
    arguments: ['flutter', 'doctor'],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );

  await runMelosBootstrap();
}

Future<bool> _checkCommand(String command) {
  late String which;
  late List<String> args;
  if (Platform.isWindows) {
    which = 'where';
    args = ['/Q'];
  } else {
    which = 'which';
    args = [];
  }

  return internalRunAsync(
    which,
    [command, ...args],
  );
}
