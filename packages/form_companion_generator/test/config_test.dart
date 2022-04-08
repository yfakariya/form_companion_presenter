// See LICENCE file in the root.

import 'package:form_companion_generator/src/config.dart';
import 'package:test/test.dart';

void main() {
  test('constructor and defaults', () {
    const target = Config(<String, dynamic>{});
    expect(target.asPart, isFalse);
    expect(target.autovalidateByDefault, isTrue);
    expect(target.extraLibraries, isEmpty);
  });

  group('asPart', () {
    test('true -> true', () {
      const target = Config(<String, dynamic>{'as_part': true});
      expect(target.asPart, isTrue);
    });

    test('false -> false', () {
      const target = Config(<String, dynamic>{'as_part': false});
      expect(target.asPart, isFalse);
    });

    test('invalid casing -- ignored', () {
      const target = Config(<String, dynamic>{'As_Part': true});
      expect(target.asPart, isFalse);
    });

    test('non boolean -- ignored', () {
      const target = Config(<String, dynamic>{'as_part': 'true'});
      expect(target.asPart, isFalse);
    });
  });

  group('autovalidateByDefault', () {
    test('true -> true', () {
      const target = Config(<String, dynamic>{'autovalidate_by_default': true});
      expect(target.autovalidateByDefault, isTrue);
    });

    test('false -> false', () {
      const target =
          Config(<String, dynamic>{'autovalidate_by_default': false});
      expect(target.autovalidateByDefault, isFalse);
    });

    test('invalid casing -- ignored', () {
      const target = Config(<String, dynamic>{'autoValidate_by_default': true});
      expect(target.autovalidateByDefault, isTrue);
    });

    test('non boolean -- ignored', () {
      const target =
          Config(<String, dynamic>{'autovalidate_by_default': 'true'});
      expect(target.autovalidateByDefault, isTrue);
    });
  });

  group('extraLibraries', () {
    test('1 extra_libraries -> recognized', () {
      const target =
          Config(<String, dynamic>{'extra_libraries': 'package:foo/foo.dart'});
      expect(target.extraLibraries, ['package:foo/foo.dart']);
    });

    test('2 extra_libraries -> recognized', () {
      const target = Config(<String, dynamic>{
        'extra_libraries': ['package:foo/foo.dart', 'package:bar/bar.dart']
      });
      expect(
        target.extraLibraries,
        ['package:foo/foo.dart', 'package:bar/bar.dart'],
      );
    });

    test('0 extra_libraries -> empty', () {
      const target = Config(<String, dynamic>{'extra_libraries': <String>[]});
      expect(target.extraLibraries, isEmpty);
    });

    test('invalid casing -- ignored', () {
      const target = Config(<String, dynamic>{
        'Extra_Libraries': ['package:foo/foo.dart', 'package:bar/bar.dart']
      });
      expect(target.extraLibraries, isEmpty);
    });

    test('non boolean -- ignored', () {
      const target = Config(<String, dynamic>{'extra_libraries': true});
      expect(target.extraLibraries, isEmpty);
    });

    test(
        'hetero types -- only non-nested string elements in list are recognized',
        () {
      const target = Config(<String, dynamic>{
        'extra_libraries': [
          'package:foo/foo.dart',
          true,
          ['package:bar/bar.dart'],
          'package:boo/boo.dart',
        ]
      });
      expect(
        target.extraLibraries,
        ['package:foo/foo.dart', 'package:boo/boo.dart'],
      );
    });
  });
}
