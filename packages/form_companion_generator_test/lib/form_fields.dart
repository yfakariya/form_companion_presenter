// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file_: type=lint, unused_element,
// ignore_for_file: public_member_api_docs

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

import 'enum.dart';
import 'enum.dart' as e;

// for allowing emitter testings lookup FormFields.

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

const Type dropdownButtonFormFieldOfString = DropdownButtonFormField<String>;

const Type formBuilderDropdownOfMyEnum = FormBuilderDropdown<MyEnum>;
const Type formBuilderFilterChipOfMyEnum = FormBuilderFilterChip<MyEnum>;

const Type myEnum = MyEnum;

typedef _StringComparison = int Function(String, String);

const Type stringComparison = _StringComparison;

class FormFieldWithPropertyParameter extends TextFormField {
  FormFieldWithPropertyParameter({
    Key? key,
    String? initialValue,
    InputDecoration? decoration = const InputDecoration(),
    FormFieldSetter<String>? onSaved,
    FormFieldValidator<String>? validator,
    // ignore: avoid_unused_constructor_parameters
    String? property,
  }) : super(
          key: key,
          initialValue: initialValue,
          decoration: decoration,
          onSaved: onSaved,
          validator: validator,
        );
}

class FormFieldRefersConstants extends TextFormField {
  final String withPrefix;
  final String withoutPrefix;

  FormFieldRefersConstants({
    this.withPrefix = e.constVariable,
    this.withoutPrefix = constVariable,
  });
}
