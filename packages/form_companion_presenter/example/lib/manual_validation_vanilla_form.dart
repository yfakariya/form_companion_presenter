// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter/form_companion_extension.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';

// TODO(yfakariya): use generator

//------------------------------------------------------------------------------
// In this example, [AutovalidateMode] of the form and fields are disabled (default value).
// In this case, [CompanionPresenterMixin.canSubmit] always returns `true`,
// so users always tap "submit" button.
// Note that [CompanionPresenterMixin.validateAndSave()] is automatically called
// in [CompanionPresenterMixin.submit] method,
// and [CompanionPresenterMixin.duSubmit] is only called when no validation errors.
//
// This mode is predictable for users by "submit" button is always shown and enabled,
// but it might be frastrated in long form because users cannot recognize their
// error until tapping "submit" button.
// Note that vanilla FormFields requires settings key and onSaved callbacks.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [Form].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [Form.of] to access form state which requires
/// [Form] exists in ancestor of element tree ([BuildContext]).
class ManualValidationVanillaFormAccountPage extends Screen {
  /// Constructor.
  const ManualValidationVanillaFormAccountPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.manual_vanilla_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: _ManualValidationVanillaFormAccountPane(),
      );
}

class _ManualValidationVanillaFormAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_presenter);
    final presenter = ref.watch(_presenter.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            key: presenter.getKey('id', context),
            initialValue: state.id,
            validator: presenter.getPropertyValidator('id', context),
            onSaved: presenter.savePropertyValue('id', context),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr(),
              suffix: AsyncValidationIndicator(
                presenter: presenter,
                propertyName: 'id',
              ),
            ),
          ),
          TextFormField(
            key: presenter.getKey('name', context),
            initialValue: state.name,
            validator: presenter.getPropertyValidator('name', context),
            onSaved: presenter.savePropertyValue('name', context),
            decoration: InputDecoration(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr(),
            ),
          ),
          DropdownButtonFormField<Gender>(
            key: presenter.getKey('gender', context),
            value: state.gender,
            onSaved: presenter.savePropertyValue('gender', context),
            // Tip: required to work
            onChanged: (_) {},
            decoration: InputDecoration(
              labelText: LocaleKeys.gender_label.tr(),
              hintText: LocaleKeys.gender_hint.tr(),
            ),
            items: [
              DropdownMenuItem(
                value: Gender.notKnown,
                child: Text(LocaleKeys.gender_enumNotKnown.tr()),
              ),
              DropdownMenuItem(
                value: Gender.male,
                child: Text(LocaleKeys.gender_enumMale.tr()),
              ),
              DropdownMenuItem(
                value: Gender.female,
                child: Text(LocaleKeys.gender_enumFemale.tr()),
              ),
              DropdownMenuItem(
                value: Gender.notApplicable,
                child: Text(LocaleKeys.gender_enumNotApplicable.tr()),
              ),
            ],
          ),
          TextFormField(
            key: presenter.getKey('age', context),
            initialValue: state.age.toString(),
            validator: presenter.getPropertyValidator('age', context),
            onSaved: presenter.savePropertyValue('age', context),
            decoration: InputDecoration(
              labelText: LocaleKeys.age_label.tr(),
              hintText: LocaleKeys.age_hint.tr(),
            ),
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

/// Testable presenter.
@visibleForTesting
class ManualValidationVanillaFormAccountPresenter extends StateNotifier<Account>
    with CompanionPresenterMixin, FormCompanionMixin {
  final Reader _read;

  /// Creates new [ManualValidationVanillaFormAccountPresenter].
  ManualValidationVanillaFormAccountPresenter(
    Account initialState,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..addText(
          name: 'id',
          validatorFactories: [
            Validator.required,
            Validator.email,
          ],
          asyncValidatorFactories: [
            Validator.id,
          ],
        )
        ..addText(
          name: 'name',
          validatorFactories: [
            Validator.required,
          ],
        )
        ..addEnum<Gender>(
          name: 'gender',
        )
        ..addString(
          name: 'age',
          validatorFactories: [
            Validator.required,
            Validator.min(0),
          ],
          initialValue: 20,
          stringConverter: intStringConverter,
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final id = getSavedPropertyValue<String>('id')!;
    final name = getSavedPropertyValue<String>('name')!;
    final gender = getSavedPropertyValue<Gender>('gender')!;
    // You can omit generic type argument occasionally.
    final age = getSavedPropertyValue<int>('age')!;

    // Call business logic.
    if (!(await doSubmitLogic(id, name, gender, age))) {
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
    transitToHome(_read);
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
    StateNotifierProvider<ManualValidationVanillaFormAccountPresenter, Account>(
  (ref) => ManualValidationVanillaFormAccountPresenter(
    ref.watch(account),
    ref.read,
  ),
);
