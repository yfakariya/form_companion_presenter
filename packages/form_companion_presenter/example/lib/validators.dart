// See LICENCE file in the root.

import 'package:form_companion_presenter/form_companion_presenter.dart';

// ignore: avoid_classes_with_only_static_members
class Validator {
  // very simple, naive regex for informative purpose only.
  static final RegExp _email = RegExp(r'^[^@]+@[a-z]+\.[a-z]+$');
  static FormFieldValidatorFactory<String> get required =>
      (_) => (v) => (v?.isEmpty ?? true) ? 'Required.' : null;

  static FormFieldValidatorFactory<String> get email =>
      (_) => (v) => !_email.hasMatch(v ?? '') ? 'Invalid email.' : null;

  static FormFieldValidatorFactory<String> min(num min) => (_) => (v) {
        if (v != null) {
          final number = num.tryParse(v);
          if (number != null) {
            if (number >= min) {
              return null;
            } else {
              return 'Must be greator than or equal to $min.';
            }
          }
        }

        return 'Input must be a number.';
      };
}
