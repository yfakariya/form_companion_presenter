// See LICENCE file in the root.

import 'dart:async';
import 'dart:math';

import 'package:flutter/src/foundation/diagnostics.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

class TestPresenter with FormCompanionPresenterMixin {
  final void Function(BuildContext) _doSubmitCalled;
  final FormStateAdapter? Function(BuildContext) _maybeFormStateOfCalled;

  TestPresenter({
    required PropertyDescriptorsBuilder properties,
    void Function(BuildContext)? doSubmitCalled,
    FormStateAdapter? Function(BuildContext)? maybeFormStateOfCalled,
  })  : _doSubmitCalled = (doSubmitCalled ?? (_) {}),
        _maybeFormStateOfCalled = (maybeFormStateOfCalled ?? (_) => null) {
    initializeFormCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    _doSubmitCalled(context);
  }

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _maybeFormStateOfCalled(context);
}
void main() {
  // Note: maybeFormStateOf() and saveFields() should be tested as overridden.
  group('property', () {
    group('properties', () {
      test('is initialized with constructor argument.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(name: 'int')
            ..add<String>(name: 'string'),
        );
        expect(target.properties.length, equals(2));
        expect(target.properties, contains('int'));
        expect(target.properties['int'], isA<PropertyDescriptor<int, void>>());

        expect(target.properties, contains('string'));
        expect(
          target.properties['string'],
          isA<PropertyDescriptor<String, void>>(),
        );
      });

      test('can be empty even if it looks useless.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
        );
        expect(target.properties.length, equals(0));
      });
    });

    group('getProperty', () {
      test('is wrapper of properties.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(name: 'int')
            ..add<String>(name: 'string'),
        );
        expect(target.getProperty<int>('int'), isNotNull);
        expect(target.getProperty<int>('int'), same(target.properties['int']));

        expect(target.getProperty<String>('string'), isNotNull);
        expect(
          target.getProperty<String>('string'),
          same(target.properties['string']),
        );
      });

      test('throws ArgumentError for unknown.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        expect(() => target.getProperty<String>('string'), throwsArgumentError);
      });

      test('throws StateError for incompatible type.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        expect(() => target.getProperty<String>('int'), throwsStateError);
      });
    });

    group('PropertyDescriptor', () {
      test('can be get / set typed value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int?>(name: 'int'),
        );

        final property = target.getProperty<int?>('int');
        // ignore: cascade_invocations
        property.value = 123;
        expect(property.value, equals(123));
      });

      test('can be get / set dynamic value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int?>(name: 'int'),
        );

        final property = target.getProperty<int?>('int');
        // ignore: cascade_invocations
        property.setDynamicValue(123);
        expect(property.value, equals(123));
      });

      test('throws StateError from get value until any value set.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int?>(name: 'int?')
            ..add<int>(name: 'int'),
        );

        expect(() => target.getProperty<int>('int').value, throwsStateError);
        // ... even if nullable
        expect(() => target.getProperty<int?>('int?').value, throwsStateError);
      });

      test('throws ArgumentError from setDynamicValue for incompatible type.',
          () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int?>(name: 'int'),
        );

        final property = target.getProperty<int?>('int');
        // ignore: cascade_invocations
        expect(() => property.setDynamicValue('ABC'), throwsArgumentError);
      });

      test(
          'throws ArgumentError from setDynamicValue for incompatible nullability type.',
          () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final property = target.getProperty<int>('int');
        expect(() => property.setDynamicValue(null), throwsArgumentError);
      });

      test('throws StateError from get value for non-nullable type initially.',
          () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final property = target.getProperty<int>('int');
        expect(() => property.value, throwsStateError);
      });
    });
  });
}
