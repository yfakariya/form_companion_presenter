part of '../../emitter.dart';

/// Emits a builder class to help `copyWith` of typed `FormProperties`.
@visibleForTesting
String emitFormPropertiesBuilder(
  String baseName,
  Map<String, PropertyAndFormFieldDefinition> properties,
  String buildMethodName,
) =>
    '''
/// Defines a builder to help [${baseName}FormProperties.copyWith].
@sealed
class \$${baseName}FormPropertiesBuilder {
  final \$${baseName}FormProperties _properties;
  final Map<String, Object?> _newValues = {};

  \$${baseName}FormPropertiesBuilder._(this._properties);
${_emitBuilderSetters(properties).join('\n')}

  \$${baseName}FormProperties ${buildMethodName}() =>
      _properties.copyWithProperties(_newValues);
}''';

/// Emits each setter lines of typed `FormProperties` builder.
Iterable<String> _emitBuilderSetters(
  Map<String, PropertyAndFormFieldDefinition> properties,
) sync* {
  for (final property in properties.entries) {
    // blank line
    yield '';
    yield '  /// Sets a new value of `${property.key}` property.';
    yield '  void ${property.key}(${property.value.propertyValueType} value) =>';
    yield "      _newValues['${property.key}'] = value;";
  }
}
