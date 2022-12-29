part of '../../emitter.dart';

/// Emits a typed `FormProperties` class.
@visibleForTesting
String emitTypedFormProperties(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
  String builderBuildMethodName,
) =>
    '''
/// Defines typed property state accessors
/// for [$baseName].
@sealed
@immutable
class \$${baseName}FormProperties implements FormProperties {
  final FormProperties _underlying;

  /// Gets a [$baseName] instance which holds this properties state.
  $baseName get presenter => _underlying.presenter as $baseName;

  /// Gets a typed [PropertyDescriptor] accessor [\$${baseName}PropertyDescriptors]
  /// for [$baseName].
  late final \$${baseName}PropertyDescriptors descriptors;

  /// Gets a typed property value accessor [\$${baseName}PropertyValues]
  /// for [$baseName].
  late final \$${baseName}PropertyValues values;

  /// Returns a [\$${baseName}FormProperties] which wraps [FormProperties].
  /// 
  /// Note that this factory returns [underlying] if [underlying] is 
  /// [\$${baseName}FormProperties] type.
  factory \$${baseName}FormProperties(FormProperties underlying) {
    if (underlying is \$${baseName}FormProperties) {
      return underlying;
    }

    if (underlying.presenter is! $baseName) {
      throw ArgumentError(
        'Specified FormProperties does not hold \${$baseName} type presenter.',
        'underlying',
      );
    }

    return \$${baseName}FormProperties._(underlying);
  }

  \$${baseName}FormProperties._(this._underlying) {
    descriptors = \$${baseName}PropertyDescriptors._(_underlying);
    values = \$${baseName}PropertyValues._(_underlying);
  }

  @override
  bool canSubmit(BuildContext context) => _underlying.canSubmit(context);

  @override
  void Function()? submit(BuildContext context) => _underlying.submit(context);

  @override
  \$${baseName}FormProperties copyWithProperties(
    Map<String, Object?> newValues,
  ) {
    final newUnderlying = _underlying.copyWithProperties(newValues);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return \$${baseName}FormProperties(newUnderlying);
  }

  @override
  \$${baseName}FormProperties copyWithProperty(
    String name,
    Object? newValue,
  ) {
    final newUnderlying = _underlying.copyWithProperty(name, newValue);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return \$${baseName}FormProperties(newUnderlying);
  }

  /// Copies this instance with specified new property values specified via
  /// returned [\$${baseName}FormPropertiesBuilder] object.
  /// 
  /// You must call [\$${baseName}FormPropertiesBuilder.$builderBuildMethodName]
  /// to finish copying.
  \$${baseName}FormPropertiesBuilder copyWith() =>
      \$${baseName}FormPropertiesBuilder._(this);

  @override
  PropertyDescriptor<P, F> getDescriptor<P extends Object, F extends Object>(
    String name,
  ) =>
      _underlying.getDescriptor<P, F>(name);
      
  @override
  PropertyDescriptor<P, F>?
      tryGetDescriptor<P extends Object, F extends Object>(
    String name,
  ) =>
          _underlying.tryGetDescriptor(name);

  @override
  Iterable<PropertyDescriptor<Object, Object>> getAllDescriptors() =>
      _underlying.getAllDescriptors();

  @override
  Object? getValue(String name) => _underlying.getValue(name);
}''';
