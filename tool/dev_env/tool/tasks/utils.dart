// See LICENCE file in the root.

import 'dart:convert';
import 'dart:io';

import 'package:grinder/grinder.dart';

Future<bool> internalRunAsync(
  String command, [
  List<String>? args,
]) async =>
    (await Process.run(
      command,
      args ?? [],
      // From runAsync() code.
      runInShell: Platform.isWindows,
    ))
        .exitCode ==
    0;

Future<void> runMelosBootstrap() => runAsync(
      'fvm',
      arguments: ['flutter', 'pub', 'global', 'run', 'melos', 'bs'],
      runOptions: RunOptions(
        // These are required to avoid mojibake in Windows.
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
    );

Stream<String> getPackages(String directory) =>
    getDir(directory).list().where((e) => e is Directory).map((e) {
      final pathSegments = e.uri.pathSegments;
      // Get last directory. Note that last segment is empty
      // because directories' URIs always end with '/'.
      return pathSegments[pathSegments.length - 2];
    });
