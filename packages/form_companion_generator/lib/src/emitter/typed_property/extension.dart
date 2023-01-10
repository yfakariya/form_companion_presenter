part of '../../emitter.dart';

/// Emits extension for the presenter to get `$[baseName]FormProperties` object.
@visibleForTesting
String emitPropertyAccessorExtension(
  String baseName,
  Iterable<PropertyAndFormFieldDefinition> properties,
) =>
    '''
/// Defines typed property accessors as extension properties for [$baseName].
extension \$${baseName}PropertyExtension on $baseName {
  /// Gets a current [\$${baseName}FormProperties] which holds properties' values
  /// and their [PropertyDescriptor]s.
  \$${baseName}FormProperties get properties =>
      \$${baseName}FormProperties(propertiesState);

  /// Resets [properties] (and underlying[CompanionPresenterMixin.propertiesState])
  /// with specified new [\$${baseName}FormProperties].
  ///
  /// This method also calls [CompanionPresenterMixin.onPropertiesChanged] callback.
  /// 
  /// This method returns passed [FormProperties] for convinience.
  /// 
  /// This method is preferred over [CompanionPresenterMixin.resetPropertiesState]
  /// because takes and returns more specific [\$${baseName}FormProperties] type.
  \$${baseName}FormProperties resetProperties(
    \$${baseName}FormProperties newProperties,
  ) {
    resetPropertiesState(newProperties);
    return newProperties;
  }
}''';
