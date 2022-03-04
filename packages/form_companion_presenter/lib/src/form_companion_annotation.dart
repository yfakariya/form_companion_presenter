// See LICENCE file in the root.

import 'package:meta/meta.dart';

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
