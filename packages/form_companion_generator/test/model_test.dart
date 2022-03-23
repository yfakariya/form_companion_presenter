// See LICENCE file in the root.

import 'dart:async';

import 'package:form_companion_generator/src/model.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final libraryReader = LibraryReader(
    (await getResolvedLibraryResult('form_companion_annotation.dart')).element,
  );

  ConstantReader findAnnotation(String className) {
    final type = libraryReader.findType(className);
    if (type == null) {
      throw AssertionError('Failed to find "$className" class.');
    }

    final value = type.metadata.single.computeConstantValue();
    if (value == null) {
      throw AssertionError(
          'Failed to resolve annotation of "$className" class.');
    }

    return ConstantReader(value);
  }

  group('FormCompanionAnnotation', () {
    test('default -> autovalidate is true, suppressFieldFactory is false', () {
      final target = FormCompanionAnnotation(findAnnotation('Default'));
      expect(target.autovalidate, isTrue);
      expect(target.suppressFieldFactory, isFalse);
    });

    test('autovalidate is true', () {
      final target =
          FormCompanionAnnotation(findAnnotation('AutovalidateIsTrue'));
      expect(target.autovalidate, isTrue);
    });

    test('autovalidate is false', () {
      final target =
          FormCompanionAnnotation(findAnnotation('AutovalidateIsFalse'));
      expect(target.autovalidate, isFalse);
    });

    test('suppressFieldFactory is true', () {
      final target =
          FormCompanionAnnotation(findAnnotation('SuppressFieldFactoryIsTrue'));
      expect(target.suppressFieldFactory, isTrue);
    });

    test('suppressFieldFactory is false', () {
      final target = FormCompanionAnnotation(
          findAnnotation('SuppressFieldFactoryIsFalse'));
      expect(target.suppressFieldFactory, isFalse);
    });
  });

  // Other classes can be tested well via emitter_test.
}
