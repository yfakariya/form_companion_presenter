// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint
// GENERATED CODE - DO NOT MODIFY BY HAND

import 'dart:ui' as ui;

import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:meta/meta.dart';

/// A builder for [FormBuilderSwitch].
@sealed
class FormBuilderSwitchBuilder {
  Key? key;
  String? name;
  FormFieldValidator<bool>? validator;
  bool? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<bool?>? onChanged;
  ValueTransformer<bool?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<bool>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  Widget? title;
  Color? activeColor;
  Color? activeTrackColor;
  Color? inactiveThumbColor;
  Color? inactiveTrackColor;
  ImageProvider? activeThumbImage;
  ImageProvider? inactiveThumbImage;
  Widget? subtitle;
  Widget? secondary;
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.trailing;
  EdgeInsets contentPadding = EdgeInsets.zero;
  bool autofocus = false;
  bool selected = false;

  /// Build [FormBuilderSwitch] instance from this builder.
  FormBuilderSwitch build() {
    assert(name != null, "'name' is required.");
    assert(title != null, "'title' is required.");
    return FormBuilderSwitch(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      title: title!,
      activeColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      activeThumbImage: activeThumbImage,
      inactiveThumbImage: inactiveThumbImage,
      subtitle: subtitle,
      secondary: secondary,
      controlAffinity: controlAffinity,
      contentPadding: contentPadding,
      autofocus: autofocus,
      selected: selected,
    );
  }
}

/// A builder for [FormBuilderSlider].
@sealed
class FormBuilderSliderBuilder {
  Key? key;
  String? name;
  FormFieldValidator<double>? validator;
  double? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<double?>? onChanged;
  ValueTransformer<double?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<double>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  double? min;
  double? max;
  int? divisions;
  Color? activeColor;
  Color? inactiveColor;
  ValueChanged<double>? onChangeStart;
  ValueChanged<double>? onChangeEnd;
  String? label;
  SemanticFormatterCallback? semanticFormatterCallback;
  intl.NumberFormat? numberFormat;
  DisplayValues displayValues = DisplayValues.all;
  TextStyle? minTextStyle;
  TextStyle? textStyle;
  TextStyle? maxTextStyle;
  bool autofocus = false;
  MouseCursor? mouseCursor;

  /// Build [FormBuilderSlider] instance from this builder.
  FormBuilderSlider build() {
    assert(name != null, "'name' is required.");
    assert(initialValue != null, "'initialValue' is required.");
    assert(min != null, "'min' is required.");
    assert(max != null, "'max' is required.");
    return FormBuilderSlider(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue!,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      min: min!,
      max: max!,
      divisions: divisions,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      label: label,
      semanticFormatterCallback: semanticFormatterCallback,
      numberFormat: numberFormat,
      displayValues: displayValues,
      minTextStyle: minTextStyle,
      textStyle: textStyle,
      maxTextStyle: maxTextStyle,
      autofocus: autofocus,
      mouseCursor: mouseCursor,
    );
  }
}

/// A builder for [FormBuilderDropdown].
@sealed
class FormBuilderDropdownBuilder<T> {
  Key? key;
  String? name;
  FormFieldValidator<T>? validator;
  T? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<T?>? onChanged;
  ValueTransformer<T?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<T>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<DropdownMenuItem<T>>? items;
  bool isExpanded = true;
  bool isDense = true;
  int elevation = 8;
  double iconSize = 24.0;
  Widget? hint;
  TextStyle? style;
  Widget? disabledHint;
  Widget? icon;
  Color? iconDisabledColor;
  Color? iconEnabledColor;
  bool allowClear = false;
  Widget clearIcon = const Icon(Icons.close);
  VoidCallback? onTap;
  bool autofocus = false;
  Color? dropdownColor;
  Color? focusColor;
  double itemHeight = kMinInteractiveDimension;
  DropdownButtonBuilder? selectedItemBuilder;
  double? menuMaxHeight;

  /// Build [FormBuilderDropdown] instance from this builder.
  FormBuilderDropdown<T> build() {
    assert(name != null, "'name' is required.");
    assert(items != null, "'items' is required.");
    return FormBuilderDropdown<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      items: items!,
      isExpanded: isExpanded,
      isDense: isDense,
      elevation: elevation,
      iconSize: iconSize,
      hint: hint,
      style: style,
      disabledHint: disabledHint,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      allowClear: allowClear,
      clearIcon: clearIcon,
      onTap: onTap,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      focusColor: focusColor,
      itemHeight: itemHeight,
      selectedItemBuilder: selectedItemBuilder,
      menuMaxHeight: menuMaxHeight,
    );
  }
}

/// A builder for [FormBuilderCheckbox].
@sealed
class FormBuilderCheckboxBuilder {
  Key? key;
  String? name;
  FormFieldValidator<bool>? validator;
  bool? initialValue;
  InputDecoration decoration = const InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none);
  ValueChanged<bool?>? onChanged;
  ValueTransformer<bool?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<bool?>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  Widget? title;
  Color? activeColor;
  Color? checkColor;
  Widget? subtitle;
  Widget? secondary;
  ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading;
  EdgeInsets contentPadding = EdgeInsets.zero;
  bool autofocus = false;
  bool tristate = false;
  bool selected = false;

  /// Build [FormBuilderCheckbox] instance from this builder.
  FormBuilderCheckbox build() {
    assert(name != null, "'name' is required.");
    assert(title != null, "'title' is required.");
    return FormBuilderCheckbox(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      title: title!,
      activeColor: activeColor,
      checkColor: checkColor,
      subtitle: subtitle,
      secondary: secondary,
      controlAffinity: controlAffinity,
      contentPadding: contentPadding,
      autofocus: autofocus,
      tristate: tristate,
      selected: selected,
    );
  }
}

/// A builder for [FormBuilderTextField].
@sealed
class FormBuilderTextFieldBuilder {
  Key? key;
  String? name;
  FormFieldValidator<String>? validator;
  String? initialValue;
  bool readOnly = false;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<String?>? onChanged;
  ValueTransformer<String?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<String>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  int? maxLines = 1;
  bool obscureText = false;
  TextCapitalization textCapitalization = TextCapitalization.none;
  EdgeInsets scrollPadding = const EdgeInsets.all(20.0);
  bool enableInteractiveSelection = true;
  MaxLengthEnforcement? maxLengthEnforcement;
  TextAlign textAlign = TextAlign.start;
  bool autofocus = false;
  bool autocorrect = true;
  double cursorWidth = 2.0;
  TextInputType? keyboardType;
  TextStyle? style;
  TextEditingController? controller;
  TextInputAction? textInputAction;
  StrutStyle? strutStyle;
  TextDirection? textDirection;
  int? maxLength;
  VoidCallback? onEditingComplete;
  ValueChanged<String?>? onSubmitted;
  List<TextInputFormatter>? inputFormatters;
  Radius? cursorRadius;
  Color? cursorColor;
  Brightness? keyboardAppearance;
  InputCounterWidgetBuilder? buildCounter;
  bool expands = false;
  int? minLines;
  bool? showCursor;
  GestureTapCallback? onTap;
  bool enableSuggestions = false;
  TextAlignVertical? textAlignVertical;
  DragStartBehavior dragStartBehavior = DragStartBehavior.start;
  ScrollController? scrollController;
  ScrollPhysics? scrollPhysics;
  ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight;
  SmartDashesType? smartDashesType;
  SmartQuotesType? smartQuotesType;
  ToolbarOptions? toolbarOptions;
  ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight;
  Iterable<String>? autofillHints;
  String obscuringCharacter = '•';
  MouseCursor? mouseCursor;

  /// Build [FormBuilderTextField] instance from this builder.
  FormBuilderTextField build() {
    assert(name != null, "'name' is required.");
    return FormBuilderTextField(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      readOnly: readOnly,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      keyboardType: keyboardType,
      style: style,
      controller: controller,
      textInputAction: textInputAction,
      strutStyle: strutStyle,
      textDirection: textDirection,
      maxLength: maxLength,
      onEditingComplete: onEditingComplete,
      onSubmitted: onSubmitted,
      inputFormatters: inputFormatters,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      buildCounter: buildCounter,
      expands: expands,
      minLines: minLines,
      showCursor: showCursor,
      onTap: onTap,
      enableSuggestions: enableSuggestions,
      textAlignVertical: textAlignVertical,
      dragStartBehavior: dragStartBehavior,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      selectionWidthStyle: selectionWidthStyle,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      toolbarOptions: toolbarOptions,
      selectionHeightStyle: selectionHeightStyle,
      autofillHints: autofillHints,
      obscuringCharacter: obscuringCharacter,
      mouseCursor: mouseCursor,
    );
  }
}

/// A builder for [FormBuilderRadioGroup].
@sealed
class FormBuilderRadioGroupBuilder<T> {
  Key? key;
  String? name;
  FormFieldValidator<T>? validator;
  T? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<T?>? onChanged;
  ValueTransformer<T?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<T>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<FormBuilderFieldOption<T>>? options;
  Color? activeColor;
  Color? focusColor;
  Color? hoverColor;
  List<T>? disabled;
  MaterialTapTargetSize? materialTapTargetSize;
  Axis wrapDirection = Axis.horizontal;
  WrapAlignment wrapAlignment = WrapAlignment.start;
  double wrapSpacing = 0.0;
  WrapAlignment wrapRunAlignment = WrapAlignment.start;
  double wrapRunSpacing = 0.0;
  WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start;
  TextDirection? wrapTextDirection;
  VerticalDirection wrapVerticalDirection = VerticalDirection.down;
  Widget? separator;
  ControlAffinity controlAffinity = ControlAffinity.leading;
  OptionsOrientation orientation = OptionsOrientation.wrap;

  /// Build [FormBuilderRadioGroup] instance from this builder.
  FormBuilderRadioGroup<T> build() {
    assert(name != null, "'name' is required.");
    assert(options != null, "'options' is required.");
    return FormBuilderRadioGroup<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      options: options!,
      activeColor: activeColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      disabled: disabled,
      materialTapTargetSize: materialTapTargetSize,
      wrapDirection: wrapDirection,
      wrapAlignment: wrapAlignment,
      wrapSpacing: wrapSpacing,
      wrapRunAlignment: wrapRunAlignment,
      wrapRunSpacing: wrapRunSpacing,
      wrapCrossAxisAlignment: wrapCrossAxisAlignment,
      wrapTextDirection: wrapTextDirection,
      wrapVerticalDirection: wrapVerticalDirection,
      separator: separator,
      controlAffinity: controlAffinity,
      orientation: orientation,
    );
  }
}

/// A builder for [FormBuilderChoiceChip].
@sealed
class FormBuilderChoiceChipBuilder<T> {
  Key? key;
  String? name;
  FormFieldValidator<T>? validator;
  T? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<T?>? onChanged;
  ValueTransformer<T?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<T>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<FormBuilderFieldOption<T>>? options;
  Color? selectedColor;
  Color? disabledColor;
  Color? backgroundColor;
  Color? shadowColor;
  Color? selectedShadowColor;
  OutlinedBorder? shape;
  double? elevation;
  double? pressElevation;
  MaterialTapTargetSize? materialTapTargetSize;
  Axis direction = Axis.horizontal;
  WrapAlignment alignment = WrapAlignment.start;
  WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start;
  WrapAlignment runAlignment = WrapAlignment.start;
  double runSpacing = 0.0;
  double spacing = 0.0;
  TextDirection? textDirection;
  VerticalDirection verticalDirection = VerticalDirection.down;
  EdgeInsets? labelPadding;
  TextStyle? labelStyle;
  EdgeInsets? padding;
  VisualDensity? visualDensity;

  /// Build [FormBuilderChoiceChip] instance from this builder.
  FormBuilderChoiceChip<T> build() {
    assert(name != null, "'name' is required.");
    assert(options != null, "'options' is required.");
    return FormBuilderChoiceChip<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      options: options!,
      selectedColor: selectedColor,
      disabledColor: disabledColor,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      selectedShadowColor: selectedShadowColor,
      shape: shape,
      elevation: elevation,
      pressElevation: pressElevation,
      materialTapTargetSize: materialTapTargetSize,
      direction: direction,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      padding: padding,
      visualDensity: visualDensity,
    );
  }
}

/// A builder for [FormBuilderFilterChip].
@sealed
class FormBuilderFilterChipBuilder<T> {
  Key? key;
  String? name;
  FormFieldValidator<List<T>>? validator;
  List<T> initialValue = const [];
  InputDecoration decoration = const InputDecoration(border: InputBorder.none, focusedBorder: InputBorder.none, enabledBorder: InputBorder.none, errorBorder: InputBorder.none, disabledBorder: InputBorder.none);
  ValueChanged<List<T>?>? onChanged;
  ValueTransformer<List<T>?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<List<T>>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<FormBuilderFieldOption<T>>? options;
  Color? selectedColor;
  Color? disabledColor;
  Color? backgroundColor;
  Color? shadowColor;
  Color? selectedShadowColor;
  OutlinedBorder? shape;
  double? elevation;
  double? pressElevation;
  MaterialTapTargetSize? materialTapTargetSize;
  Axis direction = Axis.horizontal;
  WrapAlignment alignment = WrapAlignment.start;
  WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start;
  WrapAlignment runAlignment = WrapAlignment.start;
  double runSpacing = 0.0;
  double spacing = 0.0;
  TextDirection? textDirection;
  VerticalDirection verticalDirection = VerticalDirection.down;
  EdgeInsets? padding;
  Color? checkmarkColor;
  Clip clipBehavior = Clip.none;
  TextStyle? labelStyle;
  bool showCheckmark = true;
  EdgeInsets? labelPadding;
  int? maxChips;

  /// Build [FormBuilderFilterChip] instance from this builder.
  FormBuilderFilterChip<T> build() {
    assert(name != null, "'name' is required.");
    assert(options != null, "'options' is required.");
    return FormBuilderFilterChip<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      options: options!,
      selectedColor: selectedColor,
      disabledColor: disabledColor,
      backgroundColor: backgroundColor,
      shadowColor: shadowColor,
      selectedShadowColor: selectedShadowColor,
      shape: shape,
      elevation: elevation,
      pressElevation: pressElevation,
      materialTapTargetSize: materialTapTargetSize,
      direction: direction,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      padding: padding,
      checkmarkColor: checkmarkColor,
      clipBehavior: clipBehavior,
      labelStyle: labelStyle,
      showCheckmark: showCheckmark,
      labelPadding: labelPadding,
      maxChips: maxChips,
    );
  }
}

/// A builder for [FormBuilderRangeSlider].
@sealed
class FormBuilderRangeSliderBuilder {
  Key? key;
  String? name;
  FormFieldValidator<RangeValues>? validator;
  RangeValues? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<RangeValues?>? onChanged;
  ValueTransformer<RangeValues?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<RangeValues>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  double? min;
  double? max;
  int? divisions;
  Color? activeColor;
  Color? inactiveColor;
  ValueChanged<RangeValues>? onChangeStart;
  ValueChanged<RangeValues>? onChangeEnd;
  RangeLabels? labels;
  SemanticFormatterCallback? semanticFormatterCallback;
  DisplayValues displayValues = DisplayValues.all;
  TextStyle? minTextStyle;
  TextStyle? textStyle;
  TextStyle? maxTextStyle;
  intl.NumberFormat? numberFormat;

  /// Build [FormBuilderRangeSlider] instance from this builder.
  FormBuilderRangeSlider build() {
    assert(name != null, "'name' is required.");
    assert(min != null, "'min' is required.");
    assert(max != null, "'max' is required.");
    return FormBuilderRangeSlider(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      min: min!,
      max: max!,
      divisions: divisions,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      onChangeStart: onChangeStart,
      onChangeEnd: onChangeEnd,
      labels: labels,
      semanticFormatterCallback: semanticFormatterCallback,
      displayValues: displayValues,
      minTextStyle: minTextStyle,
      textStyle: textStyle,
      maxTextStyle: maxTextStyle,
      numberFormat: numberFormat,
    );
  }
}

/// A builder for [FormBuilderCheckboxGroup].
@sealed
class FormBuilderCheckboxGroupBuilder<T> {
  Key? key;
  String? name;
  FormFieldValidator<List<T>>? validator;
  List<T>? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<List<T>?>? onChanged;
  ValueTransformer<List<T>?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<List<T>>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<FormBuilderFieldOption<T>>? options;
  Color? activeColor;
  Color? checkColor;
  Color? focusColor;
  Color? hoverColor;
  List<T>? disabled;
  MaterialTapTargetSize? materialTapTargetSize;
  bool tristate = false;
  Axis wrapDirection = Axis.horizontal;
  WrapAlignment wrapAlignment = WrapAlignment.start;
  double wrapSpacing = 0.0;
  WrapAlignment wrapRunAlignment = WrapAlignment.start;
  double wrapRunSpacing = 0.0;
  WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start;
  TextDirection? wrapTextDirection;
  VerticalDirection wrapVerticalDirection = VerticalDirection.down;
  Widget? separator;
  ControlAffinity controlAffinity = ControlAffinity.leading;
  OptionsOrientation orientation = OptionsOrientation.wrap;

  /// Build [FormBuilderCheckboxGroup] instance from this builder.
  FormBuilderCheckboxGroup<T> build() {
    assert(name != null, "'name' is required.");
    assert(options != null, "'options' is required.");
    return FormBuilderCheckboxGroup<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      options: options!,
      activeColor: activeColor,
      checkColor: checkColor,
      focusColor: focusColor,
      hoverColor: hoverColor,
      disabled: disabled,
      materialTapTargetSize: materialTapTargetSize,
      tristate: tristate,
      wrapDirection: wrapDirection,
      wrapAlignment: wrapAlignment,
      wrapSpacing: wrapSpacing,
      wrapRunAlignment: wrapRunAlignment,
      wrapRunSpacing: wrapRunSpacing,
      wrapCrossAxisAlignment: wrapCrossAxisAlignment,
      wrapTextDirection: wrapTextDirection,
      wrapVerticalDirection: wrapVerticalDirection,
      separator: separator,
      controlAffinity: controlAffinity,
      orientation: orientation,
    );
  }
}

/// A builder for [FormBuilderDateTimePicker].
@sealed
class FormBuilderDateTimePickerBuilder {
  Key? key;
  String? name;
  FormFieldValidator<DateTime>? validator;
  DateTime? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<DateTime?>? onChanged;
  ValueTransformer<DateTime?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<DateTime>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  InputType inputType = InputType.both;
  EdgeInsets scrollPadding = const EdgeInsets.all(20.0);
  double cursorWidth = 2.0;
  bool enableInteractiveSelection = true;
  Icon resetIcon = const Icon(Icons.close);
  TimeOfDay initialTime = const TimeOfDay(hour: 12, minute: 0);
  TextInputType keyboardType = TextInputType.text;
  TextAlign textAlign = TextAlign.start;
  bool autofocus = false;
  bool obscureText = false;
  bool autocorrect = true;
  int? maxLines = 1;
  bool expands = false;
  DatePickerMode initialDatePickerMode = DatePickerMode.day;
  TransitionBuilder? transitionBuilder;
  TextCapitalization textCapitalization = TextCapitalization.none;
  bool useRootNavigator = true;
  bool alwaysUse24HourFormat = false;
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar;
  TimePickerEntryMode timePickerInitialEntryMode = TimePickerEntryMode.dial;
  intl.DateFormat? format;
  DateTime? initialDate;
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? currentDate;
  Locale? locale;
  int? maxLength;
  ui.TextDirection? textDirection;
  ValueChanged<DateTime?>? onFieldSubmitted;
  TextEditingController? controller;
  TextStyle? style;
  MaxLengthEnforcement maxLengthEnforcement = MaxLengthEnforcement.none;
  List<TextInputFormatter>? inputFormatters;
  bool showCursor = false;
  int? minLines;
  TextInputAction? textInputAction;
  VoidCallback? onEditingComplete;
  InputCounterWidgetBuilder? buildCounter;
  Radius? cursorRadius;
  Color? cursorColor;
  Brightness? keyboardAppearance;
  String? cancelText;
  String? confirmText;
  String? errorFormatText;
  String? errorInvalidText;
  String? fieldHintText;
  String? fieldLabelText;
  String? helpText;
  RouteSettings? routeSettings;
  StrutStyle? strutStyle;
  SelectableDayPredicate? selectableDayPredicate;

  /// Build [FormBuilderDateTimePicker] instance from this builder.
  FormBuilderDateTimePicker build() {
    assert(name != null, "'name' is required.");
    return FormBuilderDateTimePicker(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      inputType: inputType,
      scrollPadding: scrollPadding,
      cursorWidth: cursorWidth,
      enableInteractiveSelection: enableInteractiveSelection,
      resetIcon: resetIcon,
      initialTime: initialTime,
      keyboardType: keyboardType,
      textAlign: textAlign,
      autofocus: autofocus,
      obscureText: obscureText,
      autocorrect: autocorrect,
      maxLines: maxLines,
      expands: expands,
      initialDatePickerMode: initialDatePickerMode,
      transitionBuilder: transitionBuilder,
      textCapitalization: textCapitalization,
      useRootNavigator: useRootNavigator,
      alwaysUse24HourFormat: alwaysUse24HourFormat,
      initialEntryMode: initialEntryMode,
      timePickerInitialEntryMode: timePickerInitialEntryMode,
      format: format,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      currentDate: currentDate,
      locale: locale,
      maxLength: maxLength,
      textDirection: textDirection,
      onFieldSubmitted: onFieldSubmitted,
      controller: controller,
      style: style,
      maxLengthEnforcement: maxLengthEnforcement,
      inputFormatters: inputFormatters,
      showCursor: showCursor,
      minLines: minLines,
      textInputAction: textInputAction,
      onEditingComplete: onEditingComplete,
      buildCounter: buildCounter,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      cancelText: cancelText,
      confirmText: confirmText,
      errorFormatText: errorFormatText,
      errorInvalidText: errorInvalidText,
      fieldHintText: fieldHintText,
      fieldLabelText: fieldLabelText,
      helpText: helpText,
      routeSettings: routeSettings,
      strutStyle: strutStyle,
      selectableDayPredicate: selectableDayPredicate,
    );
  }
}

/// A builder for [FormBuilderSegmentedControl].
@sealed
class FormBuilderSegmentedControlBuilder<T extends Object> {
  Key? key;
  String? name;
  FormFieldValidator<T>? validator;
  T? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<T?>? onChanged;
  ValueTransformer<T?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<T>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  List<FormBuilderFieldOption<T>>? options;
  Color? borderColor;
  Color? selectedColor;
  Color? pressedColor;
  EdgeInsetsGeometry? padding;
  Color? unselectedColor;

  /// Build [FormBuilderSegmentedControl] instance from this builder.
  FormBuilderSegmentedControl<T> build() {
    assert(name != null, "'name' is required.");
    assert(options != null, "'options' is required.");
    return FormBuilderSegmentedControl<T>(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      options: options!,
      borderColor: borderColor,
      selectedColor: selectedColor,
      pressedColor: pressedColor,
      padding: padding,
      unselectedColor: unselectedColor,
    );
  }
}

/// A builder for [FormBuilderDateRangePicker].
@sealed
class FormBuilderDateRangePickerBuilder {
  Key? key;
  String? name;
  FormFieldValidator<DateTimeRange>? validator;
  DateTimeRange? initialValue;
  InputDecoration decoration = const InputDecoration();
  ValueChanged<DateTimeRange?>? onChanged;
  ValueTransformer<DateTimeRange?>? valueTransformer;
  bool enabled = true;
  FormFieldSetter<DateTimeRange>? onSaved;
  AutovalidateMode autovalidateMode = AutovalidateMode.disabled;
  VoidCallback? onReset;
  FocusNode? focusNode;
  DateTime? firstDate;
  DateTime? lastDate;
  intl.DateFormat? format;
  int maxLines = 1;
  bool obscureText = false;
  TextCapitalization textCapitalization = TextCapitalization.none;
  EdgeInsets scrollPadding = const EdgeInsets.all(20.0);
  bool enableInteractiveSelection = true;
  MaxLengthEnforcement? maxLengthEnforcement;
  TextAlign textAlign = TextAlign.start;
  bool autofocus = false;
  bool autocorrect = true;
  double cursorWidth = 2.0;
  TextInputType? keyboardType;
  TextStyle? style;
  TextEditingController? controller;
  TextInputAction? textInputAction;
  StrutStyle? strutStyle;
  TextDirection? textDirection;
  int? maxLength;
  VoidCallback? onEditingComplete;
  ValueChanged<DateTimeRange?>? onFieldSubmitted;
  List<TextInputFormatter>? inputFormatters;
  Radius? cursorRadius;
  Color? cursorColor;
  Brightness? keyboardAppearance;
  InputCounterWidgetBuilder? buildCounter;
  bool expands = false;
  int? minLines;
  bool showCursor = false;
  Locale? locale;
  String? cancelText;
  String? confirmText;
  DateTime? currentDate;
  String? errorFormatText;
  Widget Function(BuildContext, Widget?)? pickerBuilder;
  String? errorInvalidRangeText;
  String? errorInvalidText;
  String? fieldEndHintText;
  String? fieldEndLabelText;
  String? fieldStartHintText;
  String? fieldStartLabelText;
  String? helpText;
  DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar;
  RouteSettings? routeSettings;
  String? saveText;
  bool useRootNavigator = true;

  /// Build [FormBuilderDateRangePicker] instance from this builder.
  FormBuilderDateRangePicker build() {
    assert(name != null, "'name' is required.");
    assert(firstDate != null, "'firstDate' is required.");
    assert(lastDate != null, "'lastDate' is required.");
    return FormBuilderDateRangePicker(
      key: key,
      name: name!,
      validator: validator,
      initialValue: initialValue,
      decoration: decoration,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      onSaved: onSaved,
      autovalidateMode: autovalidateMode,
      onReset: onReset,
      focusNode: focusNode,
      firstDate: firstDate!,
      lastDate: lastDate!,
      format: format,
      maxLines: maxLines,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      keyboardType: keyboardType,
      style: style,
      controller: controller,
      textInputAction: textInputAction,
      strutStyle: strutStyle,
      textDirection: textDirection,
      maxLength: maxLength,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      inputFormatters: inputFormatters,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      buildCounter: buildCounter,
      expands: expands,
      minLines: minLines,
      showCursor: showCursor,
      locale: locale,
      cancelText: cancelText,
      confirmText: confirmText,
      currentDate: currentDate,
      errorFormatText: errorFormatText,
      pickerBuilder: pickerBuilder,
      errorInvalidRangeText: errorInvalidRangeText,
      errorInvalidText: errorInvalidText,
      fieldEndHintText: fieldEndHintText,
      fieldEndLabelText: fieldEndLabelText,
      fieldStartHintText: fieldStartHintText,
      fieldStartLabelText: fieldStartLabelText,
      helpText: helpText,
      initialEntryMode: initialEntryMode,
      routeSettings: routeSettings,
      saveText: saveText,
      useRootNavigator: useRootNavigator,
    );
  }
}
