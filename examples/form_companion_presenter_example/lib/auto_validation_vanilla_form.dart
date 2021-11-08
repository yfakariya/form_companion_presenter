// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import 'async_validation_indicator.dart';
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
  Widget buildPage(BuildContext context, ScopedReader watch) => Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: _AutoValidationVanillaFormAccountPane(),
      );
}

class _AutoValidationVanillaFormAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(_presenter);
    final presenter = watch(_presenter.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          TextFormField(
            key: presenter.getKey('id', context),
            initialValue: state.id,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: presenter.getPropertyValidator('id', context),
            onSaved: presenter.savePropertyValue('id'),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: presenter.getPropertyValidator('name', context),
            onSaved: presenter.savePropertyValue('name'),
            decoration: InputDecoration(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr(),
            ),
          ),
          DropdownButtonFormField<Gender>(
            key: presenter.getKey('gender', context),
            value: state.gender,
            onSaved: presenter.savePropertyValue('gender'),
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
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: presenter.getPropertyValidator('age', context),
            onSaved: presenter.savePropertyValue('age'),
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
        ..add<String>(
          name: 'id',
          validatorFactories: [
            Validator.required,
            Validator.email,
          ],
          asyncValidatorFactories: [
            (context) => validateId,
          ],
        )
        ..add<String>(
          name: 'name',
          validatorFactories: [
            Validator.required,
          ],
        )
        ..add<Gender>(
          name: 'gender',
        )
        ..add<String>(
          name: 'age',
          validatorFactories: [
            Validator.required,
            Validator.min(0),
          ],
        ),
    );
  }

  FutureOr<String?> validateId(
      String? value, AsyncValidatorOptions options) async {
    if (value == null || value.isEmpty) {
      return 'ID is required.';
    }

    // Dummy actions to check async validator behavior.
    switch (value) {
      case 'john@example.com':
        return await Future.delayed(
          const Duration(seconds: 5),
          () => throw Exception('Server is temporary unavailable.'),
        );
      case 'jane@example.com':
        return await Future.delayed(
          const Duration(seconds: 5),
          () => '$value is already used.',
        );
      default:
        return await Future.delayed(
          const Duration(seconds: 5),
          () => null,
        );
    }
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final id = getSavedPropertyValue<String>('id')!;
    final name = getSavedPropertyValue<String>('name')!;
    final gender = getSavedPropertyValue<Gender>('gender')!;
    // You can omit generic type argument occasionally.
    final age = int.parse(getSavedPropertyValue('age')!);

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
    _read(account).state = state;
    _read(pagesProvider).state = home;
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
    ref.watch(account).state,
    ref.read,
  ),
);
