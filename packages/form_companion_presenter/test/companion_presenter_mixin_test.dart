// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/form_companion_presenter.dart';

class TestPresenter with CompanionPresenterMixin {
  final void Function() _doSubmitCalled;
  final FormStateAdapter? Function(BuildContext) _maybeFormStateOfCalled;
  final void Function(AsyncError)? _onHandleCanceledAsyncValidationError;
  final bool Function(BuildContext) _canSubmitCalled;

  TestPresenter({
    required PropertyDescriptorsBuilder properties,
    void Function()? doSubmitCalled,
    FormStateAdapter? Function(BuildContext)? maybeFormStateOfCalled,
    void Function(AsyncError)? onHandleCanceledAsyncValidationError,
    bool Function(BuildContext)? canSubmitCalled,
  })  : _doSubmitCalled = (doSubmitCalled ?? () {}),
        _maybeFormStateOfCalled = (maybeFormStateOfCalled ?? (_) => null),
        _onHandleCanceledAsyncValidationError =
            onHandleCanceledAsyncValidationError,
        _canSubmitCalled = (canSubmitCalled ?? (_) => true) {
    initializeCompanionMixin(properties);
  }

  @override
  void handleCanceledAsyncValidationError(AsyncError error) {
    final handler = _onHandleCanceledAsyncValidationError;
    if (handler != null) {
      handler(error);
    } else {
      super.handleCanceledAsyncValidationError(error);
    }
  }

  @override
  FutureOr<void> doSubmit() async {
    _doSubmitCalled();
  }

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _maybeFormStateOfCalled(context);

  @override
  bool canSubmit(BuildContext context) => _canSubmitCalled(context);
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
        _onValidate = (onValidate ?? () => true);

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
  // For debugging
  loggerSink = (
    name,
    level,
    message,
    zone,
    error,
    stackTrace,
  ) {
    String messageString;
    if (message is String Function()) {
      messageString = message();
    } else if (message is String) {
      messageString = message;
    } else {
      messageString = message?.toString() ?? '';
    }

    String errorString;
    if (error != null) {
      if (stackTrace != null) {
        errorString = ' $error\n$stackTrace';
      } else {
        errorString = ' $error';
      }
    } else {
      errorString = '';
    }

    printOnFailure('[${level.name}] $name: $messageString$errorString');
  };

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
        expect(target.properties['int'], isA<PropertyDescriptor<int>>());

        expect(target.properties, contains('string'));
        expect(
          target.properties['string'],
          isA<PropertyDescriptor<String>>(),
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

    group('savePropertyValue', () {
      test('non-null for never-registered property but throws ArgumentError.',
          () {
        final presenter = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final target = presenter.savePropertyValue('long');
        expect(target, isNotNull);
        expect(() => target(0), throwsArgumentError);
      });

      test(
          'non-null for registered property and passes through to PropertyDescriptor.saveValue.',
          () {
        final presenter = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final target = presenter.savePropertyValue('int');
        expect(target, isNotNull);
        final value = DateTime.now().microsecondsSinceEpoch;
        target(value);

        // Check pass through
        expect(presenter.getProperty('int').savedValue, equals(value));
      });
    });

    group('getSavedPropertyValue', () {
      test('assertion error when never saved.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        expect(() => target.getSavedPropertyValue('int'), throwsAssertionError);
      });

      test('can get saved value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final value = DateTime.now().microsecondsSinceEpoch;
        target.savePropertyValue('int')(value);
        expect(target.getSavedPropertyValue('int'), equals(value));
      });
    });

    group('hasPendingAsyncValidations', () {
      test('ArgumentError for never-registered property.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        expect(
          () => target.hasPendingAsyncValidations('long'),
          throwsArgumentError,
        );
      });

      test('false for any async validations have never run.', () {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(name: 'int', asyncValidatorFactories: [
              (_) => (value, options) async {
                    await completer.future;
                    return null;
                  }
            ]),
        );

        expect(target.hasPendingAsyncValidations('int'), isFalse);
      });

      test('true for any async validations are running.', () {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(name: 'int', asyncValidatorFactories: [
              (_) => (value, options) async {
                    await completer.future;
                    return null;
                  }
            ]),
        );

        target.getProperty<int>('int').getValidator(DummyBuildContext())(123);
        expect(target.hasPendingAsyncValidations('int'), isTrue);
        completer.complete();
      });

      test('false for all async validations are finished.', () async {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(name: 'int', asyncValidatorFactories: [
              (_) => (value, options) async {
                    completer.complete();
                    return null;
                  }
            ]),
        );

        target.getProperty<int>('int').getValidator(DummyBuildContext())(123);
        await completer.future;
        // pump
        await Future<void>.delayed(Duration.zero);
        expect(target.hasPendingAsyncValidations('int'), isFalse);
      });
    });

    group('PropertyDescriptor', () {
      test('can be get / save value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final property = target.getProperty<int>('int');
        // ignore: cascade_invocations
        property.saveValue(123);
        expect(property.savedValue, equals(123));
      });

      test('throws ArgumentError from saveValue for incompatible type.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );

        final property = target.getProperty<int>('int');
        // ignore: cascade_invocations
        expect(() => property.saveValue('ABC'), throwsArgumentError);
      });
    });
  });

  group('submit', () {
    test('returns null when canSubmit() is false.', () {
      TestPresenter? target;
      target = TestPresenter(
        properties: PropertyDescriptorsBuilder(),
        doSubmitCalled: () {},
        maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onValidate: () => target!.properties.values.every(
            // Simulate validators call here with null value
            // and then check there is no error message (null).
            (p) => p.getValidator(DummyBuildContext()).call(null) == null,
          ),
        ),
        canSubmitCalled: (_) => false,
      );

      expect(target.submit(DummyBuildContext()), isNull);
    });

    test('returns doSubmit when canSubmit() is true.', () async {
      final doSubmitCalled = Completer<void>();
      final context = DummyBuildContext();
      TestPresenter? target;
      target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add(name: 'valid', validatorFactories: [
            (_) => (v) => null,
          ]),
        doSubmitCalled: doSubmitCalled.complete,
        maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onValidate: () => target!.properties.values.every(
            // Simulate validators call here with null value
            // and then check there is no error message (null).
            (p) => p.getValidator(DummyBuildContext()).call(null) == null,
          ),
        ),
        canSubmitCalled: (_) => true,
      );

      final submit = target.submit(context);
      expect(submit, isNotNull);
      submit!();
      await doSubmitCalled.future;
      expect(doSubmitCalled.isCompleted, isTrue);
    });
  });

  group('validation', () {
    test('preceding validation is canceled', () async {
      final context = DummyBuildContext();
      final asyncOperationStartGates = [
        Completer<void>(),
        Completer<void>(),
      ];
      final asyncOperationCompletions = [
        Completer<void>(),
        Completer<void>(),
      ];

      final values = <int?>[];
      final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(
              name: 'prop',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      values.add(value);
                      if (value != null) {
                        await asyncOperationStartGates[value].future;
                      }

                      try {
                        return value?.toString() ?? 'null';
                      } finally {
                        final completion =
                            asyncOperationCompletions[value ?? 0];
                        if (!completion.isCompleted) {
                          completion.complete();
                        }
                      }
                    }
              ],
            ));

      final validator = target.getProperty<int>('prop').getValidator(context);
      expect(validator(0), isNull);
      expect(asyncOperationStartGates[0].isCompleted, isFalse);
      expect(validator(1), isNull);
      expect(asyncOperationStartGates[1].isCompleted, isFalse);

      // Resume following validation first and then wait.
      asyncOperationStartGates[1].complete();
      await asyncOperationCompletions[1].future;

      // Resume preceding validation next and then wait.
      asyncOperationStartGates[0].complete();
      await asyncOperationCompletions[0].future;

      // Check validation calls with their order.
      expect(values, equals([0, 1]));

      // Try call following validation again
      expect(validator(1), equals('1'));
      // If preceding validation is NOT canceled,
      // the cache should be a result of validator(0),
      // so validator(1) invocation does not hit the cache
      // and causes additional validation logic execution.
      // But if the preceding validation is canceled correctly,
      // validation calls record should not be changed here.
      expect(values, equals([0, 1]));
    });

    group('handleCanceledAsyncValidationError()', () {
      Future<void> doTest({
        void Function(AsyncError)? onHandleCanceledAsyncValidationError,
      }) async {
        final context = DummyBuildContext();
        final completers = [
          Completer<void>(),
          Completer<void>(),
          Completer<void>(),
        ];
        final backCompleters = [
          Completer<void>(),
          Completer<void>(),
          Completer<void>(),
        ];

        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int>(
              name: 'prop',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      if (value != null) {
                        await completers[value].future;
                      }

                      try {
                        if ((value ?? 0) == 0) {
                          return null;
                        } else if (value == 1) {
                          return 'Validation error.';
                        } else {
                          throw Exception(value?.toString());
                        }
                      } finally {
                        final backCompleter = backCompleters[value ?? 0];
                        if (!backCompleter.isCompleted) {
                          backCompleter.complete();
                        }
                      }
                    }
              ],
            ),
          onHandleCanceledAsyncValidationError:
              onHandleCanceledAsyncValidationError,
        );

        final validator = target.getProperty<int>('prop').getValidator(context);
        // Causes exception
        expect(validator(2), isNull);
        // Cancel previous
        expect(validator(1), isNull);
        completers[1].complete();
        completers[2].complete();

        await backCompleters[1].future;
        await backCompleters[2].future;

        expect(validator(1), isNotNull);
      }

      test('is called for unhandled exception in canceled validation.',
          () async {
        Object? handledError;
        await doTest(
          onHandleCanceledAsyncValidationError: (error) {
            handledError = error;
          },
        );

        expect(handledError, isNotNull);
      });
      test('just call print().', () async {
        String? handledErrorToString;
        Zone? unhandledZone;

        await runZoned(
          () async {
            await doTest();

            // Default implementation of handleCanceledAsyncValidationError()
            // calles current zone's handleUncaughtError()
            expect(handledErrorToString, isNotNull);
            expect(unhandledZone, same(Zone.current));
          },
          zoneSpecification: ZoneSpecification(
            print: (self, parent, zone, line) {
              handledErrorToString = line;
              unhandledZone = zone;
            },
          ),
        );
      });
    });

    group('buildOnAsyncValidationCompleted()', () {
      test('returned callback calls validator\'s.validate()', () {
        var isValidatorCalled = false;
        final state = FixedFormStateAdapter(
          onValidate: () {
            isValidatorCalled = true;
            return true;
          },
        );
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => state,
        );

        final context = DummyBuildContext();
        final notifier =
            target.buildOnAsyncValidationCompleted('prop', context);
        notifier(null, null);
        expect(isValidatorCalled, isTrue);
      });
    });

    group('validateAll()', () {
      test('calls validate() when no asyncs', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
        );

        var isStateValidateCalled = false;
        final state = FixedFormStateAdapter(
          onValidate: () {
            isStateValidateCalled = true;
            return true;
          },
        );
        target.validateAll(state);
        expect(isStateValidateCalled, isTrue);
      });

      test('just call state.validate() once when no asyncs', () async {
        Future<void> testCore(
          TestPresenter presenter,
          // ignore: avoid_positional_boolean_parameters
          bool dummyValidateResult,
        ) async {
          var stateValidateCalled = false;
          final state = FixedFormStateAdapter(onValidate: () {
            stateValidateCalled = true;
            return dummyValidateResult;
          });

          expect(
              await presenter.validateAll(state), equals(dummyValidateResult));
          expect(stateValidateCalled, isTrue);
        }

        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int>(name: 'int'),
        );
        await testCore(target, true);
        await testCore(target, false);
      });

      test(
          'call state.validate() twice with waiting async completion when any asyncs',
          () async {
        Future<void> testCore({
          bool? expectedResult,
        }) async {
          FormStateAdapter? state;
          var asyncValidatorCalled = false;
          final target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..add<int>(name: 'int', asyncValidatorFactories: [
                (_) => (value, options) async {
                      final result = await Future.delayed(
                        Duration.zero,
                        () {
                          return (expectedResult ?? false) ? null : 'ERROR';
                        },
                      );
                      asyncValidatorCalled = true;
                      return result;
                    }
              ]),
            maybeFormStateOfCalled: (_) => state,
          );
          final validationResults = <bool>[];
          state = FixedFormStateAdapter(
            onValidate: () {
              // dummy logic
              final context = DummyBuildContext();
              final validator =
                  target.getProperty<int>('int').getValidator(context);
              final result = validator(1) == null;
              validationResults.add(result);
              return result;
            },
          );

          expect(
            await target.validateAll(state),
            equals(expectedResult ?? false),
          );
          expect(validationResults.length, equals(2));
          expect(validationResults, equals([true, expectedResult ?? false]));
          expect(asyncValidatorCalled, isTrue);
        }

        await testCore(expectedResult: true);
        await testCore(expectedResult: false);
      });
    });

    group('validateAndSave()', () {
      test(
          'calls validateAll() and call save() when validateAll() returns true',
          () async {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
        );

        var isStateValidateCalled = false;
        var isSaveCalled = false;
        final state = FixedFormStateAdapter(
          onValidate: () {
            isStateValidateCalled = true;
            return true;
          },
          onSave: () {
            isSaveCalled = true;
          },
        );
        final result = await target.validateAndSave(state);
        expect(isStateValidateCalled, isTrue);
        expect(result, isTrue);
        expect(isSaveCalled, isTrue);
      });

      test(
          'calls validateAll() and then just return false when validateAll() returns false',
          () async {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
        );

        var isStateValidateCalled = false;
        var isSaveCalled = false;
        final state = FixedFormStateAdapter(
          onValidate: () {
            isStateValidateCalled = true;
            return false;
          },
          onSave: () {
            isSaveCalled = true;
          },
        );
        final result = await target.validateAndSave(state);
        expect(isStateValidateCalled, isTrue);
        expect(result, isFalse);
        expect(isSaveCalled, isFalse);
      });
    });
  });

  group('PropertyDescriptor', () {
    test('getValidator() returns validator which wraps syncs and asyncs.',
        () async {
      const name = 'property';
      final completer1 = Completer<void>();
      final completer2 = Completer<void>();
      int? syncValue1;
      int? syncValue2;
      int? asyncValue1;
      int? asyncValue2;
      Locale? asyncLocale1;
      Locale? asyncLocale2;
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int>(
            name: name,
            validatorFactories: [
              (context) => (value) {
                    syncValue1 = value;
                    return null;
                  },
              (context) => (value) {
                    syncValue2 = value;
                    return null;
                  },
            ],
            asyncValidatorFactories: [
              (context) => (value, options) {
                    printOnFailure('async1 with $value');
                    asyncValue1 = value;
                    asyncLocale1 = options.locale;
                    completer1.complete();
                    return null;
                  },
              (context) => (value, options) {
                    printOnFailure('async2 with $value');
                    asyncValue2 = value;
                    asyncLocale2 = options.locale;
                    completer2.complete();
                    return null;
                  },
            ],
          ),
      );

      final property = target.getProperty<int>(name);
      const locale = Locale('en', 'US');
      final context = DummyBuildContext();
      const value = 123;
      // NOTE: We cannot inject Locale, so we just validate default (en-US) or not.
      final result = property.getValidator(context)(value);
      await completer1.future;
      await completer2.future;
      expect(result, isNull);
      expect(syncValue1, equals(value));
      expect(syncValue2, equals(value));
      expect(asyncValue1, equals(value));
      expect(asyncValue2, equals(value));
      expect(asyncLocale1, equals(locale));
      expect(asyncLocale2, equals(locale));
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

    group('formStateOf', () {
      test('returns state when maybeFormStateOf returns non-null state.', () {
        final expectedState = FixedFormStateAdapter();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => expectedState,
        );

        expect(target.formStateOf(DummyBuildContext()), same(expectedState));
      });

      test('throws StateError when maybeFormStateOf returns null state.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
          maybeFormStateOfCalled: (_) => null,
        );

        expect(() => target.formStateOf(DummyBuildContext()), throwsStateError);
      });
    });
  });
}
