// See LICENCE file in the root.

import 'package:flutter/widgets.dart';
import 'package:state_notifier/state_notifier.dart';

import 'package:form_companion_presenter/form_companion_presenter.dart';

/// [FormStateAdapter] implementation for [FormState].
class _FormStateAdapter implements FormStateAdapter {
  final FormState _state;

  @override
  AutovalidateMode get autovalidateMode => _state.widget.autovalidateMode;

  _FormStateAdapter(this._state);

  @override
  bool validate() => _state.validate();

  @override
  void save() => _state.save();
}

/// Provides base implementation of presenter which cooporates with correspond
/// [Form] and [FormField]s to handle user inputs, their transitive states,
/// validations, and submission.
///
/// **It is required for [submit] method that there is a [Form] widget as
/// an ancestor in [BuildContext].**
///
/// This class supports following features:
/// * Decouples validation logic from view layer -- validation logic often
///   should exist in domain layer to encourage reuse.
/// * Async validation handling. This class tracks pending asynchronous
///   validation logics. The underlying validation infrastructure supports:
///   * Throttling. If continous validation requests are issued, the validation
///     will only handle last one. [FormField] often issues continous validation
///     because of such user input like fast text typing as well as repeated
///     validate() calls.
///   * Caching. Since async validation can be costly and idempotent in most
///     cases, and the result must be same for identical input, so caching
///     validation result reduces latency. It also second guard about continuous
///     validation requests.
/// * Disables "submit" action. The [submit] method returns [Function] when it
///   is ready for "submit" or `null` otherwise. This class checks validation
///   results of [FormField]s and existance of pending async validations.
abstract class FormPresenter<T> extends StateNotifier<T>
    with FormCompanionPresenterMixin {
  /// Creates a new [FormPresenter] with its initial state and properties.
  ///
  /// [properties] must be [PropertyDescriptorsBuilder] instance which
  /// have all properties which will be input via correspond [FormField]s.
  /// You can define properties in the presenter constructor as following:
  /// ```dart
  /// MyPresenter() : super(
  ///   initialState: MyState(),
  ///   properties: PropertyDescriptorsBuilder()
  ///   ..add<String>(
  ///     name: 'name',
  ///     validatorFactories: [
  ///       MyValidatorLibrary.required,
  ///       (context) => MyValidatorLibrary.minmumLength(context, 1),
  ///     ],
  ///     asyncValidatorFactories: [
  ///       (_) => MyLogic.checkValidNameOnServer,
  ///     ]
  ///   )
  ///   ..add<int>(
  ///     name: 'age',
  ///     validatorFactories: [
  ///       MyValidatorLibrary.nonNegativeInteger,
  ///     ],
  ///   ),
  /// )
  /// ```
  FormPresenter({
    required T initialState,
    required PropertyDescriptorsBuilder properties,
  }) : super(initialState) {
    initializeFormCompanionMixin(properties);
  }

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) {
    final state = Form.of(context);
    return state == null ? null : _FormStateAdapter(state);
  }
}
