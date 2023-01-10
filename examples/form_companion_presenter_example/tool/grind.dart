// See LICENCE file in the root.

import 'dart:convert';

import 'package:grinder/grinder.dart';

import 'grinder_tasks/assemble.dart';
import 'grinder_tasks/distribute.dart';

Future<dynamic> main(List<String> args) => grind(args);

@Task()
Future<dynamic> test() => runAsync(
      'fvm',
      arguments: [
        'flutter',
        'test',
        '--reporter=expanded',
      ],
    );

@DefaultTask()
@Depends(clean, assemble, runBuildRunner, test, distribute)
void buildAll() {}

@Task()
Future<void> build() async => runAsync(
      'fvm',
      arguments: [
        'flutter',
        'build',
      ],
    );

@Task()
void clean() => defaultClean();

@Task('Assembles example files.')
Future<dynamic> assemble() => assembleCore(
      context.invocation.arguments.getOption('source') ?? 'lib/components',
      context.invocation.arguments.getOption('destination') ?? 'lib',
    );

@Task('Distributes example files to each package.')
Future<void> distribute() => distributeCore();

@Task('Generates easy_localization sources.')
Future<void> easyL10n() async {
  await runAsync(
    'fvm',
    arguments: [
      'flutter',
      'pub',
      'run',
      'easy_localization:generate',
      '-O',
      'lib/l10n',
      '-f',
      'json'
    ],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );

  await runAsync(
    'fvm',
    arguments: [
      'flutter',
      'pub',
      'run',
      'easy_localization:generate',
      '-O',
      'lib/l10n',
      '-f',
      'keys',
      '-o',
      'locale_keys.g.dart',
    ],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );
}

@Task(
  'Run freezed, riverpod_generator, and form_companion_generator. Specify --watch to run with watch mode.',
)
Future<void> runBuildRunner() async {
  final command =
      context.invocation.arguments.getFlag('watch') ? 'watch' : 'build';
  await runAsync(
    'fvm',
    arguments: [
      'flutter',
      'pub',
      'run',
      'build_runner',
      command,
      '--delete-conflicting-outputs',
    ],
    runOptions: RunOptions(
      stdoutEncoding: utf8,
      stderrEncoding: utf8,
    ),
  );
}
