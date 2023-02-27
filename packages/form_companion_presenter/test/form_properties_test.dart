// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';

import 'test_helpers.dart';

class _TestCompanionPresenterFeatures extends CompanionPresenterFeatures {
  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      FixedFormStateAdapter();

  @override
  void restoreField(
    BuildContext context,
    String name,
    Object? value, {
    required bool hasError,
  }) =>
      throw UnimplementedError();
}

class TestPresenter with CompanionPresenterMixin {
  late final CompanionPresenterFeatures presenterFeatures;

  final FutureOr<void> Function() _onDoSubmit;
  final bool Function(BuildContext) _onCanSubmit;

  TestPresenter({
    required PropertyDescriptorsBuilder properties,
    FutureOr<void> Function()? onDoSubmit,
    bool Function(BuildContext)? onCanSubmit,
  })  : _onDoSubmit = (onDoSubmit ?? () {}),
        _onCanSubmit = (onCanSubmit ?? (_) => true) {
    presenterFeatures = _TestCompanionPresenterFeatures();
    initializeCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit() => _onDoSubmit();

  @override
  bool canSubmit(BuildContext context) => _onCanSubmit(context);
}

void main() {
  group('presenter', () {
    test('can get from presenter property', () {
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
      );

      final target = presenter.propertiesState;

      expect(target.presenter, same(presenter));
    });

    test('is proxied with canSubmit', () {
      BuildContext? passed;
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
        onCanSubmit: (x) {
          passed = x;
          return true;
        },
      );

      final target = presenter.propertiesState;
      final context = DummyBuildContext();
      final result = target.canSubmit(context);

      expect(result, isTrue);
      expect(passed, same(context));
    });

    test('is proxied with submit', () async {
      final completer = Completer<void>();
      BuildContext? passed;
      var called = 0;
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
        onCanSubmit: (x) {
          passed = x;
          return true;
        },
        onDoSubmit: () {
          called++;
          completer.complete();
        },
      );

      final target = presenter.propertiesState;
      final context = DummyBuildContext();
      final submit = target.submit(context);
      expect(submit, isNotNull);

      submit!();
      await completer.future;

      expect(passed, same(context));
      expect(called, 1);
    });
  });

  group('getDescriptor', () {
    test('can get registered descriptor', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int')
          ..string(name: 'string'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 2);
      expect(descriptors, contains('int'));
      expect(descriptors, contains('string'));

      expect(target.getDescriptor('int'), same(descriptors['int']));
      expect(target.getDescriptor('string'), same(descriptors['string']));
    });

    test('cannot get not registered descriptor', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 1);
      expect(descriptors, contains('int'));

      expect(
        () => target.getDescriptor('double'),
        throwsArgumentError,
      );
    });
  });

  group('tryGetDescriptor', () {
    test('can get registered descriptor', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int')
          ..string(name: 'string'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 2);
      expect(descriptors, contains('int'));
      expect(descriptors, contains('string'));

      expect(target.tryGetDescriptor('int'), same(descriptors['int']));
      expect(target.tryGetDescriptor('string'), same(descriptors['string']));
    });

    test('returns null for not registered descriptor', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 1);
      expect(descriptors, contains('int'));

      expect(target.tryGetDescriptor('double'), isNull);
    });

    test('can get registered descriptor as right typed', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 1);
      expect(descriptors, contains('int'));

      expect(
        target.tryGetDescriptor<int, String>('int'),
        same(descriptors['int']),
      );
    });

    test('cannot get registered descriptor as miss typed', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()..integerText(name: 'int'),
      ).propertiesState;

      final descriptors = {
        for (final d in target.getAllDescriptors()) d.name: d
      };
      expect(descriptors.length, 1);
      expect(descriptors, contains('int'));

      expect(
        () => target.tryGetDescriptor<String, String>('int'),
        throwsStateError,
      );
    });
  });

  group('getValue', () {
    test('can get initial value', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      expect(target.getValue('int'), initialInt);
      expect(target.getValue('string'), initialString);
    });

    test('can get uninitialized value (null)', () {
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int')
          ..string(name: 'string'),
      ).propertiesState;

      expect(target.getValue('int'), isNull);
      expect(target.getValue('string'), isNull);
    });

    test('cannot get unregistered value', () {
      const initialInt = 123;
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt),
      ).propertiesState;

      expect(
        () => target.getValue('string'),
        throwsArgumentError,
      );
    });
  });

  group('copyWithProperty', () {
    test('registered value can be overriden and new copy is returned', () {
      const initialInt = 123;
      const newInt = 987;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperty('int', newInt);

      expect(identical(target, source), isFalse);
      expect(target.getValue('int'), newInt);
      expect(source.getValue('int'), initialInt);
    });

    test('unspecified value can not be overriden and new copy is returned', () {
      const initialInt = 123;
      const newInt = 987;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperty('int', newInt);
      expect(target.getValue('string'), initialString);
    });

    test('with same value, original instance is returned', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperty('int', initialInt);

      expect(target, same(source));
      expect(target.getValue('int'), initialInt);
      expect(target.getValue('string'), initialString);
    });

    test('can set null', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperty('int', null);
      ;
      expect(target.getValue('int'), null);
      expect(target.getValue('string'), initialString);
    });

    test('with unregistered value, original instance is returned', () {
      const initialInt = 123;
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt),
      ).propertiesState;

      final target = source.copyWithProperty('string', 'ABC');

      expect(target, same(source));
      expect(target.getValue('int'), initialInt);
    });
  });

  group('copyWithProperties', () {
    test('registered value can be overriden and new copy is returned', () {
      const initialInt = 123;
      const newInt = 987;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperties({'int': newInt});

      expect(identical(target, source), isFalse);
      expect(target.getValue('int'), newInt);
      expect(source.getValue('int'), initialInt);
    });

    test('unspecified value can not be overriden and new copy is returned', () {
      const initialInt = 123;
      const newInt = 987;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperties({'int': newInt});
      expect(target.getValue('string'), initialString);
    });

    test('with same value, original instance is returned', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperties({
        'int': initialInt,
        'string': initialString,
      });

      expect(target, same(source));
      expect(target.getValue('int'), initialInt);
      expect(target.getValue('string'), initialString);
    });

    test('can set null', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      final target = source.copyWithProperties({'int': null});
      ;
      expect(target.getValue('int'), null);
      expect(target.getValue('string'), initialString);
    });

    test('with unregistered value, original instance is returned', () {
      const initialInt = 123;
      final source = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt),
      ).propertiesState;

      final target = source.copyWithProperties({'string': 'ABC'});

      expect(target, same(source));
      expect(target.getValue('int'), initialInt);
    });
  });

  group('equality', () {
    test('same instance returns true', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      expect(target == target, isTrue);
    });

    test('different instance with sameValue returns true', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      );
      final target1 = presenter.propertiesState;
      final target2 = target1
          .copyWithProperty('int', 0)
          .copyWithProperty('int', initialInt);

      expect(identical(target1, target2), isFalse);
      expect(target1 == target2, isTrue);
    });

    test('different values returns false', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      );
      final target1 = presenter.propertiesState;
      final target2 = target1.copyWithProperties({'int': 123, 'string': 'ZYX'});

      expect(target1 == target2, isFalse);
    });

    test('different presenter returns false', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final properties = PropertyDescriptorsBuilder()
        ..integerText(name: 'int', initialValue: initialInt)
        ..string(name: 'string', initialValue: initialString);

      final presenter1 = TestPresenter(
        properties: properties,
      );

      final presenter2 = TestPresenter(
        properties: properties,
      );

      final target1 = presenter1.propertiesState;
      final target2 = presenter2.propertiesState;

      expect(target1 == target2, isFalse);
    });
  });

  group('hashcode', () {
    test('same instance returns same', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      ).propertiesState;

      expect(target.hashCode == target.hashCode, isTrue);
    });

    test('different instance with sameValue returns same', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      );
      final target1 = presenter.propertiesState;
      final target2 = presenter.propertiesState
          .copyWithProperty('int', 0)
          .copyWithProperty('int', initialInt);

      expect(identical(target1, target2), isFalse);
      expect(target1.hashCode == target2.hashCode, isTrue);
    });

    test('different values may return differ', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final presenter = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..integerText(name: 'int', initialValue: initialInt)
          ..string(name: 'string', initialValue: initialString),
      );
      final target1 = presenter.propertiesState;
      final target2 = target1.copyWithProperties({'int': 123, 'string': 'ZYX'});

      expect(target1.hashCode == target2.hashCode, isFalse);
    });

    test('different presenter may return differ', () {
      const initialInt = 123;
      const initialString = 'ABC';
      final properties = PropertyDescriptorsBuilder()
        ..integerText(name: 'int', initialValue: initialInt)
        ..string(name: 'string', initialValue: initialString);

      final presenter1 = TestPresenter(
        properties: properties,
      );

      final presenter2 = TestPresenter(
        properties: properties,
      );

      final target1 = presenter1.propertiesState;
      final target2 = presenter2.propertiesState;

      expect(target1.hashCode == target2.hashCode, isFalse);
    });
  });
}
