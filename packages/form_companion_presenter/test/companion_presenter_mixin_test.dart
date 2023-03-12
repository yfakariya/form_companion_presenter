// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/form_companion_mixin.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';
import 'package:form_companion_presenter/src/string_converter.dart';

import 'test_helpers.dart';

class TestPresenterFeatures extends CompanionPresenterFeatures {
  final TestPresenter _presenter;

  TestPresenterFeatures(this._presenter);

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      _presenter._maybeFormStateOfCalled(context);

  @override
  void handleCanceledAsyncValidationError(AsyncError error) {
    final handler = _presenter._onHandleCanceledAsyncValidationError;
    if (handler != null) {
      handler(error);
    } else {
      super.handleCanceledAsyncValidationError(error);
    }
  }

  @override
  void restoreField(
    BuildContext context,
    String name,
    Object? value, {
    required bool hasError,
  }) =>
      throw UnimplementedError();
}

class TestPresenter extends TestCompanionPresenter {
  late final CompanionPresenterFeatures _presenterFeatures;
  @override
  CompanionPresenterFeatures get presenterFeatures => _presenterFeatures;

  final void Function() _doSubmitCalled;
  final void Function(OnPropertiesChangedEvent) _onPropertiesChangedCalled;
  final FormStateAdapter? Function(BuildContext) _maybeFormStateOfCalled;
  final void Function(AsyncError)? _onHandleCanceledAsyncValidationError;
  final bool Function(BuildContext) _canSubmitCalled;

  TestPresenter({
    required PropertyDescriptorsBuilder properties,
    void Function()? doSubmitCalled,
    FormStateAdapter? Function(BuildContext)? maybeFormStateOfCalled,
    void Function(AsyncError)? onHandleCanceledAsyncValidationError,
    bool Function(BuildContext)? canSubmitCalled,
    void Function(OnPropertiesChangedEvent)? onPropertiesChangedCalled,
  })  : _doSubmitCalled = (doSubmitCalled ?? () {}),
        _maybeFormStateOfCalled = (maybeFormStateOfCalled ?? (_) => null),
        _onHandleCanceledAsyncValidationError =
            onHandleCanceledAsyncValidationError,
        _canSubmitCalled = (canSubmitCalled ?? (_) => true),
        _onPropertiesChangedCalled = (onPropertiesChangedCalled ?? (_) {}) {
    _presenterFeatures = TestPresenterFeatures(this);
    initializeCompanionMixin(properties);
  }

  @override
  void onPropertiesChanged(OnPropertiesChangedEvent event) {
    _onPropertiesChangedCalled(event);
    // call super to test harmless
    super.onPropertiesChanged(event);
  }

  @override
  FutureOr<void> doSubmit() async {
    _doSubmitCalled();
  }

  @override
  bool canSubmit(BuildContext context) => _canSubmitCalled(context);
}

void main() {
  // For debugging
  // loggerSink = (
  //   name,
  //   level,
  //   message,
  //   zone,
  //   error,
  //   stackTrace,
  // ) {
  //   String messageString;
  //   if (message is String Function()) {
  //     messageString = message();
  //   } else if (message is String) {
  //     messageString = message;
  //   } else {
  //     messageString = message?.toString() ?? '';
  //   }

  //   String errorString;
  //   if (error != null) {
  //     if (stackTrace != null) {
  //       errorString = ' $error\n$stackTrace';
  //     } else {
  //       errorString = ' $error';
  //     }
  //   } else {
  //     errorString = '';
  //   }

  //   printOnFailure('[${level.name}] $name: $messageString$errorString');
  // };

  // Note: maybeFormStateOf() and saveFields() should be tested as overridden.
  group('property', () {
    group('propertiesState', () {
      test('is initialized with initializeCompanionMixin argument.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int')
            ..add<String, String>(name: 'string'),
        );
        expect(target.propertiesState.getAllDescriptors().length, equals(2));
        expect(
          target.propertiesState.getAllDescriptors().map((e) => e.name),
          contains('int'),
        );
        expect(
          target.propertiesState.getDescriptor('int'),
          isA<PropertyDescriptor<int, String>>(),
        );

        expect(
          target.propertiesState.getAllDescriptors().map((e) => e.name),
          contains('string'),
        );
        expect(
          target.propertiesState.getDescriptor('string'),
          isA<PropertyDescriptor<String, String>>(),
        );
      });

      test('can be empty even if it looks useless.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder(),
        );
        expect(target.propertiesState.getAllDescriptors().length, equals(0));
      });
    });

    group('getDescriptor', () {
      test('can get existing', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int')
            ..add<String, String>(name: 'string'),
        );
        expect(
          target.propertiesState.getDescriptor<int, String>('int'),
          isNotNull,
        );
        expect(
          target.propertiesState.getDescriptor<String, String>('string'),
          isNotNull,
        );
      });

      test('throws ArgumentError for unknown.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int'),
        );

        expect(
          () => target.propertiesState.getDescriptor<String, String>('string'),
          throwsArgumentError,
        );
      });

      test('throws StateError for incompatible type.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int'),
        );

        expect(
          () => target.propertiesState.getDescriptor<String, String>('int'),
          throwsStateError,
        );
      });
    });

    group('savePropertyValue', () {
      test('non-null for never-registered property but throws ArgumentError.',
          () {
        final presenter = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int'),
        );

        final target = presenter.propertiesState
            .savePropertyValue('long', DummyBuildContext());
        expect(target, isNotNull);
        expect(() => target(0), throwsArgumentError);
      });

      test(
          'non-null for registered property and passes through to PropertyDescriptor.saveValue.',
          () {
        final presenter = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int', valueConverter: intStringConverter),
        );

        final target = presenter.propertiesState
            .savePropertyValue('int', DummyBuildContext());
        expect(target, isNotNull);
        final value = DateTime.now().microsecondsSinceEpoch;
        target(value.toString());

        // Check pass through
        expect(presenter.propertiesState.getValue('int'), equals(value));
      });
    });

    group('getValue', () {
      test('null when never saved and no initial value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int', valueConverter: intStringConverter),
        );

        expect(target.propertiesState.getValue('int'), isNull);
      });

      test('initial value when never saved and initial value was specified.',
          () {
        final initialValue = DateTime.now().microsecondsSinceEpoch;
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(
              name: 'int',
              valueConverter: intStringConverter,
              initialValue: initialValue,
            ),
        );

        expect(target.propertiesState.getValue('int'), initialValue);
      });

      test('can get saved value.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int', valueConverter: intStringConverter),
        );

        final value = DateTime.now().microsecondsSinceEpoch;
        target.propertiesState
            .savePropertyValue('int', DummyBuildContext())(value.toString());
        expect(target.propertiesState.getValue('int'), value);
      });
    });

    group('hasPendingAsyncValidations', () {
      test('ArgumentError for never-registered property.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(name: 'int'),
        );

        expect(
          () => target.propertiesState.hasPendingAsyncValidations('long'),
          throwsArgumentError,
        );
      });

      test('false for any async validations have never run.', () {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(
              name: 'int',
              asyncValidatorFactories: [
                (_) => (value, options) async {
                      await completer.future;
                      return null;
                    }
              ],
            ),
        );

        expect(
          target.propertiesState.hasPendingAsyncValidations('int'),
          isFalse,
        );
      });

      test('true for any async validations are running.', () {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, int>(
              name: 'int',
              asyncValidatorFactories: [
                (_) => (value, options) async {
                      await completer.future;
                      return null;
                    }
              ],
            ),
        );

        target.propertiesState
            .getDescriptor<int, int>('int')
            .getValidator(DummyBuildContext())(123);
        expect(
          target.propertiesState.hasPendingAsyncValidations('int'),
          isTrue,
        );
        completer.complete();
      });

      test('false for all async validations are finished.', () async {
        final completer = Completer<void>();
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, int>(
              name: 'int',
              asyncValidatorFactories: [
                (_) => (value, options) async {
                      completer.complete();
                      return null;
                    }
              ],
            ),
        );

        target.propertiesState
            .getDescriptor<int, int>('int')
            .getValidator(DummyBuildContext())(123);
        await completer.future;
        // pump
        await Future<void>.delayed(Duration.zero);
        expect(
          target.propertiesState.hasPendingAsyncValidations('int'),
          isFalse,
        );
      });
    });

    group('PropertyDescriptor', () {
      test('can save value, and the callback called.', () {
        FormProperties? callbacked;
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(
              name: 'int',
              valueConverter: intStringConverter,
            ),
          onPropertiesChangedCalled: (event) {
            callbacked = event.newProperties;
          },
        );

        final property =
            target.propertiesState.getDescriptor<int, String>('int');
        // ignore: cascade_invocations
        property.setFieldValue('123', defaultLocale);
        expect(target.propertiesState.getValue('int'), 123);
        expect(callbacked, isNotNull);
        expect(callbacked!.getValue('int'), 123);
        expect(callbacked, same(target.propertiesState));
      });

      test('conversion failure.', () {
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(
              name: 'int',
              valueConverter: intStringConverter,
            ),
        );

        final property =
            target.propertiesState.getDescriptor<int, String>('int');
        // ignore: cascade_invocations
        expect(
          () => property.setFieldValue('A', defaultLocale),
          throwsArgumentError,
        );
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
          onValidate: () => target!.propertiesState.getAllDescriptors().every(
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
          ..add(
            name: 'valid',
            validatorFactories: [
              (_) => (v) => null,
            ],
          ),
        doSubmitCalled: doSubmitCalled.complete,
        maybeFormStateOfCalled: (_) => FixedFormStateAdapter(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onValidate: () => target!.propertiesState.getAllDescriptors().every(
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

    group('resetPropertiesState', () {
      test('call changes propertiesState and kick onPropertiesChanged', () {
        FormProperties? callbacked;
        const initialValue = 123;
        const newValue = 987;
        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()
            ..add<int, String>(
              name: 'int',
              valueConverter: intStringConverter,
              initialValue: initialValue,
            ),
          onPropertiesChangedCalled: (event) {
            callbacked = event.newProperties;
          },
        );

        final newState =
            target.propertiesState.copyWithProperty('int', newValue);
        target.resetPropertiesState(newState);

        expect(target.propertiesState.getValue('int'), newValue);
        expect(target.propertiesState, same(newState));
        expect(callbacked, isNotNull);
        expect(callbacked!.getValue('int'), newValue);
        expect(callbacked, same(newState));
      });

      test(
        'initialValue does not call onPropertiesChanged, but initializeCompanionMixin does',
        () {
          final callbacked = <FormProperties>[];
          const initialValue1 = 123;
          const initialValue2 = 456;
          final target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..add<int, String>(
                name: 'int1',
                valueConverter: intStringConverter,
                initialValue: initialValue1,
              )
              ..add<int, String>(
                name: 'int2',
                valueConverter: intStringConverter,
                initialValue: initialValue2,
              ),
            onPropertiesChangedCalled: (event) {
              callbacked.add(event.newProperties);
            },
          );

          expect(target.propertiesState.getValue('int1'), initialValue1);
          expect(target.propertiesState.getValue('int2'), initialValue2);
          expect(callbacked.length, 1);
          expect(callbacked[0].getValue('int1'), initialValue1);
          expect(callbacked[0].getValue('int2'), initialValue2);
        },
      );
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
          ..add<int, int>(
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
                      final completion = asyncOperationCompletions[value ?? 0];
                      if (!completion.isCompleted) {
                        completion.complete();
                      }
                    }
                  }
            ],
          ),
      );

      final validator = target.propertiesState
          .getDescriptor<int, int>('prop')
          .getValidator(context);
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

    test('normal validation failure prevents async validation', () async {
      final context = DummyBuildContext();
      FormFieldValidator<int?>? validator;
      const dummyMessage = 'DUMMY_ERROR';

      final values = <int?>[];
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: 'prop',
            validatorFactories: [
              (context) => (_) => dummyMessage,
            ],
            asyncValidatorFactories: [
              (context) => (value, options) {
                    values.add(value);
                    throw Exception('DUMMY');
                  },
            ],
          ),
        maybeFormStateOfCalled: (x) => FixedFormStateAdapter(
          onValidate: () {
            // Simulate validator call on callback.
            validator!(0);
            return true;
          },
        ),
      );

      final property = target.propertiesState.getDescriptor<int, int>('prop');
      validator = property.getValidator(context);
      expect(validator(0), dummyMessage);
      expect(values, isEmpty);
      expect(property.hasPendingAsyncValidations, isFalse);
      // Try call following validation again
      expect(validator(0), dummyMessage);
    });

    test('validation failure on head is ignored', () async {
      final context = DummyBuildContext();
      final asyncOperationCompletion = Completer<void>();
      FormFieldValidator<int?>? validator;

      final values = <int?>[];
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) {
                    values.add(value);

                    try {
                      throw Exception('DUMMY');
                    } finally {
                      if (!asyncOperationCompletion.isCompleted) {
                        asyncOperationCompletion.complete();
                      }
                    }
                  },
            ],
          ),
        maybeFormStateOfCalled: (x) => FixedFormStateAdapter(
          onValidate: () {
            // Simulate validator call on callback.
            validator!(0);
            return true;
          },
        ),
      );

      validator = target.propertiesState
          .getDescriptor<int, int>('prop')
          .getValidator(context);
      expect(validator(0), isNull);
      await asyncOperationCompletion.future;
      // Try call following validation again
      expect(validator(0), isNull);
    });

    test('validation failure on second is ignored', () async {
      final context = DummyBuildContext();
      final asyncOperationCompletion = Completer<void>();
      FormFieldValidator<int?>? validator;

      final values = <int?>[];
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) {
                    values.add(value);
                    return null;
                  },
              (context) => (value, options) {
                    try {
                      throw Exception('DUMMY');
                    } finally {
                      if (!asyncOperationCompletion.isCompleted) {
                        asyncOperationCompletion.complete();
                      }
                    }
                  }
            ],
          ),
        maybeFormStateOfCalled: (x) => FixedFormStateAdapter(
          onValidate: () {
            // Simulate validator call on callback.
            validator!(0);
            return true;
          },
        ),
      );

      validator = target.propertiesState
          .getDescriptor<int, int>('prop')
          .getValidator(context);
      expect(validator(0), isNull);
      await asyncOperationCompletion.future;
      // Try call following validation again
      expect(validator(0), isNull);
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
            ..add<int, int>(
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

        final validator = target.propertiesState
            .getDescriptor<int, int>('prop')
            .getValidator(context);
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
      test('calls validate() when no asyncs', () async {
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
        await target.validateAll(state);
        expect(isStateValidateCalled, isTrue);
      });

      test('just call state.validate() once when no asyncs', () async {
        Future<void> testCore(
          TestPresenter presenter,
          // ignore: avoid_positional_boolean_parameters
          bool dummyValidateResult,
        ) async {
          var stateValidateCalled = false;
          final state = FixedFormStateAdapter(
            onValidate: () {
              stateValidateCalled = true;
              return dummyValidateResult;
            },
          );

          expect(
            await presenter.validateAll(state),
            equals(dummyValidateResult),
          );
          expect(stateValidateCalled, isTrue);
        }

        final target = TestPresenter(
          properties: PropertyDescriptorsBuilder()..add<int, int>(name: 'int'),
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
              ..add<int, int>(
                name: 'int',
                asyncValidatorFactories: [
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
                ],
              ),
            maybeFormStateOfCalled: (_) => state,
          );
          final validationResults = <bool>[];
          state = FixedFormStateAdapter(
            onValidate: () {
              // dummy logic
              final context = DummyBuildContext();
              final validator = target.propertiesState
                  .getDescriptor<int, int>('int')
                  .getValidator(context);
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

    group('default validator with converter', () {
      test(
        'successful case -- no effect',
        () {
          final target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..stringConvertible(
                name: 'prop',
                stringConverter: intStringConverter,
              ),
          );
          expect(
            target.propertiesState.getFieldValidator<String>(
              'prop',
              DummyBuildContext(),
            )('123'),
            isNull,
          );
        },
      );

      test(
        'failure case -- FailureResult.message is returned',
        () {
          final target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..stringConvertible(
                name: 'prop',
                stringConverter: intStringConverter,
              ),
          );
          expect(
            target.propertiesState.getFieldValidator<String>(
              'prop',
              DummyBuildContext(),
            )('ABC'),
            'Value is not a valid int.',
          );
        },
      );

      test(
        'null case -- no effect',
        () {
          final target = TestPresenter(
            properties: PropertyDescriptorsBuilder()
              ..stringConvertible(
                name: 'prop',
                stringConverter: intStringConverter,
              ),
          );
          expect(
            target.propertiesState.getFieldValidator<String>(
              'prop',
              DummyBuildContext(),
            )(null),
            isNull,
          );
        },
      );
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
          ..add<int, int>(
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

      final property = target.propertiesState.getDescriptor<int, int>(name);
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

    test('onChanged chains to passed onChanged', () {
      const name = 'property';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: name,
          ),
      );

      final property = target.propertiesState.getDescriptor<int, int>(name);
      int? passedValue;
      final chainedOnChanged = property.onChanged(DummyBuildContext(), (value) {
        passedValue = value;
      });
      final value = DateTime.now().microsecondsSinceEpoch;

      chainedOnChanged(value);
      expect(passedValue, value);
    });

    test('onChanged chains to passed onChanged even if null', () {
      const name = 'property';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: name,
          ),
      );

      final property = target.propertiesState.getDescriptor<int, int>(name);
      int? passedValue = 0;
      final chainedOnChanged = property.onChanged(DummyBuildContext(), (value) {
        passedValue = value;
      });

      chainedOnChanged(null);
      expect(passedValue, isNull);
    });

    test('onChangedNonNull chains to passed onChanged', () {
      const name = 'property';
      final target = TestPresenter(
        properties: PropertyDescriptorsBuilder()
          ..add<int, int>(
            name: name,
          ),
      );

      final property = target.propertiesState.getDescriptor<int, int>(name);
      int? passedValue;
      final chainedOnChanged =
          property.onChangedNonNull(DummyBuildContext(), (value) {
        passedValue = value;
      });
      final value = DateTime.now().microsecondsSinceEpoch;

      chainedOnChanged(value);
      expect(passedValue, value);
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
