// See LICENCE file in the root.

import 'package:meta/meta.dart';

/// Defines macro keys for context values, which refers context specific values
/// rather than user defined values.
@sealed
class ContextValueKeys {
  /// Token for name of current property without any quotations.
  static const propertyName = 'PROPERTY_NAME';

  /// Token for property value type (`P`) of current property.
  static const propertyValueType = 'PROPERTY_VALUE_TYPE';

  /// Token for field value type (`F`) of current property.
  static const fieldValueType = 'FIELD_VALUE_TYPE';

  /// Expression for a local variable which stores current `PropertyDescriptor<P, F>`.
  static const property = 'PROPERTY';

  /// Expression for an argument of current form field factory for currently assigning
  /// `FormField`'s constructor parameter.
  ///
  /// Note that this is default value of argument templates.
  static const argument = 'ARGUMENT';

  /// Expression for default value of currently assigning `FormField`'s
  /// constructor parameter, which is declared in part of the constructor signature.
  static const defaultValue = 'DEFAULT_VALUE';

  /// Token for a type of currently assigning `FormField`'s constructor parameter.
  static const parameterType = 'PARAMETER_TYPE';

  /// Expression for an argument typed `BuildContext`, which is supplied from
  /// form field factory's call site.
  static const buildContext = 'BUILD_CONTEXT';

  /// Token for name of current presenter type without any quotations.
  static const presenterName = 'PRESENTER_NAME';

  // For list items

  /// Current item of list like field value of `PropertyDescriptor`.
  ///
  /// * If the value is [Iterable] type, then this value is each item of it.
  /// * If the value is enum type, then this value is each members of the enum.
  ///   * If the value is also nullable, `null` is also listed as this value.
  /// * If the value is [bool] type, then this value is `true` or `false`.
  ///   * If the value is also nullable, `null` is also listed as this value.
  ///
  /// This value can be used in items template only.
  static const itemValue = 'ITEM_VALUE';

  /// Current item type of list like field value of `PropertyDescriptor`.
  ///
  /// * If the value is [Iterable] type, then this value is `E`.
  ///   * If the value is also nullable, then this value also be nullable.
  /// * If the value is enum type, then this value is type of its enum type.
  ///   * If the value is also nullable, then this value also be nullable.
  /// * If the value is [bool] type, then this value is [bool].
  ///   * If the value is also nullable, then this value also be nullable.
  ///
  /// This value can be used in items template only.
  static const itemValueType = 'ITEM_VALUE_TYPE';

  /// Expression for string representation of [itemValue].
  ///
  /// * If the value is [String], then this value should be identical for [itemValue].
  /// * If the value is not [String], then this value is returned value of
  ///   [toString] method call for [itemValue].
  /// * If the value is `null`, then this value is an empty string rather than "null".
  ///
  /// This value can be used in items template only.
  static const itemValueString = 'ITEM_VALUE_STRING';

  // Synthetics

  /// If default value exists in target parameter declaration,
  /// the default value expression with `.copyWith` suffix will be used.
  /// Otherwise, type name of the parameter will be used (for default constructor call).
  static const defaultValueCopyOrNew = 'DEFAULT_VALUE_COPY_OR_NEW';

  /// Expression for `AutovalidateMode` which is configured via `FormCompanion`
  /// annotation or `build.yaml` configuration.
  static const autoValidateMode = 'AUTO_VALIDATE_MODE';
}
