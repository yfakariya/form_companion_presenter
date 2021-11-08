// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import '../async_validation_indicator.dart';
import '../l10n/locale_keys.g.dart';
import '../models.dart';
import '../routes.dart';
import '../screen.dart';
//!macro beginVanillaOnly
import '../validators.dart';
//!macro endVanillaOnly

//!macro headerNote

/// //!macro pageDocument
class AccountPageTemplate extends Screen {
  /// Constructor.
  const AccountPageTemplate({Key? key}) : super(key: key);

  @override
  String get title => 'TITLE_TEMPLATE';

  @override
  Widget buildPage(BuildContext context, ScopedReader watch) => FormBuilder(
        //!macro formValidateMode
        child: _AccountPaneTemplate(),
      );
}

class _AccountPaneTemplate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(_presenter);
    final presenter = watch(_presenter.notifier);

    return SingleChildScrollView(
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'id', //!macro fieldInit id
            initialValue: state.id,
            //!macro beginAutoOnly
            autovalidateMode: AutovalidateMode.onUserInteraction,
            //!macro endAutoOnly
            validator: presenter.getPropertyValidator('id', context),
            //!macro beginVanillaOnly
            onSaved: presenter.savePropertyValue('id'),
            //!macro endVanillaOnly
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
          FormBuilderTextField(
            name: 'name', //!macro fieldInit name
            initialValue: state.name,
            //!macro beginAutoOnly
            autovalidateMode: AutovalidateMode.onUserInteraction,
            //!macro endAutoOnly
            validator: presenter.getPropertyValidator('name', context),
            //!macro beginVanillaOnly
            onSaved: presenter.savePropertyValue('name'),
            //!macro endVanillaOnly
            decoration: InputDecoration(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr(),
            ),
          ),
          FormBuilderDropdown<Gender>(
            name: 'gender', //!macro fieldInit gender
            //!macro dropDownInit gender
            onSaved: presenter.savePropertyValue('gender'),
            // Tip: required to work
            onChanged: (_) {},
            //!macro endVanillaOnly
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
          FormBuilderTextField(
            name: 'age', //!macro fieldInit age
            initialValue: state.age.toString(),
            //!macro beginAutoOnly
            autovalidateMode: AutovalidateMode.onUserInteraction,
            //!macro endAutoOnly
            validator: presenter.getPropertyValidator('age', context),
            //!macro beginVanillaOnly
            onSaved: presenter.savePropertyValue('age'),
            //!macro endVanillaOnly
            decoration: InputDecoration(
              labelText: LocaleKeys.age_label.tr(),
              hintText: LocaleKeys.age_hint.tr(),
            ),
          ),
          //!macro beginBuilderOnly
          FormBuilderCheckboxGroup<Region>(
            name: 'preferredRegions', //!macro fieldInit preferredRegions
            initialValue: state.preferredRegsions,
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

/// Testable presenter.
@visibleForTesting
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
        ..add<String>(
          name: 'id',
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            Validator.email,
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            FormBuilderValidators.required,
            FormBuilderValidators.email,
            //!macro endBuilderOnly
          ],
          asyncValidatorFactories: [
            (context) => validateId,
          ],
        )
        ..add<String>(
          name: 'name',
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            FormBuilderValidators.required,
            //!macro endBuilderOnly
          ],
        )
        ..add<Gender>(
          name: 'gender',
        )
        ..add<String>(
          name: 'age',
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            Validator.min(0),
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            FormBuilderValidators.required,
            (context) => FormBuilderValidators.min(context, 0),
            //!macro endBuilderOnly
          ],
        )
        //!macro beginBuilderOnly
        ..add<List<Region>>(name: 'preferredRegions')
      //!macro endBuilderOnly
      ,
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
    //!macro beginBuilderOnly
    final preferredRegions =
        getSavedPropertyValue<List<Region>>('preferredRegions')!;
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
    ref.watch(account).state,
    ref.read,
  ),
);
