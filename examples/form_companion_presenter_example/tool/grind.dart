// ignore_for_file: avoid_print

import 'package:grinder/grinder.dart';

import 'grinder_tasks/assemble.dart';

Future<dynamic> main(List<String> args) => grind(args);

@Task()
Future<dynamic> test() => TestRunner().testAsync();

@DefaultTask()
@Depends(test)
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
