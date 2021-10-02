# Design doc

See Readme in root for basic concepts and usage.
This file will be updated to describe implementation designs for maintainers.

## Concept

* Usability first. We should keep simple and easy in example code.
  * Minimal features, minimal dependencies.
* Do not limit Form usage patterns as possible.
  * But we only support "presenter" pattern because very simple pattern like single `FormField` does not need to reduce its code anyway.
* Keep backward compatibility as possible.
  * However, flutter looks that prefer improvement and simplicity than backward compatibility like sounds null safety.

## Note

* We use mixin instead of class to prevent limiting combination of other framework.
  * Unfortunately, mixin does not support inheritance, so we use double mixin (`on` for another mixin). This design should be improved when dart lang supports mixin inheritance.
* We avoid reflection for wide platform support.
* We avoid code generation for simplicity, but it looks OK to provide typed properties wrapper like `TypedPropertyDescriptor<T> get xxx` as presenter mixin as `freezed`.

## What is "presenter" ?

In this package, presenter means [Martin Fowlers definition](https://martinfowler.com/eaaDev/uiArchs.html#Model-view-presentermvp), which setup view (widget tree) and handle inputs via event handler. When we use provider (including riverpod) in flutter, we naturally adopt MVP pattern, and presenter is `build()` method. In addition, when we use state notifier, the presenter is separated to:

* `ConsumerWidget.build()`, which setup view (widget tree) including event handler binding.
* `StateNotifier<TState>`, which defines event handler, call "model" of app, and then update "State".
* `State`, which is immutable "view model".
  * Unlike classic MVVM, `Provider` and `StateNotifier` handles change notification so smartly, commands should be implemented in `StateNotifier<TState>`, and no data binding. But recently, many people use a term "view model" for "data model which represents view's state and structure" espetially in SPA web frameworks.
* `Provider` is an observer.

Unlike Martin's Supervising Controller pattern, there are no abstraction between presenter and view. Our `ConsumerWidget` directly manipulate widget. It is not a matter, however, because flutter provides built-in widget testing mechanism, so it reduces most of motivations inserting abstraction between presenter and view. For rest area, we can implement unit tests for `StateNotifier`, which should accept "view model" and "model" in its constructor (constructor dependency injection) and it does not have any dependency for view.

### About `BuildContext`

OK, it is not true. Our mixin's methods often accepts `BuildContext`, it is undoubtedly a part of view. Why we decide to pass `BuildContext` for them? Because flutter binds many things to it including locale settings or pop of navigation stack.
