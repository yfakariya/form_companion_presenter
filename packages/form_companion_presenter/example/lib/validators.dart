// See LICENCE file in the root.

import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  static AsyncValidatorFactory<String> get id => (context) {
        final container = ProviderScope.containerOf(context);
        return (value, options) {
          if (value == null || value.isEmpty) {
            return 'ID is required.';
          }

          late final String? Function() validation;
          // Dummy actions to check async validator behavior.
          // john and jane can be used to demonstrate async validation error or
          // failure.
          switch (value) {
            case 'john@example.com':
              // Demonstrate failure.
              validation =
                  () => throw Exception('Server is temporary unavailable.');
              break;
            case 'jane@example.com':
              // Demonstrate validation error.
              validation = () => '$value is already used.';
              break;
            default:
              validation = () => null;
              break;
          }

          // Injects hooks for widget testing.
          // Default factory just wait 5 seconds and call validation to show
          // behavior of async validation.
          return container.read(asyncValidationFutureFactory)(
            const Duration(seconds: 5),
            validation,
          );
        };
      };
}

final asyncValidationFutureFactory =
    StateProvider<Future<String?> Function(Duration, String? Function())>(
        (_) => Future<String?>.delayed);
