// See LICENCE file in the root.

import '../form_companion_presenter.dart';

// TODO(yfakariya): test, clean-up, push

/// A [ValueConverter] between [int] property value type and
/// [double] form field value type.
final intDoubleConverter = ValueConverter<int, double>.fromCallbacks(
  toFieldValue: (v, l) => v?.toDouble(),
  toPropertyValue: (v, l) => ConversionResult<int>(v?.toInt()),
);

/// A [ValueConverter] between [int] property value type and
/// [double] form field value type.
final bigIntDoubleConverter = ValueConverter<BigInt, double>.fromCallbacks(
  toFieldValue: (v, l) => v?.toDouble(),
  toPropertyValue: (v, l) =>
      ConversionResult<BigInt>(v == null ? null : BigInt.from(v)),
);
