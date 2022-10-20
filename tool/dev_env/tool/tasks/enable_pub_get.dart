// See LICENCE file in the root.

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import 'utils.dart';

Future<void> enablePubGetCore({required bool runPubGet}) async {
  log(path.canonicalize(path.current));
  final packages = await getPackages('../../packages').toList();
  for (final package in packages) {
    if (runPubGet) {
      await _runPubGet('../../packages/$package');
    }
  }

  if (runPubGet) {
    await for (final example in getPackages('../../examples')) {
      await _runPubGet('../../examples/$example');
    }
  }
}

Future<void> _runPubGet(String directory) async {
  await runAsync(
    'fvm',
    arguments: ['flutter', 'pub', 'get'],
    workingDirectory: directory,
  );
}
