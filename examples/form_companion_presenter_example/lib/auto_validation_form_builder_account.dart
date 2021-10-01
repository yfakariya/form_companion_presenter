// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'screen.dart';

//------------------------------------------------------------------------------
// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [FormBuilder].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [FormBuilder.of] to access form state which requires
/// [FormBuilder] exists in ancestor of element tree ([BuildContext]).
class AutoValidationFormBuilderAccountPage extends Screen {
  /// Constructor.
  const AutoValidationFormBuilderAccountPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.auto_flutterFormBuilderAccount_title.tr();

  @override
  Widget buildPage(BuildContext context, ScopedReader watch) => FormBuilder(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _AutoValidationFormBuilderAccountPane(),
      );
}

class _AutoValidationFormBuilderAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final state = watch(_presenter);
    final presenter = watch(_presenter.notifier);

    return Column(
      children: [
        FormBuilderTextField(
          name: 'id',
          initialValue: state.id,
          validator: presenter.getPropertyValidator('id', context),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: LocaleKeys.id_label.tr(),
            hintText: LocaleKeys.id_hint.tr(),
          ),
        ),
        FormBuilderTextField(
          name: 'name',
          initialValue: state.name,
          validator: presenter.getPropertyValidator('name', context),
          decoration: InputDecoration(
            labelText: LocaleKeys.name_label.tr(),
            hintText: LocaleKeys.name_hint.tr(),
          ),
        ),
        FormBuilderDropdown<Gender>(
          name: 'gender',
          initialValue: state.gender,
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
          name: 'age',
          initialValue: state.age.toString(),
          validator: presenter.getPropertyValidator('age', context),
          decoration: InputDecoration(
            labelText: LocaleKeys.age_label.tr(),
            hintText: LocaleKeys.age_hint.tr(),
          ),
        ),
        FormBuilderCheckboxGroup<Region>(
          name: 'preferredRegions',
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
        ElevatedButton(
          onPressed: presenter.submit(context),
          child: Text(
            LocaleKeys.submit.tr(),
          ),
        ),
      ],
    );
  }
}

/// Testable presenter.
@visibleForTesting
class AutoValidationFormBuilderAccountPresenter extends StateNotifier<Account>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final Reader _read;

  /// Creates new [AutoValidationFormBuilderAccountPresenter].
  AutoValidationFormBuilderAccountPresenter(
    Account initialState,
    this._read,
  ) : super(initialState) {
    initializeFormCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<String>(name: 'id')
        ..add<String>(name: 'name')
        ..add<Gender>(
          name: 'gender',
        )
        ..add<String>(
          name: 'age',
        )
        ..add<List<Region>>(name: 'preferredRegions'),
    );
  }

  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    // Get saved values here to call business logic.
    final id = getSavedPropertyValue<String>('id')!;
    final name = getSavedPropertyValue<String>('name')!;
    final gender = getSavedPropertyValue<Gender>('gender')!;
    // You can omit generic type argument occasionally.
    final age = int.parse(getSavedPropertyValue('age')!);
    final preferredRegions =
        getSavedPropertyValue<List<Region>>('preferredRegions')!;

    // Call business logic.
    if (!(await doSubmitLogic(id, name, gender, age, preferredRegions))) {
      return;
    }

    // Set local state.
    state = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: preferredRegions,
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
    List<Region> preferredRegions,
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}

final _presenter =
    StateNotifierProvider<AutoValidationFormBuilderAccountPresenter, Account>(
  (ref) => AutoValidationFormBuilderAccountPresenter(
    ref.watch(account).state,
    ref.read,
  ),
);
