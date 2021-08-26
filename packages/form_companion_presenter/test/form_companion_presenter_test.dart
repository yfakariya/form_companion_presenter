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

class FixedFormStateAdapter implements FormStateAdapter {
  final AutovalidateMode _autovalidateMode;
  final VoidCallback _onSave;
  final bool Function() _onValidate;

  FixedFormStateAdapter({
    AutovalidateMode? autovalidateMode,
    VoidCallback? onSave,
    bool Function()? onValidate,
  })  : _autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        _onSave = (onSave ?? () {}),
        _onValidate = (onValidate ?? () => true) {}

  @override
  AutovalidateMode get autovalidateMode => _autovalidateMode;

  @override
  void save() => _onSave();

  @override
  bool validate() => _onValidate();
}

class DummyBuildContext extends BuildContext {
  DummyBuildContext();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor,
      {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object? aspect}) {
    // Required for getLocale() test.
    return null;
  }

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    throw UnimplementedError();
  }

  @override
  RenderObject? findRenderObject() {
    throw UnimplementedError();
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    throw UnimplementedError();
  }

  @override
  BuildOwner? get owner => throw UnimplementedError();

  @override
  Size? get size => throw UnimplementedError();

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    throw UnimplementedError();
  }

  @override
  void visitChildElements(ElementVisitor visitor) {
    throw UnimplementedError();
  }

  @override
  Widget get widget => throw UnimplementedError();
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

  group('submit', () {
    group('canSubmit()', () {
      test('calls maybeFormStateOf() anyway.', () {
        final context = DummyBuildContext();
        BuildContext? passedContext;
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (x) {
            passedContext = x;
            return null;
          },
        );

        // ignore: cascade_invocations, invalid_use_of_protected_member
        target.canSubmit(context);
        expect(passedContext, same(context));
      });

      test('returns true when maybeFormStateOf() returns null.', () {
        final context = DummyBuildContext();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => null,
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isTrue);
      });

      test('returns true when maybeFormStateOf() returns null.', () {
        final context = DummyBuildContext();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
            autovalidateMode: AutovalidateMode.disabled,
          ),
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isTrue);
      });

      test('returns false when any validation is failed.', () {
        final context = DummyBuildContext();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onValidate: () => false,
          ),
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isFalse);
      });

      test('returns false when any async validation is not completed.', () {
        final completer = Completer<String?>();
        final context = DummyBuildContext();
        TestPresenter? target;
        target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add(
              name: 'never',
              asyncValidatorFactories: [
                (_) => (v, l, p) => completer.future,
              ],
            ),
          maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onValidate: () => target!.properties.values.every(
              // Simulate validators call here with null value
              // and then check there is no error message (null).
              (p) => p.getValidator(DummyBuildContext()).call(null) == null,
            ),
          ),
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isFalse);
        // drain
        completer.complete();
      });

      test('returns true when there are no properties.', () {
        final context = DummyBuildContext();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            // This lamda returns null because the array is empty.
            onValidate: () => <bool>[].every((_) => false),
          ),
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isTrue);
      });

      test('returns true when all validation is completed successfully.',
          () async {
        final context = DummyBuildContext();
        TestPresenter? target;
        target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add(
              name: 'valid',
              validatorFactories: [
                (_) => (v) => null,
                (_) => (v) => null,
              ],
              asyncValidatorFactories: [
                // Note that following lambdas will complete only after
                // event pumping...
                (_) => (v, l, p) => null,
                (_) => (v, l, p) => null,
              ],
            ),
          maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onValidate: () => target!.properties.values.every(
              // Simulate validators call here with null value
              // and then check there is no error message (null).
              (p) => p.getValidator(DummyBuildContext()).call(null) == null,
            ),
          ),
        );
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isFalse);
        // Do event pumping to complete Future.sync of lambdas.
        await Future<void>.delayed(Duration.zero);
        // ignore: invalid_use_of_protected_member
        expect(target.canSubmit(context), isTrue);
      });

      group('submit', () {
        test('returns null when canSubmit() is false.', () {
          TestPresenter? target;
          target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..add(name: 'valid', validatorFactories: [
                (_) => (v) => 'DUMMY',
              ]),
            doSubmitCalled: (_) {},
            maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onValidate: () => target!.properties.values.every(
                // Simulate validators call here with null value
                // and then check there is no error message (null).
                (p) => p.getValidator(DummyBuildContext()).call(null) == null,
              ),
            ),
          );

          expect(target.submit(DummyBuildContext()), isNull);
        });

        test('returns doSubmit when canSubmit() is true.', () {
          BuildContext? passedContext;
          final context = DummyBuildContext();
          TestPresenter? target;
          target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..add(name: 'valid', validatorFactories: [
                (_) => (v) => null,
              ]),
            doSubmitCalled: (x) {
              passedContext = x;
            },
            maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onValidate: () => target!.properties.values.every(
                // Simulate validators call here with null value
                // and then check there is no error message (null).
                (p) => p.getValidator(DummyBuildContext()).call(null) == null,
              ),
            ),
          );

          final submit = target.submit(context);
          expect(submit, isNotNull);
          submit!();
          expect(passedContext, same(context));
        });
      });

      // TODO(yfakariya): delayed async validation completion case in Widget tests.
    });
  });

  group('helpers', () {
    test('getLocale() returns \'en-US\' for outside widgets.', () {
      final target = TestPresenter(properties: PropertyDescriptorsBuilder());
      // ignore: invalid_use_of_protected_member
      final locale = target.getLocale(DummyBuildContext());
      expect(locale.languageCode, equals('en'));
      expect(locale.countryCode, equals('US'));
      expect(locale.scriptCode, isNull);
    });
  });
}
