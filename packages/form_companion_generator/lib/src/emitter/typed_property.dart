// See LICENCE file in the root.

part of '../emitter.dart';

/// Emits property accessors and a their holder.
@visibleForTesting
String emitPropertyAccessor(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
  Config config,
) {
  assert(properties.isNotEmpty);
  return _emitPropertyAccessorLines(baseName, properties, config).join('\n');
}

Iterable<String> _emitPropertyAccessorLines(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
  Config config,
) sync* {
  final builderBuildMethodName =
      config.customNamings[baseName]?.formPropertiesBuilder?.build ?? 'build';

  yield emitTypedFormProperties(baseName, properties, builderBuildMethodName);

  // blank line
  yield '';

  yield emitPropertyDescriptorAccessor(baseName, properties);

  // blank line
  yield '';

  yield emitPropertyValueAccessor(baseName, properties);

  // blank line
  yield '';

  yield emitFormPropertiesBuilder(
    baseName,
    {for (final e in properties) e.name: e},
    builderBuildMethodName,
  );

  // blank line
  yield '';
  yield emitPropertyAccessorExtension(baseName, properties);
}
