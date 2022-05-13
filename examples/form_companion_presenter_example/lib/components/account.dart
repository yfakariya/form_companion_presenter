// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

//!macro beginNotManualOnly
//!macro importFcp
//!macro endNotManualOnly
import '../l10n/locale_keys.g.dart';
//!macro beginManualOnly
//!macro importFcp
//!macro endManualOnly
import '../models.dart';
import '../routes.dart';
import '../screen.dart';
import '../validators.dart';
//!macro beginRemove
import 'account.fcp.dart';
//!macro endRemove

//!macro headerNote

/// //!macro pageDocument
class AccountPageTemplate extends Screen {
  /// Constructor.
  const AccountPageTemplate({Key? key}) : super(key: key);

  @override
  String get title => 'TITLE_TEMPLATE';

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => FormBuilder(
        //!macro formValidateMode
        child: _AccountPaneTemplate(),
      );
}

class _AccountPaneTemplate extends ConsumerWidget {
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
            decoration: InputDecoration(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr(),
            ),
          ),
          presenter.fields.gender(
            context,
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
          presenter.fields.age(context,
              decoration: InputDecoration(
                labelText: LocaleKeys.age_label.tr(),
                hintText: LocaleKeys.age_hint.tr(),
              )),
          //!macro beginBuilderOnly
          presenter.fields.preferredRegions(
            context,
            decoration: InputDecoration(
              labelText: LocaleKeys.preferredRegions_label.tr(),
              hintText: LocaleKeys.preferredRegions_hint.tr(),
            ),
            options: [
              FormBuilderFieldOption(
                value: Region.afurika,
                child: Text(
                  LocaleKeys.region_afurika.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: Region.asia,
                child: Text(
                  LocaleKeys.region_asia.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: Region.australia,
                child: Text(
                  LocaleKeys.region_australia.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: Region.europe,
                child: Text(
                  LocaleKeys.region_europe.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: Region.northAmelica,
                child: Text(
                  LocaleKeys.region_northAmelica.tr(),
                ),
              ),
              FormBuilderFieldOption(
                value: Region.southAmelica,
                child: Text(
                  LocaleKeys.region_southAmelica.tr(),
                ),
              ),
            ],
          ),
          //!macro endBuilderOnly
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
class AccountPresenterTemplate extends StateNotifier<Account>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final Reader _read;

  /// Creates new [AccountPresenterTemplate].
  AccountPresenterTemplate(
    Account initialState,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
          initialValue: initialState.id,
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            Validator.email,
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            (_) => FormBuilderValidators.required(),
            (_) => FormBuilderValidators.email(),
            //!macro endBuilderOnly
          ],
          asyncValidatorFactories: [
            Validator.id,
          ],
        )
        ..string(
          name: 'name',
          initialValue: initialState.name,
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            (_) => FormBuilderValidators.required(),
            //!macro endBuilderOnly
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
            //!macro beginVanillaOnly
            Validator.required,
            Validator.min(0),
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            (_) => FormBuilderValidators.required(),
            (_) => FormBuilderValidators.min(0),
            //!macro endBuilderOnly
          ],
        )
        //!macro beginBuilderOnly
        ..enumeratedList<Region>(
          name: 'preferredRegions',
          initialValues: initialState.preferredRegsions,
        )
      //!macro endBuilderOnly
      ,
    );
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final id = this.id.value!;
    final name = this.name.value!;
    final gender = this.gender.value!;
    final age = this.age.value!;
    //!macro beginBuilderOnly
    final preferredRegions = this.preferredRegions.value!;
    //!macro endBuilderOnly

    // Call business logic.
    if (!(await doSubmitLogic(
        id,
        name,
        gender,
        age
        //!macro beginBuilderOnly
        ,
        preferredRegions
        //!macro endBuilderOnly
        ))) {
      return;
    }

    // Set local state.
    state = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: preferredRegions, //!macro preferredRegionsAssignment
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
    //!macro beginBuilderOnly
    List<Region> preferredRegions,
    //!macro endBuilderOnly
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}

final _presenter = StateNotifierProvider<AccountPresenterTemplate, Account>(
  (ref) => AccountPresenterTemplate(
    ref.watch(account),
    ref.read,
  ),
);
