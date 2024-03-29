// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_companion_presenter/async_validation_indicator.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_annotation.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'l10n/locale_keys.g.dart';
import 'manual_validation_form_builder_account.fcp.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';
part 'manual_validation_form_builder_account.g.dart';
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
// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [FormBuilder].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [FormBuilder.of] to access form state which requires
/// [FormBuilder] exists in ancestor of element tree ([BuildContext]).
class ManualValidationFormBuilderAccountPage extends Screen {
  /// Constructor.
  const ManualValidationFormBuilderAccountPage();

  @override
  String get title => LocaleKeys.manual_flutterFormBuilderAccount_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final presenter =
        ref.read(manualValidationFormBuilderAccountPresenterProvider.notifier);
    return FormBuilder(
      autovalidateMode: AutovalidateMode.disabled,
      child: FormPropertiesRestorationScope(
        presenter: presenter,
        child: _ManualValidationFormBuilderAccountPane(),
      ),
    );
  }
}

class _ManualValidationFormBuilderAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(manualValidationFormBuilderAccountPresenterProvider);

    if (state is! AsyncData<
        $ManualValidationFormBuilderAccountPresenterFormProperties>) {
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
          state.value.fields.preferredRegions(
            context,
          ),
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
@FormCompanion(autovalidate: false)
@riverpod
class ManualValidationFormBuilderAccountPresenter
    extends _$ManualValidationFormBuilderAccountPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  ManualValidationFormBuilderAccountPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
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
          validatorFactories: [
            (_) => FormBuilderValidators.required(),
          ],
        )
        ..enumerated(
          name: 'gender',
          enumValues: Gender.values,
        )
        ..integerText(
          name: 'age',
          validatorFactories: [
            (_) => FormBuilderValidators.required(),
            (_) => FormBuilderValidators.min(0),
          ],
        )
        ..enumeratedList(
          name: 'preferredRegions',
          enumValues: Region.values,
        ),
    );
  }

  @override
  FutureOr<$ManualValidationFormBuilderAccountPresenterFormProperties>
      build() async {
    final initialState = await ref.watch(accountStateProvider.future);

    // Restore or set default for optional properties using cascading syntax.
    final builder = properties.copyWith()
      ..age(initialState.age)
      ..gender(initialState.gender)
      ..preferredRegions(initialState.preferredRegions);

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
    final preferredRegions = properties.values.preferredRegions;

    // Call business logic.
    if (!(await doSubmitLogic(
      id,
      name,
      gender,
      age,
      preferredRegions,
    ))) {
      return;
    }

    final account = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: preferredRegions,
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
    List<Region> preferredRegions,
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}
