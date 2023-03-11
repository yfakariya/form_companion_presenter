// See LICENCE file in the root.

import 'dart:async';

/* #PRE_IMPORT# */
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_annotation.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_generator_test_targets/enum.dart';
/* #POST_IMPORT# */

/* #PART# */

@formCompanion
class TheFormBuilderPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  TheFormBuilderPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(name: 'propString')
        ..enumerated(
          name: 'propEnum',
          enumValues: MyEnum.values,
        )
        ..boolean(name: 'propBool')
        ..dateTime(name: 'propDateTime')
        ..dateTimeRange(name: 'propDateTimeRange')
        ..rangeValues(name: 'propRangeValues')
        ..enumeratedList(
          name: 'propEnumList',
          enumValues: MyEnum.values,
        )
        ..booleanWithField<FormBuilderCheckbox>(name: 'propBoolCheckBox')
        ..enumeratedListWithField<MyEnum, FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumListCheckBoxGroup',
          enumValues: MyEnum.values,
        )
        ..enumeratedWithField<MyEnum, FormBuilderChoiceChip<MyEnum>>(
          name: 'propEnumChoiceChip',
          enumValues: MyEnum.values,
        )
        ..enumeratedListWithField<MyEnum, FormBuilderFilterChip<MyEnum>>(
          name: 'propEnumListFilterChip',
          enumValues: MyEnum.values,
        )
        ..enumeratedWithField<MyEnum, FormBuilderRadioGroup<MyEnum>>(
          name: 'propEnumRadioGroup',
          enumValues: MyEnum.values,
        )
        ..enumeratedWithField<MyEnum, FormBuilderSegmentedControl<MyEnum>>(
          name: 'propEnumSegmentedControl',
          enumValues: MyEnum.values,
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
