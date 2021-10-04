// See LICENCE file in the root.

import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:pubspec_parse/pubspec_parse.dart';
import 'package:yaml_edit/yaml_edit.dart';

import 'tasks/check_env.dart';
import 'tasks/enable_pub_get.dart';
import 'tasks/prepare_publish.dart';

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

@Task('Prepare publish. Assemble examples, revert `enable-pub-get`, and so on.')
Future<void> preparePublish() => preparePublishCore();
