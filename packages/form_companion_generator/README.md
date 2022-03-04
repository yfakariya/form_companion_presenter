# form_companion_generator

Code generator for `form_companion_presenter` and `form_builder_companion_presetner`

## Features

* Generates easy and type-safe accessors for `PropertyDescritor`s and their saved values.
* Generates customizable `FormField` (or `FormBuilderField`) factories for each `PropertyDescritor`.

## Spec

### Prereqs

* Decorate your companion with `@formCompanion` annotation.
  * If you use `FormBuilderCompanionPresenterMixin`, then the generator creates codes using `FormBuilder`; otherwise, it generates sources which only use vanilla `Form`.
* You can specify validation mode for the annotation.
* The generator will read property definitions from a **single expression** which is passed to `initializeCompanionMixin` method call in the constructor body. The single expression must be one of the following:
  * Inline `PropertyDescritorBuilder` construction.
  * Local variable reference, which is `PropertyDescritorBuilder` type. Note that the generator only tracks its initialization expression.
  * Static field, which is `PropertyDescritorBuilder` type. Note that the generator only tracks its initialization expression.
