// See LICENCE file in the root.

import 'dart:convert';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import 'utils.dart';

Future<void> formatCore() async => runFormats(
      packages: await getPackages('../../packages').toList(),
      examples: await getPackages('../../examples').toList(),
    );

Future<void> runFormats({
  required List<String> packages,
  required List<String> examples,
}) async {
  // Do manual execution rather than melos
  // to avoid format genrated sources...
  Future<void> _runFormat(String directory) async {
    final sources = await getDir(directory)
        .list(recursive: true, followLinks: false)
        .where(
          (f) =>
              f.path.endsWith('.dart') &&
              !f.path.endsWith('.freezed.dart') &&
              !f.path.endsWith('.g.dart'),
        )
        .map((f) => path.relative(f.path, from: directory))
        .where((f) => !f.startsWith('.'))
        .toList();
    await runAsync(
      'fvm',
      arguments: [
        'flutter',
        'format',
        '--set-exit-if-changed',
        ...sources,
      ],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: directory,
    );
  }

  for (final example in examples) {
    await _runFormat('../../examples/$example/');
  }

  for (final package in packages) {
    await _runFormat('../../packages/$package/');
  }
}
