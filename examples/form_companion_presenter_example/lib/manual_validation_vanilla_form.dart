import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_presenter_state_notifier/form_presenter_state_notifier.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';

class ManualValidationVanillaFormPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) => Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: _ManualValidationVanillaFormPane(),
      );
}

class _ManualValidationVanillaFormPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final presenter = watch(_presenter.notifier);
    final id = presenter.getProperty<String>('id');
    final name = presenter.getProperty<String>('name');
    final age = presenter.getProperty<String>('age');
    final sex = presenter.getProperty<Sex>('sex');
    final note = presenter.getProperty<String>('note');
    return Column(
      children: [
        TextFormField(
          initialValue: id.value,
          decoration: InputDecoration(
            labelText: LocaleKeys.id_label.tr(),
            hintText: LocaleKeys.id_hint.tr(),
          ),
          validator: id.getValidator(context),
          onSaved: id.setDynamicValue,
        ),
        TextFormField(
          initialValue: name.value,
          decoration: InputDecoration(
            labelText: LocaleKeys.name_label.tr(),
            hintText: LocaleKeys.name_hint.tr(),
          ),
          validator: name.getValidator(context),
          onSaved: name.setDynamicValue,
        ),
        DropdownButtonFormField<Sex>(
          decoration: InputDecoration(
            labelText: LocaleKeys.sex_label.tr(),
            hintText: LocaleKeys.sex_hint.tr(),
          ),
          value: sex.value,
          onSaved: sex.setDynamicValue,
          items: [
            DropdownMenuItem(
              value: Sex.notKnown,
              child: Text(LocaleKeys.sex_enumNotKnown.tr()),
            ),
            DropdownMenuItem(
              value: Sex.male,
              child: Text(LocaleKeys.sex_enumMale.tr()),
            ),
            DropdownMenuItem(
              value: Sex.female,
              child: Text(LocaleKeys.sex_enumFemale.tr()),
            ),
            DropdownMenuItem(
              value: Sex.notApplicable,
              child: Text(LocaleKeys.sex_enumNotApplicable.tr()),
            ),
          ],
        ),
        TextFormField(
          initialValue: age.value.toString(),
          decoration: InputDecoration(
            labelText: LocaleKeys.age_label.tr(),
            hintText: LocaleKeys.age_hint.tr(),
          ),
          validator: age.getValidator(context),
          onSaved: (v) => age.setDynamicValue(int.parse(v!)),
        ),
        TextFormField(
          initialValue: note.value,
          maxLines: null,
          decoration: InputDecoration(
            labelText: LocaleKeys.note_label.tr(),
            hintText: LocaleKeys.note_label.tr(),
          ),
          validator: note.getValidator(context),
          onSaved: note.setDynamicValue,
        ),
      ],
    );
  }
}

@visibleForTesting
class ManualValidationVanillaFormPresenter extends FormPresenter<TargetState> {
  ManualValidationVanillaFormPresenter()
      : super(
          initialState: TargetState.partial(),
          properties: PropertyDescriptorsBuilder()
            ..add<String>(name: 'id')
            ..add<String>(name: 'name')
            ..add<Sex>(name: 'sex')
            ..add<String>(name: 'age')
            ..add<String>(name: 'note'),
        );

  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    if (!(await validateAndSave(maybeFormStateOf(context)!))) {
      return;
    }

    state = TargetState.completed(
      id: getProperty<String>('id').value,
      name: getProperty<String>('name').value,
      sex: getProperty<Sex>('sex').value,
      age: int.parse(getProperty<String>('age').value),
      note: getProperty<String>('note').value,
    );
  }
}

final _presenter =
    StateNotifierProvider<ManualValidationVanillaFormPresenter, TargetState>(
  (_) => ManualValidationVanillaFormPresenter(),
);
