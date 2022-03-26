// See LICENCE file in the root.

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'utils.dart';

Future<void> enablePubGetCore({required bool runPubGet}) async {
  log(path.canonicalize(path.current));
  final packages = await getPackages('../../packages').toList();
  for (final package in packages) {
    await _enablePubGetCore(
      package,
      '../../packages/$package',
      packages,
      runPubGet: runPubGet,
    );
  }

  if (runPubGet) {
    await for (final example in getPackages('../../examples')) {
      await _runPubGet('../../examples/$example');
    }
  }
}

Future<void> _enablePubGetCore(
  String package,
  String directory,
  List<String> packages, {
  bool runPubGet = false,
}) async {
  if (shouldEnablePubGetTargets(package)) {
    final pubspecFile = getFile('$directory/pubspec.yaml');
    final yamlContent = await pubspecFile.readAsString();
    final pubspec = Pubspec.parse(yamlContent);
    final pubspecEditor = YamlEditor(yamlContent);

    final dependentPackages = findDependentPackages(
      packages,
      pubspec,
    );

    _enableLocalPackageDepencendies(
      dependentPackages.toList(),
      pubspec,
      pubspecEditor,
    );

    await pubspecFile.writeAsString(pubspecEditor.toString());
    log('`pub get` is enabled for `${path.canonicalize(pubspecFile.path)}`.');
  }

  if (runPubGet) {
    await _runPubGet(directory);
  }
}

Future<void> _runPubGet(String directory) async {
  await runAsync(
    'fvm',
    arguments: ['flutter', 'pub', 'get'],
    workingDirectory: directory,
  );
}

void _enableLocalPackageDepencendies(
  List<String> dependentPackages,
  Pubspec pubspec,
  YamlEditor pubspecEditor,
) {
  if (dependentPackages.isEmpty) {
    // nothing to do.
    return;
  }

  if (pubspec.dependencyOverrides.isEmpty) {
    pubspecEditor.update(
      ['dependency_overrides'],
      <String, dynamic>{},
    );
  }

  for (final dependentPackage in dependentPackages) {
    final override = pubspec.dependencyOverrides[dependentPackage];

    late String message;
    if (override == null) {
      message = 'Package dependency override of `$dependentPackage` is added.';
    } else if (override is PathDependency) {
      log('Package dependency override of `$dependentPackage` already exists.');
      continue;
    } else {
      message =
          'Package dependency override of `$dependentPackage` is updated to path dependency.';
    }

    pubspecEditor.update(
      ['dependency_overrides', dependentPackage],
      {'path': '../../packages/$dependentPackage'},
    );
    log(message);
  }
}
