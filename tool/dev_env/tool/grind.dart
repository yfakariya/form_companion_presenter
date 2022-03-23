// See LICENCE file in the root.

import 'package:grinder/grinder.dart';

import 'tasks/check_env.dart';
import 'tasks/enable_pub_get.dart';
import 'tasks/prepare_publish.dart';
import 'tasks/run_formats.dart';

Future<dynamic> main(List<String> args) => grind(args);

@Task('Check development environment.')
Future<dynamic> checkEnv() => checkDevEnv();

@DefaultTask('Setup development environment.')
@Depends(checkEnv)
void setupEnv() => enablePubGetCore(runPubGet: true);

@Task(
  'Enable `pub get` for melos enabled projects. Pass --run to run `pub get` immediately.',
)
Future<void> enablePubGet() => enablePubGetCore(
      runPubGet: context.invocation.arguments.getFlag('run'),
    );

@Task(
    'Run `flutter format` for all project but except *.g.dart, *.freezed.dart, and .dart_tools/**/*.dart')
Future<void> format() => formatCore();

@Task(
  'Prepare publish. Assemble examples, revert `enable-pub-get`, and so on. Pass --preserve-env to skip reverting enable-pub-get.',
)
Future<void> preparePublish() => preparePublishCore(
      revertsEnvironment: !context.invocation.arguments.getFlag('preserve-env'),
    );
