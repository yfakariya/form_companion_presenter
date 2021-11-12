// See LICENCE file in the root.

import 'dart:convert';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils.dart';

Future<void> preparePublishCore({
  required bool revertsEnvironment,
}) async {
  final examples = await getPackages('../../examples').toList();
  final packages = await getPackages('../../packages').toList();

  await _runFormats(packages: packages, examples: examples);

  await _assembleExamples(packages: packages, examples: examples);

  await _runMelosScript('analyze');

  await _runMelosScript('test');

  if (revertsEnvironment) {
    await _revertEnablingPubGet(packages);

    await runMelosBootstrap();
  }
}

Future<void> _runFormats({
  required List<String> packages,
  required List<String> examples,
}) async {
  // Do manual execution rather than melos
  // to avoid format genrated sources...
  Future<void> _runFormat(String directory) async {
    final sources = await getDir(directory)
        .list(recursive: true, followLinks: false)
        .where((f) =>
            f.path.endsWith('.dart') &&
            !f.path.endsWith('.freezed.dart') &&
            !f.path.endsWith('.g.dart'))
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
        '--no-select',
      ],
      runOptions: RunOptions(
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      ),
      workingDirectory: '../../',
    );

Future<void> _revertEnablingPubGet(List<String> packages) async {
  for (final package in packages) {
    await _restoreEnablePubGetCore(
      '../../packages/$package',
      packages,
    );
  }
}

Future<void> _restoreEnablePubGetCore(
  String directory,
  List<String> packages,
) async {
  final pubspecFile = getFile('$directory/pubspec.yaml');
  final yamlContent = await pubspecFile.readAsString();
  final pubspec = Pubspec.parse(yamlContent);
  final pubspecEditor = YamlEditor(yamlContent);

  final dependentPackages = findDependentPackages(
    packages,
    pubspec,
  );

  _revertEnabledLocalPackageDependencies(
    dependentPackages,
    pubspec,
    pubspecEditor,
  );

  await pubspecFile.writeAsString(pubspecEditor.toString());
  log('`pub get` is enabled for `${path.canonicalize(pubspecFile.path)}`.');
}

void _revertEnabledLocalPackageDependencies(
  Iterable<String> dependentPackages,
  Pubspec pubspec,
  YamlEditor pubspecEditor,
) {
  if (pubspec.dependencyOverrides.isEmpty) {
    // nothing to do.
    return;
  }

  // For tracking
  final dependenyOverrides =
      Map<String, Dependency>.from(pubspec.dependencyOverrides);
  for (final dependentPackage in dependentPackages) {
    final override = pubspec.dependencyOverrides[dependentPackage];

    if (override is PathDependency) {
      log('Package dependency override of `$dependentPackage` is removed.');
      pubspecEditor.remove(['dependency_overrides', dependentPackage]);
      dependenyOverrides.remove(dependentPackage);
    } else {
      log('Package dependency override of `$dependentPackage` is preserved.');
    }
  }

  if (dependenyOverrides.isEmpty) {
    log('Remove empty `dependency_overrides`.');
    pubspecEditor.remove(['dependency_overrides']);
  }
}
