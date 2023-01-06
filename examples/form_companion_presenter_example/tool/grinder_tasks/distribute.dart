// See LICENCE file in the root.

import 'dart:io';

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;

String _path(String name) => 'lib${Platform.pathSeparator}$name';

List<String> _commonItems = [
  _path('l10n'),
  _path('generated_plugin_registrant.dart'),
  _path('home.dart'),
  _path('main.dart'),
  _path('models.dart'),
  _path('models.freezed.dart'),
  _path('models.g.dart'),
  _path('validators.dart'),
  _path('validators.g.dart'),
];

final Map<String, Set<String>> _itemSets = {
  'form_companion_presenter': {
    ..._commonItems,
    _path('auto_validation_vanilla_form.dart'),
    _path('auto_validation_vanilla_form.fcp.dart'),
    _path('auto_validation_vanilla_form.g.dart'),
    _path('bulk_auto_validation_vanilla_form.dart'),
    _path('bulk_auto_validation_vanilla_form.fcp.dart'),
    _path('bulk_auto_validation_vanilla_form.g.dart'),
    _path('manual_validation_vanilla_form.dart'),
    _path('manual_validation_vanilla_form.fcp.dart'),
    _path('manual_validation_vanilla_form.g.dart'),
    _path('simple_form.dart'),
  },
  'form_builder_companion_presenter': {
    ..._commonItems,
    _path('auto_validation_form_builder_account.dart'),
    _path('auto_validation_form_builder_account.fcp.dart'),
    _path('auto_validation_form_builder_account.g.dart'),
    _path('auto_validation_form_builder_booking.dart'),
    _path('auto_validation_form_builder_booking.fcp.dart'),
    _path('auto_validation_form_builder_booking.g.dart'),
    _path('bulk_auto_validation_form_builder_account.dart'),
    _path('bulk_auto_validation_form_builder_account.fcp.dart'),
    _path('bulk_auto_validation_form_builder_account.g.dart'),
    _path('bulk_auto_validation_form_builder_booking.dart'),
    _path('bulk_auto_validation_form_builder_booking.fcp.dart'),
    _path('bulk_auto_validation_form_builder_booking.g.dart'),
    _path('manual_validation_form_builder_account.dart'),
    _path('manual_validation_form_builder_account.fcp.dart'),
    _path('manual_validation_form_builder_account.g.dart'),
    _path('manual_validation_form_builder_booking.dart'),
    _path('manual_validation_form_builder_booking.fcp.dart'),
    _path('manual_validation_form_builder_booking.g.dart'),
  },
  // empty
  'form_companion_generator': {},
  'form_companion_generator_test': {},
};

Future<void> distributeCore() async {
  final lib = getDir('lib');
  await for (final package in getDir('../../packages').list()) {
    if (package is Directory) {
      final target = getDir('${package.path}/example');
      final packageName = path.basename(package.path);
      final itemSet = _itemSets[packageName];
      if (itemSet == null) {
        throw Exception('Item list for package "$packageName" is not defined.');
      }

      await for (final item
          in lib.list().where((e) => itemSet.contains(e.path))) {
        if (item is Directory) {
          copy(item, Directory('${target.path}/${item.path}'));
        } else {
          assert(item is File);
          copy(item as File, Directory('${target.path}/${item.parent.path}'));
        }
      }

      log(
        'Copied "${path.canonicalize(lib.path)}" contents to "${path.canonicalize(target.path)}"',
      );
    }
  }
}
