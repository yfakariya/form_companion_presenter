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
    Equality<F>? equality,
    ValueConverter<P, F>? valueConverter,
  }) {
    final descriptor = _PropertyDescriptorSource<P, F>(
      name: name,
      validatorFactories: validatorFactories ?? [],
      asyncValidatorFactories: asyncValidatorFactories ?? [],
      initialValue: initialValue,
      equality: equality,
      valueConverter: valueConverter,
    );
    final oldOrNew = _properties.putIfAbsent(name, () => descriptor);
    assert(oldOrNew == descriptor, '$name is already registered.');
  }

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  Map<String, PropertyDescriptor<Object, Object>> _build(
    CompanionPresenterMixin presenter,
  ) =>
      _properties.map(
        (key, value) => MapEntry(
          key,
          // Delegates actual build to (typed) _PropertyDescriptorSource to
          // handle generic type arguments of them.
          value.build(presenter),
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
  }) =>
      add<P, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: stringConverter,
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
  }) =>
      add<String, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
      );

  /// Defines a new property with [bool] for both of property value type and
  /// form field value type.
  ///
  /// {@macro pdb_add_remarks}
  void boolean({
    required String name,
    bool initialValue = false,
  }) =>
      add<bool, bool>(name: name, initialValue: initialValue);

  /// Defines a new property with enum type [T] for both of property value type
  /// and form field value type.
  ///
  /// {@macro pdb_add_remarks}
  void enumerated<T extends Enum>({
    required String name,
    T? initialValue,
  }) =>
      add<T, T>(name: name, initialValue: initialValue);

  /// Defines a new property with property value type [int] and
  /// form field value type [String].
  ///
  /// {@macro pdb_add_remarks}
  void integerText({
    required String name,
    List<FormFieldValidatorFactory<String>>? validatorFactories,
    List<AsyncValidatorFactory<String>>? asyncValidatorFactories,
    int? initialValue,
  }) =>
      add<int, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: intStringConverter,
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
  }) =>
      add<double, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: doubleStringConverter,
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
  }) =>
      add<BigInt, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: bigIntStringConverter,
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
    // TODO(yfakariya): capability l10n
  }) =>
      add<Uri, String>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
        initialValue: initialValue,
        valueConverter: uriStringConverter,
      );
}

/// Object which holds required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<P extends Object, F extends Object> {
  final String name;
  final List<FormFieldValidatorFactory<F>> validatorFactories;
  final List<AsyncValidatorFactory<F>> asyncValidatorFactories;
  final P? initialValue;
  final Equality<F>? equality;
  final ValueConverter<P, F>? valueConverter;

  _PropertyDescriptorSource({
    required this.name,
    required this.validatorFactories,
    required this.asyncValidatorFactories,
    required this.initialValue,
    required this.equality,
    required this.valueConverter,
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
        initialValue: initialValue,
        equality: equality,
        valueConverter: valueConverter,
      );
}
