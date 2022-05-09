// See LICENCE file in the root.

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/form_companion_annotation.dart';

const frenchLocale = Locale('fr', 'FR');

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
