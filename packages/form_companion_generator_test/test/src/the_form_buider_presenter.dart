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
        ..string(name: 'propString')
        ..enumerated<MyEnum>(name: 'propEnum')
        ..boolean(name: 'propBool')
        ..dateTime(name: 'propDateTime')
        ..dateTimeRange(name: 'propDateTimeRange')
        ..rangeValues(name: 'propRangeValues')
        ..enumeratedList<MyEnum>(name: 'propEnumList')
        ..booleanList(name: 'propBoolList')
        ..booleanWithField<FormBuilderCheckbox>(name: 'propBoolCheckBox')
        ..enumeratedListWithField<MyEnum, FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumListCheckBoxGroup',
        )
        ..enumeratedWithField<MyEnum, FormBuilderChoiceChip<MyEnum>>(
          name: 'propEnumChoiceChip',
        )
        ..enumeratedListWithField<MyEnum, FormBuilderFilterChip<MyEnum>>(
          name: 'propEnumListFilterChip',
        )
        ..enumeratedWithField<MyEnum, FormBuilderRadioGroup<MyEnum>>(
          name: 'propEnumRadioGroup',
        )
        ..enumeratedWithField<MyEnum, FormBuilderSegmentedControl<MyEnum>>(
          name: 'propEnumSegmentedControl',
        )
        ..realWithField<FormBuilderSlider>(
          name: 'propDoubleSlider',
        )
        ..integerText(
          name: 'propInt',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
