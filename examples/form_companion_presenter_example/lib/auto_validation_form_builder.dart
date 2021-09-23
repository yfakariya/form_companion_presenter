// See LICENCE file in the root.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_presenter_state_notifier/form_builder_presenter_state_notifier.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
import 'package:meta/meta.dart';

import 'l10n/locale_keys.g.dart';
import 'models.dart';
import 'screen.dart';

class AutoValidationFormBuilderPage extends Screen {
  @override
  String get title => LocaleKeys.auto_flutterFormBuilder_title.tr();

  @override
  Widget buildPage(BuildContext context, ScopedReader watch) => FormBuilder(
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: _AutoValidationFormBuilderPane(),
      );
}

class _AutoValidationFormBuilderPane extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    final presenter = watch(_presenter.notifier);
    return Column(
      children: [
        FormBuilderTextField(
          name: 'id',
          initialValue: presenter.getPropertyValue('id'),
          decoration: InputDecoration(
            labelText: LocaleKeys.id_label.tr(),
            hintText: LocaleKeys.id_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('id', context),
        ),
        FormBuilderTextField(
          name: 'name',
          initialValue: presenter.getPropertyValue('name'),
          decoration: InputDecoration(
            labelText: LocaleKeys.name_label.tr(),
            hintText: LocaleKeys.name_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('name', context),
        ),
        FormBuilderDropdown<Sex>(
          name: 'sex',
          decoration: InputDecoration(
            labelText: LocaleKeys.sex_label.tr(),
            hintText: LocaleKeys.sex_hint.tr(),
          ),
          initialValue: presenter.getPropertyValue('sex'),
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
        FormBuilderTextField(
          name: 'age',
          initialValue: presenter.getPropertyValue('age'),
          decoration: InputDecoration(
            labelText: LocaleKeys.age_label.tr(),
            hintText: LocaleKeys.age_hint.tr(),
          ),
          validator: presenter.getPropertyValidator('age', context),
          valueTransformer: (v) => v == null ? null : int.parse(v),
        ),
        FormBuilderTextField(
          name: 'note',
          initialValue: presenter.getPropertyValue('note'),
          maxLines: null,
          decoration: InputDecoration(
            labelText: LocaleKeys.note_label.tr(),
            hintText: LocaleKeys.note_label.tr(),
          ),
          validator: presenter.getPropertyValidator('note', context),
        ),
      ],
    );
  }
}

@visibleForTesting
class AutoValidationFormBuilderPresenter
    extends FormBuilderPresenter<TargetState> {
  AutoValidationFormBuilderPresenter()
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
    StateNotifierProvider<AutoValidationFormBuilderPresenter, TargetState>(
  (_) => AutoValidationFormBuilderPresenter(),
);
