# Breaking Changes

## 0.5

### form_companion_presenter (and form_builder_companion_presenter)

* To implement restoration support, we introduce new abstract member `restoreField()` to `CompanionPresenterFeatures`.
  We believe that it is rare to enhance `CompanionPresenterFeatures`.
  * How to migrate: implement `restoreField()` in your `CompanionPresenterFeatures` subtypes. See `FormCompanionFeatures` and `FormBuilderCompanionFeatures` implementation for reference. If you implement test double for tests which do not restore state, just implement throwing `UnimplementedError`.
* To implement restoration support, we cannot avoid add required parameters for enum related members on `PropertyDescriptorBuilder`, namely: `enumerated`, `enumeratedWithField`, `enumeratedList`, `enumeratedListWithField`.
  * How to migrate: specify `YourEnumTypes.values` for newly added `enumValues` parameters.
    * Bonus: for `enumerated` and `enumeratedList`, generic type arguments now can be inferred thanks to `enumValues`.

### form_builder_companion_presenter

* We decided to remove `booleanList` and `booleanListWithField` because these have never work correctly on `flutter_form_builder` widgets. Frankly speaking, they should not exist. So, we remove them before 1.0 version.
  * How to migrate: if you have a form field which works for `List<bool>`, use `addWithField` method.
* Move `FormBuilderCompanionPropertyDescriptorsBuilderExtension` from `form_builder_companion_presenter` to `form_builder_companion_annotation`.
  * How to migrate: if you use `FormBuilderCompanionPropertyDescriptorsBuilderExtension` and do not import `form_builder_companion_annotation`, import it.

## 0.4

### form_companion_presenter (and form_builder_companion_presenter)

* Due to [Flutter 3.7 breaking changes](https://docs.flutter.dev/release/breaking-changes/supplemental-maybeOf-migration), we cannot support old Flutter versions. Flutter 3.7 is minimum supported version.  
  We also drop support for older Dart version (< 2.19).
  * How to migrate: update your `pubspec.yaml` to use `Flutter >= 3.7` and `SDK > 2.19` as following:

```yaml
environment:
  sdk: ">=2.19.0 <3.0.0"
  flutter: ">=3.7.0"
```

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

* Config (`build.yaml`) parser now reports type error more aggressively.
  Although previous parser just ignored invalid typed value as long as it could do it, new parser will report such errors because ignoring such invalid values promotes complexity of fixing misconfiguration.
* Accessing properties' value now uses `properties.values.{propertyName}` instead of `{propertyName}.value` extensions.
  So, replace `[this.]{propertyName}.value` with  `{propertyName}.value`
* Form field factory accessor (`.fields`) now an extension for the subtype of generated `${PresenterName}FormProperties` instead of presenter itself.  
  You should watch the state instead of presenter itself. The state also exposes `submit` and `canSubmit`.  
  In addition, the extension type name is now `${presenterName}FormPropertiesFieldFactoryExtension` instead of `${presenterName}FieldFactoryExtension` according to its target type change.
