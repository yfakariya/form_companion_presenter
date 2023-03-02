// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_builder_companion_presenter/src/form_builder_extension.dart';
import 'package:form_builder_companion_presenter/src/form_companion_builder_extension.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
// Required for getValueConverter() helper function call.
import 'package:form_companion_presenter/src/form_companion_mixin.dart';
// Required for DefaultValueConverter reference
import 'package:form_companion_presenter/src/value_converter.dart';

enum _MyEnum {
  one,
  two,
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
  Locale get locale => defaultLocale;

  @override
  bool get mounted => true;

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
  bool get mounted => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    // Required for getLocale() test.
    return null;
  }

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({
    required Type expectedAncestorType,
  }) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
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

  @override
  void dispatchNotification(Notification notification) {
    throw UnimplementedError();
  }
}

class _TestPresenterFeatures extends CompanionPresenterFeatures {
  const _TestPresenterFeatures();

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) =>
      FixedFormStateAdapter();

  @override
  void handleCanceledAsyncValidationError(AsyncError error) {
    printOnFailure(error.toString());
  }
}

class Presenter with CompanionPresenterMixin {
  @override
  CompanionPresenterFeatures get presenterFeatures =>
      const _TestPresenterFeatures();

  Presenter(PropertyDescriptorsBuilder properties) {
    initializeCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit() {
    // nop
  }

  @override
  bool canSubmit(BuildContext context) => true;
}

class ValidatorTester<F extends Object> {
  final _completer = Completer<void>();
  F? _passedToValidator;
  F? _passedToAsyncValidator;

  F? get passedToValidator => _passedToValidator;
  F? get passedToAsyncValidator => _passedToAsyncValidator;

  String? Function(F?) Function(BuildContext) get validator => (_) => (v) {
        _passedToValidator = v;
        return null;
      };

  Future<String?> Function(F?, AsyncValidatorOptions) Function(BuildContext)
      get asyncValidator => (_) => (v, o) async {
            _passedToAsyncValidator = v;
            if (!_completer.isCompleted) {
              _completer.complete();
            }
            return null;
          };

  Future<void> waitForPendingValidation() async {
    await _completer.future;
    // pump
    await Future<void>.delayed(Duration.zero);
  }
}

const defaultLocale = Locale('en', 'US');

void main() {
  String? verifyPropertyDescriptor<P extends Object, F extends Object>(
    PropertyDescriptorsBuilder target, {
    required String name,
    required P? initialPropertyValue,
    required F? initialFieldValue,
    ValueConverter? converter,
    String? converterType,
    required F value,
  }) {
    final presenter = Presenter(target);
    final result = presenter.propertiesState.getAllDescriptors().single;
    expect(
      result,
      isA<PropertyDescriptor<P, F>>()
          .having((p) => p.name, 'name', name)
          .having((p) => p.presenter, 'presenter', same(presenter))
          .having(
            (p) => presenter.propertiesState.getValue(p.name),
            'value',
            initialPropertyValue,
          )
          .having(
            (p) => p.getFieldValue(defaultLocale),
            'getFieldValue',
            initialFieldValue,
          ),
    );

    if (converter != null) {
      expect(getValueConverter(result), same(converter));
    } else if (converterType != null) {
      expect(getValueConverter(result).runtimeType.toString(), converterType);
    } else {
      // ignore: invalid_use_of_internal_member
      expect(getValueConverter(result), isA<DefaultValueConverter<P, F>>());
    }

    return (result as PropertyDescriptor<P, F>)
        .getValidator(DummyBuildContext())
        .call(value);
  }

  group('FormBuilderCompanionPropertyDescriptorsBuilderExtension', () {
    test('booleanList default', () {
      final target = PropertyDescriptorsBuilder()
        ..booleanList(
          name: 'prop',
        );
      verifyPropertyDescriptor<List<bool>, List<bool>>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: [true],
      );
    });

    test('booleanList fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..booleanList(
          name: 'prop',
          initialValues: [true],
        );

      verifyPropertyDescriptor<List<bool>, List<bool>>(
        target,
        name: 'prop',
        initialPropertyValue: [true],
        initialFieldValue: [true],
        value: [true],
      );
    });

    test('enumeratedList default', () {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedList(
          name: 'prop',
        );
      verifyPropertyDescriptor<List<Enum>, List<Enum>>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: [_MyEnum.two],
      );
    });

    test('enumeratedList fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedList(
          name: 'prop',
          initialValues: [_MyEnum.one],
        );

      verifyPropertyDescriptor<List<_MyEnum>, List<_MyEnum>>(
        target,
        name: 'prop',
        initialPropertyValue: [_MyEnum.one],
        initialFieldValue: [_MyEnum.one],
        value: [_MyEnum.two],
      );
    });

    test('dateTime default', () {
      final target = PropertyDescriptorsBuilder()
        ..dateTime(
          name: 'prop',
        );
      verifyPropertyDescriptor<DateTime, DateTime>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: DateTime.now(),
      );
    });

    test('dateTime fully specified', () async {
      final now = DateTime.now();
      final target = PropertyDescriptorsBuilder()
        ..dateTime(
          name: 'prop',
          initialValue: now,
        );

      verifyPropertyDescriptor<DateTime, DateTime>(
        target,
        name: 'prop',
        initialPropertyValue: now,
        initialFieldValue: now,
        value: DateTime.now(),
      );
    });

    test('dateTimeRange default', () {
      final target = PropertyDescriptorsBuilder()
        ..dateTimeRange(
          name: 'prop',
        );
      verifyPropertyDescriptor<DateTimeRange, DateTimeRange>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: DateTimeRange(
          // ignore: avoid_redundant_argument_values
          start: DateTime(2000, 1, 1),
          end: DateTime(2000, 12, 31),
        ),
      );
    });

    test('dateTimeRange fully specified', () async {
      final range = DateTimeRange(
        // ignore: avoid_redundant_argument_values
        start: DateTime(2000, 1, 1),
        end: DateTime(2000, 12, 31),
      );
      final target = PropertyDescriptorsBuilder()
        ..dateTimeRange(
          name: 'prop',
          initialValue: range,
        );

      verifyPropertyDescriptor<DateTimeRange, DateTimeRange>(
        target,
        name: 'prop',
        initialPropertyValue: range,
        initialFieldValue: range,
        value: DateTimeRange(
          // ignore: avoid_redundant_argument_values
          start: DateTime(2020, 1, 1),
          end: DateTime(2020, 12, 31),
        ),
      );
    });

    test('rangeValues default', () {
      final target = PropertyDescriptorsBuilder()
        ..rangeValues(
          name: 'prop',
        );
      verifyPropertyDescriptor<RangeValues, RangeValues>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: const RangeValues(0, 1),
      );
    });

    test('rangeValues fully specified', () async {
      const range = RangeValues(0, 1);
      final target = PropertyDescriptorsBuilder()
        ..rangeValues(
          name: 'prop',
          initialValue: range,
        );

      verifyPropertyDescriptor<RangeValues, RangeValues>(
        target,
        name: 'prop',
        initialPropertyValue: range,
        initialFieldValue: range,
        value: const RangeValues(-100, 100),
      );
    });
  });

  group('FormCompanionBuilderCompanionPropertyDescriptorsBuilderExtension', () {
    test('booleanListWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..booleanListWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<List<bool>, List<bool>>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: [true],
      );
    });

    test('booleanListWithField fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..booleanListWithField(
          name: 'prop',
          initialValues: [true],
        );

      verifyPropertyDescriptor<List<bool>, List<bool>>(
        target,
        name: 'prop',
        initialPropertyValue: [true],
        initialFieldValue: [true],
        value: [true],
      );
    });

    test('enumeratedListWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedListWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<List<Enum>, List<Enum>>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: [_MyEnum.two],
      );
    });

    test('enumeratedListWithField fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedListWithField(
          name: 'prop',
          initialValues: [_MyEnum.one],
        );

      verifyPropertyDescriptor<List<_MyEnum>, List<_MyEnum>>(
        target,
        name: 'prop',
        initialPropertyValue: [_MyEnum.one],
        initialFieldValue: [_MyEnum.one],
        value: [_MyEnum.two],
      );
    });
  });
}
