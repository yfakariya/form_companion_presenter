// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Builder object to build [PropertyDescriptor].
@sealed
class PropertyDescriptorsBuilder {
  final Map<String, _PropertyDescriptorSource<Object, Object>> _properties = {};

  /// Defines a new property with property value type [P]
  /// and form field value type [F].
  ///
  /// {@template pdb_add_remarks}
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  /// {@endtemplate}
  void add<P extends Object, F extends Object>({
    required String name,
    List<FormFieldValidatorFactory<F>>? validatorFactories,
    List<AsyncValidatorFactory<F>>? asyncValidatorFactories,
    P? initialValue,
    Equality<F>? fieldValueEquality,
    Equality<P>? propertyValueEquality,
    ValueConverter<P, F>? valueConverter,
    PropertyValueTraits? valueTraits,
  }) {
    final descriptor = _PropertyDescriptorSource<P, F>(
      name: name,
      validatorFactories: validatorFactories ?? [],
      asyncValidatorFactories: asyncValidatorFactories ?? [],
      initialValue: initialValue,
      fieldValueEquality: fieldValueEquality,
      propertyValueEquality: propertyValueEquality,
      valueConverter: valueConverter,
      valueTraits: valueTraits ?? PropertyValueTraits.none,
    );
    final oldOrNew = _properties.putIfAbsent(name, () => descriptor);
    assert(oldOrNew == descriptor, '$name is already registered.');
  }

  /// Build [FormProperties] which is connected with specified [presenter].
  FormProperties _build(
    CompanionPresenterMixin presenter,
  ) =>
      FormProperties._(
        presenter,
        _properties.map(
          (key, value) => MapEntry(
            key,
            // Delegates actual build to (typed) _PropertyDescriptorSource to
            // handle generic type arguments of them.
            _PropertyState(value.build(presenter), value.initialValue),
          ),
        ),
      );
}

/// Defines convinient extension methos for [PropertyDescriptorsBuilder] to
/// define typical type combinations.
extension FormCompanionPropertyDescriptorsBuilderExtension
    on PropertyDescriptorsBuilder {
  /// Defines a new property with property value type [P] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void stringConvertible<P extends Object>({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    P? initialValue,
    required StringConverter<P>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      add<P, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter,
        valueTraits: valueTraits,
      );

  /// Defines a new property with [String] for both of property value type and
  /// form field value type.
  ///
  /// {@macro pdb_add_remarks}
  void string({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    String? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      add<String, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueTraits: valueTraits,
      );

  /// Defines a new property with [bool] for both of property value type and
  /// form field value type.
  ///
  /// {@macro pdb_add_remarks}
  void boolean({
    required String name,
    bool initialValue = false,
    PropertyValueTraits? valueTraits,
  }) =>
      add<bool, bool>(name: name, initialValue: initialValue);
        valueTraits: valueTraits,

  /// Defines a new property with enum type [T] for both of property value type
  /// and form field value type.
  ///
  /// {@macro pdb_add_remarks}
  void enumerated<T extends Enum>({
    required String name,
    T? initialValue,
    PropertyValueTraits? valueTraits,
  }) =>
      add<T, T>(name: name, initialValue: initialValue);
        valueTraits: valueTraits,

  /// Defines a new property with property value type [int] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void integerText({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    int? initialValue,
    StringConverter<int>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      add<int, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter ?? intStringConverter,
        valueTraits: valueTraits,
      );

  /// Defines a new property with property value type [double] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void realText({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    double? initialValue,
    StringConverter<double>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      add<double, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter ?? doubleStringConverter,
        valueTraits: valueTraits,
      );

  /// Defines a new property with property value type [BigInt] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void bigIntText({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    BigInt? initialValue,
    StringConverter<BigInt>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      add<BigInt, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter ?? bigIntStringConverter,
        valueTraits: valueTraits,
      );

  /// Defines a new property with property value type [Uri] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void uriText({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    Uri? initialValue,
    StringConverter<Uri>? stringConverter,
    PropertyValueTraits? valueTraits,
  }) =>
      add<Uri, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter ?? uriStringConverter,
        valueTraits: valueTraits,
      );
}

/// Object which holds required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<P extends Object, F extends Object> {
  final String name;
  final List<FormFieldValidatorFactory<F>> validatorFactories;
  final List<AsyncValidatorFactory<F>> asyncValidatorFactories;
  final P? initialValue;
  final Equality<F>? fieldValueEquality;
  final Equality<P>? propertyValueEquality;
  final ValueConverter<P, F>? valueConverter;
  final PropertyValueTraits valueTraits;

  _PropertyDescriptorSource({
    required this.name,
    required this.validatorFactories,
    required this.asyncValidatorFactories,
    required this.initialValue,
    required this.fieldValueEquality,
    required this.propertyValueEquality,
    required this.valueConverter,
    required this.valueTraits,
  });

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  PropertyDescriptor<P, F> build(
    CompanionPresenterMixin presenter,
  ) =>
      PropertyDescriptor<P, F>._(
        name: name,
        presenter: presenter,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        onPropertyChanged: presenter._onPropertyChanged,
        fieldValueEquality: fieldValueEquality,
        propertyValueEquality: propertyValueEquality,
        valueConverter: valueConverter,
        valueTraits: valueTraits,
      );
}
