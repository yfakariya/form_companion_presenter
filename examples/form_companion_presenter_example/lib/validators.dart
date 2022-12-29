// See LICENCE file in the root.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'validators.g.dart';

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

  static AsyncValidatorFactory<String> get id => (options) {
        final container = ProviderScope.containerOf(options.context);
        return (value, options) async {
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
          return container.read(asyncValidationFutureFactoryProvider).run(
                const Duration(seconds: 5),
                validation,
              );
        };
      };
}

// To avoid type error when we use closure.
@visibleForTesting
class Waiter {
  final Future<String?> Function(Duration, String? Function()) _function;

  Waiter(this._function);

  Future<String?> run(Duration wait, String? Function() validator) =>
      _function(wait, validator);

  static final Waiter defaultLogic = Waiter(Future<String?>.delayed);
}

@riverpod
Waiter asyncValidationFutureFactory(AsyncValidationFutureFactoryRef _) =>
    Waiter.defaultLogic;
