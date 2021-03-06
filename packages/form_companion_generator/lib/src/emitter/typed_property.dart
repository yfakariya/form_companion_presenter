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

  return '''
/// Defines typed property accessors as extension properties for [$baseName].
extension \$${baseName}PropertyExtension on $baseName {
${_emitPropertyAccessors(properties).join('\n')}
}
''';
}

/// Emits each property accessor lines.
Iterable<String> _emitPropertyAccessors(
  Iterable<PropertyAndFormFieldDefinition> properties,
) sync* {
  var isFirst = true;
  for (final property in properties) {
    if (isFirst) {
      isFirst = false;
    } else {
      // empty line
      yield '';
    }

    yield '  /// Gets a [PropertyDescriptor] of `${property.name}` property.';
    yield '  PropertyDescriptor<${property.propertyValueType}, ${property.fieldValueType}> get ${property.name} =>';
    // properties is marked as @protected and @visibleForTesting
    yield '      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member';
    yield "      properties['${property.name}']! as PropertyDescriptor<${property.propertyValueType}, ${property.fieldValueType}>;";
  }
}
