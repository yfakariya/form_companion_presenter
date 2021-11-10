// See LICENCE file in the root.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

class AsyncValidationIndicator extends StatelessWidget {
  final ValueListenable<bool> _hasPendingAsyncValidationListener;
  final String? text;
  final double? height;

  AsyncValidationIndicator({
    Key? key,
    required CompanionPresenterMixin presenter,
    required String propertyName,
    this.text,
    this.height,
  })  : _hasPendingAsyncValidationListener =
            presenter.getPropertyPendingAsyncValidationsListener(propertyName),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final indicatorSize =
        height ?? Theme.of(context).textTheme.subtitle1?.height ?? 16;
    return ValueListenableBuilder<bool>(
      valueListenable: _hasPendingAsyncValidationListener,
      builder: (_, hasPendingAsyncValidation, indicator) =>
          hasPendingAsyncValidation ? indicator! : const SizedBox(width: 0),
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
          Text(text ?? 'Validating...'),
        ],
      ),
    );
  }
}
