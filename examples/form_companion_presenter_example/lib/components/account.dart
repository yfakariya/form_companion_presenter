// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
//!macro beginBuilderOnly
import 'package:flutter_form_builder/flutter_form_builder.dart';
//!macro endBuilderOnly
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/async_validation_indicator.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_annotation.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
//!macro beginBuilderOnly
import 'package:form_builder_validators/form_builder_validators.dart';
//!macro endBuilderOnly
import 'package:riverpod_annotation/riverpod_annotation.dart';

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

part 'account.g.dart';
//!macro endRemove
//!macro partG

//!macro headerNote

/// //!macro pageDocument
class AccountPageTemplate extends Screen {
  /// Constructor.
  const AccountPageTemplate();

  @override
  String get title => 'TITLE_TEMPLATE';

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final presenter = ref.read(accountPresenterTemplateProvider.notifier);
    return FormBuilder(
      //!macro formValidateMode
      child: FormPropertiesRestorationScope(
        presenter: presenter,
        child: _AccountPaneTemplate(),
      ),
    );
  }
}

class _AccountPaneTemplate extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountPresenterTemplateProvider);

    if (state is! AsyncData<$AccountPresenterTemplateFormProperties>) {
      return Text('now loading...');
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          state.value.fields.id(
            context,
            decoration: InputDecoration(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr(),
              suffix: AsyncValidationIndicator(
                presenter: state.value.presenter,
                propertyName: 'id',
              ),
            ),
          ),
          state.value.fields.name(
            context,
          ),
          state.value.fields.gender(
            context,
          ),
          state.value.fields.age(
            context,
          ),
          //!macro beginBuilderOnly
          state.value.fields.preferredRegions(
            context,
          ),
          //!macro endBuilderOnly
          ElevatedButton(
            onPressed: state.value.submit(context),
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
@riverpod
class AccountPresenterTemplate extends _$AccountPresenterTemplate
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  AccountPresenterTemplate() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
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
          validatorFactories: [
            //!macro beginVanillaOnly
            Validator.required,
            //!macro endVanillaOnly
            //!macro beginBuilderOnly
            (_) => FormBuilderValidators.required(),
            //!macro endBuilderOnly
          ],
        )
        ..enumerated(
          name: 'gender',
          enumValues: Gender.values,
        )
        ..integerText(
          name: 'age',
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
        ..enumeratedList(
          name: 'preferredRegions',
          enumValues: Region.values,
        )
      //!macro endBuilderOnly
      ,
    );
  }

  @override
  FutureOr<$AccountPresenterTemplateFormProperties> build() async {
    final initialState = await ref.watch(accountStateProvider.future);

    // Restore or set default for optional properties using cascading syntax.
    final builder = properties.copyWith()
          ..age(initialState.age)
          ..gender(initialState.gender)
          //!macro beginBuilderOnly
          ..preferredRegions(initialState.preferredRegions)
        //!macro endBuilderOnly
        ;

    // Try to restore required fields only if stored.
    if (initialState.id != null) {
      builder.id(initialState.id!);
    }

    if (initialState.name != null) {
      builder.name(initialState.name!);
    }

    return resetProperties(builder.build());
  }

  @override
  FutureOr<void> doSubmit() async {
    // Get saved values here to call business logic.
    final id = properties.values.id;
    final name = properties.values.name;
    final gender = properties.values.gender;
    final age = properties.values.age;
    //!macro beginBuilderOnly
    final preferredRegions = properties.values.preferredRegions;
    //!macro endBuilderOnly

    // Call business logic.
    if (!(await doSubmitLogic(
      id,
      name,
      gender,
      age,
      //!macro beginBuilderOnly
      preferredRegions,
      //!macro endBuilderOnly
    ))) {
      return;
    }

    final account = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: preferredRegions, //!macro preferredRegionsAssignment
    );

    // Propagate to global state.
    await ref.read(accountStateProvider.notifier).save(account);
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
    //!macro beginBuilderOnly
    List<Region> preferredRegions,
    //!macro endBuilderOnly
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}
