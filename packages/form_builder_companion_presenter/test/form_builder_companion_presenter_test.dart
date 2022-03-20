// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_extension.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

Widget _buildChilren(
  BuildContext context, {
  required String fieldName,
  FormFieldSetter<String>? onSaved,
  FormFieldValidator<String> Function(BuildContext)? validatorFactory,
}) =>
    FormBuilderTextField(
      name: fieldName,
      // TODO(yfakariya): This work around should be removed
      // Work around to avoid double invocation of validation in first entry.
      initialValue: '',
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
    return FormBuilder(
      child: _buildChilren(context, fieldName: 'property'),
    );
  }
}

class _InlineChildren extends StatelessWidget {
  final String fieldName;
  final FormFieldSetter<String>? onSaved;
  final FormFieldValidator<String> Function(BuildContext)? validatorFactory;
  final void Function(BuildContext) onBuilding;
  const _InlineChildren({
    required this.onBuilding,
    required this.fieldName,
    Key? key,
    this.onSaved,
    this.validatorFactory,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    onBuilding(context);
    return _buildChilren(
      context,
      fieldName: fieldName,
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
  final String? _fieldName;
  final FormFieldSetter<String>? _onSaved;
  final FormFieldValidator<String> Function(BuildContext)? _validatorFactory;
  final void Function(BuildContext) _onBuilding;
  final List<Widget> Function(BuildContext)? _childrenFactory;

  const HierarchicalForm._({
    Key? key,
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    String? fieldName,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String> Function(BuildContext)? validatorFactory,
    List<Widget> Function(BuildContext)? childrenFactory,
  })  : _onBuilding = onBuilding,
        _autovalidateMode = autovalidateMode,
        _fieldName = fieldName,
        _onSaved = onSaved,
        _validatorFactory = validatorFactory,
        _childrenFactory = childrenFactory,
        super(key: key);

  // ignore: sort_unnamed_constructors_first
  factory HierarchicalForm({
    Key? key,
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    required String fieldName,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String> Function(BuildContext)? validatorFactory,
  }) =>
      HierarchicalForm._(
        key: key,
        onBuilding: onBuilding,
        autovalidateMode: autovalidateMode,
        fieldName: fieldName,
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
  Widget build(BuildContext context) => FormBuilder(
        autovalidateMode: _autovalidateMode,
        child: _childrenFactory != null
            ? _DynamicChildren(_childrenFactory!, _onBuilding)
            : _InlineChildren(
                fieldName: _fieldName!,
                onBuilding: _onBuilding,
                onSaved: _onSaved,
                validatorFactory: _validatorFactory,
              ),
      );
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

class Presenter with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final FutureOr<void> Function() _doSubmitCalled;

  Presenter(
      {required PropertyDescriptorsBuilder properties,
      FutureOr<void> Function()? doSubmitCalled})
      : _doSubmitCalled = (doSubmitCalled ?? () {}) {
    initializeCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit() => _doSubmitCalled();
}

void main() {
  // For debugging
  // To enable this, you also enable export of loggerSink in tail of form_companion_presenter.dart
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
            fieldName: 'prop',
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(FormBuilderTextField),
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
            fieldName: 'prop',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(FormBuilderTextField),
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
            fieldName: 'prop',
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(FormBuilderTextField),
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
            fieldName: 'prop',
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
            fieldName: 'prop',
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validatorFactory: (context) =>
                presenter.getPropertyValidator('prop', context),
          ),
        ),
      );

      await tester.enterText(
        find.byType(FormBuilderTextField),
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
            fieldName: 'prop',
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
            fieldName: 'prop',
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
        "adapter.validate() will call each FormBuilderField's validators and true for success.",
        (tester) async {
      expect(await testValidate(tester, null), isTrue);
    });

    testWidgets(
        "adapter.validate() will call each FormBuilderField's validators and false for failure.",
        (tester) async {
      expect(await testValidate(tester, 'Dummy error'), isFalse);
    });

    testWidgets("adapter.save() will call each FormBuilderField's onSave.",
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
            fieldName: 'prop',
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
        WidgetTester tester, AutovalidateMode autovalidateMode) async {
      final presenter = Presenter(properties: PropertyDescriptorsBuilder());
      FormStateAdapter? adapter;
      await tester.pumpWidget(
        _app(
          HierarchicalForm(
            onBuilding: (context) {
              adapter = presenter.maybeFormStateOf(context);
            },
            fieldName: 'prop',
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
  });

  group('async validation completion behavor', () {
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
              FormBuilderTextField(
                name: 'target',
                validator: presenter.getPropertyValidator('target', context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // TODO(yfakariya): This work around should be removed
                // Work around to avoid double invocation of validation in first entry.
                initialValue: '',
              ),
              FormBuilderTextField(
                name: 'another',
                validator: presenter.getPropertyValidator('another', context),
                autovalidateMode: AutovalidateMode.onUserInteraction,
                // TODO(yfakariya): This work around should be removed
                // Work around to avoid double invocation of validation in first entry.
                initialValue: '',
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
          (widget) => widget is FormBuilderTextField && widget.name == 'target',
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

      // Async validation completion explicitly calls validate(), so +1
      // In addition, validate() causes rebuild, so +1 (consequently, +3)
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

  group('saveFields()', () {
    Future<void> testSaveFields(
      WidgetTester tester,
      PropertyDescriptorsBuilder properties,
      List<Widget> Function(BuildContext) childrenFactory,
    ) async {
      final presenter = Presenter(
        properties: properties,
      );

      late BuildContext lastContext;
      await tester.pumpWidget(
        _app(
          HierarchicalForm.dynamic(
            onBuilding: (context) {
              lastContext = context;
            },
            autovalidateMode: AutovalidateMode.disabled,
            childrenFactory: childrenFactory,
          ),
        ),
      );

      await tester.enterText(
        find.byWidgetPredicate(
          (widget) => widget is FormBuilderTextField && widget.name == 'target',
        ),
        'A',
      );
      await tester.pump();

      presenter.saveFields(presenter.maybeFormStateOf(lastContext)!);

      expect(presenter.getSavedPropertyValue('target'), equals('A'));
    }

    testWidgets(
      'saves each field values without onSaved handler.',
      (widgetTester) => testSaveFields(
        widgetTester,
        PropertyDescriptorsBuilder()..add<String, String>(name: 'target'),
        (context) => [
          FormBuilderTextField(name: 'target'),
        ],
      ),
    );

    testWidgets(
      'extra fields are ignored and harmless.',
      (widgetTester) async => testSaveFields(
        widgetTester,
        PropertyDescriptorsBuilder()..add<String, String>(name: 'target'),
        (context) => [
          FormBuilderTextField(name: 'target'),
          FormBuilderTextField(name: 'another'),
        ],
      ),
    );

    testWidgets(
      'extra properties are ignored and harmless.',
      (widgetTester) => testSaveFields(
        widgetTester,
        PropertyDescriptorsBuilder()
          ..add<String, String>(name: 'target')
          ..add<String, String>(name: 'another'),
        (context) => [
          FormBuilderTextField(name: 'target'),
        ],
      ),
    );
  });
}
