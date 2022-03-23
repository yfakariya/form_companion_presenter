// See LICENCE file in the root.

import 'dart:ui';

import 'package:meta/meta.dart';

// TODO(yfakariya): test, clean-up, push

/// A function which converts form field input value [F] to property value [P].
///
/// [Locale] can be used to localize value for form field.
typedef FieldToPropertyConverter<P extends Object, F extends Object>
    = SomeConversionResult<P> Function(F?, Locale);

/// A function which converts property value [P] to form field initial value [F].
///
/// [Locale] can be used to parse value from form field which might be localized.
typedef PropertyToFieldConverter<P extends Object, F extends Object> = F?
    Function(P?, Locale);

/// Defines value converter between `PropertyDescriptor<P>` value
/// and `FormField<F>` value.
///
/// [P] is type of property value and [F] is form field value.
///
/// Typically, you can implement `StringConverter` or just use one of the
/// predefined string converters instead of implementing this class directly
/// for text field based form fields
abstract class ValueConverter<P extends Object, F extends Object> {
  /// Initializes a new [ValueConverter] instance.
  ValueConverter();

  /// Creates a new [ValueConverter] from specified callbacks.
  factory ValueConverter.fromCallbacks({
    required PropertyToFieldConverter<P, F> toFieldValue,
    required FieldToPropertyConverter<P, F> toPropertyValue,
  }) =>
      _CallbackValueConverter(
        toFieldValue,
        toPropertyValue,
      );

  /// Converts the property [value] to form field's value.
  ///
  /// `null` input means the property value is not supplied at all,
  /// and `null` output indicates that there are no reasonable initial values
  /// for the form field.
  ///
  /// This method should not be failed.
  /// If so, the method should throw error.
  ///
  /// [locale] can be used to localize value for form field.
  F? toFieldValue(P? value, Locale locale);

  /// Converts the form field saved [value] to property's value.
  ///
  /// [locale] can be used to parse value from form field which might be localized.
  SomeConversionResult<P> toPropertyValue(F? value, Locale locale);
}

/// Internal.
///
/// Default [ValueConverter] for `PropertyDescriptor`.
/// This class just do with simple type cast, so it may throw error in many cases,
/// but it is OK because many users do not require conversion in the first place.
@sealed
@internal
class DefaultValueConverter<P extends Object, F extends Object>
    implements ValueConverter<P, F> {
  @override
  F toFieldValue(P? value, Locale locale) {
    if (value == null) {
      throw StateError('Initial value is not supplied.');
    }

    return value as F;
  }

  @override
  SomeConversionResult<P> toPropertyValue(F? value, Locale locale) {
    if (value is P) {
      return ConversionResult(value);
    } else {
      return FailureResult(
        '${value.runtimeType} is not compatible with $P.',
      );
    }
  }
}

/// Callback based [ValueConverter] for user convinience.
@sealed
class _CallbackValueConverter<P extends Object, F extends Object>
    extends ValueConverter<P, F> {
  final PropertyToFieldConverter<P, F> _toFieldValue;
  final FieldToPropertyConverter<P, F> _toPropertyValue;

  _CallbackValueConverter(
    this._toFieldValue,
    this._toPropertyValue,
  );

  @override
  F? toFieldValue(P? value, Locale locale) => _toFieldValue(value, locale);

  @override
  SomeConversionResult<P> toPropertyValue(F? value, Locale locale) =>
      _toPropertyValue(value, locale);
}

/// Represents a result of conversion from form field input value
/// to property value.
///
/// In many cases, user input cannot be converted to typed value
/// even if the value has been passed the validator chain.
/// This pattern enableds conversion implementer to return non-exceptional
/// failure from errors and exceptions which can be caused unexpectedly.
///
/// Clients may not extend, implement or mix-in this class directly.
abstract class SomeConversionResult<T extends Object> {
  const SomeConversionResult._();
}

/// Represents successful conversion result.
@sealed
class ConversionResult<T extends Object> implements SomeConversionResult<T> {
  /// Converted property value. Note that this value may be `null` if it is
  /// valid property value for some form field input value such as empty [String].
  final T? value;

  /// Initializes a new [ConversionResult] instance.
  ConversionResult(this.value);
}

/// Represents any conversion failure.
class FailureResult<T extends Object> implements SomeConversionResult<T> {
  /// User-friendly, localized, secure message which describes the failure.
  final String message;

  /// Detailed information for debugging.
  final String debugInfo;

  /// Initializes a new [FailureResult] instance.
  ///
  /// Note that [message] should be shown for users, so it should be user-friendly,
  /// localized, and secure.
  ///
  /// And [debugInfo] should be recorded or sent to failure reporting system,
  /// so it should be technically precise, detailed, potentially unsecure but
  /// should be compliant with data privacy conformance between app provider and users.
  /// In addition, [debugInfo] should not be localized to improve searchability
  /// in www.
  const FailureResult(
    this.message, [
    String? debugInfo,
  ]) : debugInfo = debugInfo ?? message;

  @override
  String toString() => message;
}
