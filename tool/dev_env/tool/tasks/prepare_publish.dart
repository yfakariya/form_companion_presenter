// See LICENCE file in the root.

import 'dart:convert';

import 'package:grinder/grinder.dart';

import 'run_formats.dart';
import 'utils.dart';

Future<void> preparePublishCore({
  required bool revertsEnvironment,
}) async {
  final examples = await getPackages('../../examples').toList();
  final packages = await getPackages('../../packages').toList();

  await runFormats(packages: packages, examples: examples);

  await _assembleExamples(packages: packages, examples: examples);

  await _runMelosScript('analyze');

  await _runMelosScript('test');

  if (revertsEnvironment) {
    await runMelosBootstrap();
  }
}

Future<void> _assembleExamples({
  required List<String> packages,
  required List<String> examples,
}) async {
  for (final example in examples) {
    await runAsync(
      'grind',
      arguments: ['assemble'],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: '../../examples/$example',
    );

    await runAsync(
      'fvm',
      arguments: [
        'flutter',
        'pub',
        'run',
        'build_runner',
        'build',
      ],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: '../../examples/$example',
    );

    await runAsync(
      'grind',
      arguments: ['distribute'],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: '../../examples/$example',
    );
  }
}

Future<void> _runMelosScript(String scriptName) => runAsync(
      'fvm',
      arguments: [
        'flutter',
        'pub',
        'global',
        'run',
        'melos',
        'run',
        scriptName,
      ],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: '../../',
    );
