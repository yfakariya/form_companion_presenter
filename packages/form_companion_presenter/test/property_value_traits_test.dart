// See LICENCE file in the root.

import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/property_value_traits.dart';

void main() {
  test('sensitive: isSensitive is true and canRestoreState is false', () {
    final target = PropertyValueTraits.sensitive;
    expect(target.isSensitive, isTrue);
    expect(target.canRestoreState, isFalse);
  });

  test('doNotRestoreState: isSensitive is false and canRestoreState is false',
      () {
    final target = PropertyValueTraits.doNotRestoreState;
    expect(target.isSensitive, isFalse);
    expect(target.canRestoreState, isFalse);
  });

  test('none: isSensitive is false and canRestoreState is true', () {
    final target = PropertyValueTraits.none;
    expect(target.isSensitive, isFalse);
    expect(target.canRestoreState, isTrue);
  });
}
