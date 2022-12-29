# Breaking Changes

## 0.3

v0.3 introduces some breaking changes to support riverpod 2.x and to be more state management friendly.

### form_companion_presenter (and form_builder_companion_presenter)

* Preferred state type of `StateNotifier` becomes generated `{PresenterName}FormProperties` instead of domain type.
  If you set the `state` in `submit` method, it should be removed.
* The `CompanionPresenterMixin.properties` are renamed to `propertiesState` and its type is now `FormProperties` instead of `Map<String, PropertyDescriptor>`.
* The `CompanionPresenterMixinPropertiesExtension` extension is removed. You can use:
  * `FormProperties.getDescriptor()` instead of `getProperty()` extension method.
  * `FormProperties.getValue()` instead of `getSavedPropertyValue()` extension method.
  * `FormProperties.saveValue()` extension method instead of `savePropertyValue()` extension method.
  * `FormProperties.getFieldValidator()` extension method instead of `getPropertyValidator()` extension method.
* `PropertyDescriptor.value` property is removed. Use `FormProperties.getValue()` method instead.
* `CompanionPresenterFeatures get presenterFeatures` property of `CompanionPresenterMixin` becomes abstract. This breaking change affects advanced users who declares custom `CompanionPresenterMixin` subtype.

### form_companion_generator

* Config (`builde.yaml`) parser now reports type error more aggressively.
  Although previous parser just ignored invalid typed value as long as it could do it, new parser will report such errors because ignoring such invalid values promotes complexity of fixing misconfiguration.
* Accessing properties' value now uses `properties.values.{propertyName}` instead of `{propertyName}.value` extensions.
  So, replace `[this.]{propertyName}.value` with  `{propertyName}.value`
* Form field factory accessor (`.fields`) now an extension for the subtype of generated `${PresenterName}FormProperties` instead of presenter itself.  
  You should watch the state instead of presenter itself. The state also exposes `submit` and `canSubmit`.  
  In addition, the extension type name is now `${presenterName}FormPropertiesFieldFactoryExtension` instead of `${presenterName}FieldFactoryExtension` according to its target type change.
