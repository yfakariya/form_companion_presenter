// See LICENCE file in the root.

import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import 'grinder_tasks/assemble.dart';

Future<dynamic> main(List<String> args) => grind(args);

@Task()
Future<dynamic> test() => TestRunner().testAsync();

@DefaultTask()
@Depends(clean, test, assemble, distribute)
void build() {
  Pub.build();
}

@Task()
void clean() => defaultClean();

@Task('Assemble example files.')
Future<dynamic> assemble() => assembleCore(
      context.invocation.arguments.getOption('source') ?? 'lib/components',
      context.invocation.arguments.getOption('destination') ?? 'lib',
    );

@Task('Distribute example files to each package.')
Future<void> distribute() async {
  await for (final package in getDir('../../packages').list()) {
    if (package is Directory) {
      final lib = getDir('lib');
      final example = getDir('${package.path}/example');
      copyDirectory(lib, example);
      log(
        'Copied ${path.canonicalize(lib.path)} contents to ${path.canonicalize(example.path)}',
      );
    }
  }
}
