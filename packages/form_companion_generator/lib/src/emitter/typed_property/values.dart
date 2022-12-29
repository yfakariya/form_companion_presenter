part of '../../emitter.dart';

/// Emits an accessor class to get typed properties' values.
@visibleForTesting
String emitPropertyValueAccessor(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
) =>
    '''
/// Defines typed property value accessors
/// for [${baseName}FormProperties].
@sealed
class \$${baseName}PropertyValues {
  final FormProperties _properties;

  \$${baseName}PropertyValues._(this._properties);
${_emitPropertyValueAccessors(properties).join('\n')}
}''';

/// Emits each property descriptor accessor getter lines.
Iterable<String> _emitPropertyValueAccessors(
  Iterable<PropertyAndFormFieldDefinition> properties,
) sync* {
  for (final property in properties) {
    // blank line
    yield '';
    yield '  /// Gets a current value of `${property.name}` property.';
    yield '  ${property.propertyValueType} get ${property.name} =>';
    yield "      _properties.getValue('${property.name}') as ${property.propertyValueType};";
  }
}
