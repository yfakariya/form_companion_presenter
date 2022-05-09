// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/src/async_validator_executor.dart';
import 'package:form_companion_presenter/src/form_companion_annotation.dart';

import 'package:form_companion_presenter/src/form_companion_mixin.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';
import 'package:form_companion_presenter/src/string_converter.dart';
import 'package:form_companion_presenter/src/value_converter.dart';

import 'companion_presenter_mixin_test.dart';

enum _MyEnum {
  one,
  two,
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
    final result = presenter.properties.values.single;
    expect(
      result,
      isA<PropertyDescriptor<P, F>>()
          .having((p) => p.name, 'name', name)
          .having((p) => p.presenter, 'presenter', same(presenter))
          .having((p) => p.value, 'value', initialPropertyValue)
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
      expect(getValueConverter(result), isA<DefaultValueConverter<P, F>>());
    }

    return (result as PropertyDescriptor<P, F>)
        .getValidator(DummyBuildContext())
        .call(value);
  }

  group('FormCompanionPropertyDescriptorsBuilderExtension', () {
    test('stringConvertible default', () {
      final target = PropertyDescriptorsBuilder();
      final converter = intStringConverter;
      target.stringConvertible(
        name: 'prop',
        stringConverter: intStringConverter,
      );
      verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        converter: converter,
        value: '',
      );
    });

    test('stringConvertible fully specified', () async {
      final target = PropertyDescriptorsBuilder();
      final validator = ValidatorTester<String>();
      final converter = intStringConverter;

      target.stringConvertible(
        name: 'prop',
        stringConverter: intStringConverter,
        asyncValidatorFactories: [validator.asyncValidator],
        validatorFactories: [validator.validator],
        initialValue: 123,
      );

      final value = DateTime.now().microsecondsSinceEpoch.toString();

      final validationResult = verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: 123,
        initialFieldValue: '123',
        converter: converter,
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('string default', () {
      final target = PropertyDescriptorsBuilder()
        ..string(
          name: 'prop',
        );
      verifyPropertyDescriptor<String, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        value: '',
      );
    });

    test('string fully specified', () async {
      final validator = ValidatorTester<String>();
      final target = PropertyDescriptorsBuilder()
        ..string(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: '123',
        );

      final value = DateTime.now().microsecondsSinceEpoch.toString();

      final validationResult = verifyPropertyDescriptor<String, String>(
        target,
        name: 'prop',
        initialPropertyValue: '123',
        initialFieldValue: '123',
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('boolean default', () {
      final target = PropertyDescriptorsBuilder()
        ..boolean(
          name: 'prop',
        );
      verifyPropertyDescriptor<bool, bool>(
        target,
        name: 'prop',
        initialPropertyValue: false,
        initialFieldValue: false,
        value: true,
      );
    });

    test('boolean fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..boolean(
          name: 'prop',
          initialValue: true,
        );

      verifyPropertyDescriptor<bool, bool>(
        target,
        name: 'prop',
        initialPropertyValue: true,
        initialFieldValue: true,
        value: true,
      );
    });

    test('enumerated default', () {
      final target = PropertyDescriptorsBuilder()
        ..enumerated(
          name: 'prop',
        );
      verifyPropertyDescriptor<Enum, Enum>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: _MyEnum.two,
      );
    });

    test('enumerated fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..enumerated<_MyEnum>(
          name: 'prop',
          initialValue: _MyEnum.one,
        );

      verifyPropertyDescriptor<_MyEnum, _MyEnum>(
        target,
        name: 'prop',
        initialPropertyValue: _MyEnum.one,
        initialFieldValue: _MyEnum.one,
        value: _MyEnum.two,
      );
    });

    test('integerText default', () {
      final target = PropertyDescriptorsBuilder()
        ..integerText(
          name: 'prop',
        );
      verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        converterType: '_CallbackStringConverter<int>',
        value: '',
      );
    });

    test('integerText fully specified', () async {
      final validator = ValidatorTester<String>();
      final target = PropertyDescriptorsBuilder()
        ..integerText(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: 123,
        );

      final value = DateTime.now().microsecondsSinceEpoch.toString();

      final validationResult = verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: 123,
        initialFieldValue: '123',
        converterType: '_CallbackStringConverter<int>',
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('realText default', () {
      final target = PropertyDescriptorsBuilder()
        ..realText(
          name: 'prop',
        );
      verifyPropertyDescriptor<double, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        converterType: '_CallbackStringConverter<double>',
        value: '',
      );
    });

    test('realText fully specified', () async {
      final validator = ValidatorTester<String>();
      final target = PropertyDescriptorsBuilder()
        ..realText(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: 123.45,
        );

      final value = (DateTime.now().microsecondsSinceEpoch / 1000.0).toString();

      final validationResult = verifyPropertyDescriptor<double, String>(
        target,
        name: 'prop',
        initialPropertyValue: 123.45,
        initialFieldValue: '123.45',
        converterType: '_CallbackStringConverter<double>',
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('bigIntText default', () {
      final target = PropertyDescriptorsBuilder()
        ..bigIntText(
          name: 'prop',
        );
      verifyPropertyDescriptor<BigInt, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        converterType: '_CallbackStringConverter<BigInt>',
        value: '',
      );
    });

    test('bigIntText fully specified', () async {
      final validator = ValidatorTester<String>();
      final target = PropertyDescriptorsBuilder()
        ..bigIntText(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: BigInt.from(123),
        );

      final value = DateTime.now().microsecondsSinceEpoch.toString();

      final validationResult = verifyPropertyDescriptor<BigInt, String>(
        target,
        name: 'prop',
        initialPropertyValue: BigInt.from(123),
        initialFieldValue: '123',
        converterType: '_CallbackStringConverter<BigInt>',
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });
  });

  group('FormCompanionPropertyDescriptorBuilderExtensions', () {
    test('stringConvertibleWithField default', () {
      final target = PropertyDescriptorsBuilder();
      final converter = intStringConverter;
      target.stringConvertibleWithField(
        name: 'prop',
        stringConverter: intStringConverter,
      );
      verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: '',
        converter: converter,
        value: '',
      );
    });

    test('stringConvertibleWithField fully specified', () async {
      final target = PropertyDescriptorsBuilder();
      final validator = ValidatorTester<String>();
      final converter = intStringConverter;

      target.stringConvertibleWithField(
        name: 'prop',
        stringConverter: intStringConverter,
        asyncValidatorFactories: [validator.asyncValidator],
        validatorFactories: [validator.validator],
        initialValue: 123,
      );

      final value = DateTime.now().microsecondsSinceEpoch.toString();

      final validationResult = verifyPropertyDescriptor<int, String>(
        target,
        name: 'prop',
        initialPropertyValue: 123,
        initialFieldValue: '123',
        converter: converter,
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('booleanWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..booleanWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<bool, bool>(
        target,
        name: 'prop',
        initialPropertyValue: false,
        initialFieldValue: false,
        value: true,
      );
    });

    test('booleanWithField fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..booleanWithField(
          name: 'prop',
          initialValue: true,
        );

      verifyPropertyDescriptor<bool, bool>(
        target,
        name: 'prop',
        initialPropertyValue: true,
        initialFieldValue: true,
        value: true,
      );
    });

    test('enumeratedWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<Enum, Enum>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: _MyEnum.two,
      );
    });

    test('enumeratedWithField fully specified', () async {
      final target = PropertyDescriptorsBuilder()
        ..enumeratedWithField(
          name: 'prop',
          initialValue: _MyEnum.one,
        );

      verifyPropertyDescriptor<_MyEnum, _MyEnum>(
        target,
        name: 'prop',
        initialPropertyValue: _MyEnum.one,
        initialFieldValue: _MyEnum.one,
        value: _MyEnum.two,
      );
    });

    test('integerWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..integerWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<int, int>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: 0,
      );
    });

    test('integerWithField fully specified', () async {
      final validator = ValidatorTester<int>();
      final target = PropertyDescriptorsBuilder()
        ..integerWithField(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: 123,
        );

      final value = DateTime.now().microsecondsSinceEpoch;

      final validationResult = verifyPropertyDescriptor<int, int>(
        target,
        name: 'prop',
        initialPropertyValue: 123,
        initialFieldValue: 123,
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('realWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..realWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<double, double>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: 0,
      );
    });

    test('realWithField fully specified', () async {
      final validator = ValidatorTester<double>();
      final target = PropertyDescriptorsBuilder()
        ..realWithField(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: 123.45,
        );

      final value = DateTime.now().microsecondsSinceEpoch / 1000.0;

      final validationResult = verifyPropertyDescriptor<double, double>(
        target,
        name: 'prop',
        initialPropertyValue: 123.45,
        initialFieldValue: 123.45,
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });

    test('bigIntWithField default', () {
      final target = PropertyDescriptorsBuilder()
        ..bigIntWithField(
          name: 'prop',
        );
      verifyPropertyDescriptor<BigInt, BigInt>(
        target,
        name: 'prop',
        initialPropertyValue: null,
        initialFieldValue: null,
        value: BigInt.zero,
      );
    });

    test('bigIntWithField fully specified', () async {
      final validator = ValidatorTester<BigInt>();
      final target = PropertyDescriptorsBuilder()
        ..bigIntWithField(
          name: 'prop',
          asyncValidatorFactories: [validator.asyncValidator],
          validatorFactories: [validator.validator],
          initialValue: BigInt.from(123),
        );

      final value = BigInt.from(DateTime.now().microsecondsSinceEpoch);

      final validationResult = verifyPropertyDescriptor<BigInt, BigInt>(
        target,
        name: 'prop',
        initialPropertyValue: BigInt.from(123),
        initialFieldValue: BigInt.from(123),
        value: value,
      );

      await validator.waitForPendingValidation();

      expect(validationResult, isNull);
      expect(validator.passedToValidator, value);
      expect(validator.passedToAsyncValidator, value);
    });
  });
}
