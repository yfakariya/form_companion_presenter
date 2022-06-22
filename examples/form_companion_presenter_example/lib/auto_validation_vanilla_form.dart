// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'auto_validation_vanilla_form.fcp.dart';
import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';

//------------------------------------------------------------------------------
// In this example, [AutovalidateMode] of the form is disabled (default value)
// and [AutovalidateMode] of fields are set to [AutovalidateMode.onUserInteraction].
// In this case, [CompanionPresenterMixin.canSubmit] returns `false` when any
// invalid inputs exist.
// Note that users can tap "submit" button in initial state, so
// [CompanionPresenterMixin.validateAndSave()] is still automatically called
// in [CompanionPresenterMixin.submit] method,
// and [CompanionPresenterMixin.duSubmit] is only called when no validation errors.
//
// This mode is predictable for users by "submit" button is shown and enabled initially,
// and users can recognize their error after input. It looks ideal but some situation
// needs "bulk auto" or "manual" mode.
// Note that vanilla FormFields requires settings key and onSaved callbacks.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [Form].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [Form.of] to access form state which requires
/// [Form] exists in ancestor of element tree ([BuildContext]).
class AutoValidationVanillaFormAccountPage extends Screen {
  /// Constructor.
  const AutoValidationVanillaFormAccountPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.auto_vanilla_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: _AutoValidationVanillaFormAccountPane(),
      );
}

class _AutoValidationVanillaFormAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presenter = ref.watch(_presenter.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          presenter.fields.id(
            context,
            decoration: InputDecoration(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr(),
              suffix: AsyncValidationIndicator(
                presenter: presenter,
                propertyName: 'id',
              ),
            ),
          ),
          presenter.fields.name(
            context,
          ),
          presenter.fields.gender(
            context,
          ),
          presenter.fields.age(
            context,
          ),
          ElevatedButton(
            onPressed: presenter.submit(context),
            child: Text(
              LocaleKeys.submit.tr(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Presenter which holds form properties.
@formCompanion
class AutoValidationVanillaFormAccountPresenter extends StateNotifier<Account>
    with CompanionPresenterMixin, FormCompanionMixin {
  final Reader _read;

  /// Creates new [AutoValidationVanillaFormAccountPresenter].
  AutoValidationVanillaFormAccountPresenter(
    Account initialState,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
          initialValue: initialState.id,
          validatorFactories: [
            Validator.required,
            Validator.email,
          ],
          asyncValidatorFactories: [
            Validator.id,
          ],
        )
        ..string(
          name: 'name',
          initialValue: initialState.name,
          validatorFactories: [
            Validator.required,
          ],
        )
        ..enumerated<Gender>(
          name: 'gender',
          initialValue: initialState.gender,
        )
        ..integerText(
          name: 'age',
          initialValue: initialState.age,
          validatorFactories: [
            Validator.required,
            Validator.min(0),
          ],
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final id = this.id.value!;
    final name = this.name.value!;
    final gender = this.gender.value!;
    final age = this.age.value!;

    // Call business logic.
    if (!(await doSubmitLogic(
      id,
      name,
      gender,
      age,
    ))) {
      return;
    }

    // Set local state.
    state = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: [],
    );

    // Propagate to global state.
    _read(account.state).state = state;
    router.go('/');
  }

  /// Example of business logic of submit.
  /// Returns a bool value to indicate submit is success or not.
  /// For example, this method returns `false` if the [id] is already used
  /// when the server API is called (you cannot avoid this because someone may
  /// use the same ID between validation and submit even if you use validation
  /// logic to call server side API.)
  @visibleForTesting
  FutureOr<bool> doSubmitLogic(
    String id,
    String name,
    Gender gender,
    int age,
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}

final _presenter =
    StateNotifierProvider<AutoValidationVanillaFormAccountPresenter, Account>(
  (ref) => AutoValidationVanillaFormAccountPresenter(
    ref.watch(account),
    ref.read,
  ),
);
