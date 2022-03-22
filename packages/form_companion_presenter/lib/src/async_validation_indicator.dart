// See LICENCE file in the root.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../form_companion_presenter.dart';

/// Simple indicator to indicate async validation is in progress or not.
class AsyncValidationIndicator extends StatelessWidget {
  final ValueListenable<bool> _hasPendingAsyncValidationListener;

  /// A text to describe that there is a pending async validation.
  ///
  /// If `null`, built-in default message is shown.
  final String? text;

  /// A height of this control.
  ///
  /// If `null`, `subtitle1` text theme's height will be used.
  /// If the theme is not found, `16` is used.
  /// The intent of the default value is that it should be aligned to default
  /// height of `FormTextField`, so the logic to determine default height
  /// subject to change in future.
  /// If you want to stabilize the height, specify this value explicitly.
  final double? height;

  /// Initializes a new [AsyncValidationIndicator].
  ///
  /// Specify [presenter] and [propertyName] to create indicator for the
  /// specified property in the [presenter].
  /// The [propertyName] should be used for the form field which handles input
  /// for the property.
  AsyncValidationIndicator({
    Key? key,
    required CompanionPresenterMixin presenter,
    required String propertyName,
    this.text,
    this.height,
  })  : _hasPendingAsyncValidationListener = presenter.internals
            .getPropertyPendingAsyncValidationsListener(propertyName),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorSize =
        height ?? Theme.of(context).textTheme.subtitle1?.height ?? 16;
    return ValueListenableBuilder<bool>(
      valueListenable: _hasPendingAsyncValidationListener,
      builder: (_, hasPendingAsyncValidation, child) => Visibility(
        visible: hasPendingAsyncValidation,
        child: child!,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: indicatorSize,
            height: indicatorSize,
            child: const CircularProgressIndicator(),
          ),
          const SizedBox(
            width: 4,
          ),
          // Currently, there is no L10N here... it is not so good to bring
          // additional dependency for intl package just for this simple message.
          Text(text ?? 'Validating...'),
        ],
      ),
    );
  }
}
