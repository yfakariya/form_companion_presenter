// See LICENCE file in the root.

import 'package:form_companion_generator/src/config.dart';
import 'package:test/test.dart';

void main() {
  test('constructor and defaults', () {
    const target = Config(<String, dynamic>{});
    expect(target.asPart, isFalse);
    expect(target.extraLibraries, isEmpty);
  });

  // group('suppressFieldFactory', () {
  //   test('true -> true', () {
  //     const target = Config(<String, dynamic>{'suppress_field_factory': true});
  //     expect(target.suppressFieldFactory, isTrue);
  //   });

  //   test('false -> false', () {
  //     const target = Config(<String, dynamic>{'suppress_field_factory': false});
  //     expect(target.suppressFieldFactory, isFalse);
  //   });

  //   test('invalid casing -- ignored', () {
  //     const target = Config(<String, dynamic>{'Suppress_Field_Factory': true});
  //     expect(target.suppressFieldFactory, isFalse);
  //   });

  //   test('non boolean -- ignored', () {
  //     const target =
  //         Config(<String, dynamic>{'Suppress_Field_Factory': 'true'});
  //     expect(target.suppressFieldFactory, isFalse);
  //   });
  // });
}
