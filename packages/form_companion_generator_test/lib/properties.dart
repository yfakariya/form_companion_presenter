// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'dart:io';

import 'package:form_companion_presenter/form_companion_presenter.dart';

enum MyEnum { one, two }

// Statics
class PropertyDescritptors {
  static final inlineInitialized = PropertyDescriptorsBuilder()
    ..add<int, String>(name: 'propInt')
    ..add<String, String>(name: 'propString')
    ..add<bool, bool>(name: 'propBool')
    ..add<MyEnum, MyEnum>(name: 'propEnum')
    ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');

  static final noAddition = PropertyDescriptorsBuilder();

  static PropertyDescriptorsBuilder get refersInlineInitialized =>
      inlineInitialized;
  static PropertyDescriptorsBuilder get refersFactoryInitialized =>
      withCascadingFactory;
  static PropertyDescriptorsBuilder get refersFactory => cascadingFactory();

  static final withCascadingFactory = cascadingFactory();

  static PropertyDescriptorsBuilder cascadingFactory() =>
      PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt')
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');

  static final withClassicFactory = classicFactory();

  static PropertyDescriptorsBuilder classicFactory() {
    final builder = PropertyDescriptorsBuilder();
    builder.add<int, String>(name: 'propInt');
    builder.add<String, String>(name: 'propString');
    builder.add<bool, bool>(name: 'propBool');
    builder.add<MyEnum, MyEnum>(name: 'propEnum');
    builder.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
    return builder;
  }

  static final withWithHelpersFactory = withHelpersFactory();

  static PropertyDescriptorsBuilder withHelpersFactory() {
    final builder = PropertyDescriptorsBuilder();
    builder.add<int, String>(name: 'propInt');
    _helper(builder);
    builder.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
    return builder;
  }
}

// Globals

final inlineInitialized = PropertyDescriptorsBuilder()
  ..add<int, String>(name: 'propInt')
  ..add<String, String>(name: 'propString')
  ..add<bool, bool>(name: 'propBool')
  ..add<MyEnum, MyEnum>(name: 'propEnum')
  ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');

final noAddition = PropertyDescriptorsBuilder();

PropertyDescriptorsBuilder get refersInlineInitialized => inlineInitialized;
PropertyDescriptorsBuilder get refersFactoryInitialized => withCascadingFactory;
PropertyDescriptorsBuilder get refersFactory => cascadingFactory();

final withCascadingFactory = cascadingFactory();

PropertyDescriptorsBuilder cascadingFactory() => PropertyDescriptorsBuilder()
  ..add<int, String>(name: 'propInt')
  ..add<String, String>(name: 'propString')
  ..add<bool, bool>(name: 'propBool')
  ..add<MyEnum, MyEnum>(name: 'propEnum')
  ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');

final withClassicFactory = classicFactory();

PropertyDescriptorsBuilder classicFactory() {
  final builder = PropertyDescriptorsBuilder();
  builder.add<int, String>(name: 'propInt');
  builder.add<String, String>(name: 'propString');
  builder.add<bool, bool>(name: 'propBool');
  builder.add<MyEnum, MyEnum>(name: 'propEnum');
  builder.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  return builder;
}

final withWithHelpersFactory = withHelpersFactory();

PropertyDescriptorsBuilder withHelpersFactory() {
  final builder = PropertyDescriptorsBuilder();
  builder.add<int, String>(name: 'propInt');
  _helper(builder);
  builder.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  return builder;
}

void _helper(PropertyDescriptorsBuilder pdb) {
  pdb.add<String, String>(name: 'propString');
  pdb
    ..add<bool, bool>(name: 'propBool')
    ..add<MyEnum, MyEnum>(name: 'propEnum');
}

PropertyDescriptorsBuilder singletonFactory() => inlineInitialized;

void helper(PropertyDescriptorsBuilder builder) => _helper(builder);

// invalid factories

PropertyDescriptorsBuilder factoryWithIf() {
  final pdb = PropertyDescriptorsBuilder();
  if (Platform.isWindows) {
    pdb.add<String, String>(name: 'volumeName');
  }
  return pdb;
}

PropertyDescriptorsBuilder factoryWithFor() {
  final pdb = PropertyDescriptorsBuilder();
  for (final i in [0, 1]) {
    pdb.add<String, String>(name: 'volumeName$i');
  }
  return pdb;
}

PropertyDescriptorsBuilder factoryWithWhile() {
  final pdb = PropertyDescriptorsBuilder();
  while (Platform.isWindows) {
    pdb.add<String, String>(name: 'volumeName');
  }
  return pdb;
}

PropertyDescriptorsBuilder factoryWithDo() {
  final pdb = PropertyDescriptorsBuilder();
  do {
    pdb.add<String, String>(name: 'volumeName');
  } while (Platform.isWindows);
  return pdb;
}

PropertyDescriptorsBuilder factoryWithTry() {
  final pdb = PropertyDescriptorsBuilder();
  try {
    pdb.add<int, String>(name: 'propInt');
    pdb.add<String, String>(name: 'propString');
  } catch (e) {
    print(e);
  } finally {
    pdb.add<bool, bool>(name: 'propBool');
    pdb.add<MyEnum, MyEnum>(name: 'propEnum');
    pdb.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  }
  return pdb;
}

PropertyDescriptorsBuilder factoryWithDuplication() {
  final pdb = PropertyDescriptorsBuilder();
  pdb.add<int, String>(name: 'propInt');
  pdb.add<String, String>(name: 'propString');
  pdb.add<bool, bool>(name: 'propBool');
  pdb.add<MyEnum, MyEnum>(name: 'propEnum');
  pdb.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  pdb.add<String, String>(name: 'propInt');
  return pdb;
}

// factories calls invalid helpers

PropertyDescriptorsBuilder factoryCallsWithIf() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithIf(pdb);
  return pdb;
}

PropertyDescriptorsBuilder factoryCallsWithFor() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithFor(pdb);
  return pdb;
}

PropertyDescriptorsBuilder factoryCallsWithWhile() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithWhile(pdb);
  return pdb;
}

PropertyDescriptorsBuilder factoryCallsWithDo() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithDo(pdb);
  return pdb;
}

PropertyDescriptorsBuilder factoryCallsWithTry() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithTry(pdb);
  return pdb;
}

PropertyDescriptorsBuilder factoryCallsWithDuplication() {
  final pdb = PropertyDescriptorsBuilder();
  _helperWithDuplication(pdb);
  return pdb;
}

// invalid helpers

void _helperWithIf(PropertyDescriptorsBuilder pdb) {
  if (Platform.isWindows) {
    pdb.add<String, String>(name: 'volumeName');
  }
}

void _helperWithFor(PropertyDescriptorsBuilder pdb) {
  for (final i in [0, 1]) {
    pdb.add<String, String>(name: 'volumeName$i');
  }
}

void _helperWithWhile(PropertyDescriptorsBuilder pdb) {
  while (Platform.isWindows) {
    pdb.add<String, String>(name: 'volumeName');
  }
}

void _helperWithDo(PropertyDescriptorsBuilder pdb) {
  do {
    pdb.add<String, String>(name: 'volumeName');
  } while (Platform.isWindows);
}

void _helperWithTry(PropertyDescriptorsBuilder pdb) {
  try {
    pdb.add<int, String>(name: 'propInt');
    pdb.add<String, String>(name: 'propString');
  } catch (e) {
    print(e);
  } finally {
    pdb.add<bool, bool>(name: 'propBool');
    pdb.add<MyEnum, MyEnum>(name: 'propEnum');
    pdb.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  }
}

void _helperWithDuplication(PropertyDescriptorsBuilder pdb) {
  pdb.add<int, String>(name: 'propInt');
  pdb.add<String, String>(name: 'propString');
  pdb.add<bool, bool>(name: 'propBool');
  pdb.add<MyEnum, MyEnum>(name: 'propEnum');
  pdb.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
  pdb.add<String, String>(name: 'propInt');
}

void helperWithDuplication(PropertyDescriptorsBuilder builder) =>
    _helperWithDuplication(builder);
