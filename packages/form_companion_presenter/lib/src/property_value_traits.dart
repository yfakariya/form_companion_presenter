// See LICENCE file in the root.

import 'form_companion_mixin.dart';

/// Represents traits of [PropertyDescriptor] value.
enum PropertyValueTraits {
  /// No special traits. This is default value.
  none(0),

  /// The value is senstive.
  ///
  /// {@template PropertyValueTraits.generator.obscure}
  /// `form_companion_generator` respects this value to set some constructor
  /// arguments for some form fields.
  /// For example, change `obscureText` to `true`.
  /// {@endtemplate}
  sensitive(_sensitiveBit),
  ;

  static const _sensitiveBit = 1;

  final int _bits;

  /// Gets a value whether the value is senstive.
  ///
  /// {@macro PropertyValueTraits.generator.obscure}
  bool get isSensitive => (_bits & _sensitiveBit) != 0;

  /// **Do not call this constructor directly.**
  ///
  /// Initializes new [PropertyValueTraits] with specified bits.
  const PropertyValueTraits(this._bits);
}
