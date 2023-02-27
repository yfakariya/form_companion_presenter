// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';

typedef WrapperFormFieldFactory = Widget Function(
  Key,
  AutovalidateMode,
  BuildContext,
  FormFieldValidator<dynamic>?,
);

typedef WrapperFormFieldFactoryWithPresenter = Widget Function(
  Presenter,
  Key,
  AutovalidateMode,
  BuildContext,
  bool,
);

typedef FormFieldFactory = Widget Function(
  Key,
  AutovalidateMode,
  BuildContext,
);

typedef ViewChildFactory = Widget Function(FormViewState, AutovalidateMode);

typedef TextTestLogic = FutureOr<void> Function(
  WidgetTester,
  Type,
  ViewChildFactory,
);

typedef SelectableTestLogic<T extends Enum> = FutureOr<void> Function(
  WidgetTester,
  Type,
  T,
  String,
  ViewChildFactory,
);

final FormFieldValidator<dynamic> alwaysError = (dynamic v) => '$v:error';
final FormFieldValidator<String> mustBeEmpty =
    (v) => (v ?? '').isNotEmpty ? '$v:error' : null;
final FormFieldValidator<String> mustNotBeEmpty =
    (v) => (v ?? '').isEmpty ? '$v:error' : null;

final _formFieldFactoriesForBaseline = <Type, WrapperFormFieldFactory>{
  TextFormField: (key, mode, context, validator) => TextFormField(
        key: key,
        restorationId: 'form_field',
        autovalidateMode: mode,
        validator: validator,
        initialValue: 'INITIAL_VALUE',
      ),
};

final _formFieldFactoriesForPresenter =
    <Type, Map<String, WrapperFormFieldFactoryWithPresenter>>{
  TextFormField: {
    'text': (presenter, key, mode, context, isErrorCase) => TextFormField(
          key: key,
          autovalidateMode: mode,
          onChanged:
              presenter.propertiesState.onChangedNonNull(context, 'text'),
          validator: isErrorCase
              ? presenter.propertiesState.getFieldValidator('text', context)
              : null,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'text'),
        ),
    'text#withRestorationId': (presenter, key, mode, context, isErrorCase) =>
        TextFormField(
          key: key,
          autovalidateMode: mode,
          restorationId: 'text',
          onChanged:
              presenter.propertiesState.onChangedNonNull(context, 'text'),
          validator: isErrorCase
              ? presenter.propertiesState.getFieldValidator('text', context)
              : null,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'text'),
        ),
    'trivial': (presenter, key, mode, context, isErrorCase) => TextFormField(
          key: key,
          autovalidateMode: mode,
          onChanged:
              presenter.propertiesState.onChangedNonNull(context, 'trivial'),
          validator: isErrorCase
              ? presenter.propertiesState.getFieldValidator('trivial', context)
              : null,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'trivial'),
        ),
    'sensitive': (presenter, key, mode, context, isErrorCase) => TextFormField(
          key: key,
          autovalidateMode: mode,
          onChanged:
              presenter.propertiesState.onChangedNonNull(context, 'sensitive'),
          validator: isErrorCase
              ? presenter.propertiesState
                  .getFieldValidator('sensitive', context)
              : null,
          // This is done by generator
          obscureText: true,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'sensitive'),
        ),
    'async': (presenter, key, mode, context, _) => TextFormField(
          key: key,
          autovalidateMode: mode,
          onChanged:
              presenter.propertiesState.onChangedNonNull(context, 'async'),
          validator:
              presenter.propertiesState.getFieldValidator('async', context),
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'async'),
        ),
  },
  DropdownButtonFormField<Brightness>: {
    'enum': (presenter, key, mode, context, _) =>
        DropdownButtonFormField<Brightness>(
          key: key,
          items: [
            DropdownMenuItem(value: Brightness.light, child: Text('light')),
            DropdownMenuItem(value: Brightness.dark, child: Text('dark')),
          ],
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'enum'),
          value: presenter.propertiesState.getInitialValue(context, 'enum'),
        ),
  },
};

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

  FutureOr<void> testValueCore<T extends Object>(
    WidgetTester tester,
    Type formFieldType,
    ViewChildFactory widgetFactory,
    FutureOr<void> Function() setValueToTarget,
    FutureOr<void> Function() verifyExistence,
    FutureOr<void> Function() verifyNonExistence,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
    state.key!.currentState!.reset();
    await setValueToTarget();
    await tester.pumpAndSettle();

    final data = await tester.getRestorationData();
    // ignore: invalid_use_of_protected_member
    final dataBinary = data.binary;
    if (dataBinary != null) {
      final dynamic decoded = const StandardMessageCodec().decodeMessage(
        dataBinary.buffer.asByteData(
          dataBinary.offsetInBytes,
          dataBinary.length,
        ),
      );
      printOnFailure('restorationData:$decoded');
    }
    await tester.restartAndRestore();
    await tester.pumpAndSettle();
    // Target should be restored after restart and restore.
    await verifyExistence();

    state.key!.currentState!.reset();
    await tester.pumpAndSettle();
    // Cofirm disappearance
    await verifyNonExistence();
    await tester.restoreFrom(data);
    await tester.pumpAndSettle();
    await verifyExistence();
  }

  FutureOr<void> testValueOnTextForm(
    WidgetTester tester,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    FutureOr<void> testValueOnTextFormCore(String value) async {
      await testValueCore(
        tester,
        formFieldType,
        widgetFactory,
        () => tester.enterText(find.byType(formFieldType), value),
        () => expect(find.text(value), findsOneWidget),
        () => expect(find.text(value), findsNothing),
      );
    }

    await testValueOnTextFormCore('abc');
    await testValueOnTextFormCore('');
  }

  FutureOr<void> testValidationErrorOnTextForm(
    WidgetTester tester,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkErrorText(String value, String error) async {
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      // We have to manually validate if we're not autovalidating.
      expect(find.text(error), findsNothing);
      state.key!.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget);
      final data = await tester.getRestorationData();
      // ignore: invalid_use_of_protected_member
      final dataBinary = data.binary;
      if (dataBinary != null) {
        final dynamic decoded = const StandardMessageCodec().decodeMessage(
          dataBinary.buffer.asByteData(
            dataBinary.offsetInBytes,
            dataBinary.length,
          ),
        );
        printOnFailure('restorationData:$decoded');
      }
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      // Error text should be present after restart and restore.
      expect(find.text(error), findsOneWidget);

      state.key!.currentState!.reset();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      await tester.restoreFrom(data);
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget);

      // Try again with autovalidation. Should validate immediately.
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.always));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      expect(find.text(error), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.restartAndRestore();
      await tester.pumpAndSettle();

      // Error text should be present after restart and restore.
      expect(find.text(error), findsOneWidget);
    }

    await checkErrorText('abc', 'abc:error');
    await checkErrorText('', ':error');
  }

  FutureOr<void> testValueOnTextFormWillNotBeRestored(
    WidgetTester tester,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkText(String value) async {
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      final data1 = await tester.getRestorationData();
      // ignore: invalid_use_of_protected_member
      final dataBinary1 = data1.binary;
      if (dataBinary1 != null) {
        final dynamic decoded = const StandardMessageCodec().decodeMessage(
          dataBinary1.buffer.asByteData(
            dataBinary1.offsetInBytes,
            dataBinary1.length,
          ),
        );
        printOnFailure('restorationData(1):$decoded');
      }
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      // Text should be lost after restart and restore.
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      state.key!.currentState!.reset();
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      await tester.restoreFrom(data1);
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      // Try again with autovalidation. Should validate immediately.
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.always));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      final data2 = await tester.getRestorationData();
      // ignore: invalid_use_of_protected_member
      final dataBinary2 = data2.binary;
      if (dataBinary2 != null) {
        final dynamic decoded = const StandardMessageCodec().decodeMessage(
          dataBinary2.buffer.asByteData(
            dataBinary2.offsetInBytes,
            dataBinary2.length,
          ),
        );
        printOnFailure('restorationData(2):$decoded');
      }
      await tester.pumpAndSettle();
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      // Text should be present after restart and restore.
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      state.key!.currentState!.reset();
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      await tester.restoreFrom(data2);
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);
    }

    await checkText('abc');
    await checkText('');
  }

  FutureOr<void> testValidationErrorOnTextFormWillNotBeRestored(
    WidgetTester tester,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkErrorText(String value, String error) async {
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      // We have to manually validate if we're not autovalidating.
      expect(find.text(error), findsNothing);
      state.key!.currentState!.validate();
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget);
      final data = await tester.getRestorationData();
      // ignore: invalid_use_of_protected_member
      final dataBinary = data.binary;
      if (dataBinary != null) {
        final dynamic decoded = const StandardMessageCodec().decodeMessage(
          dataBinary.buffer.asByteData(
            dataBinary.offsetInBytes,
            dataBinary.length,
          ),
        );
        printOnFailure('restorationData:$decoded');
      }
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      // Error text should be lost after restart and restore.
      expect(find.text(error), findsNothing);

      state.key!.currentState!.reset();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      await tester.restoreFrom(data);
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      // Try again with autovalidation. Should validate immediately.
      state.key!.currentState!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.always));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      expect(find.text(error), findsOneWidget);
      await tester.pumpAndSettle();
      await tester.restartAndRestore();
      await tester.pumpAndSettle();

      // Error text should be lost after restart and restore.
      expect(find.text(error), findsNothing);
    }

    await checkErrorText('abc', 'abc:error');
    await checkErrorText('', ':error');
  }

  FutureOr<void> testValidationErrorOnTextFormAsync(
    WidgetTester tester,
    Presenter presenter,
    Type formFieldType,
    ViewChildFactory widgetFactory,
    AsyncValidation asyncValidation,
  ) async {
    final state = FormViewState();

    Widget builder(AutovalidateMode mode) {
      return MaterialApp(
        restorationScopeId: 'app',
        home: Material(
          child: Center(
            child: widgetFactory(state, mode),
          ),
        ),
      );
    }

    await tester.pumpWidget(builder(AutovalidateMode.disabled));

    FutureOr<void> checkErrorText(String value) async {
      state.key!.currentState!.reset();
      presenter.resetAsyncValidators();
      await tester.pumpWidget(builder(AutovalidateMode.disabled));
      asyncValidation.prepare();
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();
      await asyncValidation.goAhead('#1 - Enter without validation');
      await tester.pumpAndSettle();
      var error = '$value:error:#1 - Enter without validation';
      // We have to manually validate if we're not autovalidating.
      expect(find.text(error), findsNothing);
      asyncValidation.prepare();
      state.key!.currentState!.validate();
      await tester.pumpAndSettle();
      await asyncValidation.goAhead('#2 - Manual validation');
      await tester.pumpAndSettle();
      error = '$value:error:#2 - Manual validation';
      expect(find.text(error), findsOneWidget);
      await tester.pumpAndSettle();
      final data = await tester.getRestorationData();
      asyncValidation.prepare();
      presenter.resetAsyncValidators();
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();

      await asyncValidation.goAhead('#3 - Restart');
      await tester.pumpAndSettle();
      error = '$value:error:#3 - Restart';
      // Error text should be present after restart and restore, but new async validation was kicked.
      expect(find.text(error), findsOneWidget);

      state.key!.currentState!.reset();
      presenter.resetAsyncValidators();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      asyncValidation.prepare();
      await tester.restoreFrom(data);
      await tester.pumpAndSettle();
      await asyncValidation.goAhead('#4 - Restore manually');
      await tester.pumpAndSettle();
      error = '$value:error:#4 - Restore manually';
      expect(find.text(error), findsOneWidget);

      // Try again with autovalidation. Should validate immediately.
      state.key!.currentState!.reset();
      presenter.resetAsyncValidators();
      await tester.pumpWidget(builder(AutovalidateMode.always));
      asyncValidation.prepare();
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();
      await asyncValidation.goAhead('#5 - Autovalidate');
      await tester.pumpAndSettle();
      error = '$value:error:#5 - Autovalidate';

      expect(find.text(error), findsOneWidget);
      await tester.pumpAndSettle();

      asyncValidation.prepare();
      presenter.resetAsyncValidators();
      await tester.restartAndRestore();
      await tester.pumpAndSettle();
      await asyncValidation.goAhead('#6 - Restart');
      await tester.pumpAndSettle();
      error = '$value:error:#6 - Restart';

      // Error text should be present after restart and restore, but new async validation was kicked.
      expect(find.text(error), findsOneWidget);
    }

    await checkErrorText('abc');
    await checkErrorText('');
  }

  FutureOr<void> testValueOnDropdown<T extends Object>(
    WidgetTester tester,
    Type formFieldType,
    T value,
    String displayText,
    ViewChildFactory widgetFactory,
  ) async {
    await testValueCore(
      tester,
      formFieldType,
      widgetFactory,
      () async {
        await tester.tap(find.byType(formFieldType));
        await tester.pumpAndSettle();

        await tester.tap(find.text(displayText).last);
        await tester.pumpAndSettle();
      },
      () {
        // We cannot use text based verification for dropdown.
        expect(
          tester
              .state<FormFieldState<dynamic>>(find.byType(formFieldType))
              .value,
          value,
        );
      },
      () {
        // We cannot use text based verification for dropdown.
        expect(
          tester
              .state<FormFieldState<dynamic>>(find.byType(formFieldType))
              .value,
          isNot(value),
        );
      },
    );
  }

  FutureOr<void> testCoreForBaseline(
    WidgetTester tester,
    Type formFieldType,
    FutureOr<void> Function(WidgetTester, Type, ViewChildFactory) doTest,
    FormFieldValidator<dynamic>? validator,
  ) async {
    final formFieldFactory = _formFieldFactoriesForBaseline[formFieldType]!;
    final ViewChildFactory builder = (state, mode) => FormViewWithoutForm(
          state: state,
          mode: mode,
          keyFactory: (_) => GlobalKey(),
          formFieldFactory: (k, m, x) => formFieldFactory(k, m, x, validator),
        );
    await doTest(tester, formFieldType, builder);
  }

  testWidgets('baseline - value', (tester) async {
    await testCoreForBaseline(
      tester,
      TextFormField,
      testValueOnTextForm,
      null,
    );
  });

  testWidgets('baseline - validation error', (tester) async {
    await testCoreForBaseline(
      tester,
      TextFormField,
      testValidationErrorOnTextForm,
      alwaysError,
    );
  });

  FutureOr<void> testTextCoreForPresenter<T extends Object>(
    WidgetTester tester,
    Type formFieldType,
    String propertyName,
    TextTestLogic doTest, {
    required bool isErrorCase,
    bool specifiesRestorationId = false,
  }) async {
    final presenter = Presenter();
    final subKey = specifiesRestorationId
        ? '$propertyName#withRestorationId'
        : propertyName;
    final formFieldFactory =
        _formFieldFactoriesForPresenter[formFieldType]![subKey]!;
    final ViewChildFactory builder = (state, mode) => FormViewWithForm(
          presenter: presenter,
          state: state,
          mode: mode,
          keyFactory: (context) => presenter.getKey(propertyName, context)
              as GlobalKey<FormFieldState<dynamic>>,
          formFieldFactory: (k, m, x) =>
              formFieldFactory(presenter, k, m, x, isErrorCase),
        );
    await doTest(tester, formFieldType, builder);
  }

  FutureOr<void> testSelectableCoreForPresenter<T extends Enum>(
    WidgetTester tester,
    Type formFieldType,
    SelectableTestLogic<T> doTest,
    T initialValue,
    T testValue,
  ) async {
    final presenter = Presenter();
    final formFieldFactory =
        _formFieldFactoriesForPresenter[formFieldType]!['enum']!;
    final ViewChildFactory builder = (state, mode) => FormViewWithForm(
          presenter: presenter,
          state: state,
          mode: mode,
          keyFactory: (context) => presenter.getKey('enum', context)
              as GlobalKey<FormFieldState<dynamic>>,
          formFieldFactory: (k, m, x) =>
              formFieldFactory(presenter, k, m, x, false),
        );
    await doTest(
      tester,
      formFieldType,
      testValue,
      testValue.name,
      builder,
    );
  }

  group('vanilla form fields with presenter', () {
    testWidgets('with presenter, TextFormField, value', (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'text',
        testValueOnTextForm,
        isErrorCase: false,
      );
    });

    testWidgets('with presenter, TextFormField, validation error',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'text',
        testValidationErrorOnTextForm,
        isErrorCase: true,
      );
    });

    testWidgets(
        'with presenter, TextFormField, value is restored even if restorationId is specified',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'text',
        testValueOnTextForm,
        isErrorCase: false,
        specifiesRestorationId: true,
      );
    });

    testWidgets(
        'with presenter, TextFormField, value is not restored for doNotRestoreState trait',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'trivial',
        testValueOnTextFormWillNotBeRestored,
        isErrorCase: false,
      );
    });

    testWidgets(
        'with presenter, TextFormField, validation is not restored for doNotRestoreState trait',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'trivial',
        testValidationErrorOnTextFormWillNotBeRestored,
        isErrorCase: true,
      );
    });

    testWidgets(
        'with presenter, TextFormField, value is not restored for sensitive trait',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'sensitive',
        testValueOnTextFormWillNotBeRestored,
        isErrorCase: false,
      );
    });

    testWidgets(
        'with presenter, TextFormField, validation is not restored for sensitive trait',
        (tester) async {
      await testTextCoreForPresenter(
        tester,
        TextFormField,
        'sensitive',
        testValidationErrorOnTextFormWillNotBeRestored,
        isErrorCase: true,
      );
    });

    testWidgets('with presenter, TextFormField, async validation error',
        (tester) async {
      final asyncValidation = AsyncValidation();
      final presenter = Presenter(asyncValidation.getValidator);
      final formFieldFactory =
          _formFieldFactoriesForPresenter[TextFormField]!['async']!;
      final ViewChildFactory builder = (state, mode) => FormViewWithForm(
            presenter: presenter,
            state: state,
            mode: mode,
            keyFactory: (context) => presenter.getKey('async', context)
                as GlobalKey<FormFieldState<dynamic>>,
            formFieldFactory: (k, m, x) =>
                formFieldFactory(presenter, k, m, x, true),
          );
      await testValidationErrorOnTextFormAsync(
        tester,
        presenter,
        TextFormField,
        builder,
        asyncValidation,
      );
    });

    testWidgets('with presenter, DropdownButtonFormField, value',
        (tester) async {
      await testSelectableCoreForPresenter(
        tester,
        DropdownButtonFormField<Brightness>,
        testValueOnDropdown<Brightness>,
        Brightness.light,
        Brightness.dark,
      );
    });
  });

  group('multiple field combination', () {
    for (final formAutovalidateMode in AutovalidateMode.values) {
      for (final fieldAutovalidateMode in AutovalidateMode.values) {
        final targetShouldBeAutovalidated =
            formAutovalidateMode != AutovalidateMode.disabled ||
                fieldAutovalidateMode != AutovalidateMode.disabled;
        final anotherShouldBeValidated =
            formAutovalidateMode != AutovalidateMode.disabled ||
                fieldAutovalidateMode == AutovalidateMode.always;
        final targetShouldNotBeAutovalidated = !targetShouldBeAutovalidated;

        // restore with validation
        testWidgets(
          'Form: ${formAutovalidateMode.name}, Field: ${fieldAutovalidateMode.name}, restored with validation',
          (tester) async {
            final state = MultipleFormViewState();
            final presenter = MultiplePresenter();
            final widget = MultipleFormView(
              presenter: presenter,
              state: state,
              formAutovalidateMode: formAutovalidateMode,
              fieldAutovalidateMode: fieldAutovalidateMode,
            );

            await tester.pumpWidget(widget);
            await tester.enterText(find.byKey(state.targetKey), 'target');
            await tester.enterText(find.byKey(state.notRestoredKey), 'trivial');
            await tester.pumpAndSettle();
            if (targetShouldNotBeAutovalidated) {
              expect(state.targetKey.currentState!.validate(), isFalse);
              await tester.pumpAndSettle();
            }

            // ignore: invalid_use_of_protected_member
            final restorationData = (await tester.getRestorationData()).binary!;
            printOnFailure(
              const StandardMessageCodec()
                  .decodeMessage(
                    restorationData.buffer.asByteData(
                      restorationData.offsetInBytes,
                      restorationData.length,
                    ),
                  )
                  .toString(),
            );

            await tester.restartAndRestore();
            await tester.pumpAndSettle();

            expect(
              find.text('target'),
              findsOneWidget,
              reason: 'target.value shuold be restored',
            );
            expect(
              find.text('target:error'),
              findsOneWidget,
              reason: 'target.hasError shuold be restored',
            );

            expect(
              find.text('trivial'),
              findsNothing,
              reason: 'trivial.value shuold not be restored',
            );
            expect(
              find.text('trivial:error'),
              findsNothing,
              reason: 'trivial.hasError shuold not be restored',
            );

            expect(
              find.text('invalid'),
              findsOneWidget,
              reason: 'invalid.value shuold be restored',
            );
            expect(
              find.text('invalid:error'),
              anotherShouldBeValidated ? findsOneWidget : findsNothing,
              reason: anotherShouldBeValidated
                  ? 'invalid.hasError should be restored'
                  : 'invalid.hasError should not be restored',
            );

            expect(
              find.text('valid'),
              findsOneWidget,
              reason: 'valid.value shuold be restored',
            );
            expect(
              find.text('valid:error'),
              findsNothing,
              reason: 'valid.hasError should never be true',
            );

            expect(
              tester
                  .state<FormFieldState<Brightness>>(
                    find.byKey(state.hasNullInitialValueKey),
                  )
                  .value,
              isNull,
              reason: 'null.value',
            );
            expect(
              find.text('null:error'),
              findsNothing,
              reason: 'null.hasError should never be true',
            );

            await tester.pumpAndSettle();
            expect(
              find.text('target'),
              findsOneWidget,
              reason: 'restored value should not be replaced with initialValue',
            );
          },
        );
      }
    }

    testWidgets(
      'Never fired validation is not fired on restoration',
      (tester) async {
        final state = MultipleFormViewState();
        final presenter = MultiplePresenter();
        final widget = MultipleFormView(
          presenter: presenter,
          state: state,
          formAutovalidateMode: AutovalidateMode.disabled,
          fieldAutovalidateMode: AutovalidateMode.disabled,
        );

        await tester.pumpWidget(widget);
        await tester.enterText(find.byKey(state.targetKey), 'target');
        await tester.enterText(find.byKey(state.notRestoredKey), 'trivial');
        await tester.pumpAndSettle();

        await tester.restartAndRestore();
        await tester.pumpAndSettle();

        expect(
          find.text('target'),
          findsOneWidget,
          reason: 'target.value shuold be restored',
        );
        expect(
          find.text('target:error'),
          findsNothing,
          reason: 'target.hasError shuold not be restored',
        );
      },
    );
  });
}

// TODO: documentation on Readme

class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  Presenter([AsyncValidatorFactory<String>? asyncValidatorFactory]) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'text',
          validatorFactories: [
            (_) => alwaysError,
          ],
          initialValue: 'INITIAL_VALUE',
        )
        ..string(
          name: 'trivial',
          validatorFactories: [
            (_) => alwaysError,
          ],
          initialValue: 'INITIAL_VALUE',
          valueTraits: PropertyValueTraits.doNotRestoreState,
        )
        ..string(
          name: 'sensitive',
          validatorFactories: [
            (_) => alwaysError,
          ],
          initialValue: 'INITIAL_VALUE',
          valueTraits: PropertyValueTraits.sensitive,
        )
        ..string(
          name: 'async',
          asyncValidatorFactories: [
            if (asyncValidatorFactory != null) asyncValidatorFactory
          ],
          initialValue: 'INITIAL_VALUE',
        )
        ..enumerated(
          name: 'enum',
          initialValue: Brightness.light,
          enumValues: Brightness.values,
        ),
    );
  }
  @override
  FutureOr<void> doSubmit() {}
}

class FormViewState {
  GlobalKey<FormFieldState<dynamic>>? key;
}

class FormViewWithoutForm extends StatelessWidget {
  final FormViewState state;
  final AutovalidateMode mode;
  final GlobalKey<FormFieldState<dynamic>> Function(BuildContext) keyFactory;
  final FormFieldFactory formFieldFactory;

  FormViewWithoutForm({
    super.key,
    required this.state,
    required this.mode,
    required this.keyFactory,
    required this.formFieldFactory,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      home: Material(
        child: Center(
          child: FormView(
            state: state,
            mode: mode,
            keyFactory: keyFactory,
            formFieldFactory: formFieldFactory,
          ),
        ),
      ),
    );
  }
}

class FormViewWithForm extends StatelessWidget {
  final Presenter presenter;
  final FormViewState state;
  final AutovalidateMode mode;
  final GlobalKey<FormFieldState<dynamic>> Function(BuildContext) keyFactory;
  final FormFieldFactory formFieldFactory;

  FormViewWithForm({
    super.key,
    required this.presenter,
    required this.state,
    required this.mode,
    required this.keyFactory,
    required this.formFieldFactory,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      home: Material(
        child: Center(
          child: Form(
            child: FormPropertiesRestorationScope(
              presenter: presenter,
              child: FormView(
                state: state,
                mode: mode,
                keyFactory: keyFactory,
                formFieldFactory: formFieldFactory,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FormView extends StatelessWidget {
  final FormViewState state;
  final AutovalidateMode mode;
  final GlobalKey<FormFieldState<dynamic>> Function(BuildContext) keyFactory;
  final FormFieldFactory formFieldFactory;

  FormView({
    super.key,
    required this.state,
    required this.mode,
    required this.keyFactory,
    required this.formFieldFactory,
  });

  @override
  Widget build(BuildContext context) {
    final key = keyFactory(context);
    state.key = key;
    return formFieldFactory(key, mode, context);
  }
}

class MultiplePresenter with CompanionPresenterMixin, FormCompanionMixin {
  MultiplePresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'target',
          validatorFactories: [
            (_) => mustBeEmpty,
          ],
        )
        ..string(
          name: 'trivial',
          validatorFactories: [
            (_) => mustBeEmpty,
          ],
          valueTraits: PropertyValueTraits.doNotRestoreState,
        )
        ..string(
          name: 'invalid',
          validatorFactories: [
            (_) => mustBeEmpty,
          ],
          initialValue: 'invalid',
        )
        ..string(
          name: 'valid',
          validatorFactories: [
            (_) => mustNotBeEmpty,
          ],
          initialValue: 'valid',
        )
        ..enumerated(
          name: 'null',
          enumValues: Brightness.values,
        ),
    );
  }
  @override
  FutureOr<void> doSubmit() {}
}

class MultipleFormViewState {
  late GlobalKey<FormFieldState<dynamic>> targetKey;
  late GlobalKey<FormFieldState<dynamic>> hasInvalidInitialValueKey;
  late GlobalKey<FormFieldState<dynamic>> notRestoredKey;
  late GlobalKey<FormFieldState<dynamic>> hasValidInitialValueKey;
  late GlobalKey<FormFieldState<dynamic>> hasNullInitialValueKey;
}

class MultipleFormView extends StatelessWidget {
  final MultiplePresenter presenter;
  final MultipleFormViewState state;
  final AutovalidateMode formAutovalidateMode;
  final AutovalidateMode fieldAutovalidateMode;

  MultipleFormView({
    super.key,
    required this.presenter,
    required this.state,
    required this.formAutovalidateMode,
    required this.fieldAutovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      restorationScopeId: 'app',
      home: Material(
        child: Form(
          autovalidateMode: formAutovalidateMode,
          child: FormPropertiesRestorationScope(
            presenter: presenter,
            child: FixedFormFields(
              presenter: presenter,
              state: state,
              autovalidateMode: fieldAutovalidateMode,
            ),
          ),
        ),
      ),
    );
  }
}

class FixedFormFields extends StatelessWidget {
  final MultiplePresenter presenter;
  final MultipleFormViewState state;
  final AutovalidateMode autovalidateMode;

  FixedFormFields({
    super.key,
    required this.presenter,
    required this.state,
    required this.autovalidateMode,
  });

  @override
  Widget build(BuildContext context) {
    assert(Form.maybeOf(context) != null);
    final textFormFieldKeys = {
      'target': state.targetKey = presenter.getKey(
        'target',
        context,
      ) as GlobalKey<FormFieldState<dynamic>>,
      'trivial': state.notRestoredKey = presenter.getKey(
        'trivial',
        context,
      ) as GlobalKey<FormFieldState<dynamic>>,
      'invalid': state.hasInvalidInitialValueKey = presenter.getKey(
        'invalid',
        context,
      ) as GlobalKey<FormFieldState<dynamic>>,
      'valid': state.hasValidInitialValueKey = presenter.getKey(
        'valid',
        context,
      ) as GlobalKey<FormFieldState<dynamic>>,
    };
    final dropdownFieldKey = state.hasNullInitialValueKey = presenter.getKey(
      'null',
      context,
    ) as GlobalKey<FormFieldState<dynamic>>;

    return Column(
      children: [
        ...textFormFieldKeys.entries.map(
          (e) => TextFormField(
            key: e.value,
            autovalidateMode: autovalidateMode,
            onChanged:
                presenter.propertiesState.onChangedNonNull(context, e.key),
            validator:
                presenter.propertiesState.getFieldValidator(e.key, context),
            initialValue:
                presenter.propertiesState.getInitialValue(context, e.key),
          ),
        ),
        DropdownButtonFormField<Brightness>(
          key: dropdownFieldKey,
          items: [null, ...Brightness.values]
              .map(
                (e) => DropdownMenuItem(value: e, child: Text(e?.name ?? '')),
              )
              .toList(),
          autovalidateMode: autovalidateMode,
          onChanged: presenter.propertiesState.onChanged(context, 'null'),
          value: presenter.propertiesState.getInitialValue(context, 'null'),
        ),
      ],
    );
  }
}

class AsyncValidation {
  Completer<String>? _completer;

  void prepare() {
    assert(_completer == null || _completer!.isCompleted);
    _completer = Completer();
  }

  Future<void> goAhead(String token) async {
    _completer!.complete(token);
  }

  AsyncValidator<String> getValidator(ValidatorCreationOptions _) =>
      (value, options) async {
        final token = await _completer!.future;
        return '$value:error:$token';
      };
}
