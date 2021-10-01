// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';

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

class HierarchicalForm extends StatelessWidget {
  final AutovalidateMode _autovalidateMode;
  final Key Function(BuildContext)? _fieldKeyFactory;
  final FormFieldSetter<String>? _onSaved;
  final FormFieldValidator<String> Function(BuildContext)? _validatorFactory;
  final void Function(BuildContext) _onBuilding;

  const HierarchicalForm({
    Key? key,
    required void Function(BuildContext) onBuilding,
    required AutovalidateMode autovalidateMode,
    Key Function(BuildContext)? fieldKeyFactory,
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String> Function(BuildContext)? validatorFactory,
  })  : _onBuilding = onBuilding,
        _autovalidateMode = autovalidateMode,
        _fieldKeyFactory = fieldKeyFactory,
        _onSaved = onSaved,
        _validatorFactory = validatorFactory,
        super(key: key);

  @override
  Widget build(BuildContext context) => Form(
        autovalidateMode: _autovalidateMode,
        child: _InlineChildren(
          fieldKeyFactory: _fieldKeyFactory,
          onBuilding: _onBuilding,
          onSaved: _onSaved,
          validatorFactory: _validatorFactory,
        ),
      );
}

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  final FutureOr<void> Function(BuildContext) _doSubmitCalled;

  Presenter(
      {required PropertyDescriptorsBuilder properties,
      FutureOr<void> Function(BuildContext)? doSubmitCalled})
      : _doSubmitCalled = (doSubmitCalled ?? (_) {}) {
    initializeFormCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit(BuildContext context) => _doSubmitCalled(context);
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
          ..add<String>(
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
        find.byWidgetPredicate((w) => w is TextFormField),
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
          ..add<String>(
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
        find.byWidgetPredicate((w) => w is TextFormField),
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
          ..add<String>(
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
        find.byWidgetPredicate((w) => w is TextFormField),
        'A',
      );

      expect(maybeFormStateOfResult, isNotNull);

      expect(canSubmitResult, isNotNull);
      expect(canSubmitResult, isFalse);

      completer.complete();
      await tester.pump();
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
          ..add<String>(
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
        find.byWidgetPredicate((w) => w is TextFormField),
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
        WidgetTester tester, AutovalidateMode autovalidateMode) async {
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
  });
}
