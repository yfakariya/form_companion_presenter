// See LICENCE file in the root.

part of '../form_companion_mixin.dart';

/// Builder object to build [PropertyDescriptor].
@sealed
class PropertyDescriptorsBuilder {
  final Map<String, _PropertyDescriptorSource<Object>> _properties = {};

  /// Defines new property without asynchronous validation progress reporting.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void add<T extends Object>({
    required String name,
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T>>? asyncValidatorFactories,
  }) {
    final descriptor = _PropertyDescriptorSource<T>(
      name: name,
      validatorFactories: validatorFactories ?? [],
      asyncValidatorFactories: asyncValidatorFactories ?? [],
    );
    final oldOrNew = _properties.putIfAbsent(name, () => descriptor);
    assert(oldOrNew == descriptor, '$name is already registered.');
  }

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  Map<String, PropertyDescriptor<Object>> _build(
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

/// Object which holds required values to create [PropertyDescriptor].
class _PropertyDescriptorSource<T extends Object> {
  final String name;
  final List<FormFieldValidatorFactory<T>> validatorFactories;
  final List<AsyncValidatorFactory<T>> asyncValidatorFactories;

  _PropertyDescriptorSource({
    required this.name,
    required this.validatorFactories,
    required this.asyncValidatorFactories,
  });

  /// Build [PropertyDescriptor] which is connected with specified [presenter].
  PropertyDescriptor<T> build(
    CompanionPresenterMixin presenter,
  ) =>
      PropertyDescriptor<T>._(
        name: name,
        presenter: presenter,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
      );
}
