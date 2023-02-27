// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Function which creates appropriate [RestorableValue] subtype for [F].
///
/// Note that values of [RestorableValue] are always nullable because of
/// [PropertyDescriptor]'s design.
typedef RestorableValueFactory<F extends Object> = RestorableValue<F?>
    Function();

/// A [RestorableValueFactory] for [String].
final RestorableValueFactory<String> stringRestorableValueFactory =
    () => RestorableStringN(null);

/// A [RestorableValueFactory] for [int].
final RestorableValueFactory<int> intRestorableValueFactory =
    () => RestorableIntN(null);

/// A [RestorableValueFactory] for [double].
final RestorableValueFactory<double> doubleRestorableValueFactory =
    () => RestorableDoubleN(null);

/// A [RestorableValueFactory] for [bool].
final RestorableValueFactory<bool> boolRestorableValueFactory =
    () => RestorableBoolN(null);

/// A [RestorableValueFactory] for [BigInt].
final RestorableValueFactory<BigInt> bigIntRestorableValueFactory =
    () => _RestorableBigIntN(null);

/// Creates a new [RestorableValueFactory] for [Enum].
///
/// [values] are required to serialize/deserialize restoration state.
/// It should be supplied with `values` static properties of enums.
RestorableValueFactory<E> enumRestorableValueFactory<E extends Enum>(
  Iterable<E> values,
) =>
    () => RestorableEnumN<E>(null, values: values);

/// Creates a new [RestorableValueFactory] for [List] of [Enum].
///
/// [values] are required to serialize/deserialize restoration state.
/// It should be supplied with `values` static properties of enums.
RestorableValueFactory<List<E>> enumListRestorableValueFactory<E extends Enum>(
  Iterable<E> values,
) =>
    () => _RestorableEnumList<E>(null, values: values);

/// A [RestorableValueFactory] for [DateTime].
final RestorableValueFactory<DateTime> dateTimeRestorableValueFactory =
    () => RestorableDateTimeN(null);

/// A [RestorableValueFactory] for [DateTimeRange].
final RestorableValueFactory<DateTimeRange>
    dateTimeRangeRestorableValueFactory = () => _RestorableDateTimeRangeN(null);

/// A [RestorableValueFactory] for [RangeValues].
final RestorableValueFactory<RangeValues> rangeValuesRestorableValueFactory =
    () => _RestorableRangeValuesN(null);

class _RestorableBigIntN extends RestorableValue<BigInt?> {
  final BigInt? _defaultValue;

  _RestorableBigIntN(this._defaultValue);

  @override
  BigInt? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(BigInt? oldValue) {
    notifyListeners();
  }

  @override
  BigInt? fromPrimitives(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is String) {
      return BigInt.parse(data);
    }
    return _defaultValue;
  }

  @override
  Object? toPrimitives() => value?.toString();
}

class _RestorableEnumList<T extends Enum> extends RestorableValue<List<T>?> {
  final List<T>? _defaultValue;
  final Set<T> values;

  _RestorableEnumList(
    List<T>? defaultValue, {
    required Iterable<T> values,
  })  : assert(
          defaultValue == null || defaultValue.every((e) => values.contains(e)),
          'Default value $defaultValue not found in $T values: $values', // coverage:ignore-line
        ),
        _defaultValue = defaultValue,
        values = values.toSet();

  @override
  List<T>? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(List<T>? oldValue) {
    notifyListeners();
  }

  T _verifyEnumValue(T value) {
    assert(
      values.contains(value),
      'Attempted to set an unknown enum value "$value" '
      'that is not in the valid set of enum values for the $T type: '
      '${values.map<String>((value) => value.name).toSet()}',
    );

    return value;
  }

  T _mapEnumValue(String stringValue) {
    for (final enumValue in values) {
      if (enumValue.name == stringValue) {
        return enumValue;
      }
    }

    throw FlutterError(
      'Attempted to restore an unknown enum value "$stringValue" '
      'that is not in the valid set of enum values for the $T type: '
      '${values.map<String>((value) => value.name).toSet()}',
    );
  }

  @override
  void set value(List<T>? value) {
    if (value != null) {
      value.forEach(_verifyEnumValue);
    }
    super.value = value;
  }

  @override
  List<T>? fromPrimitives(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is List<String>) {
      return data.map(_mapEnumValue).toList();
    }
    if (data is List) {
      return data.cast<String>().map(_mapEnumValue).toList();
    }
    return _defaultValue;
  }

  @override
  Object? toPrimitives() => value?.map((e) => e.name).toList();
}

class _RestorableDateTimeRangeN extends RestorableValue<DateTimeRange?> {
  final DateTimeRange? _defaultValue;

  _RestorableDateTimeRangeN(this._defaultValue);

  @override
  DateTimeRange? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(DateTimeRange? oldValue) {
    notifyListeners();
  }

  @override
  DateTimeRange? fromPrimitives(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is List<int> && data.length == 2) {
      return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(data[0]),
        end: DateTime.fromMillisecondsSinceEpoch(data[1]),
      );
    }
    if (data is List && data.length == 2) {
      return DateTimeRange(
        start: DateTime.fromMillisecondsSinceEpoch(data[0] as int),
        end: DateTime.fromMillisecondsSinceEpoch(data[1] as int),
      );
    }
    return _defaultValue;
  }

  @override
  Object? toPrimitives() => value == null
      ? null
      : [
          value!.start.millisecondsSinceEpoch,
          value!.end.millisecondsSinceEpoch,
        ];
}

class _RestorableRangeValuesN extends RestorableValue<RangeValues?> {
  final RangeValues? _defaultValue;

  _RestorableRangeValuesN(this._defaultValue);

  @override
  RangeValues? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(RangeValues? oldValue) {
    notifyListeners();
  }

  @override
  RangeValues? fromPrimitives(Object? data) {
    if (data == null) {
      return null;
    }
    if (data is List<double> && data.length == 2) {
      return RangeValues(data[0], data[1]);
    }
    if (data is List && data.length == 2) {
      return RangeValues(data[0] as double, data[1] as double);
    }
    return _defaultValue;
  }

  @override
  Object? toPrimitives() => value == null ? null : [value!.start, value!.end];
}

/// Internal extensions of [PropertyDescriptor]
/// for [FormPropertiesRestorationScope].
@internal
extension PropertyDescriptorRestorationExtension<P extends Object,
    F extends Object> on PropertyDescriptor<P, F> {
  /// Gets a value which is
  bool get isRestorable =>
      valueTraits.canRestoreState && _restorableFieldValueFactory != null;

  /// Gets a [RestorableFieldValues] to implement restoration.
  RestorableFieldValues<F>? getRestorableProperty() {
    // Always create new [RestorableFieldValues] here because this method is
    // called multiply in widget-tree rebuild, but each RestorableProperties
    // record whether they are registered to RestorationManager or not,
    // so caching RestorableFieldValues causes assertion error.
    final newValue = _createRestorableFieldValues();
    _restorableFieldValue = newValue;
    return newValue;
  }
}
