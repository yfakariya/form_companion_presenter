// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';
import 'package:form_companion_presenter/src/presenter_extension.dart';

Widget _buildChilren(
  BuildContext context, {
  Key Function(BuildContext)? fieldKeyFactory,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String> Function(BuildContext)? validatorFactory,
}) =>
    TextFormField(
      key: fieldKeyFactory?.call(context),
      onSaved: onSaved,
      validator: validatorFactory?.call(context),
    );

class InlineForm extends StatelessWidget {
  final void Function(BuildContext) onBuilding;
  const InlineForm({
    required this.onBuilding,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onBuilding(context);
    return Form(
      child: _buildChilren(context),
    );
  }
}

class _InlineChildren extends StatelessWidget {
  final Key Function(BuildContext)? fieldKeyFactory;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String> Function(BuildContext)? validatorFactory;
  final void Function(BuildContext) onBuilding;
  const _InlineChildren({
    required this.onBuilding,
    Key? key,
    this.fieldKeyFactory,
    this.onSaved,
    this.validatorFactory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onBuilding(context);
    return _buildChilren(
      context,
      fieldKeyFactory: fieldKeyFactory,
      onSaved: onSaved,
      validatorFactory: validatorFactory,
    );
  }
}

class _DynamicChildren extends StatelessWidget {
  final void Function(BuildContext) _onBuilding;
  final List<Widget> Function(BuildContext) _widgetsFactory;
  const _DynamicChildren(
    this._widgetsFactory,
    this._onBuilding, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _onBuilding(context);
    return Column(
      children: _widgetsFactory(context),
    );
  }
}

class HierarchicalForm extends StatelessWidget {
  final AutovalidateMode _autovalidateMode;
  final Key Function(BuildContext)? _fieldKeyFactory;
  final FormFieldSetter<String>? _onSaved;
  final FormFieldValidator<String> Function(BuildContext)? _validatorFactory;
  final void Function(BuildContext) _onBuilding;
  final List<Widget> Function(BuildContext)? _childrenFactory;

  const HierarchicalForm._({
    Key? key,
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    Key Function(BuildContext)? fieldKeyFactory,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String> Function(BuildContext)? validatorFactory,
    List<Widget> Function(BuildContext)? childrenFactory,
  })  : _onBuilding = onBuilding,
        _autovalidateMode = autovalidateMode,
        _fieldKeyFactory = fieldKeyFactory,
        _onSaved = onSaved,
        _validatorFactory = validatorFactory,
        _childrenFactory = childrenFactory,
        super(key: key);

  // ignore: sort_unnamed_constructors_first
  factory HierarchicalForm({
    Key? key,
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    Key Function(BuildContext)? fieldKeyFactory,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String> Function(BuildContext)? validatorFactory,
  }) =>
      HierarchicalForm._(
        key: key,
        onBuilding: onBuilding,
        autovalidateMode: autovalidateMode,
        fieldKeyFactory: fieldKeyFactory,
        onSaved: onSaved,
        validatorFactory: validatorFactory,
      );

  factory HierarchicalForm.dynamic({
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    required List<Widget> Function(BuildContext) childrenFactory,
  }) =>
      HierarchicalForm._(
        onBuilding: onBuilding,
        autovalidateMode: autovalidateMode,
        childrenFactory: childrenFactory,
      );

  @override
  Widget build(BuildContext context) => Form(
        autovalidateMode: _autovalidateMode,
        child: _childrenFactory != null
            ? _DynamicChildren(_childrenFactory!, _onBuilding)
            : _InlineChildren(
                fieldKeyFactory: _fieldKeyFactory,
                onBuilding: _onBuilding,
                onSaved: _onSaved,
                validatorFactory: _validatorFactory,
              ),
      );
}

Widget _app(
  Widget child, {
  Locale? locale,
}) =>
    MaterialApp(
      home: Scaffold(body: child),
      locale: locale,
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
    );

class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  final FutureOr<void> Function() _doSubmitCalled;

  Presenter({
    required PropertyDescriptorsBuilder properties,
    FutureOr<void> Function()? doSubmitCalled,
  }) : _doSubmitCalled = (doSubmitCalled ?? () {}) {
    initializeCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit() => _doSubmitCalled();
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

  group('canSubmit()', () {
    testWidgets('returns true when maybeFormStateOf() returns null.',
        (tester) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;
      await tester.pumpWidget(
        _app(
          InlineForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
          ),
        ),
      );

      expect(maybeFormStateOfResult, isNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isTrue);
    });

    testWidgets('returns false when any validation is failed.', (tester) async {
      var validatorCalled = false;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            validatorFactories: [
              (context) => (value) {
                    validatorCalled = true;
                    return 'Dummy error';
                  },
            ],
          ),
      );
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'A',
      );

      await tester.pump();

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isFalse);
      expect(validatorCalled, isTrue);
    });

    testWidgets('returns false when any async validation is not completed.',
        (tester) async {
      final completer = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    await completer.future;
                    return null;
                  },
            ],
          ),
      );
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;

      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await tester.pump();

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isFalse);

      completer.complete();
    });

    testWidgets('returns false when any async validation is completed.',
        (tester) async {
      final completer = Completer<void>();
      final validatorCompleted = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    await completer.future;
                    validatorCompleted.complete();
                    return null;
                  },
            ],
          ),
      );
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;

      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await tester.pump();

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isFalse);

      completer.complete();
      await validatorCompleted.future;
      // widget pump again
      await tester.pump();

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isTrue);
    });

    testWidgets('returns true when there are no properties.', (tester) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
          ),
        ),
      );

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isTrue);
    });

    testWidgets('returns true when all validation is completed successfully.',
        (tester) async {
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            validatorFactories: [
              (context) => (value) => null,
              (context) => (value) => null,
            ],
          ),
      );
      FormStateAdapter? maybeFormStateOfResult;
      bool? canSubmitResult;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              maybeFormStateOfResult = presenter.maybeFormStateOf(context);
              canSubmitResult = presenter.canSubmit(context);
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await tester.pump();

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isTrue);
    });
  });

  group('mayBeFormStateof', () {
    testWidgets('returns null there are no ancestor Form', (tester) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      await tester.pumpWidget(
        _app(
          InlineForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
          ),
        ),
      );
      expect(adapter, isNull);
    });

    testWidgets('returns not null there are any ancestor Form', (tester) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            autovalidateMode: AutovalidateMode.disabled,
          ),
        ),
      );
      expect(adapter, isNotNull);
    });

    FutureOr<bool> testValidate(
      WidgetTester tester,
      String? validatorResult,
    ) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      String? validatorArgument;
      var validatorCalled = false;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            autovalidateMode: AutovalidateMode.disabled,
            validatorFactory: (_) => (v) {
              validatorArgument = v;
              validatorCalled = true;
              return validatorResult;
            },
          ),
        ),
      );

      final result = adapter!.validate();
      expect(validatorCalled, isTrue);
      expect(validatorArgument, isEmpty);
      return result;
    }

    testWidgets(
        "adapter.validate() will call each FormField's validators and true for success.",
        (tester) async {
      expect(await testValidate(tester, null), isTrue);
    });

    testWidgets(
        "adapter.validate() will call each FormField's validators and false for failure.",
        (tester) async {
      expect(await testValidate(tester, 'Dummy error'), isFalse);
    });

    testWidgets("adapter.save() will call each FormField's onSave.",
        (tester) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      String? savingArgument;
      var onSavedCalled = false;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            autovalidateMode: AutovalidateMode.disabled,
            onSaved: (v) {
              savingArgument = v;
              onSavedCalled = true;
            },
          ),
        ),
      );

      adapter!.save();
      expect(onSavedCalled, isTrue);
      expect(savingArgument, isEmpty);
    });

    FutureOr<void> testAutoValidateMode(
      WidgetTester tester,
      AutovalidateMode autovalidateMode,
    ) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            autovalidateMode: autovalidateMode,
          ),
        ),
      );

      expect(adapter!.autovalidateMode, autovalidateMode);
    }

    testWidgets("adapter.autovalidateMode reflects Form's autoValidateMode.",
        (tester) async {
      await testAutoValidateMode(tester, AutovalidateMode.always);
      await testAutoValidateMode(tester, AutovalidateMode.disabled);
      await testAutoValidateMode(tester, AutovalidateMode.onUserInteraction);
    });

    FutureOr<void> testLocale(WidgetTester tester, Locale locale) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            autovalidateMode: AutovalidateMode.disabled,
          ),
          locale: locale,
        ),
      );

      expect(adapter!.locale, locale);
    }

    testWidgets('adapter.locale reflects ancesstor Locale.', (tester) async {
      await testLocale(tester, const Locale('en', 'US'));
      await testLocale(tester, const Locale('ja', 'JP'));
    });
  });

  group('async validation completion behavior', () {
    Future<void> testRebuildBehavior(
      WidgetTester tester,
      AutovalidateMode formValidateMode,
    ) async {
      var targetValidatorCalled = 0;
      var anotherValidatorCalled = 0;
      final completer = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'target',
            validatorFactories: [
              (_) => (value) {
                    targetValidatorCalled++;
                    return null;
                  },
            ],
            asyncValidatorFactories: [
              (_) => (value, options) async {
                    await completer.future;
                    return null;
                  },
            ],
          )
          ..add<String, String>(
            name: 'another',
            validatorFactories: [
              (_) => (value) {
                    anotherValidatorCalled++;
                    return null;
                  },
            ],
          ),
      );

      var entireFormBuilt = 0;
      late BuildContext lastContext;
      await tester.pumpWidget(
        _app(
          HierarchicalForm.dynamic(
            onBuilding: (context) {
              lastContext = context;
              entireFormBuilt++;
            },
            autovalidateMode: formValidateMode,
            childrenFactory: (context) => [
              TextFormField(
                key: presenter.getKey('target', context),
                initialValue: 'target',
                validator: presenter.getPropertyValidator('target', context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              TextFormField(
                key: presenter.getKey('another', context),
                initialValue: 'another',
                validator: presenter.getPropertyValidator('another', context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
      );

      var formBuilt = 1;
      var fieldShouldBeReevaluated = 0;
      var formShouldBeReevaluated = fieldShouldBeReevaluated;

      expect(entireFormBuilt, equals(formBuilt));
      expect(targetValidatorCalled, equals(fieldShouldBeReevaluated));
      expect(anotherValidatorCalled, equals(formShouldBeReevaluated));

      // kick target validation
      await tester.enterText(
        find.byWidgetPredicate(
          (widget) =>
              widget is TextFormField && widget.initialValue == 'target',
        ),
        'A',
      );
      await tester.pump();

      // Target field should be validated.
      fieldShouldBeReevaluated++;
      if (formValidateMode != AutovalidateMode.disabled) {
        // Caused more because of Form level auto validation.
        fieldShouldBeReevaluated++;

        // Another field should be validated because of Form level auto validation.
        formShouldBeReevaluated++;
      }

      // Input causes form level rebuild.
      formBuilt++;

      // should be re-evaulated by text input
      expect(entireFormBuilt, equals(formBuilt));
      expect(targetValidatorCalled, equals(fieldShouldBeReevaluated));
      expect(anotherValidatorCalled, equals(formShouldBeReevaluated));

      // completes async and pump
      completer.complete();
      // Note: do pump again for run rebuild caused by explicit validate() call
      // even if we do not use complter to stop async validation.
      await tester.pump();

      // Async validation completion explicitly calls validate(), so +1.
      // In addition, validate() causes rebuild, so +1 (consequently, +2)
      fieldShouldBeReevaluated += 2;
      if (formValidateMode != AutovalidateMode.disabled) {
        // Caused more because of Form level auto validation,
        // but validation completion was not called twice because async cache was used.
        fieldShouldBeReevaluated++;
        // Another field should be validated because of Form level auto validation.
        // Async validation completion explicitly calls validate(), so +1.
        // In addition, validate() causes rebuild, so +1 (consequently, +2)
        formShouldBeReevaluated += 2;
        // But, rebuild is only once, which is caused by validate() call
        formBuilt++;
      }

      // should be re-evaulated by async validation completion
      expect(entireFormBuilt, equals(formBuilt));
      expect(targetValidatorCalled, equals(fieldShouldBeReevaluated));
      expect(anotherValidatorCalled, equals(formShouldBeReevaluated));

      // reset causes validation only AutovalidateMode.always
      Form.of(lastContext)!.reset();
      await tester.pump();

      // By resetting form
      formBuilt++;
      if (formValidateMode == AutovalidateMode.always) {
        // A diffrence between always and onUserInteraction is reaction for
        // reset() (or unclear reasons Form is requested rebuilding other than
        // its fields manipulation)

        // Reset caused validation, it caused async validation without blocking
        // because we already had been completed the Completer, so re-evaluation
        // was occurred and ultimately all validators called twice.
        fieldShouldBeReevaluated += 2;
        formShouldBeReevaluated += 2;
      }

      // should be re-evaulated by async validation completion
      expect(entireFormBuilt, equals(formBuilt));
      expect(targetValidatorCalled, equals(fieldShouldBeReevaluated));
      expect(anotherValidatorCalled, equals(formShouldBeReevaluated));
    }

    testWidgets(
      'all fields are re-validated when Form.autiValidateMode is always.',
      (widgetTester) =>
          testRebuildBehavior(widgetTester, AutovalidateMode.always),
    );

    testWidgets(
      'all fields are re-validated when Form.autiValidateMode is onUserInteraction.',
      (widgetTester) =>
          testRebuildBehavior(widgetTester, AutovalidateMode.onUserInteraction),
    );

    testWidgets(
      'only the field is re-validated when Form.autiValidateMode is disable.',
      (widgetTester) =>
          testRebuildBehavior(widgetTester, AutovalidateMode.disabled),
    );
  });

  group('Async validator error handling', () {
    testWidgets('async exception is ignored on auto field validation',
        (widgetTester) async {
      final validationStopper = Completer<void>();
      final validationCompletion = Completer<void>();
      var validatorCalled = 0;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    validatorCalled++;
                    await validationStopper.future;
                    if (!validationCompletion.isCompleted) {
                      validationCompletion.complete();
                    }
                    throw Exception(validatorCalled);
                  }
            ],
          ),
      );
      late BuildContext lastContext;
      await widgetTester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      final key = presenter.getKey('prop', lastContext)
          as GlobalObjectKey<FormFieldState<dynamic>>;

      await widgetTester.enterText(
        find.byType(TextFormField),
        'A',
      );

      await widgetTester.pump();
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isTrue);

      validationStopper.complete();
      await validationCompletion.future;

      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);

      expect(key.currentState?.hasError, isFalse);
      expect(key.currentState?.errorText, isNull);
      expect(validatorCalled, equals(1));
    });

    testWidgets('async exception in auto field validation uses cached result',
        (widgetTester) async {
      final validationStopper = Completer<void>();
      final validationCompletion = Completer<void>();
      var validatorCalled = 0;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    validatorCalled++;
                    await validationStopper.future;
                    validationCompletion.complete();
                    throw Exception(validatorCalled);
                  }
            ],
          ),
      );
      late BuildContext lastContext;
      await widgetTester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      final key = presenter.getKey('prop', lastContext)
          as GlobalObjectKey<FormFieldState<dynamic>>;

      await widgetTester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await widgetTester.pump();
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isTrue);

      validationStopper.complete();
      await validationCompletion.future;

      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);

      expect(key.currentState?.hasError, isFalse);
      expect(key.currentState?.errorText, isNull);

      await widgetTester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await widgetTester.pump();
      // If we use cache, no pending async validation exist.
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);
      expect(validatorCalled, equals(1));
    });

    testWidgets('async exception is translated to error message on submit',
        (widgetTester) async {
      final validationStopper = Completer<void>();
      final validationCompletion = Completer<void>();
      var validatorCalled = 0;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    validatorCalled++;
                    await validationStopper.future;
                    if (!validationCompletion.isCompleted) {
                      validationCompletion.complete();
                    }
                    throw Exception(validatorCalled);
                  }
            ],
          ),
      );
      late BuildContext lastContext;
      await widgetTester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      final key = presenter.getKey('prop', lastContext)
          as GlobalObjectKey<FormFieldState<dynamic>>;

      presenter.submit(lastContext)!();
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isTrue);

      validationStopper.complete();
      await validationCompletion.future;

      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);

      expect(key.currentState?.hasError, isTrue);
      expect(
        key.currentState?.errorText,
        equals(
          presenter.getAsyncValidationFailureMessage(
            AsyncError(Object(), null),
            defaultLocale,
          ),
        ),
      );
      expect(validatorCalled, equals(1));
    });

    testWidgets(
        'async exception is ignored on auto field validation but be translated to error message on submit',
        (widgetTester) async {
      final validationStoppers = [
        Completer<void>(),
        Completer<void>(),
      ];
      final validationCompletions = [
        Completer<void>(),
        Completer<void>(),
      ];
      var validatorCalled = 0;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    final i = validatorCalled;
                    validatorCalled++;
                    if (i < validationStoppers.length) {
                      await validationStoppers[i].future;
                      validationCompletions[i].complete();
                    }
                    throw Exception(validatorCalled);
                  }
            ],
          ),
      );
      late BuildContext lastContext;
      await widgetTester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      final key = presenter.getKey('prop', lastContext)
          as GlobalObjectKey<FormFieldState<dynamic>>;
      final submit = presenter.submit(lastContext);
      expect(submit, isNotNull);

      await widgetTester.enterText(
        find.byType(TextFormField),
        'A',
      );
      await widgetTester.pump();
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isTrue);

      validationStoppers[0].complete();
      await validationCompletions[0].future;

      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);

      expect(key.currentState?.hasError, isFalse);
      expect(key.currentState?.errorText, isNull);

      expect(validatorCalled, equals(1));

      submit!();
      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isTrue);

      validationStoppers[1].complete();
      await validationCompletions[1].future;

      expect(presenter.getProperty('prop').hasPendingAsyncValidations, isFalse);

      // Failure is reported as error.
      expect(key.currentState?.hasError, isTrue);
      expect(
        key.currentState?.errorText,
        equals(
          presenter.getAsyncValidationFailureMessage(
            AsyncError(Object(), null),
            defaultLocale,
          ),
        ),
      );
      expect(validatorCalled, equals(2));
    });

    testWidgets(
      '2 individual field validations are isolated in auto validation.',
      (widgetTester) async {
        final validationStopper = Completer<void>();
        final validationCompletion1 = Completer<void>();
        final validationCompletion2 = Completer<void>();
        var validation1Called = 0;
        var validation2Called = 0;
        final presenter = Presenter(
          properties: PropertyDescriptorsBuilder()
            ..add<String, String>(
              name: 'prop1',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      validation1Called++;
                      await validationStopper.future;
                      validationCompletion1.complete();
                      throw Exception(validation1Called);
                    }
              ],
            )
            ..add<String, String>(
              name: 'prop2',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      validation2Called++;
                      await validationStopper.future;
                      validationCompletion2.complete();
                      throw Exception(validation2Called);
                    }
              ],
            ),
        );
        late BuildContext lastContext;
        await widgetTester.pumpWidget(
          _app(
            HierarchicalForm.dynamic(
              onBuilding: (context) {
                lastContext = context;
              },
              autovalidateMode: AutovalidateMode.disabled,
              childrenFactory: (context) => [
                TextFormField(
                  key: presenter.getKey('prop1', context),
                  validator: presenter.getPropertyValidator('prop1', context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextFormField(
                  key: presenter.getKey('prop2', context),
                  validator: presenter.getPropertyValidator('prop2', context),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],
            ),
          ),
        );

        final key = presenter.getKey('prop1', lastContext)
            as GlobalObjectKey<FormFieldState<dynamic>>;

        await widgetTester.enterText(
          find.byType(TextFormField).first,
          'A',
        );
        await widgetTester.pump();
        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isTrue,
        );

        validationStopper.complete();
        await validationCompletion1.future;
        // pump for async completion
        await widgetTester.pump();
        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isFalse,
        );

        expect(key.currentState?.hasError, isFalse);
        expect(key.currentState?.errorText, isNull);

        // check counter
        expect(validation1Called, equals(1));
        expect(validation2Called, equals(0));
      },
    );

    testWidgets(
      '2 individual field validations are isolated in submit.',
      (widgetTester) async {
        final validationStoppers1 = [
          Completer<void>(),
          Completer<void>(),
        ];
        final validationStoppers2 = [
          Completer<void>(),
          Completer<void>(),
        ];
        final validationCompletions1 = [
          Completer<void>(),
          Completer<void>(),
        ];
        final validationCompletions2 = [
          Completer<void>(),
          Completer<void>(),
        ];
        var validation1Called = 0;
        var validation2Called = 0;
        final presenter = Presenter(
          properties: PropertyDescriptorsBuilder()
            ..add<String, String>(
              name: 'prop1',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      final i = validation1Called;
                      validation1Called++;
                      if (i < validationStoppers1.length) {
                        await validationStoppers1[i].future;
                        validationCompletions1[i].complete();
                      }
                      throw Exception(validation1Called);
                    }
              ],
            )
            ..add<String, String>(
              name: 'prop2',
              asyncValidatorFactories: [
                (context) => (value, options) async {
                      final i = validation2Called;
                      validation2Called++;
                      if (i < validationStoppers2.length) {
                        await validationStoppers2[i].future;
                        validationCompletions2[i].complete();
                      }
                      throw Exception(validation2Called);
                    }
              ],
            ),
        );
        late BuildContext lastContext;
        await widgetTester.pumpWidget(
          _app(
            HierarchicalForm.dynamic(
              onBuilding: (context) {
                lastContext = context;
              },
              autovalidateMode: AutovalidateMode.disabled,
              childrenFactory: (context) => [
                TextFormField(
                  key: presenter.getKey('prop1', context),
                  validator: presenter.getPropertyValidator('prop1', context),
                  initialValue: 'prop1',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                TextFormField(
                  key: presenter.getKey('prop2', context),
                  validator: presenter.getPropertyValidator('prop2', context),
                  initialValue: 'prop2',
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
              ],
            ),
          ),
        );

        final key1 = presenter.getKey('prop1', lastContext)
            as GlobalObjectKey<FormFieldState<dynamic>>;
        final key2 = presenter.getKey('prop2', lastContext)
            as GlobalObjectKey<FormFieldState<dynamic>>;
        final submit = presenter.submit(lastContext);
        expect(submit, isNotNull);

        await widgetTester.enterText(
          find.byWidgetPredicate(
            (w) => w is TextFormField && w.initialValue == 'prop1',
          ),
          'A',
        );
        await widgetTester.pump();
        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isTrue,
        );

        validationStoppers1[0].complete();
        await validationCompletions1[0].future;

        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isFalse,
        );

        expect(key1.currentState?.hasError, isFalse);
        expect(key1.currentState?.errorText, isNull);

        await widgetTester.enterText(
          find.byWidgetPredicate(
            (w) => w is TextFormField && w.initialValue == 'prop2',
          ),
          'B',
        );
        await widgetTester.pump();
        expect(
          presenter.getProperty('prop2').hasPendingAsyncValidations,
          isTrue,
        );

        validationStoppers2[0].complete();
        await validationCompletions2[0].future;

        expect(
          presenter.getProperty('prop2').hasPendingAsyncValidations,
          isFalse,
        );

        expect(key2.currentState?.hasError, isFalse);
        expect(key2.currentState?.errorText, isNull);

        submit!();
        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isTrue,
        );
        validationStoppers1[1].complete();
        await validationCompletions1[1].future;

        expect(
          presenter.getProperty('prop2').hasPendingAsyncValidations,
          isTrue,
        );
        validationStoppers2[1].complete();
        await validationCompletions2[1].future;

        expect(
          presenter.getProperty('prop1').hasPendingAsyncValidations,
          isFalse,
        );
        expect(
          presenter.getProperty('prop2').hasPendingAsyncValidations,
          isFalse,
        );

        // Failure is reported as error.
        expect(key1.currentState?.hasError, isTrue);
        expect(key1.currentState?.errorText, isNotEmpty);
        expect(key2.currentState?.hasError, isTrue);
        expect(key2.currentState?.errorText, isNotEmpty);
        expect(validation1Called, equals(2));
        expect(validation1Called, equals(2));
      },
    );

    Future<void> testMultipleAsyncValidators(
      WidgetTester widgetTester,
      FutureOr<String?> Function() first,
      FutureOr<String?> Function() second,
      Completer<void>? firstStopper,
      Completer<void>? secondStopper,
      FutureOr<void> onFirstExecuted,
      FutureOr<void> onSecondExecuted,
      String? expectedFinalResult, {
      required bool shouldSecondCalled,
      required bool isSubmitTest,
    }) async {
      var firstCalled = 0;
      var secondCalled = 0;
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    firstCalled++;
                    if (firstStopper != null) {
                      await firstStopper.future;
                    }
                    return first();
                  },
              (context) => (value, options) async {
                    secondCalled++;
                    if (secondStopper != null) {
                      await secondStopper.future;
                    }
                    return second();
                  },
            ],
          ),
      );

      late BuildContext lastContext;
      await widgetTester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            fieldKeyFactory: (context) => presenter.getKey('prop', context),
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      final fieldState = presenter.getKey('prop', lastContext)
          as GlobalObjectKey<FormFieldState<dynamic>>;

      if (isSubmitTest) {
        presenter.submit(lastContext)!();
      } else {
        await widgetTester.enterText(
          find.byType(TextFormField),
          'A',
        );
        await widgetTester.pump();
      }

      firstStopper?.complete();
      secondStopper?.complete();

      await onFirstExecuted;
      if (shouldSecondCalled) {
        await onSecondExecuted;
      }

      expect(firstCalled, equals(1));
      expect(secondCalled, equals(shouldSecondCalled ? 1 : 0));
      expect(fieldState.currentState?.errorText, equals(expectedFinalResult));
    }

    group(
      '2 async validators in a single proprety (auto field validation)',
      () {
        testWidgets(
          'sync success -> sync success',
          (widgetTester) => testMultipleAsyncValidators(
            widgetTester,
            () => null,
            () => null,
            null,
            null,
            null,
            null,
            null,
            shouldSecondCalled: true,
            isSubmitTest: false,
          ),
        );

        testWidgets(
          'sync success -> async success',
          (widgetTester) async {
            final onSecondExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () => null,
              () {
                if (!onSecondExecuted.isCompleted) {
                  onSecondExecuted.complete();
                }

                return null;
              },
              null,
              Completer<void>(),
              null,
              onSecondExecuted.future,
              null,
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'sync success -> sync error',
          (widgetTester) => testMultipleAsyncValidators(
            widgetTester,
            () => null,
            () => 'DUMMY',
            null,
            null,
            null,
            null,
            'DUMMY',
            shouldSecondCalled: true,
            isSubmitTest: false,
          ),
        );

        testWidgets(
          'sync success -> async error',
          (widgetTester) async {
            final onSecondExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () => null,
              () {
                if (!onSecondExecuted.isCompleted) {
                  onSecondExecuted.complete();
                }

                return 'DUMMY';
              },
              null,
              Completer<void>(),
              null,
              onSecondExecuted.future,
              'DUMMY',
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'async success -> sync success',
          (widgetTester) async {
            final onFirstExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () {
                if (!onFirstExecuted.isCompleted) {
                  onFirstExecuted.complete();
                }

                return null;
              },
              () => null,
              Completer<void>(),
              null,
              onFirstExecuted.future,
              null,
              null,
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'async success -> async success',
          (widgetTester) async {
            final onFirstExecuted = Completer<void>();
            final onSecondExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () {
                if (!onFirstExecuted.isCompleted) {
                  onFirstExecuted.complete();
                }

                return null;
              },
              () {
                if (!onSecondExecuted.isCompleted) {
                  onSecondExecuted.complete();
                }

                return null;
              },
              Completer<void>(),
              Completer<void>(),
              onFirstExecuted.future,
              onSecondExecuted.future,
              null,
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'async success -> sync error',
          (widgetTester) async {
            final onFirstExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () {
                if (!onFirstExecuted.isCompleted) {
                  onFirstExecuted.complete();
                }

                return null;
              },
              () => 'DUMMY',
              Completer<void>(),
              null,
              onFirstExecuted.future,
              null,
              'DUMMY',
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'async success -> async error',
          (widgetTester) async {
            final onFirstExecuted = Completer<void>();
            final onSecondExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () {
                if (!onFirstExecuted.isCompleted) {
                  onFirstExecuted.complete();
                }

                return null;
              },
              () {
                if (!onSecondExecuted.isCompleted) {
                  onSecondExecuted.complete();
                }

                return 'DUMMY';
              },
              Completer<void>(),
              Completer<void>(),
              onFirstExecuted.future,
              onSecondExecuted.future,
              'DUMMY',
              shouldSecondCalled: true,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'sync error -> n/a',
          (widgetTester) async {
            await testMultipleAsyncValidators(
              widgetTester,
              () => 'DUMMY',
              () => fail('should not be called.'),
              null,
              null,
              null,
              null,
              'DUMMY',
              shouldSecondCalled: false,
              isSubmitTest: false,
            );
          },
        );

        testWidgets(
          'async error -> n/a',
          (widgetTester) async {
            final onFirstExecuted = Completer<void>();
            await testMultipleAsyncValidators(
              widgetTester,
              () {
                if (!onFirstExecuted.isCompleted) {
                  onFirstExecuted.complete();
                }

                return 'DUMMY';
              },
              () => fail('should not be called.'),
              Completer<void>(),
              null,
              onFirstExecuted.future,
              null,
              'DUMMY',
              shouldSecondCalled: false,
              isSubmitTest: false,
            );
          },
        );
      },
    );

    group('2 async validators in a single proprety', () {
      testWidgets(
        'sync success -> sync success',
        (widgetTester) => testMultipleAsyncValidators(
          widgetTester,
          () => null,
          () => null,
          null,
          null,
          null,
          null,
          null,
          shouldSecondCalled: true,
          isSubmitTest: true,
        ),
      );

      testWidgets(
        'sync success -> async success',
        (widgetTester) async {
          final onSecondExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () => null,
            () {
              if (!onSecondExecuted.isCompleted) {
                onSecondExecuted.complete();
              }

              return null;
            },
            null,
            Completer<void>(),
            null,
            onSecondExecuted.future,
            null,
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'sync success -> sync error',
        (widgetTester) async {
          await testMultipleAsyncValidators(
            widgetTester,
            () => null,
            () => 'DUMMY',
            null,
            null,
            null,
            null,
            'DUMMY',
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'sync success -> async error',
        (widgetTester) async {
          final onSecondExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () => null,
            () {
              if (!onSecondExecuted.isCompleted) {
                onSecondExecuted.complete();
              }

              return 'DUMMY';
            },
            null,
            Completer<void>(),
            null,
            onSecondExecuted.future,
            'DUMMY',
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'async success -> sync success',
        (widgetTester) async {
          final onFirstExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () {
              if (!onFirstExecuted.isCompleted) {
                onFirstExecuted.complete();
              }

              return null;
            },
            () => null,
            Completer<void>(),
            null,
            onFirstExecuted.future,
            null,
            null,
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'async success -> async success',
        (widgetTester) async {
          final onFirstExecuted = Completer<void>();
          final onSecondExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () {
              if (!onFirstExecuted.isCompleted) {
                onFirstExecuted.complete();
              }

              return null;
            },
            () {
              if (!onSecondExecuted.isCompleted) {
                onSecondExecuted.complete();
              }

              return null;
            },
            Completer<void>(),
            Completer<void>(),
            onFirstExecuted.future,
            onSecondExecuted.future,
            null,
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'async success -> sync error',
        (widgetTester) async {
          final onFirstExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () {
              if (!onFirstExecuted.isCompleted) {
                onFirstExecuted.complete();
              }

              return null;
            },
            () => 'DUMMY',
            Completer<void>(),
            null,
            onFirstExecuted.future,
            null,
            'DUMMY',
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'async success -> async error',
        (widgetTester) async {
          final onFirstExecuted = Completer<void>();
          final onSecondExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () {
              if (!onFirstExecuted.isCompleted) {
                onFirstExecuted.complete();
              }

              return null;
            },
            () {
              if (!onSecondExecuted.isCompleted) {
                onSecondExecuted.complete();
              }

              return 'DUMMY';
            },
            Completer<void>(),
            Completer<void>(),
            onFirstExecuted.future,
            onSecondExecuted.future,
            'DUMMY',
            shouldSecondCalled: true,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'sync error -> n/a',
        (widgetTester) async {
          await testMultipleAsyncValidators(
            widgetTester,
            () => 'DUMMY',
            () => fail('should not be called.'),
            null,
            null,
            null,
            null,
            'DUMMY',
            shouldSecondCalled: false,
            isSubmitTest: true,
          );
        },
      );

      testWidgets(
        'async error -> n/a',
        (widgetTester) async {
          final onFirstExecuted = Completer<void>();
          await testMultipleAsyncValidators(
            widgetTester,
            () {
              if (!onFirstExecuted.isCompleted) {
                onFirstExecuted.complete();
              }

              return 'DUMMY';
            },
            () => fail('should not be called.'),
            Completer<void>(),
            null,
            onFirstExecuted.future,
            null,
            'DUMMY',
            shouldSecondCalled: false,
            isSubmitTest: true,
          );
        },
      );
    });
  });
}
