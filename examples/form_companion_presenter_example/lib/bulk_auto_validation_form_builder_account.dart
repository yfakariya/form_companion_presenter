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

import 'bulk_auto_validation_form_builder_account.fcp.dart';
import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';

//------------------------------------------------------------------------------
// In this example, [AutovalidateMode] of the form and fields are set to
// [AutovalidateMode.onUserInteraction].
// In this case, [CompanionPresenterMixin.canSubmit] returns `false` when any
// invalid inputs exist.
// Note that users can tap "submit" button in initial state, so
// [CompanionPresenterMixin.validateAndSave()] is still automatically called
// in [CompanionPresenterMixin.submit] method,
// and [CompanionPresenterMixin.duSubmit] is only called when no validation errors.
//
// This mode is predictable for users by "submit" button is shown and enabled initially,
// and users can recognize their error after input, but it is frastrated because
// some field's error causes displaying all fields error even if the fields are
// not input anything by the user. It might be helpful for some situation,
// but it might be just annoying on many cases.
// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [FormBuilder].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [FormBuilder.of] to access form state which requires
/// [FormBuilder] exists in ancestor of element tree ([BuildContext]).
class BulkAutoValidationFormBuilderAccountPage extends Screen {
  /// Constructor.
  const BulkAutoValidationFormBuilderAccountPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.bulk_auto_flutterFormBuilderAccount_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) => FormBuilder(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _BulkAutoValidationFormBuilderAccountPane(),
      );
}

class _BulkAutoValidationFormBuilderAccountPane extends ConsumerWidget {
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
class BulkAutoValidationFormBuilderAccountPresenter
    extends StateNotifier<Account>
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  final Reader _read;

  /// Creates new [BulkAutoValidationFormBuilderAccountPresenter].
  BulkAutoValidationFormBuilderAccountPresenter(
    Account initialState,
    this._read,
  ) : super(initialState) {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
          initialValue: initialState.id,
          validatorFactories: [
            (_) => FormBuilderValidators.required(),
            (_) => FormBuilderValidators.email(),
          ],
          asyncValidatorFactories: [
            Validator.id,
          ],
        )
        ..string(
          name: 'name',
          initialValue: initialState.name,
          validatorFactories: [
            (_) => FormBuilderValidators.required(),
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
            (_) => FormBuilderValidators.required(),
            (_) => FormBuilderValidators.min(0),
          ],
        )
        ..enumeratedList<Region>(
          name: 'preferredRegions',
          initialValues: initialState.preferredRegsions,
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
    final preferredRegions = this.preferredRegions.value!;

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
    List<Region> preferredRegions,
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}

final _presenter = StateNotifierProvider<
    BulkAutoValidationFormBuilderAccountPresenter, Account>(
  (ref) => BulkAutoValidationFormBuilderAccountPresenter(
    ref.watch(account),
    ref.read,
  ),
);
