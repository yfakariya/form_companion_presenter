// See LICENCE file in the root.

import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

import 'grinder_tasks/assemble.dart';
import 'grinder_tasks/distribute.dart';

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
Future<void> distribute() => distributeCore();
