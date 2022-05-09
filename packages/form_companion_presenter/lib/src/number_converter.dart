// See LICENCE file in the root.

import '../form_companion_presenter.dart';

const _maxInt = 0x7FFFFFFFFFFFFFFF;
const _minInt = 0x8000000000000000;

/// A [ValueConverter] between [int] property value type and
/// [double] form field value type.
final intDoubleConverter = ValueConverter<int, double>.fromCallbacks(
  toFieldValue: (v, l) => v?.toDouble(),
  toPropertyValue: (v, l) {
    if (v != null) {
      if (v < _minInt) {
        return FailureResult(
          'Value is too small.',
          'Value $v is too small for 64bit integer.',
        );
      } else if (v > _maxInt) {
        return FailureResult(
          'Value is too large.',
          'Value $v is too large for 64bit integer.',
        );
      }
    }

    return ConversionResult<int>(v?.toInt());
  },
);

final _minDouble = BigInt.from(double.maxFinite * -1);
final _maxDouble = BigInt.from(double.maxFinite);

/// A [ValueConverter] between [int] property value type and
/// [double] form field value type.
final bigIntDoubleConverter = ValueConverter<BigInt, double>.fromCallbacks(
  toFieldValue: (v, l) {
    if (v != null) {
      if (v < _minDouble) {
        throw ArgumentError.value(
          v,
          'value',
          'Value $v is too small for double.',
        );
      } else if (v > _maxDouble) {
        throw ArgumentError.value(
          v,
          'value',
          'Value $v is too large for double.',
        );
      }
    }

    return v?.toDouble();
  },
  toPropertyValue: (v, l) =>
      ConversionResult<BigInt>(v == null ? null : BigInt.from(v)),
);
