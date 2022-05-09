// See LICENCE file in the root.

import 'dart:ui';

import 'package:meta/meta.dart';

import 'value_converter.dart';

/// A function which returns localized, user friendly message for
/// `parse` or `tryParse` failure from specified input [String] and [Locale].
///
/// [Locale] can be used to parse value from form field which might be localized.
typedef ParseFailureMessageProvider = String Function(
  String?,
  FormatException?,
  Locale,
);

/// A function which converts [String] to property value [P].
///
/// [Locale] can be used to localize for form field.
typedef Parser<P extends Object> = SomeConversionResult<P> Function(
  String?,
  Locale,
  ParseFailureMessageProvider,
);

/// A function which converts property value [P] to [String].
///
/// [Locale] can be used to localize value for form field.
typedef Stringifier<P extends Object> = PropertyToFieldConverter<P, String>;

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
  ///   * Note that default implementation which calls [toString] of [P], will
  ///     be used when [stringify] is `null`.
  ///
  /// And it convert a saved form field value as follows:
  ///
  /// 1. If the value is empty, then [defaultValue] is used.
  /// 2. Otherwise, calls [parse] to convert the [String] value to [P] value.
  factory StringConverter.fromCallbacks({
    required Parser<P> parse,
    SomeConversionResult<P>? defaultValue,
    ParseFailureMessageProvider? parseFailureMessageProvider,
    Stringifier<P>? stringify,
    String? defaultString,
  }) =>
      _CallbackStringConverter<P>(
        parse: parse,
        defaultValue: defaultValue,
        parseFailureMessageProvider: parseFailureMessageProvider,
        stringify: stringify,
        defaultString: defaultString,
      );

  /// Creates a new [StringConverter] with specified properties.
  ///
  /// Primarily, this method will be used to customize parse error message
  /// via [parseFailureMessageProvider]. This callback takes input [String] and
  /// returns user friendly and secure message.
  ///
  /// See [StringConverter.fromCallbacks] for [defaultValue] and [defaultString].
  StringConverter<P> copyWith({
    ParseFailureMessageProvider? parseFailureMessageProvider,
    SomeConversionResult<P>? defaultValue,
    String? defaultString,
  });
}

/// Non public callbacked based converter.
@sealed
class _CallbackStringConverter<P extends Object> extends StringConverter<P> {
  final Parser<P> _parse;
  final ParseFailureMessageProvider _parseFailureMessageProvider;
  final String _defaultString;
  final SomeConversionResult<P> _defaultValue;
  final Stringifier<P> _stringify;

  _CallbackStringConverter({
    required Parser<P> parse,
    ParseFailureMessageProvider? parseFailureMessageProvider,
    SomeConversionResult<P>? defaultValue,
    Stringifier<P>? stringify,
    String? defaultString,
  })  : _stringify = (stringify ?? (v, _) => v.toString()),
        _defaultString = defaultString ?? '',
        _parse = parse,
        _parseFailureMessageProvider =
            parseFailureMessageProvider ?? _provideDefaultFailureMessage<P>,
        _defaultValue = defaultValue ?? const ConversionResult(null);

  @override
  SomeConversionResult<P> toPropertyValue(String? value, Locale locale) =>
      value == null
          ? _defaultValue
          : value.isEmpty
              ? _defaultValue
              : _parse(value, locale, _parseFailureMessageProvider);

  @override
  String? toFieldValue(P? value, Locale locale) =>
      value == null ? _defaultString : _stringify(value, locale);

  @override
  StringConverter<P> copyWith({
    ParseFailureMessageProvider? parseFailureMessageProvider,
    SomeConversionResult<P>? defaultValue,
    String? defaultString,
  }) =>
      _CallbackStringConverter<P>(
        parse: _parse,
        parseFailureMessageProvider:
            parseFailureMessageProvider ?? _parseFailureMessageProvider,
        stringify: _stringify,
        defaultValue: defaultValue ?? _defaultValue,
        defaultString: defaultString ?? _defaultString,
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
  String? originalValue,
  Locale locale,
  ParseFailureMessageProvider failureMessageProvider,
) =>
    value != null
        ? ConversionResult<P>(value)
        : FailureResult<P>(
            failureMessageProvider(originalValue, null, locale),
            originalValue != null
                ? "Value '$originalValue' cannot be parsed to $P."
                : 'Null value cannot be parsed to $P.',
          );

// TODO(yfakariya): L10N & digit-grouping example

/// [StringConverter] which uses [int.tryParse].
final StringConverter<int> intStringConverter = _CallbackStringConverter<int>(
  parse: (v, x, f) =>
      _fromTryParseResult(v == null ? null : int.tryParse(v), v, x, f),
);

/// [StringConverter] which uses [double.tryParse].
final StringConverter<double> doubleStringConverter =
    _CallbackStringConverter<double>(
  parse: (v, x, f) =>
      _fromTryParseResult(v == null ? null : double.tryParse(v), v, x, f),
);

/// [StringConverter] which uses [BigInt.tryParse].
final StringConverter<BigInt> bigIntStringConverter =
    _CallbackStringConverter<BigInt>(
  parse: (v, x, f) =>
      _fromTryParseResult(v == null ? null : BigInt.tryParse(v), v, x, f),
);

/// [StringConverter] which uses [Uri.tryParse].
final StringConverter<Uri> uriStringConverter = _CallbackStringConverter<Uri>(
  parse: (v, x, f) =>
      _fromTryParseResult(v == null ? null : Uri.tryParse(v), v, x, f),
);

/// [StringConverter] which uses [DateTime.tryParse].
final StringConverter<DateTime> dateTimeStringConverter =
    _CallbackStringConverter<DateTime>(
  parse: (v, x, f) =>
      _fromTryParseResult(v == null ? null : DateTime.tryParse(v), v, x, f),
);
