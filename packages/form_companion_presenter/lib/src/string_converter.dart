// See LICENCE file in the root.

import 'dart:ui';

import 'package:meta/meta.dart';

import 'value_converter.dart';

// TODO(yfakariya): test, clean-up, push

/// A function which converts [String] to property value [P].
///
/// [Locale] can be used to localize for form field.
typedef Parser<P extends Object> = FieldToPropertyConverter<P, String>;

/// A function which returns localized, user friendly message for
/// `parse` or `tryParse` failure from specified input [String] and [Locale].
///
/// [Locale] can be used to parse value from form field which might be localized.
typedef ParseFailureMessageProvider = String Function(
  String?,
  FormatException?,
  Locale,
);

/// A function which converts property value [P] to [String].
///
/// [Locale] can be used to localize value for form field.
typedef Stringifier<P extends Object> = PropertyToFieldConverter<P, String>;

typedef _CustomizableParser<P extends Object> = SomeConversionResult<P>
    Function(String, Locale, ParseFailureMessageProvider);

/// Basic implementation of [ValueConverter] for string typed `FormField`
/// such as text field based form field.
abstract class StringConverter<P extends Object>
    extends ValueConverter<P, String> {
  /// Initializes a new [StringConverter] instance.
  StringConverter();

  /// Creates a new [StringConverter] from specified callbacks.
  ///
  /// The returned converter convert a property value as follows:
  ///
  /// 1. If the value is `null`, then [defaultString] is used.
  /// 2. Otherwise, calls [stringify] to convert the [P] value to [String] value.
  ///
  /// And it convert a saved form field value as follows:
  ///
  /// 1. If the value is empty, then [defaultValue] is used.
  /// 2. Otherwise, calls [parse] to convert the [String] value to [P] value.
  factory StringConverter.fromCallbacks({
    required Stringifier<P> stringify,
    String? defaultString,
    required Parser<P> parse,
    SomeConversionResult<P>? defaultValue,
  }) =>
      _CallbackStringConverter<P>(
        stringify: stringify,
        defaultString: defaultString,
        parse: parse,
        defaultValue: defaultValue,
      );

  @override
  String? toFieldValue(P? value, Locale locale) => value?.toString();
}

/// Provides common implementation between [_CallbackStringConverter] and
/// [ParseStringConverter].
abstract class _CallbackStringConverterBase<P extends Object>
    extends StringConverter<P> {
  final String defaultString;
  final SomeConversionResult<P> defaultValue;
  final Stringifier<P> stringify;

  _CallbackStringConverterBase._({
    required Stringifier<P>? stringify,
    String? defaultString,
    SomeConversionResult<P>? defaultValue,
  })  : stringify = (stringify ?? (v, _) => v.toString()),
        defaultString = defaultString ?? '',
        defaultValue = defaultValue ?? ConversionResult(null);

  @override
  SomeConversionResult<P> toPropertyValue(String? value, Locale locale) =>
      value == null
          ? defaultValue
          : value.isEmpty
              ? defaultValue
              : parseNonEmptyValue(value, locale);

  SomeConversionResult<P> parseNonEmptyValue(String value, Locale locale);

  @override
  String? toFieldValue(P? value, Locale locale) =>
      value == null ? defaultString : stringify(value, locale);
}

/// Non public callbacked based converter.
@sealed
class _CallbackStringConverter<P extends Object>
    extends _CallbackStringConverterBase<P> implements StringConverter<P> {
  final Parser<P> _parse;

  _CallbackStringConverter({
    required Stringifier<P>? stringify,
    required String? defaultString,
    required Parser<P> parse,
    required SomeConversionResult<P>? defaultValue,
  })  : _parse = parse,
        super._(
          defaultValue: defaultValue,
          stringify: stringify,
          defaultString: defaultString,
        );

  @override
  SomeConversionResult<P> parseNonEmptyValue(String value, Locale locale) =>
      _parse(value, locale);
}

/// [StringConverter] which delegates convertion to `tryParse` and [toString].
///
/// This class cannot be instantiated.
/// To implement own [ParseStringConverter],
/// uses [StringConverter.fromCallbacks] instead.
@sealed
class ParseStringConverter<P extends Object>
    extends _CallbackStringConverterBase<P> implements StringConverter<P> {
  final _CustomizableParser<P> _parse;
  final ParseFailureMessageProvider _parseFailureMessageProvider;

  ParseStringConverter._({
    required _CustomizableParser<P> parse,
    SomeConversionResult<P>? defaultValue,
    ParseFailureMessageProvider? parseFailureMessageProvider,
    Stringifier<P>? stringify,
    String defaultString = '',
  })  : _parse = parse,
        _parseFailureMessageProvider =
            parseFailureMessageProvider ?? _provideDefaultFailureMessage<P>,
        super._(
          defaultValue: defaultValue,
          stringify: stringify,
          defaultString: defaultString,
        );

  @override
  SomeConversionResult<P> parseNonEmptyValue(String value, Locale locale) =>
      _parse(value, locale, _parseFailureMessageProvider);

  /// Creates a new [ParseStringConverter] with specified properties.
  ///
  /// Primarily, this method will be used to customize parse error message
  /// via [parseFailureMessageProvider]. This callback takes input [String] and
  /// returns user friendly and secure message.
  ///
  /// See [StringConverter.fromCallbacks] for [defaultValue] and [defaultString].
  ParseStringConverter<P> copyWith({
    ParseFailureMessageProvider? parseFailureMessageProvider,
    SomeConversionResult<P>? defaultValue,
    String? defaultString,
  }) =>
      ParseStringConverter._(
        parse: _parse,
        parseFailureMessageProvider:
            parseFailureMessageProvider ?? _parseFailureMessageProvider,
        stringify: stringify,
        defaultValue: defaultValue ?? this.defaultValue,
        defaultString: defaultString ?? this.defaultString,
      );
}

String _provideDefaultFailureMessage<P>(
  String? value,
  FormatException? exception,
  Locale locale,
) =>
    (exception == null || exception.message.isEmpty)
        ? 'Value is not a valid $P.'
        : 'Value is not a valid $P. ${exception.message}';

SomeConversionResult<P> _fromTryParseResult<P extends Object>(
  P? value,
  String originalValue,
  Locale locale,
  ParseFailureMessageProvider failureMessageProvider,
) =>
    value == null
        ? FailureResult<P>(
            failureMessageProvider(originalValue, null, locale),
            "Value '$originalValue' is not a valid $P.",
          )
        : ConversionResult<P>(value);

/// [ParseStringConverter] which uses [int.tryParse].
final ParseStringConverter<int> intStringConverter =
    ParseStringConverter<int>._(
  parse: (v, x, f) => _fromTryParseResult(int.tryParse(v), v, x, f),
);

/// [ParseStringConverter] which uses [double.tryParse].
final ParseStringConverter<double> doubleStringConverter =
    ParseStringConverter<double>._(
  parse: (v, x, f) => _fromTryParseResult(double.tryParse(v), v, x, f),
);

/// [ParseStringConverter] which uses [BigInt.tryParse].
final ParseStringConverter<BigInt> bigIntStringConverter =
    ParseStringConverter<BigInt>._(
  parse: (v, x, f) => _fromTryParseResult(BigInt.tryParse(v), v, x, f),
);

/// [ParseStringConverter] which uses [Uri.tryParse].
final ParseStringConverter<Uri> uriStringConverter =
    ParseStringConverter<Uri>._(
  parse: (v, x, f) => _fromTryParseResult(Uri.tryParse(v), v, x, f),
);

/// [ParseStringConverter] which uses [DateTime.tryParse].
final ParseStringConverter<DateTime> dateTimeStringConverter =
    ParseStringConverter<DateTime>._(
  parse: (v, x, f) => _fromTryParseResult(DateTime.tryParse(v), v, x, f),
);
