# Breaking Changes

## 0.3

v0.3 introduces some breaking changes to support riverpod 2.x and to be more state management friendly.
### form_companion_generator

* Config (`builde.yaml`) parser now reports type error more aggressively.
  Although previous parser just ignored invalid typed value as long as it could do it, new parser will report such errors because ignoring such invalid values promotes complexity of fixing misconfiguration.
