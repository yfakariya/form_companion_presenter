// See LICENCE file in the root.

import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';
import 'package:form_companion_presenter/src/value_converter.dart';

const frenchLocale = Locale('fr', 'FR');

void main() {
  void testPropertyToFieldSuccess<P extends Object, F extends Object>(
    ValueConverter<P, F> Function() targetFactory,
    P? value,
    F? expected,
    Locale locale,
  ) {
    final target = targetFactory();
    expect(target.toFieldValue(value, locale), expected);
  }

  void testPropertyToFieldFailure<P extends Object, F extends Object, X>(
    ValueConverter<P, F> Function() targetFactory,
    P? value,
    Locale locale,
    TypeMatcher<X> Function(TypeMatcher<X>) exceptionAssertion,
  ) {
    final target = targetFactory();
    expect(
      () => target.toFieldValue(value, locale),
      throwsA(exceptionAssertion(isA<X>())),
    );
  }

  void testFieldToPropertySuccess<P extends Object, F extends Object>(
    ValueConverter<P, F> Function() targetFactory,
    F? value,
    P? expected,
    Locale locale,
  ) {
    final target = targetFactory();
    final result = target.toPropertyValue(value, locale);
    expect(
      result,
      isA<ConversionResult<P>>().having((r) => r.value, 'value', expected),
    );
  }

  void testFieldToPropertyFailure<P extends Object, F extends Object>(
    ValueConverter<P, F> Function() targetFactory,
    F? value,
    Locale locale, {
    required String message,
    required String debugInfo,
  }) {
    final target = targetFactory();
    final result = target.toPropertyValue(value, locale);
    if (result is ConversionResult<P>) {
      fail('Success: ${result.value}');
    }

    expect(
      result,
      isA<FailureResult<P>>()
          .having((r) => r.message, 'message', message)
          .having((r) => r.toString(), 'toString()', message)
          .having((r) => r.debugInfo, 'debugInfo', debugInfo),
    );
  }

  group('DefaultValueConverter', () {
    test('non-null -> non-null, compatible', () {
      final value = DateTime.now().microsecond;
      testPropertyToFieldSuccess<int, num>(
        DefaultValueConverter<int, num>.new,
        value,
        value,
        defaultLocale,
      );
    });

    test('non-null <- non-null, compatible', () {
      final value = DateTime.now().microsecond;
      testFieldToPropertySuccess<int, num>(
        DefaultValueConverter<int, num>.new,
        value,
        value,
        defaultLocale,
      );
    });

    test('non-null -> non-null, incompatible', () {
      final value = DateTime.now().microsecond;
      testPropertyToFieldFailure<int, bool, StateError>(
        DefaultValueConverter<int, bool>.new,
        value,
        defaultLocale,
        (e) => e.having(
          (x) => x.message,
          'message',
          'int is not compatible with bool.',
        ),
      );
    });

    test(
      'non-null <- non-null, incompatible',
      () => testFieldToPropertyFailure<int, bool>(
        DefaultValueConverter<int, bool>.new,
        true,
        defaultLocale,
        message: 'bool is not compatible with int.',
        debugInfo: 'bool is not compatible with int.',
      ),
    );

    test(
      'null -> null, compatible',
      () => testPropertyToFieldSuccess<int, num>(
        DefaultValueConverter<int, num>.new,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null, compatible',
      () => testFieldToPropertySuccess<int, num>(
        DefaultValueConverter<int, num>.new,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'null -> null, incompatible',
      () => testPropertyToFieldSuccess<int, bool>(
        DefaultValueConverter<int, bool>.new,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null, incompatible',
      () => testFieldToPropertySuccess<int, bool>(
        DefaultValueConverter<int, bool>.new,
        null,
        null,
        defaultLocale,
      ),
    );
  });

  group('CallbackValueConverter', () {
    void testToField<P extends Object, F extends Object>(
      P? input,
      Locale locale,
      F? expectedFieldValue,
    ) {
      late final P? actualInput;
      late final Locale actualLocale;
      final target = ValueConverter<P, F>.fromCallbacks(
        toFieldValue: (v, l) {
          actualInput = v;
          actualLocale = l;
          return expectedFieldValue;
        },
        toPropertyValue: (v, l) {
          fail('toPropertyValue is called!');
        },
      );

      final actualFieldValue = target.toFieldValue(input, locale);
      expect(actualFieldValue, expectedFieldValue);
      expect(actualInput, input);
      expect(actualLocale, locale);
    }

    void testToProperty<P extends Object, F extends Object>(
      F? input,
      Locale locale,
      SomeConversionResult<P> expectedResult,
      void Function(
        SomeConversionResult<P> expected,
        SomeConversionResult<P> actual,
      )
          resultAssertion,
    ) {
      late final F? actualInput;
      late final Locale actualLocale;
      final target = ValueConverter<P, F>.fromCallbacks(
        toFieldValue: (v, l) {
          fail('toFieldValue is called!');
        },
        toPropertyValue: (v, l) {
          actualInput = v;
          actualLocale = l;
          return expectedResult;
        },
      );

      final actualResult = target.toPropertyValue(input, locale);
      resultAssertion(expectedResult, actualResult);
      expect(actualInput, input);
      expect(actualLocale, locale);
    }

    test(
      'P -> F, non-null',
      () => testToField<int, String>(123, frenchLocale, '123'),
    );

    test(
      'F -> P, non-null',
      () => testToProperty<int, String>(
        '123',
        frenchLocale,
        const ConversionResult(123),
        (e, a) => expect(
          a,
          isA<ConversionResult<int>>().having((x) => x.value, 'value', 123),
        ),
      ),
    );

    test(
      'P -> F, null',
      () => testToField<int, String>(null, frenchLocale, null),
    );

    test(
      'F -> P, null',
      () => testToProperty<int, String>(
        null,
        frenchLocale,
        const ConversionResult(null),
        (e, a) => expect(
          a,
          isA<ConversionResult<int>>().having((x) => x.value, 'value', isNull),
        ),
      ),
    );
  });

  group('StringConverter', () {
    void testToField<P extends Object>(
      P? input,
      Locale locale,
      String? expectedFieldValue,
    ) {
      late final P? actualInput;
      late final Locale actualLocale;
      var isCalled = false;
      final target = StringConverter<P>.fromCallbacks(
        stringify: (v, l) {
          isCalled = true;
          actualInput = v;
          actualLocale = l;
          return expectedFieldValue;
        },
        parse: (v, x, l) {
          fail('parse is called!');
        },
      );

      final actualFieldValue = target.toFieldValue(input, locale);
      expect(actualFieldValue, expectedFieldValue);
      if (input != null) {
        expect(isCalled, isTrue);
        expect(actualInput, input);
        expect(actualLocale, locale);
      } else {
        expect(isCalled, isFalse);
      }
    }

    void testToProperty<P extends Object>(
      String? input,
      Locale locale,
      SomeConversionResult<P> expectedResult,
      void Function(
        SomeConversionResult<P> expected,
        SomeConversionResult<P> actual,
      )
          resultAssertion,
    ) {
      late final String? actualInput;
      late final Locale actualLocale;
      late final dynamic actualProvider;
      var isCalled = false;
      final target = StringConverter<P>.fromCallbacks(
        stringify: (v, l) {
          fail('toFieldValue is called!');
        },
        parse: (v, l, p) {
          actualInput = v;
          actualLocale = l;
          actualProvider = p;
          isCalled = true;
          return expectedResult;
        },
      );

      final actualResult = target.toPropertyValue(input, locale);
      resultAssertion(expectedResult, actualResult);
      if (input?.isNotEmpty ?? false) {
        expect(isCalled, isTrue);
        expect(actualInput, input);
        expect(actualLocale, locale);
        expect(actualProvider, isNotNull);
      } else {
        expect(isCalled, isFalse);
      }
    }

    test(
      'P -> String, non-null',
      () => testToField<int>(123, frenchLocale, '123'),
    );

    test(
      'String -> P, non-null',
      () => testToProperty<int>(
        '123',
        frenchLocale,
        const ConversionResult(123),
        (e, a) => expect(
          a,
          isA<ConversionResult<int>>().having((x) => x.value, 'value', 123),
        ),
      ),
    );

    test(
      'P -> String, null (default: empty string)',
      () => testToField<int>(null, frenchLocale, ''),
    );

    test(
      'String -> P, null (default: null)',
      () => testToProperty<int>(
        null,
        frenchLocale,
        const ConversionResult(123),
        (e, a) => expect(
          a,
          isA<ConversionResult<int>>().having((x) => x.value, 'value', isNull),
        ),
      ),
    );

    test(
      'String -> P, empty (default: null)',
      () => testToProperty<int>(
        '',
        frenchLocale,
        const ConversionResult(123),
        (e, a) => expect(
          a,
          isA<ConversionResult<int>>().having((x) => x.value, 'value', isNull),
        ),
      ),
    );

    test(
      'P -> String, default stringify is toString())',
      () {
        final target = StringConverter<Object>.fromCallbacks(
          parse: (v, l, p) {
            fail('parse is called!');
          },
        );
        final result = target.toFieldValue(Object(), defaultLocale);
        expect(result, Object().toString());
      },
    );

    test(
      'P -> String, null should be defaultString)',
      () {
        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            fail('parse is called!');
          },
          defaultString: 'DEFAULT',
        );
        final result = target.toFieldValue(null, defaultLocale);
        expect(result, 'DEFAULT');
      },
    );

    test(
      'String -> P, null should be defaultValue',
      () {
        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            fail('parse is called!');
          },
          defaultValue: const ConversionResult(123),
        );
        final result = target.toPropertyValue(null, defaultLocale);
        expect(
          result,
          isA<ConversionResult<int>>().having(
            (x) => x.value,
            'value',
            123,
          ),
        );
      },
    );

    test(
      'String -> P, empty should be defaultValue',
      () {
        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            fail('parse is called!');
          },
          defaultValue: const ConversionResult(123),
        );
        final result = target.toPropertyValue('', defaultLocale);
        expect(
          result,
          isA<ConversionResult<int>>().having(
            (x) => x.value,
            'value',
            123,
          ),
        );
      },
    );

    test(
      'String -> P, default parseFailureMessageProvider',
      () {
        const formatException = FormatException('TEST');
        const debugInfo = 'DEBUG INFO';

        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            return FailureResult(p(v, formatException, l), debugInfo);
          },
        );
        const value = 'ABC';
        final result = target.toPropertyValue(value, frenchLocale);
        expect(
          result,
          isA<FailureResult<int>>()
              .having(
                (x) => x.message,
                'message',
                'Value is not a valid int. TEST',
              )
              .having((x) => x.debugInfo, 'debugInfo', debugInfo),
        );
      },
    );

    test(
      'String -> P, custom parseFailureMessageProvider',
      () {
        const message = 'MESSAGE';
        late final String? actualOriginalValue;
        late final FormatException? actualFormatException;
        late final Locale actualLocale;
        // ignore: omit_local_variable_types
        final String Function(String?, FormatException?, Locale)
            // ignore: prefer_function_declarations_over_variables
            parseFailureMessageProvider =
            (originalValue, formatException, locale) {
          actualOriginalValue = originalValue;
          actualFormatException = formatException;
          actualLocale = locale;
          return message;
        };

        const formatException = FormatException('TEST');
        const debugInfo = 'DEBUG INFO';

        late final String Function(String?, FormatException?, Locale)?
            actualParseFailureMessageProvider;
        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            actualParseFailureMessageProvider = p;
            return FailureResult(p(v, formatException, l), debugInfo);
          },
          parseFailureMessageProvider: parseFailureMessageProvider,
        );
        const value = 'ABC';
        final result = target.toPropertyValue(value, frenchLocale);
        expect(
          result,
          isA<FailureResult<int>>()
              .having((x) => x.message, 'message', message)
              .having((x) => x.debugInfo, 'debugInfo', debugInfo),
        );
        expect(actualOriginalValue, value);
        expect(actualFormatException, formatException);
        expect(actualLocale, frenchLocale);
        expect(actualParseFailureMessageProvider, parseFailureMessageProvider);
      },
    );

    void testCopyWith<T extends Object>(
      T? conversionResult,
      StringConverter<T> Function(StringConverter<T>) callCopyWith,
      ConversionResult<T> expectedForNullString,
      String? expectedForNullProperty,
    ) {
      final target = StringConverter<T>.fromCallbacks(
        parse: (v, l, p) {
          return ConversionResult<T>(conversionResult);
        },
      );
      final result = callCopyWith(target);

      expect(identical(target, result), isFalse);
      expect(
        result.toFieldValue(null, defaultLocale),
        expectedForNullProperty,
      );
      expect(
        (result.toPropertyValue(null, defaultLocale) as ConversionResult<T>)
            .value,
        expectedForNullString.value,
      );
    }

    test(
      'copyWith without any arguments -- all are not changed.',
      () => testCopyWith<int>(
        123,
        (t) => t.copyWith(),
        const ConversionResult(null),
        '',
      ),
    );

    test(
      'copyWith with defaultString -- set the value and others are not changed.',
      () => testCopyWith<int>(
        123,
        (t) => t.copyWith(defaultString: 'ABC'),
        const ConversionResult(null),
        'ABC',
      ),
    );

    test(
      'copyWith with defaultValue -- set the value and others are not changed.',
      () => testCopyWith<int>(
        123,
        (t) => t.copyWith(defaultValue: const ConversionResult(12345)),
        const ConversionResult(12345),
        '',
      ),
    );

    test(
      'copyWith with parseFailureMessageProvider -- set the value and others are not changed.',
      () {
        // ignore: prefer_function_declarations_over_variables, omit_local_variable_types
        final String Function(String?, FormatException?, Locale) provider =
            (v, x, l) => 'DUMMY';

        dynamic actualParseFailureMessageProvider;
        final target = StringConverter<int>.fromCallbacks(
          parse: (v, l, p) {
            actualParseFailureMessageProvider = p;
            return ConversionResult(v == null ? null : int.parse(v));
          },
        );
        final result = target.copyWith(parseFailureMessageProvider: provider);

        expect(identical(target, result), isFalse);
        result.toPropertyValue('123', defaultLocale);
        expect(actualParseFailureMessageProvider, same(provider));
      },
    );
  });

  group('IntStringConverter', () {
    test(
      'int -> String',
      () => testPropertyToFieldSuccess<int, String>(
        () => intStringConverter,
        1234,
        '1234',
        defaultLocale,
      ),
    );

    test(
      'int <- String',
      () => testFieldToPropertySuccess<int, String>(
        () => intStringConverter,
        '1234',
        1234,
        defaultLocale,
      ),
    );

    test(
      'null -> empty',
      () => testPropertyToFieldSuccess<int, String>(
        () => intStringConverter,
        null,
        '',
        defaultLocale,
      ),
    );

    test(
      'null <- empty',
      () => testFieldToPropertySuccess<int, String>(
        () => intStringConverter,
        '',
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<int, String>(
        () => intStringConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'invalid input',
      () => testFieldToPropertyFailure<int, String>(
        () => intStringConverter,
        'a',
        defaultLocale,
        message: 'Value is not a valid int.',
        debugInfo: "Value 'a' cannot be parsed to int.",
      ),
    );
  });

  group('DoubleStringConverter', () {
    test(
      'double -> String',
      () => testPropertyToFieldSuccess<double, String>(
        () => doubleStringConverter,
        1234.5,
        '1234.5',
        defaultLocale,
      ),
    );

    test(
      'double <- String',
      () => testFieldToPropertySuccess<double, String>(
        () => doubleStringConverter,
        '1234.5',
        1234.5,
        defaultLocale,
      ),
    );

    test(
      'null -> empty',
      () => testPropertyToFieldSuccess<double, String>(
        () => doubleStringConverter,
        null,
        '',
        defaultLocale,
      ),
    );

    test(
      'null <- empty',
      () => testFieldToPropertySuccess<double, String>(
        () => doubleStringConverter,
        '',
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<double, String>(
        () => doubleStringConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'invalid input',
      () => testFieldToPropertyFailure<double, String>(
        () => doubleStringConverter,
        'a',
        defaultLocale,
        message: 'Value is not a valid double.',
        debugInfo: "Value 'a' cannot be parsed to double.",
      ),
    );
  });

  group('BigIntStringConverter', () {
    test(
      'BigInt -> String',
      () => testPropertyToFieldSuccess<BigInt, String>(
        () => bigIntStringConverter,
        BigInt.from(123),
        '123',
        defaultLocale,
      ),
    );

    test(
      'BigInt <- String',
      () => testFieldToPropertySuccess<BigInt, String>(
        () => bigIntStringConverter,
        '123',
        BigInt.from(123),
        defaultLocale,
      ),
    );

    test(
      'null -> empty',
      () => testPropertyToFieldSuccess<BigInt, String>(
        () => bigIntStringConverter,
        null,
        '',
        defaultLocale,
      ),
    );

    test(
      'null <- empty',
      () => testFieldToPropertySuccess<BigInt, String>(
        () => bigIntStringConverter,
        '',
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<BigInt, String>(
        () => bigIntStringConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'invalid input',
      () => testFieldToPropertyFailure<BigInt, String>(
        () => bigIntStringConverter,
        'a',
        defaultLocale,
        message: 'Value is not a valid BigInt.',
        debugInfo: "Value 'a' cannot be parsed to BigInt.",
      ),
    );
  });

  group('UriStringConverter', () {
    test(
      'Uri -> String',
      () => testPropertyToFieldSuccess<Uri, String>(
        () => uriStringConverter,
        Uri.parse('http://example.com'),
        'http://example.com',
        defaultLocale,
      ),
    );

    test(
      'Uri <- String',
      () => testFieldToPropertySuccess<Uri, String>(
        () => uriStringConverter,
        'http://example.com',
        Uri.parse('http://example.com'),
        defaultLocale,
      ),
    );

    test(
      'null -> empty',
      () => testPropertyToFieldSuccess<Uri, String>(
        () => uriStringConverter,
        null,
        '',
        defaultLocale,
      ),
    );

    test(
      'null <- empty',
      () => testFieldToPropertySuccess<Uri, String>(
        () => uriStringConverter,
        '',
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<Uri, String>(
        () => uriStringConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'invalid input',
      () => testFieldToPropertyFailure<Uri, String>(
        () => uriStringConverter,
        ':',
        defaultLocale,
        message: 'Value is not a valid Uri.',
        debugInfo: "Value ':' cannot be parsed to Uri.",
      ),
    );
  });

  group('DateTimeStringConverter', () {
    test(
      'DateTime -> String',
      () => testPropertyToFieldSuccess<DateTime, String>(
        () => dateTimeStringConverter,
        DateTime(2012, 12, 30, 12, 34, 56, 789),
        '2012-12-30 12:34:56.789',
        defaultLocale,
      ),
    );

    test(
      'DateTime <- String',
      () => testFieldToPropertySuccess<DateTime, String>(
        () => dateTimeStringConverter,
        '2012-12-30 12:34:56.789',
        DateTime(2012, 12, 30, 12, 34, 56, 789),
        defaultLocale,
      ),
    );

    test(
      'null -> empty',
      () => testPropertyToFieldSuccess<DateTime, String>(
        () => dateTimeStringConverter,
        null,
        '',
        defaultLocale,
      ),
    );

    test(
      'null <- empty',
      () => testFieldToPropertySuccess<DateTime, String>(
        () => dateTimeStringConverter,
        '',
        null,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<DateTime, String>(
        () => dateTimeStringConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'invalid input',
      () => testFieldToPropertyFailure<DateTime, String>(
        () => dateTimeStringConverter,
        'a',
        defaultLocale,
        message: 'Value is not a valid DateTime.',
        debugInfo: "Value 'a' cannot be parsed to DateTime.",
      ),
    );
  });

  group('IntDoubleConverter', () {
    test(
      'int -> double',
      () => testPropertyToFieldSuccess<int, double>(
        () => intDoubleConverter,
        1234,
        1234,
        defaultLocale,
      ),
    );

    test(
      'int <- double',
      () => testFieldToPropertySuccess<int, double>(
        () => intDoubleConverter,
        1234.5,
        1234,
        defaultLocale,
      ),
    );

    test(
      'null -> null',
      () => testPropertyToFieldSuccess<int, double>(
        () => intDoubleConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'zero <- zero',
      () => testFieldToPropertySuccess<int, double>(
        () => intDoubleConverter,
        0,
        0,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<int, double>(
        () => intDoubleConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'int.max -> double',
      () => testPropertyToFieldSuccess<int, double>(
        () => intDoubleConverter,
        0x7FFFFFFFFFFFFFFF,
        0x7FFFFFFFFFFFFFFF * 1.0,
        defaultLocale,
      ),
    );

    test(
      'int.min -> double',
      () => testPropertyToFieldSuccess<int, double>(
        () => intDoubleConverter,
        0x8000000000000000,
        0x8000000000000000 * 1.0,
        defaultLocale,
      ),
    );

    test(
      'int <- double(int.max)',
      () => testFieldToPropertySuccess<int, double>(
        () => intDoubleConverter,
        0x7FFFFFFFFFFFFFFF * 1.0,
        0x7FFFFFFFFFFFFFFF,
        defaultLocale,
      ),
    );

    test(
      'int <- double(int.max)',
      () => testFieldToPropertySuccess<int, double>(
        () => intDoubleConverter,
        0x8000000000000000 * 1.0,
        0x8000000000000000,
        defaultLocale,
      ),
    );

    test(
      'invalid input (too large)',
      () => testFieldToPropertyFailure<int, double>(
        () => intDoubleConverter,
        9.22337203685479E+18,
        defaultLocale,
        message: 'Value is too large.',
        debugInfo:
            'Value ${9.22337203685479E+18} is too large for 64bit integer.',
      ),
    );

    test(
      'invalid input (too small)',
      () => testFieldToPropertyFailure<int, double>(
        () => intDoubleConverter,
        -9.22337203685479E+18,
        defaultLocale,
        message: 'Value is too small.',
        debugInfo:
            'Value ${-9.22337203685479E+18} is too small for 64bit integer.',
      ),
    );
  });

  group('BigIntDoubleConverter', () {
    test(
      'int -> double',
      () => testPropertyToFieldSuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        BigInt.from(1234),
        1234,
        defaultLocale,
      ),
    );

    test(
      'int <- double',
      () => testFieldToPropertySuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        1234.5,
        BigInt.from(1234),
        defaultLocale,
      ),
    );

    test(
      'null -> null',
      () => testPropertyToFieldSuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'zero <- zero',
      () => testFieldToPropertySuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        0,
        BigInt.zero,
        defaultLocale,
      ),
    );

    test(
      'null <- null',
      () => testFieldToPropertySuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        null,
        null,
        defaultLocale,
      ),
    );

    test(
      'double.max -> double',
      () => testPropertyToFieldSuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        BigInt.from(double.maxFinite),
        // NOTE: double.maxFinite is integral value.
        double.maxFinite,
        defaultLocale,
      ),
    );

    test(
      'double.min -> double',
      () => testPropertyToFieldSuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        BigInt.from(double.maxFinite * -1),
        // NOTE: double.maxFinite is integral value.
        double.maxFinite * -1,
        defaultLocale,
      ),
    );

    test(
      'double.max + 1 -> double',
      () => testPropertyToFieldFailure<BigInt, double, ArgumentError>(
        () => bigIntDoubleConverter,
        BigInt.from(double.maxFinite) + BigInt.one,
        defaultLocale,
        (e) => e
            .having((x) => x.name, 'name', 'value')
            .having(
              (x) => x.invalidValue,
              'invalidValue',
              BigInt.from(double.maxFinite) + BigInt.one,
            )
            .having(
              (x) => x.message,
              'message',
              'Value ${BigInt.from(double.maxFinite) + BigInt.one} is too large for double.',
            ),
      ),
    );

    test(
      'double.min - 1 -> double',
      () => testPropertyToFieldFailure<BigInt, double, ArgumentError>(
        () => bigIntDoubleConverter,
        BigInt.from(double.maxFinite * -1) - BigInt.one,
        defaultLocale,
        (e) => e
            .having((x) => x.name, 'name', 'value')
            .having(
              (x) => x.invalidValue,
              'invalidValue',
              BigInt.from(double.maxFinite * -1) - BigInt.one,
            )
            .having(
              (x) => x.message,
              'message',
              'Value ${BigInt.from(double.maxFinite * -1) - BigInt.one} is too small for double.',
            ),
      ),
    );

    test(
      'BigInt <- double.max',
      () => testFieldToPropertySuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        double.maxFinite,
        BigInt.from(double.maxFinite),
        defaultLocale,
      ),
    );

    test(
      'BigInt <- double.min',
      () => testFieldToPropertySuccess<BigInt, double>(
        () => bigIntDoubleConverter,
        double.maxFinite * -1,
        BigInt.from(double.maxFinite * -1),
        defaultLocale,
      ),
    );
  });
}
