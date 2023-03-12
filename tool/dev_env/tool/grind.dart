// See LICENCE file in the root.
// ignore_for_file: unreachable_from_main

import 'package:grinder/grinder.dart';

import 'tasks/check_env.dart';
import 'tasks/prepare_publish.dart';
import 'tasks/run_formats.dart';

Future<dynamic> main(List<String> args) => grind(args);

@Task('Check development environment.')
Future<dynamic> checkEnv() => checkDevEnv();

@Task(
  'Run `dart format` for all project but except *.g.dart, *.freezed.dart, and .dart_tools/**/*.dart',
)
Future<void> format() => formatCore();

@Task(
  'Prepare publish. Assemble examples, revert `enable-pub-get`, and so on. Pass --preserve-env to skip reverting enable-pub-get.',
)
Future<void> preparePublish() => preparePublishCore(
      revertsEnvironment: !context.invocation.arguments.getFlag('preserve-env'),
    );
