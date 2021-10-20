// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'screen.dart';

//------------------------------------------------------------------------------
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
        autovalidateMode: AutovalidateMode.onUserInteraction,
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
            validator: presenter.getPropertyValidator('id', context),
            onSaved: presenter.savePropertyValue('id'),
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr(),
            ),
          ),
          TextFormField(
            key: presenter.getKey('name', context),
            initialValue: state.name,
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
        )
        ..add<String>(
          name: 'name',
        )
        ..add<Gender>(
          name: 'gender',
        )
        ..add<String>(
          name: 'age',
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
