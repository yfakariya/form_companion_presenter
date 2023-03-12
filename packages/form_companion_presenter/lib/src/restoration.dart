// See LICENCE file in the root.

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import 'form_companion_mixin.dart';
import 'property_value_traits.dart';

/// Encapsulate [FormFieldState] related values for restoration.
@internal
class RestorableFieldValues<T extends Object> {
  final RestorableValue<T?> _value;

  /// Gets a stored value of [FormField].
  T? get value => _value.value;

  /// Sets a value of [FormField].
  void setValue(T? value) {
    if (_value.value != value) {
      _value.value = value;
      _hasError.value = false;
    }
  }

  /// Gets a stored value whether the [FormField] has value or not.
  bool get hasValue => _hasError.value != null;

  final RestorableBoolN _hasError;

  /// Gets a stored value whether the [FormField] has error or not.
  bool get hasError => _hasError.value ?? false;

  /// Sets a value whether the [FormField] has error or not.
  // ignore: avoid_positional_boolean_parameters
  void setHasError(bool value) {
    if (_hasError.value != value) {
      _hasError.value = value;
    }
  }

  var _hasRestoredValue = false;

  /// Marks that this value is restored, so the restored value will be gotten
  /// in next [tryScheduleRestoration].
  void markValueIsRestored() {
    _hasRestoredValue = true;
  }

  /// Calls [restoration] callback after build if there is a restored value.
  void tryScheduleRestoration(
    T? initialValue,
    void Function(T?, bool) restoration,
  ) {
    if (hasValue && _hasRestoredValue) {
      final restoredValue = _value.value;
      final hasError = this.hasError;
      // Restore value only if it is not equal to initial value to avoid extra
      // validation fields which are rest in initial value (that is, no user
      // input have been supplied) and have AutovalidateMode.onUserInteraction.
      if (restoredValue != initialValue || hasError) {
        // Postpone restoration to avoid value change / validation in build phase.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          restoration(restoredValue, hasError);
        });
      }
      _hasRestoredValue = false;
    } else if (!hasValue && _value.value != initialValue) {
      // Remember initial value for future restoration
      setValue(initialValue);
    }
  }

  /// Creates a new [RestorableFieldValues].
  ///
  /// 3rd parameter, which is `void Function(void Function())` type, is required
  /// to save restoration target state,
  /// and should be [State.setState] of [FormPropertiesRestorationScope] instance.
  RestorableFieldValues(
    RestorableValueFactory<T> valueFactory,
    RestorableFieldValues<T>? previous,
  )   : _value = valueFactory()..initWithValue(previous?.value),
        _hasError = RestorableBoolN(previous?._hasError.value);
}

/// {@template FormPropertiesRestorationScope}
/// Enables input state restoration for form properties of specified `presenter`
/// which is mix-ined with [CompanionPresenterMixin].
/// {@endtemplate}
///
/// Any form properties uses their property names for restoration ID of
/// themselves.
/// If you want to disable state restoration, specify `valueTraits` in
/// [PropertyDescriptorsBuilder.add] or any extension methods of
/// [PropertyDescriptorsBuilder] to
/// [PropertyValueTraits.sensitive] or [PropertyValueTraits.doNotRestoreState].
class FormPropertiesRestorationScope extends StatefulWidget {
  final CompanionPresenterMixin _presenter;
  final String _restorationId;
  final Widget _child;

  /// {@macro FormPropertiesRestorationScope}
  ///
  /// Note that when [restorationId] is `null`,
  /// `presenter.runtimeType` will be used.
  FormPropertiesRestorationScope({
    super.key,
    required CompanionPresenterMixin presenter,
    String? restorationId,
    required Widget child,
  })  : _presenter = presenter,
        _restorationId = restorationId ?? presenter.runtimeType.toString(),
        _child = child;

  @override
  State<StatefulWidget> createState() =>
      _FormPropertiesRestorationScopeState(_presenter);
}

class _FormPropertiesRestorationScopeState
    extends State<FormPropertiesRestorationScope> with RestorationMixin {
  late final Map<String, RestorableFieldValues<Object?>> _restorableProperties;

  @override
  String? get restorationId => widget._restorationId;

  _FormPropertiesRestorationScopeState(CompanionPresenterMixin presenter) {
    _restorableProperties = {
      for (final p in presenter.propertiesState
          .getAllDescriptors()
          .where((p) => p.isRestorable))
        p.name: p.getRestorableProperty()!
    };
  }

  @override
  Widget build(BuildContext context) => _FormPropertiesRestorationScope(
        state: this,
        child: widget._child,
      );

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    for (final restorableProperty in _restorableProperties.entries) {
      final valueKey = '${restorableProperty.key}#v';
      final hadValue = bucket?.contains(valueKey) ?? false;

      registerForRestoration(
        restorableProperty.value._value,
        valueKey,
      );
      registerForRestoration(
        restorableProperty.value._hasError,
        '${restorableProperty.key}#e',
      );

      if (hadValue) {
        // Set flag to replace initialValue with restored value.
        restorableProperty.value.markValueIsRestored();
      }
    }
  }

  @override
  void setState(VoidCallback fn) => super.setState(fn);
}

/// Provides state access from subtree.
class _FormPropertiesRestorationScope extends InheritedWidget {
  final _FormPropertiesRestorationScopeState state;
  _FormPropertiesRestorationScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(
    covariant _FormPropertiesRestorationScope oldWidget,
  ) =>
      state != oldWidget.state;
}
