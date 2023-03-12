// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_companion_presenter/src/form_builder_companion_mixin.dart';
import 'package:form_builder_companion_presenter/src/form_builder_extension.dart';
import 'package:form_builder_companion_presenter/src/form_companion_builder_extension.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:intl/intl.dart';

typedef WrapperFormFieldFactoryWithPresenter = Widget Function(
  Presenter,
  AutovalidateMode,
  BuildContext,
  bool,
);

typedef FormFieldFactory = Widget Function(
  AutovalidateMode,
  BuildContext,
);

typedef ViewChildFactory = Widget Function(FormViewState, AutovalidateMode);

final FormFieldValidator<dynamic> alwaysError = (dynamic v) => '$v:error';

final dateFormat = DateFormat('MM/dd/yyyy');

final _formFieldFactories =
    <Type, Map<String, WrapperFormFieldFactoryWithPresenter>>{
  FormBuilderTextField: {
    'text': (presenter, mode, context, isErrorCase) => FormBuilderTextField(
          name: 'text',
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'text'),
          validator: isErrorCase
              ? presenter.propertiesState.getFieldValidator('text', context)
              : null,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'text'),
        ),
    'trivial': (presenter, mode, context, isErrorCase) => FormBuilderTextField(
          name: 'trivial',
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'trivial'),
          validator: isErrorCase
              ? presenter.propertiesState.getFieldValidator('trivial', context)
              : null,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'trivial'),
        ),
    'sensitive': (presenter, mode, context, isErrorCase) =>
        FormBuilderTextField(
          name: 'sensitive',
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'sensitive'),
          validator: isErrorCase
              ? presenter.propertiesState
                  .getFieldValidator('sensitive', context)
              : null,
          // This is done by generator
          obscureText: true,
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'sensitive'),
        ),
  },
  FormBuilderCheckbox: {
    'boolCheckbox': (presenter, mode, context, _) => FormBuilderCheckbox(
          name: 'boolCheckbox',
          title: Text('boolCheckbox'),
          autovalidateMode: mode,
          onChanged:
              presenter.propertiesState.onChanged(context, 'boolCheckbox'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'boolCheckbox'),
        ),
  },
  FormBuilderCheckboxGroup<Brightness>: {
    'enumListCheckbox': (presenter, mode, context, _) =>
        FormBuilderCheckboxGroup<Brightness>(
          name: 'enumListCheckbox',
          options: Brightness.values
              .map(
                (e) => FormBuilderFieldOption(
                  value: e,
                  child: Text(e.name),
                ),
              )
              .toList(),
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<List<Brightness>>(context, 'enumListCheckbox'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumListCheckbox'),
        ),
  },
  FormBuilderChoiceChip<Brightness>: {
    'enumChoiceChip': (presenter, mode, context, _) =>
        FormBuilderChoiceChip<Brightness>(
          name: 'enumChoiceChip',
          options: Brightness.values
              .map(
                (e) => FormBuilderChipOption(
                  value: e,
                  child: Text(e.name),
                ),
              )
              .toList(),
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<Brightness>(context, 'enumChoiceChip'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumChoiceChip'),
        ),
  },
  FormBuilderDateRangePicker: {
    'dateRange': (presenter, mode, context, _) => FormBuilderDateRangePicker(
          name: 'dateRange',
          // ignore: avoid_redundant_argument_values
          firstDate: DateTime(2000, 1, 1),
          lastDate: DateTime(2099, 12, 31),
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'dateRange'),
          initialEntryMode: DatePickerEntryMode.inputOnly,
          format: dateFormat,
          confirmText: 'OK',
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'dateRange'),
        ),
  },
  FormBuilderDateTimePicker: {
    'dateTime': (presenter, mode, context, _) => FormBuilderDateTimePicker(
          name: 'dateTime',
          autovalidateMode: mode,
          initialEntryMode: DatePickerEntryMode.inputOnly,
          inputType: InputType.date,
          format: dateFormat,
          confirmText: 'OK',
          onChanged: presenter.propertiesState.onChanged(context, 'dateTime'),
          initialDate:
              presenter.propertiesState.getInitialValue(context, 'dateTime'),
        ),
  },
  FormBuilderDropdown<Brightness>: {
    'enumDropdown': (presenter, mode, context, _) =>
        FormBuilderDropdown<Brightness>(
          name: 'enumDropdown',
          items: [
            DropdownMenuItem(value: Brightness.light, child: Text('light')),
            DropdownMenuItem(value: Brightness.dark, child: Text('dark')),
          ],
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<Brightness>(context, 'enumDropdown'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumDropdown'),
        ),
  },
  FormBuilderFilterChip<Brightness>: {
    'enumListFilterChip': (presenter, mode, context, _) =>
        FormBuilderFilterChip<Brightness>(
          name: 'enumListFilterChip',
          options: Brightness.values
              .map(
                (e) => FormBuilderChipOption(
                  value: e,
                  child: Text(e.name),
                ),
              )
              .toList(),
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<List<Brightness>>(context, 'enumListFilterChip'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumListFilterChip'),
        ),
  },
  FormBuilderRadioGroup<Brightness>: {
    'enumRadioGroup': (presenter, mode, context, _) =>
        FormBuilderRadioGroup<Brightness>(
          name: 'enumRadioGroup',
          options: [
            FormBuilderFieldOption(
              value: Brightness.light,
              child: Text('light'),
            ),
            FormBuilderFieldOption(
              value: Brightness.dark,
              child: Text('dark'),
            ),
          ],
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<Brightness>(context, 'enumRadioGroup'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumRadioGroup'),
        ),
  },
  FormBuilderRangeSlider: {
    'range': (presenter, mode, context, _) => FormBuilderRangeSlider(
          name: 'range',
          // ignore: avoid_redundant_argument_values
          min: 0,
          max: 100,
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'range'),
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'range'),
        ),
  },
  FormBuilderSegmentedControl<Brightness>: {
    'enumSegmentedControl': (presenter, mode, context, _) =>
        FormBuilderSegmentedControl<Brightness>(
          name: 'enumSegmentedControl',
          options: [
            FormBuilderFieldOption(
              value: Brightness.light,
              child: Text('light'),
            ),
            FormBuilderFieldOption(
              value: Brightness.dark,
              child: Text('dark'),
            ),
          ],
          autovalidateMode: mode,
          onChanged: presenter.propertiesState
              .onChanged<Brightness>(context, 'enumSegmentedControl'),
          initialValue: presenter.propertiesState
              .getInitialValue(context, 'enumSegmentedControl'),
        ),
  },
  FormBuilderSlider: {
    'number': (presenter, mode, context, _) => FormBuilderSlider(
          name: 'number',
          // ignore: avoid_redundant_argument_values
          min: 0,
          max: 100,
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'number'),
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'number')!,
        ),
  },
  FormBuilderSwitch: {
    'boolSwitch': (presenter, mode, context, _) => FormBuilderSwitch(
          name: 'boolSwitch',
          title: Text('boolSwitch'),
          autovalidateMode: mode,
          onChanged: presenter.propertiesState.onChanged(context, 'boolSwitch'),
          initialValue:
              presenter.propertiesState.getInitialValue(context, 'boolSwitch'),
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
    String fieldName,
    Type formFieldType,
    ViewChildFactory widgetFactory,
    FutureOr<void> Function() setValueToTarget,
    FutureOr<void> Function() verifyExistence,
    FutureOr<void> Function() verifyNonExistence,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
    state.formBuilderState!.fields[fieldName]!.reset();
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

    state.formBuilderState!.fields[fieldName]!.reset();
    await tester.pumpAndSettle();
    // Cofirm disappearance
    await verifyNonExistence();
    await tester.restoreFrom(data);
    await tester.pumpAndSettle();
    await verifyExistence();
  }

  FutureOr<void> testValueOnTextForm(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    FutureOr<void> testValueOnTextFormCore(String value) async {
      await testValueCore(
        tester,
        fieldName,
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
    String fieldName,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkErrorText(String value, String error) async {
      state.formBuilderState!.fields[fieldName]!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      // We have to manually validate if we're not autovalidating.
      expect(find.text(error), findsNothing);
      state.formBuilderState!.fields[fieldName]!.validate();
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

      state.formBuilderState!.fields[fieldName]!.reset();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      await tester.restoreFrom(data);
      await tester.pumpAndSettle();
      expect(find.text(error), findsOneWidget);

      // Try again with autovalidation. Should validate immediately.
      state.formBuilderState!.fields[fieldName]!.reset();
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
    String fieldName,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkText(String value) async {
      state.formBuilderState!.fields[fieldName]!.reset();
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

      state.formBuilderState!.fields[fieldName]!.reset();
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      await tester.restoreFrom(data1);
      await tester.pumpAndSettle();
      expect(find.text(value), findsNothing);
      expect(find.text('INITIAL_VALUE'), findsOneWidget);

      // Try again with autovalidation. Should validate immediately.
      state.formBuilderState!.fields[fieldName]!.reset();
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

      state.formBuilderState!.fields[fieldName]!.reset();
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
    String fieldName,
    Type formFieldType,
    ViewChildFactory widgetFactory,
  ) async {
    final state = FormViewState();

    await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));

    FutureOr<void> checkErrorText(String value, String error) async {
      state.formBuilderState!.fields[fieldName]!.reset();
      await tester.pumpWidget(widgetFactory(state, AutovalidateMode.disabled));
      await tester.enterText(find.byType(formFieldType), value);
      await tester.pumpAndSettle();

      // We have to manually validate if we're not autovalidating.
      expect(find.text(error), findsNothing);
      state.formBuilderState!.fields[fieldName]!.validate();
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

      state.formBuilderState!.fields[fieldName]!.reset();
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      await tester.restoreFrom(data);
      await tester.pumpAndSettle();
      expect(find.text(error), findsNothing);

      // Try again with autovalidation. Should validate immediately.
      state.formBuilderState!.fields[fieldName]!.reset();
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

  FutureOr<void> testValueOnSelectable<T extends Object>(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    T value,
    String displayText,
    ViewChildFactory widgetFactory,
  ) async {
    await testValueCore(
      tester,
      fieldName,
      formFieldType,
      widgetFactory,
      () async {
        await tester.tap(find.text(displayText).last);
        await tester.pumpAndSettle();
      },
      () {
        final state =
            tester.state<FormFieldState<T>>(find.byType(formFieldType));
        expect(state.value, value);
      },
      () {
        final state =
            tester.state<FormFieldState<T>>(find.byType(formFieldType));
        expect(state.value, isNot(value));
      },
    );
  }

  FutureOr<void> testValueOnDropdown<T extends Object>(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    T value,
    String displayText,
    ViewChildFactory widgetFactory,
  ) async {
    await testValueCore(
      tester,
      fieldName,
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

  FutureOr<void> testValueOnDateTimeRangePicker(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    DateTimeRange initialValue,
    DateTimeRange value,
    ViewChildFactory widgetFactory,
  ) async {
    final initialFromText = dateFormat.format(initialValue.start);
    final initialToText = dateFormat.format(initialValue.end);
    final fromText = dateFormat.format(value.start);
    final toText = dateFormat.format(value.end);
    final text =
        '${dateFormat.format(value.start)} - ${dateFormat.format(value.end)}';
    await testValueCore(
      tester,
      fieldName,
      formFieldType,
      widgetFactory,
      () async {
        // Show inputOnly mode picker assuming `initialEntryMode: DatePickerEntryMode.inputOnly`
        await tester.tap(find.byType(formFieldType));
        await tester.pumpAndSettle();
        // find text field and then input value assuming `format: dateFormat`
        await tester.enterText(find.text(initialFromText), fromText);
        await tester.enterText(find.text(initialToText), toText);
        // await tester.pumpAndSettle();
        // tap button to close assuming `confirmText: 'OK'`
        await tester.tap(find.text('OK').last);
      },
      () => expect(find.text(text), findsOneWidget),
      () => expect(find.text(text), findsNothing),
    );
  }

  FutureOr<void> testValueOnDateTimePicker(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    DateTime initialValue,
    DateTime value,
    ViewChildFactory widgetFactory,
  ) async {
    final initialText = dateFormat.format(initialValue);
    final text = dateFormat.format(value);
    await testValueCore(
      tester,
      fieldName,
      formFieldType,
      widgetFactory,
      () async {
        // Show inputOnly mode picker assuming `initialEntryMode: DatePickerEntryMode.inputOnly`
        await tester.tap(find.byType(formFieldType));
        await tester.pumpAndSettle();
        // find text field and then input value assuming `format: dateFormat`
        await tester.enterText(find.text(initialText), text);
        await tester.pumpAndSettle();
        // tap button to close assuming `confirmText: 'OK'`
        await tester.tap(find.text('OK').last);
      },
      () => expect(find.text(text), findsOneWidget),
      () {
        // TODO(yfakariya): FormBuilderDateTimePicker does not support `reset()` on 7.8
        // expect(find.text(text), findsNothing);
      },
    );
  }

  FutureOr<void> testValueOnRangeSlider(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    String displayText, // "min - max"
    ViewChildFactory widgetFactory,
  ) async {
    await testValueCore(
      tester,
      fieldName,
      formFieldType,
      widgetFactory,
      () async {
        // With native RangeSlider instead of wrapper FormBuilderField
        final target = find.byType(RangeSlider);
        final zeroPoint = tester.getTopLeft(target) +
            Offset(24, tester.getSize(target).height / 2);
        final totalWidth = tester.getSize(target).width - (2 * 24);
        await tester.dragFrom(
          zeroPoint.translate(totalWidth / 2, 0),
          Offset(totalWidth / 2, 0),
        );
      },
      () => expect(find.text(displayText), findsOneWidget),
      () => expect(find.text(displayText), findsNothing),
    );
  }

  FutureOr<void> testValueOnSlider(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    String displayText, // "max"
    ViewChildFactory widgetFactory,
  ) async {
    await testValueCore(
      tester,
      fieldName,
      formFieldType,
      widgetFactory,
      () async {
        // With native Slider instead of wrapper FormBuilderField
        final target = find.byType(Slider);
        final zeroPoint = tester.getTopLeft(target) +
            Offset(24, tester.getSize(target).height / 2);
        final totalWidth = tester.getSize(target).width - (2 * 24);
        await tester.dragFrom(zeroPoint, Offset(totalWidth, 0));
      },
      () => expect(find.text(displayText), findsNWidgets(2)), // current, max
      () => expect(find.text(displayText), findsOneWidget), // max
    );
  }

  FutureOr<void> testCore(
    WidgetTester tester,
    String fieldName,
    Type formFieldType,
    WrapperFormFieldFactoryWithPresenter formFieldFactory,
    FutureOr<void> Function(WidgetTester, String, Type, ViewChildFactory)
        doTest, {
    required bool isErrorCase,
  }) async {
    final presenter = Presenter();
    final ViewChildFactory builder = (state, mode) => FormViewWithForm(
          presenter: presenter,
          state: state,
          mode: mode,
          formFieldFactory: (m, x) =>
              formFieldFactory(presenter, m, x, isErrorCase),
        );
    await doTest(tester, fieldName, formFieldType, builder);
  }

  for (final spec in [
    Spec(
      FormBuilderTextField,
      'value',
      'text',
      testValueOnTextForm,
    ),
    Spec(
      FormBuilderTextField,
      'validation error',
      'text',
      testValidationErrorOnTextForm,
      isErrorCase: true,
    ),
    Spec(
      FormBuilderTextField,
      'value is not restored for doNotRestoreState trait',
      'trivial',
      testValueOnTextFormWillNotBeRestored,
    ),
    Spec(
      FormBuilderTextField,
      'validation is not restored for doNotRestoreState trait',
      'trivial',
      testValidationErrorOnTextFormWillNotBeRestored,
      isErrorCase: true,
    ),
    Spec(
      FormBuilderTextField,
      'value is not restored for sensitive trait',
      'sensitive',
      testValueOnTextFormWillNotBeRestored,
    ),
    Spec(
      FormBuilderTextField,
      'validation is not restored for sensitive trait',
      'sensitive',
      testValidationErrorOnTextFormWillNotBeRestored,
      isErrorCase: true,
    ),
    Spec(
      FormBuilderCheckbox,
      'value',
      'boolCheckbox',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        true,
        'boolCheckbox',
        factory,
      ),
    ),
    Spec(
      FormBuilderCheckboxGroup<Brightness>,
      'value',
      'enumListCheckbox',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        [Brightness.dark],
        Brightness.dark.name,
        factory,
      ),
    ),
    Spec(
      FormBuilderChoiceChip<Brightness>,
      'value',
      'enumChoiceChip',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        Brightness.dark,
        Brightness.dark.name,
        factory,
      ),
    ),
    Spec(
      FormBuilderDateRangePicker,
      'value',
      'dateRange',
      (tester, name, formType, factory) async =>
          await testValueOnDateTimeRangePicker(
        tester,
        name,
        formType,
        // ignore: avoid_redundant_argument_values
        DateTimeRange(start: DateTime(2023, 1, 1), end: DateTime(2023, 1, 2)),
        // ignore: avoid_redundant_argument_values
        DateTimeRange(start: DateTime(2023, 2, 3), end: DateTime(2023, 2, 4)),
        factory,
      ),
    ),
    Spec(
      FormBuilderDateTimePicker,
      'value',
      'dateTime',
      (tester, name, formType, factory) async =>
          await testValueOnDateTimePicker(
        tester,
        name,
        formType,
        // ignore: avoid_redundant_argument_values
        DateTime(2023, 1, 1),
        // ignore: avoid_redundant_argument_values
        DateTime(2023, 2, 3),
        factory,
      ),
    ),
    Spec(
      FormBuilderDropdown<Brightness>,
      'value',
      'enumDropdown',
      (tester, name, formType, factory) async => await testValueOnDropdown(
        tester,
        name,
        formType,
        Brightness.dark,
        'dark',
        factory,
      ),
    ),
    Spec(
      FormBuilderFilterChip<Brightness>,
      'value',
      'enumListFilterChip',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        [Brightness.dark],
        Brightness.dark.name,
        factory,
      ),
    ),
    Spec(
      FormBuilderRadioGroup<Brightness>,
      'value',
      'enumRadioGroup',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        Brightness.dark,
        'dark',
        factory,
      ),
    ),
    Spec(
      FormBuilderRangeSlider,
      'value',
      'range',
      (tester, name, formType, factory) async => await testValueOnRangeSlider(
        tester,
        name,
        FormBuilderRangeSlider,
        '0 - 100',
        factory,
      ),
    ),
    Spec(
      FormBuilderSegmentedControl<Brightness>,
      'value',
      'enumSegmentedControl',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        Brightness.dark,
        'dark',
        factory,
      ),
    ),
    Spec(
      FormBuilderSlider,
      'value',
      'number',
      (tester, name, formType, factory) async => await testValueOnSlider(
        tester,
        name,
        FormBuilderSlider,
        '100', // max
        factory,
      ),
    ),
    Spec(
      FormBuilderSwitch,
      'value',
      'boolSwitch',
      (tester, name, formType, factory) async => await testValueOnSelectable(
        tester,
        name,
        formType,
        true,
        'boolSwitch',
        factory,
      ),
    ),
  ]) {
    final formFieldFactories = _formFieldFactories[spec.type]!;
    final fieldFactory = formFieldFactories[spec.property]!;
    group(spec.type.toString(), () {
      testWidgets('${spec.type} ${spec.property}, ${spec.label}',
          (tester) async {
        await testCore(
          tester,
          spec.property,
          spec.type,
          fieldFactory,
          spec.doTest,
          isErrorCase: spec.isErrorCase,
        );
      });
    });
  }
}

class Spec {
  final Type type;
  final String label;
  final String property;
  final void Function(WidgetTester, String, Type, ViewChildFactory) doTest;
  final bool isErrorCase;

  Spec(
    this.type,
    this.label,
    this.property,
    this.doTest, {
    this.isErrorCase = false,
  });
}

class Presenter with CompanionPresenterMixin, FormBuilderCompanionMixin {
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
        )
        ..booleanWithField<FormBuilderCheckbox>(
          name: 'boolCheckbox',
          // ignore: avoid_redundant_argument_values
          initialValue: false,
        )
        ..enumeratedListWithField<Brightness,
            FormBuilderCheckboxGroup<Brightness>>(
          name: 'enumListCheckbox',
          initialValues: [],
          enumValues: Brightness.values,
        )
        ..enumeratedWithField<Brightness, FormBuilderChoiceChip<Brightness>>(
          name: 'enumChoiceChip',
          initialValue: Brightness.light,
          enumValues: Brightness.values,
        )
        ..dateTimeRange(
          name: 'dateRange',
          initialValue: DateTimeRange(
            // ignore: avoid_redundant_argument_values
            start: DateTime(2023, 1, 1),
            end: DateTime(2023, 1, 2),
          ),
        )
        ..dateTime(
          name: 'dateTime',
          // ignore: avoid_redundant_argument_values
          initialValue: DateTime(2023, 1, 1),
        )
        ..enumeratedWithField<Brightness, FormBuilderDropdown<Brightness>>(
          name: 'enumDropdown',
          initialValue: Brightness.light,
          enumValues: Brightness.values,
        )
        ..enumeratedListWithField<Brightness,
            FormBuilderFilterChip<Brightness>>(
          name: 'enumListFilterChip',
          initialValues: [],
          enumValues: Brightness.values,
        )
        ..enumeratedWithField<Brightness, FormBuilderRadioGroup<Brightness>>(
          name: 'enumRadioGroup',
          enumValues: Brightness.values,
          initialValue: Brightness.light,
        )
        ..rangeValues(
          name: 'range',
          initialValue: RangeValues(0, 50),
        )
        ..enumeratedWithField<Brightness,
            FormBuilderSegmentedControl<Brightness>>(
          name: 'enumSegmentedControl',
          initialValue: Brightness.light,
          enumValues: Brightness.values,
        )
        ..realWithField<FormBuilderSlider>(
          name: 'number',
          initialValue: 0,
        )
        ..booleanWithField<FormBuilderSwitch>(
          name: 'boolSwitch',
          // ignore: avoid_redundant_argument_values
          initialValue: false,
        ),
    );
  }
  @override
  FutureOr<void> doSubmit() {}
}

class FormViewState {
  FormBuilderState? formBuilderState;
}

class FormViewWithForm extends StatelessWidget {
  final Presenter presenter;
  final FormViewState state;
  final AutovalidateMode mode;
  final FormFieldFactory formFieldFactory;

  FormViewWithForm({
    super.key,
    required this.presenter,
    required this.state,
    required this.mode,
    required this.formFieldFactory,
  });

  @override
  Widget build(BuildContext context) => MaterialApp(
        restorationScopeId: 'app',
        home: Material(
          child: Center(
            child: FormBuilder(
              child: FormPropertiesRestorationScope(
                presenter: presenter,
                child: FormView(
                  state: state,
                  mode: mode,
                  formFieldFactory: formFieldFactory,
                ),
              ),
            ),
          ),
        ),
      );
}

class FormView extends StatelessWidget {
  final FormViewState state;
  final AutovalidateMode mode;
  final FormFieldFactory formFieldFactory;

  FormView({
    super.key,
    required this.state,
    required this.mode,
    required this.formFieldFactory,
  });

  @override
  Widget build(BuildContext context) {
    state.formBuilderState = FormBuilder.of(context);
    return formFieldFactory(mode, context);
  }
}
