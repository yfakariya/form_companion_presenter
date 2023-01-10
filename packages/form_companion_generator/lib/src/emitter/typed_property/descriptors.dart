part of '../../emitter.dart';

/// Emits an accessor class to get typed `PropertyDescriptor`s.
@visibleForTesting
String emitPropertyDescriptorAccessor(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
) =>
    '''
/// Defines typed [PropertyDescriptor] accessors
/// for [${baseName}FormProperties].
@sealed
class \$${baseName}PropertyDescriptors {
  final FormProperties _properties;

  \$${baseName}PropertyDescriptors._(this._properties);
${_emitPropertyDescriptorAccessors(properties).join('\n')}
}''';

/// Emits each property descriptor accessor getter lines.
Iterable<String> _emitPropertyDescriptorAccessors(
  Iterable<PropertyAndFormFieldDefinition> properties,
) sync* {
  for (final property in properties) {
    // blank line
    yield '';
    yield '  /// Gets a [PropertyDescriptor] of `${property.name}` property.';
    yield '  PropertyDescriptor<${property.propertyValueType}, ${property.fieldValueType}> get ${property.name} =>';
    yield "      _properties.getDescriptor('${property.name}') as PropertyDescriptor<${property.propertyValueType}, ${property.fieldValueType}>;";
  }
}
