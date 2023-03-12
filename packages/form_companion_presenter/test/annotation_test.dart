// See LICENCE file in the root.

import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/form_companion_annotation.dart';

void main() {
  group('@FormCompanion', () {
    test(
      'default',
      () {
        expect(const FormCompanion().autovalidate, isNull);
      },
    );
  });
}
