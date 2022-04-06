// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file_: type=lint, unused_element,
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'enum.dart';

// for allowing emitter testings loopup FormFields.

const Type textFormField = TextFormField;
const Type dropdownButtonFormField = DropdownButtonFormField;
const Type formBuilderCheckBox = FormBuilderCheckbox;
const Type formBuilderCheckboxGroup = FormBuilderCheckboxGroup;
const Type formBuilderChoiceChip = FormBuilderChoiceChip;
const Type formBuilderDateRangePicker = FormBuilderDateRangePicker;
const Type formBuilderDateTimePicker = FormBuilderDateTimePicker;
const Type formBuilderDropdown = FormBuilderDropdown;
const Type formBuilderFilterChip = FormBuilderFilterChip;
const Type formBuilderRadioGroup = FormBuilderRadioGroup;
const Type formBuilderRangeSlider = FormBuilderRangeSlider;
const Type formBuilderSegmentedControl = FormBuilderSegmentedControl;
const Type formBuilderSlider = FormBuilderSlider;
const Type formBuilderSwitch = FormBuilderSwitch;
const Type formBuilderTextField = FormBuilderTextField;
const Type dateTime = DateTime;
const Type dateTimeRange = DateTimeRange;

const Type formBuilderDropdownOfMyEnum = FormBuilderDropdown<MyEnum>;
const Type formBuilderFilterChipOfMyEnum = FormBuilderFilterChip<MyEnum>;

const Type myEnum = MyEnum;

typedef _StringComparison = int Function(String, String);

const Type stringComparison = _StringComparison;
