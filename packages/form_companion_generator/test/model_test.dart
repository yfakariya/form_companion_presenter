// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final libraryReader = LibraryReader(
    (await getResolvedLibraryResult('form_companion_annotation.dart')).element,
  );

  ElementAnnotation findAnnotation(String className) {
    final type = libraryReader.findType(className);
    if (type == null) {
      throw AssertionError('Failed to find "$className" class.');
    }

    return type.metadata.single;
  }

  ConstantReader findAnnotationValue(String className) {
    final value = findAnnotation(className).computeConstantValue();
    if (value == null) {
      throw AssertionError(
          'Failed to resolve annotation of "$className" class.');
    }

    return ConstantReader(value);
  }

  group('FormCompanionAnnotation', () {
    test('default -> autovalidate is null', () {
      final target = FormCompanionAnnotation(findAnnotationValue('Default'));
      expect(target.autovalidate, isNull);
    });

    test('empty -> autovalidate is null', () {
      final target = FormCompanionAnnotation(findAnnotationValue('Empty'));
      expect(target.autovalidate, isNull);
    });

    test('autovalidate is true', () {
      final target =
          FormCompanionAnnotation(findAnnotationValue('AutovalidateIsTrue'));
      expect(target.autovalidate, isTrue);
    });

    test('autovalidate is false', () {
      final target =
          FormCompanionAnnotation(findAnnotationValue('AutovalidateIsFalse'));
      expect(target.autovalidate, isFalse);
    });
  });

  group('isFormCompanionAnnotation', () {
    test(
      '@formCompanion - true',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('Default')),
        isTrue,
      ),
    );

    test(
      '@FormCompanion() - true',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('Empty')),
        isTrue,
      ),
    );

    test(
      '@visibleForTesting - false',
      () => expect(
        isFormCompanionAnnotation(findAnnotation('AnotherAnnotation')),
        isFalse,
      ),
    );
  });

  group('ParameterInfo edge cases', () {
    test('fromNodeAsync(SuperFormalParameter)', () async {
      final dispose = Completer<void>();
      try {
        late final Resolver resolver;
        await resolveSource(
          '''
library _lib;

class B {
  final int v;
  B(this.v);
}
class C {
  C(super.v);
}
''',
          (r) => resolver = r,
          tearDown: dispose.future,
        );
        final library = await resolver.findLibraryByName('_lib');
        final element = library!.getType('C')!.constructors.single;
        final target = await resolver.astNodeFor(element, resolve: true);
        await expectLater(
          ParameterInfo.fromNodeAsync(
            NodeProvider(resolver),
            target!.childEntities
                .whereType<FormalParameterList>()
                .single
                .childEntities
                .whereType<FormalParameter>()
                .single,
          ),
          throwsA(
            isA<InvalidGenerationSourceError>()
                .having(
                  (e) => e.message,
                  'message',
                  startsWith(
                    "Failed to parse complex parameter 'super.v' "
                    '(SuperFormalParameterImpl) at ',
                  ),
                )
                .having(
                  (e) => e.element,
                  'element',
                  isA<SuperFormalParameterElement>(),
                ),
          ),
        );
      } finally {
        dispose.complete();
      }
    });
  });

  // Other classes can be tested well via emitter_test.
}
