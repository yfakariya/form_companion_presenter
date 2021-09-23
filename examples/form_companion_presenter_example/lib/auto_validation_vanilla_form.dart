// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:form_presenter_state_notifier/form_presenter_state_notifier.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'screen.dart';

class AutoValidationVanillaFormPage extends Screen {
  @override
  String get title => LocaleKeys.auto_vanilla_title.tr();

  @override
  Widget buildPage(BuildContext context, ScopedReader watch) => Form(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _AutoValidationVanillaFormPane(),
      );
}

class _AutoValidationVanillaFormPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final presenter = watch(_presenter.notifier);
    return Column(
      children: [
        TextFormField(
          initialValue: presenter.getPropertyValue('id'),
          decoration: InputDecoration(
            labelText: LocaleKeys.id_label.tr(),
            hintText: LocaleKeys.id_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('id', context),
          onSaved: presenter.savePropertyValue('id'),
        ),
        TextFormField(
          initialValue: presenter.getPropertyValue('name'),
          decoration: InputDecoration(
            labelText: LocaleKeys.name_label.tr(),
            hintText: LocaleKeys.name_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('name', context),
          onSaved: presenter.savePropertyValue('name'),
        ),
        DropdownButtonFormField<Sex>(
          decoration: InputDecoration(
            labelText: LocaleKeys.sex_label.tr(),
            hintText: LocaleKeys.sex_hint.tr(),
          ),
          value: presenter.getPropertyValue('sex'),
          onSaved: presenter.savePropertyValue('sex'),
          // Tip: required to work
          onChanged: (_) {},
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
          initialValue: presenter.getPropertyValue('age'),
          decoration: InputDecoration(
            labelText: LocaleKeys.age_label.tr(),
            hintText: LocaleKeys.age_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('age', context),
          onSaved: presenter.savePropertyValue('age'),
        ),
        TextFormField(
          initialValue: presenter.getPropertyValue('note'),
          maxLines: null,
          decoration: InputDecoration(
            labelText: LocaleKeys.note_label.tr(),
            hintText: LocaleKeys.note_label.tr(),
          ),
          validator: presenter.getPropertyValidator('note', context),
          onSaved: presenter.savePropertyValue('note'),
        ),
      ],
    );
  }
}

@visibleForTesting
class AutoValidationVanillaFormPresenter extends FormPresenter<TargetState> {
  AutoValidationVanillaFormPresenter()
      : super(
          initialState: TargetState.partial(),
          properties: PropertyDescriptorsBuilder()
            ..add<String>(name: 'id')
            ..add<String>(name: 'name')
            ..add<Sex>(
              name: 'sex',
              initialValue: Sex.notKnown,
            )
            ..add<String>(
              name: 'age',
              initialValue: '18',
            )
            ..add<String>(name: 'note'),
        );

  @override
  FutureOr<void> doSubmit(BuildContext context) async {
    state = TargetState.completed(
      id: getPropertyValue('id')!,
      name: getPropertyValue('name')!,
      sex: getPropertyValue('sex')!,
      age: int.parse(getPropertyValue('age')!),
      note: getPropertyValue('note')!,
    );
  }
}

final _presenter =
    StateNotifierProvider<AutoValidationVanillaFormPresenter, TargetState>(
  (_) => AutoValidationVanillaFormPresenter(),
);
