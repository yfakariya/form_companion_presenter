// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_generator_test_targets/properties.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormBuilderPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  TheFormBuilderPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<String>(name: 'propString')
        ..add<MyEnum>(name: 'propEnum')
        ..add<bool>(name: 'propBool')
        ..add<DateTime>(name: 'propDateTime')
        ..add<DateTimeRange>(name: 'propDateTimeRange')
        ..add<RangeValues>(name: 'propRangeValues')
        ..add<List<MyEnum>>(name: 'propEnumList')
        ..add<List<bool>>(name: 'propBoolList')
        ..addWithField<bool, FormBuilderCheckbox>(name: 'propBoolCheckBox')
        ..addWithField<List<MyEnum>, FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumListCheckBoxGroup',
        )
        ..addWithField<MyEnum, FormBuilderChoiceChip<MyEnum>>(
          name: 'propEnumChoiceChip',
        )
        ..addWithField<List<MyEnum>, FormBuilderFilterChip<MyEnum>>(
          name: 'propEnumListFilterChip',
        )
        ..addWithField<MyEnum, FormBuilderRadioGroup<MyEnum>>(
          name: 'propEnumRadioGroup',
        )
        ..addWithField<MyEnum, FormBuilderSegmentedControl<MyEnum>>(
          name: 'propEnumSegmentedControl',
        )
        ..addWithField<double, FormBuilderSlider>(
          name: 'propDoubleSlider',
        )
      // TODO(yfakariya): converter test
      // ..add<int>(
      //   name: 'propInt',
      // )
      ,
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
