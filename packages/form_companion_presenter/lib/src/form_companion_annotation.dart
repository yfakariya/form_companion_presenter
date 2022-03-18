// See LICENCE file in the root.

import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../form_companion_presenter.dart';

/// An annotation for presenter class.
///
/// This annotation is used from `form_companion_generator` tool,
/// which generates strongly typed property accessor sources as build tool
/// running with `build_runner`.
@sealed
class FormCompanion {
  /// Initializes a new [FormCompanion] instance.
  const FormCompanion({
    this.autovalidate = true,
    this.suppressFieldFactory = false,
  });

  /// If `true`, generating code set `AutovalidateMode.onUserInteraction` for
  /// each `FormField`s' `autovalidateMode` named argument.
  ///
  /// Default is `true`.
  final bool autovalidate;

  /// If `true`, the generator does **not** generate field factories, which
  /// are factories creating appropriate `FormField` for each properties.
  ///
  /// Default is `false`.
  final bool suppressFieldFactory;
}

/// Marks this presenter class as auto-validated and generating field factories.
const formCompanion = FormCompanion();

/// Defines extension methos for [PropertyDescriptorsBuilder]
/// to provide extra features for companions qualified by [FormCompanion] annotation.
extension FormCompanionPropertyDescriptorBuilderExtensions
    on PropertyDescriptorsBuilder {
  /// Defines new property without asynchronous validation progress reporting.
  /// This method also defines "preferred field type", which affects
  /// `FormFieldFactory` generation by `form_companion_generator`.
  ///
  /// Note that [name] must be unique, and validators are registered as
  /// factories instead of normal closures (function objects) because some
  /// validation framework requires live [BuildContext] to initialize validator,
  /// and current [Locale] of the application should be stored to
  /// [BuildContext].
  void addWithField<T extends Object, F extends FormField<T>>({
    required String name,
    List<FormFieldValidatorFactory<T>>? validatorFactories,
    List<AsyncValidatorFactory<T>>? asyncValidatorFactories,
  }) =>
      // NOTE: TField is not used in runtime.
      //       The parameter will be interpreted in form_companion_generator.
      add<T>(
        name: name,
        validatorFactories: validatorFactories,
        asyncValidatorFactories: asyncValidatorFactories,
      );

  // TODO: addWithConverter
  // TODO: addWithStringConverter
}
