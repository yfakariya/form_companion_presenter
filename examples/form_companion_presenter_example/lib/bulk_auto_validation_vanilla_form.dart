// See LICENCE file in the root.

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/async_validation_indicator.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'bulk_auto_validation_vanilla_form.fcp.dart';
import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';
part 'bulk_auto_validation_vanilla_form.g.dart';
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
// Note that vanilla FormFields requires settings key and onSaved callbacks.
//------------------------------------------------------------------------------

/// Page for [Account] input which just declares [Form].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [Form.of] to access form state which requires
/// [Form] exists in ancestor of element tree ([BuildContext]).
class BulkAutoValidationVanillaFormAccountPage extends Screen {
  /// Constructor.
  const BulkAutoValidationVanillaFormAccountPage();

  @override
  String get title => LocaleKeys.bulk_auto_vanilla_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final presenter = ref
        .read(bulkAutoValidationVanillaFormAccountPresenterProvider.notifier);
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: FormPropertiesRestorationScope(
        presenter: presenter,
        child: _BulkAutoValidationVanillaFormAccountPane(),
      ),
    );
  }
}

class _BulkAutoValidationVanillaFormAccountPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state =
        ref.watch(bulkAutoValidationVanillaFormAccountPresenterProvider);

    if (state is! AsyncData<
        $BulkAutoValidationVanillaFormAccountPresenterFormProperties>) {
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
class BulkAutoValidationVanillaFormAccountPresenter
    extends _$BulkAutoValidationVanillaFormAccountPresenter
    with CompanionPresenterMixin, FormCompanionMixin {
  BulkAutoValidationVanillaFormAccountPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
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
          validatorFactories: [
            Validator.required,
          ],
        )
        ..enumerated(
          name: 'gender',
          enumValues: Gender.values,
        )
        ..integerText(
          name: 'age',
          validatorFactories: [
            Validator.required,
            Validator.min(0),
          ],
        ),
    );
  }

  @override
  FutureOr<$BulkAutoValidationVanillaFormAccountPresenterFormProperties>
      build() async {
    final initialState = await ref.watch(accountStateProvider.future);

    // Restore or set default for optional properties using cascading syntax.
    final builder = properties.copyWith()
      ..age(initialState.age)
      ..gender(initialState.gender);

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

    // Call business logic.
    if (!(await doSubmitLogic(
      id,
      name,
      gender,
      age,
    ))) {
      return;
    }

    final account = Account.registered(
      id: id,
      name: name,
      gender: gender,
      age: age,
      preferredRegions: [],
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
  ) async {
    // Write actual registration logic via API here.
    return true;
  }
}
