// See LICENCE file in the root.

import 'dart:convert';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils.dart';

Future<void> preparePublishCore() async {
  final packages = await getPackages('../../packages').toList();

  await _assembleExamples(packages);

  await _testProjects(packages);

  await _revertEnablingPubGet();

  await runMelosBootstrap();
}

Future<void> _assembleExamples(List<String> packages) async {
  await for (final example in getPackages('../../examples')) {
    await runAsync(
      'grind',
      arguments: ['assemble'],
      workingDirectory: '../../examples/$example',
    );

    await runAsync(
      'grind',
      arguments: ['distribute'],
      workingDirectory: '../../examples/$example',
    );
  }
}

Future<void> _testProjects(List<String> packages) async {
  await for (final example in getPackages('../../examples')) {
    await _runTests('../../examples/$example/');
  }

  for (final package in packages) {
    await _runTests('../../packages/$package/');
  }
}

Future<void> _runTests(
  String projectDirectory,
) async =>
    runAsync('fvm',
        // We omit escape of `files` because it should be
        // "../../packages/$package/test/" and $package should not contain
        // any whitespaces.
        arguments: ['flutter', 'test', '--reporter=expanded'],
        runOptions: RunOptions(
          stdoutEncoding: utf8,
          stderrEncoding: utf8,
        ),
        workingDirectory: projectDirectory);

Future<void> _revertEnablingPubGet() async {
  final packages = await getPackages('../../packages').toList();
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
