// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_annotation.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_generator_test_targets/enum.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormBuilderPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  TheFormBuilderPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..addText(name: 'propString')
        ..addEnum<MyEnum>(name: 'propEnum')
        ..addBool(name: 'propBool')
        ..addDateTime(name: 'propDateTime')
        ..addDateTimeRange(name: 'propDateTimeRange')
        ..addRangeValues(name: 'propRangeValues')
        ..addEnumList<MyEnum>(name: 'propEnumList')
        ..addBoolList(name: 'propBoolList')
        ..addBoolWithField<FormBuilderCheckbox>(name: 'propBoolCheckBox')
        ..addEnumListWithField<MyEnum, FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumListCheckBoxGroup',
        )
        ..addEnumWithField<MyEnum, FormBuilderChoiceChip<MyEnum>>(
          name: 'propEnumChoiceChip',
        )
        ..addEnumListWithField<MyEnum, FormBuilderFilterChip<MyEnum>>(
          name: 'propEnumListFilterChip',
        )
        ..addEnumWithField<MyEnum, FormBuilderRadioGroup<MyEnum>>(
          name: 'propEnumRadioGroup',
        )
        ..addEnumWithField<MyEnum, FormBuilderSegmentedControl<MyEnum>>(
          name: 'propEnumSegmentedControl',
        )
        ..addDoubleWithField<FormBuilderSlider>(
          name: 'propDoubleSlider',
        )
        ..addInt(
          name: 'propInt',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
