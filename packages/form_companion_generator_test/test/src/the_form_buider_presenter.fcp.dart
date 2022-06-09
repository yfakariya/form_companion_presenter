// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

// **************************************************************************
// CompanionGenerator
// **************************************************************************

import 'dart:ui'
    show
        Brightness,
        Clip,
        Color,
        Locale,
        Radius,
        TextAlign,
        TextDirection,
        VoidCallback;

import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle, TextDirection;

import 'package:flutter/foundation.dart' show Key, ValueChanged;

import 'package:flutter/gestures.dart'
    show DragStartBehavior, GestureTapCallback;

import 'package:flutter/material.dart'
    show
        DatePickerEntryMode,
        DatePickerMode,
        DateTimeRange,
        DropdownButtonBuilder,
        DropdownMenuItem,
        Icons,
        InputBorder,
        InputCounterWidgetBuilder,
        InputDecoration,
        ListTileControlAffinity,
        MaterialTapTargetSize,
        RangeLabels,
        RangeValues,
        SelectableDayPredicate,
        SemanticFormatterCallback,
        TimeOfDay,
        TimePickerEntryMode,
        VisualDensity,
        kMinInteractiveDimension;

import 'package:flutter/painting.dart'
    show
        Axis,
        EdgeInsets,
        EdgeInsetsGeometry,
        ImageProvider,
        OutlinedBorder,
        StrutStyle,
        TextAlignVertical,
        TextStyle,
        VerticalDirection;

import 'package:flutter/rendering.dart' show WrapAlignment, WrapCrossAlignment;

import 'package:flutter/services.dart'
    show
        MaxLengthEnforcement,
        MouseCursor,
        SmartDashesType,
        SmartQuotesType,
        TextCapitalization,
        TextInputAction,
        TextInputFormatter,
        TextInputType;

import 'package:flutter/widgets.dart'
    show
        AutovalidateMode,
        BuildContext,
        FocusNode,
        Icon,
        Localizations,
        RouteSettings,
        ScrollController,
        ScrollPhysics,
        Text,
        TextEditingController,
        ToolbarOptions,
        TransitionBuilder,
        Widget;

import 'package:flutter_form_builder/flutter_form_builder.dart'
    show
        ControlAffinity,
        DisplayValues,
        FormBuilderCheckbox,
        FormBuilderCheckboxGroup,
        FormBuilderChoiceChip,
        FormBuilderDateRangePicker,
        FormBuilderDateTimePicker,
        FormBuilderDropdown,
        FormBuilderFieldOption,
        FormBuilderFilterChip,
        FormBuilderRadioGroup,
        FormBuilderRangeSlider,
        FormBuilderSegmentedControl,
        FormBuilderSlider,
        FormBuilderSwitch,
        FormBuilderTextField,
        InputType,
        OptionsOrientation,
        ValueTransformer;

import 'package:form_companion_generator_test_targets/enum.dart' show MyEnum;

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import 'package:intl/intl.dart' as intl show DateFormat;

import 'the_form_buider_presenter.dart';

/// Defines typed property accessors as extension properties for [TheFormBuilderPresenter].
extension $TheFormBuilderPresenterPropertyExtension on TheFormBuilderPresenter {
  /// Gets a [PropertyDescriptor] of `propString` property.
  PropertyDescriptor<String, String> get propString =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propString']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `propEnum` property.
  PropertyDescriptor<MyEnum, MyEnum> get propEnum =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnum']! as PropertyDescriptor<MyEnum, MyEnum>;

  /// Gets a [PropertyDescriptor] of `propBool` property.
  PropertyDescriptor<bool, bool> get propBool =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propBool']! as PropertyDescriptor<bool, bool>;

  /// Gets a [PropertyDescriptor] of `propDateTime` property.
  PropertyDescriptor<DateTime, DateTime> get propDateTime =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propDateTime']! as PropertyDescriptor<DateTime, DateTime>;

  /// Gets a [PropertyDescriptor] of `propDateTimeRange` property.
  PropertyDescriptor<DateTimeRange, DateTimeRange> get propDateTimeRange =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propDateTimeRange']!
          as PropertyDescriptor<DateTimeRange, DateTimeRange>;

  /// Gets a [PropertyDescriptor] of `propRangeValues` property.
  PropertyDescriptor<RangeValues, RangeValues> get propRangeValues =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propRangeValues']!
          as PropertyDescriptor<RangeValues, RangeValues>;

  /// Gets a [PropertyDescriptor] of `propEnumList` property.
  PropertyDescriptor<List<MyEnum>, List<MyEnum>> get propEnumList =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnumList']!
          as PropertyDescriptor<List<MyEnum>, List<MyEnum>>;

  /// Gets a [PropertyDescriptor] of `propBoolList` property.
  PropertyDescriptor<List<bool>, List<bool>> get propBoolList =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propBoolList']! as PropertyDescriptor<List<bool>, List<bool>>;

  /// Gets a [PropertyDescriptor] of `propBoolCheckBox` property.
  PropertyDescriptor<bool, bool> get propBoolCheckBox =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propBoolCheckBox']! as PropertyDescriptor<bool, bool>;

  /// Gets a [PropertyDescriptor] of `propEnumListCheckBoxGroup` property.
  PropertyDescriptor<List<MyEnum>, List<MyEnum>>
      get propEnumListCheckBoxGroup =>
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          properties['propEnumListCheckBoxGroup']!
              as PropertyDescriptor<List<MyEnum>, List<MyEnum>>;

  /// Gets a [PropertyDescriptor] of `propEnumChoiceChip` property.
  PropertyDescriptor<MyEnum, MyEnum> get propEnumChoiceChip =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnumChoiceChip']! as PropertyDescriptor<MyEnum, MyEnum>;

  /// Gets a [PropertyDescriptor] of `propEnumListFilterChip` property.
  PropertyDescriptor<List<MyEnum>, List<MyEnum>> get propEnumListFilterChip =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnumListFilterChip']!
          as PropertyDescriptor<List<MyEnum>, List<MyEnum>>;

  /// Gets a [PropertyDescriptor] of `propEnumRadioGroup` property.
  PropertyDescriptor<MyEnum, MyEnum> get propEnumRadioGroup =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnumRadioGroup']! as PropertyDescriptor<MyEnum, MyEnum>;

  /// Gets a [PropertyDescriptor] of `propEnumSegmentedControl` property.
  PropertyDescriptor<MyEnum, MyEnum> get propEnumSegmentedControl =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnumSegmentedControl']!
          as PropertyDescriptor<MyEnum, MyEnum>;

  /// Gets a [PropertyDescriptor] of `propDoubleSlider` property.
  PropertyDescriptor<double, double> get propDoubleSlider =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propDoubleSlider']! as PropertyDescriptor<double, double>;

  /// Gets a [PropertyDescriptor] of `propInt` property.
  PropertyDescriptor<int, String> get propInt =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propInt']! as PropertyDescriptor<int, String>;
}

/// Defines [FormField] factory methods for properties of [TheFormBuilderPresenter].
class $TheFormBuilderPresenterFieldFactory {
  final TheFormBuilderPresenter _presenter;

  $TheFormBuilderPresenterFieldFactory._(this._presenter);

  /// Gets a [FormField] for `propString` property.
  FormBuilderTextField propString(
    BuildContext context, {
    Key? key,
    bool readOnly = false,
    InputDecoration? decoration,
    ValueChanged<String?>? onChanged,
    ValueTransformer<String?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    int? maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    TextInputType? keyboardType,
    TextStyle? style,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<String?>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    InputCounterWidgetBuilder? buildCounter,
    bool expands = false,
    int? minLines,
    bool? showCursor,
    GestureTapCallback? onTap,
    bool enableSuggestions = false,
    TextAlignVertical? textAlignVertical,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.propString;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
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

  /// Gets a [FormField] for `propEnum` property.
  FormBuilderDropdown<MyEnum> propEnum(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<MyEnum?>? onChanged,
    ValueTransformer<MyEnum?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<DropdownMenuItem<MyEnum>>? items,
    bool isExpanded = true,
    bool isDense = true,
    int elevation = 8,
    double iconSize = 24.0,
    Widget? hint,
    TextStyle? style,
    Widget? disabledHint,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    bool allowClear = false,
    Widget clearIcon = const Icon(Icons.close),
    VoidCallback? onTap,
    bool autofocus = false,
    bool shouldRequestFocus = false,
    Color? dropdownColor,
    Color? focusColor,
    double itemHeight = kMinInteractiveDimension,
    DropdownButtonBuilder? selectedItemBuilder,
    double? menuMaxHeight,
  }) {
    final property = _presenter.propEnum;
    return FormBuilderDropdown<MyEnum>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      items: [MyEnum.one, MyEnum.two]
          .map((x) =>
              DropdownMenuItem<MyEnum>(value: x, child: Text(x.toString())))
          .toList(),
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
      shouldRequestFocus: shouldRequestFocus,
      dropdownColor: dropdownColor,
      focusColor: focusColor,
      itemHeight: itemHeight,
      selectedItemBuilder: selectedItemBuilder,
      menuMaxHeight: menuMaxHeight,
    );
  }

  /// Gets a [FormField] for `propBool` property.
  FormBuilderSwitch propBool(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<bool?>? onChanged,
    ValueTransformer<bool?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required Widget title,
    Color? activeColor,
    Color? activeTrackColor,
    Color? inactiveThumbColor,
    Color? inactiveTrackColor,
    ImageProvider? activeThumbImage,
    ImageProvider? inactiveThumbImage,
    Widget? subtitle,
    Widget? secondary,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.trailing,
    EdgeInsets contentPadding = EdgeInsets.zero,
    bool autofocus = false,
    bool shouldRequestFocus = false,
    bool selected = false,
  }) {
    final property = _presenter.propBool;
    return FormBuilderSwitch(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      title: title,
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
      shouldRequestFocus: shouldRequestFocus,
      selected: selected,
    );
  }

  /// Gets a [FormField] for `propDateTime` property.
  FormBuilderDateTimePicker propDateTime(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<DateTime?>? onChanged,
    ValueTransformer<DateTime?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    InputType inputType = InputType.both,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    double cursorWidth = 2.0,
    bool enableInteractiveSelection = true,
    Icon resetIcon = const Icon(Icons.close),
    TimeOfDay initialTime = const TimeOfDay(hour: 12, minute: 0),
    TextInputType keyboardType = TextInputType.text,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool obscureText = false,
    bool autocorrect = true,
    int? maxLines = 1,
    bool expands = false,
    DatePickerMode initialDatePickerMode = DatePickerMode.day,
    TransitionBuilder? transitionBuilder,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool useRootNavigator = true,
    bool alwaysUse24HourFormat = false,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    TimePickerEntryMode timePickerInitialEntryMode = TimePickerEntryMode.dial,
    DateFormat? format,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
    DateTime? currentDate,
    Locale? locale,
    int? maxLength,
    ui.TextDirection? textDirection,
    ValueChanged<DateTime?>? onFieldSubmitted,
    TextEditingController? controller,
    TextStyle? style,
    MaxLengthEnforcement maxLengthEnforcement = MaxLengthEnforcement.none,
    List<TextInputFormatter>? inputFormatters,
    bool showCursor = false,
    int? minLines,
    TextInputAction? textInputAction,
    VoidCallback? onEditingComplete,
    InputCounterWidgetBuilder? buildCounter,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    String? cancelText,
    String? confirmText,
    String? errorFormatText,
    String? errorInvalidText,
    String? fieldHintText,
    String? fieldLabelText,
    String? helpText,
    RouteSettings? routeSettings,
    StrutStyle? strutStyle,
    SelectableDayPredicate? selectableDayPredicate,
  }) {
    final property = _presenter.propDateTime;
    return FormBuilderDateTimePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
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

  /// Gets a [FormField] for `propDateTimeRange` property.
  FormBuilderDateRangePicker propDateTimeRange(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<DateTimeRange?>? onChanged,
    ValueTransformer<DateTimeRange?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required DateTime firstDate,
    required DateTime lastDate,
    intl.DateFormat? format,
    int maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    TextInputType? keyboardType,
    TextStyle? style,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<DateTimeRange?>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    InputCounterWidgetBuilder? buildCounter,
    bool expands = false,
    int? minLines,
    bool showCursor = false,
    Locale? locale,
    String? cancelText,
    String? confirmText,
    DateTime? currentDate,
    String? errorFormatText,
    Widget Function(BuildContext, Widget?)? pickerBuilder,
    String? errorInvalidRangeText,
    String? errorInvalidText,
    String? fieldEndHintText,
    String? fieldEndLabelText,
    String? fieldStartHintText,
    String? fieldStartLabelText,
    String? helpText,
    DatePickerEntryMode initialEntryMode = DatePickerEntryMode.calendar,
    RouteSettings? routeSettings,
    String? saveText,
    bool useRootNavigator = true,
  }) {
    final property = _presenter.propDateTimeRange;
    return FormBuilderDateRangePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      firstDate: firstDate,
      lastDate: lastDate,
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

  /// Gets a [FormField] for `propRangeValues` property.
  FormBuilderRangeSlider propRangeValues(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<RangeValues?>? onChanged,
    ValueTransformer<RangeValues?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required double min,
    required double max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    ValueChanged<RangeValues>? onChangeStart,
    ValueChanged<RangeValues>? onChangeEnd,
    RangeLabels? labels,
    SemanticFormatterCallback? semanticFormatterCallback,
    DisplayValues displayValues = DisplayValues.all,
    TextStyle? minTextStyle,
    TextStyle? textStyle,
    TextStyle? maxTextStyle,
    NumberFormat? numberFormat,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.propRangeValues;
    return FormBuilderRangeSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      min: min,
      max: max,
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
      shouldRequestFocus: shouldRequestFocus,
    );
  }

  /// Gets a [FormField] for `propEnumList` property.
  FormBuilderFilterChip<MyEnum> propEnumList(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<MyEnum>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    Color? checkmarkColor,
    Clip clipBehavior = Clip.none,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    int? maxChips,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    bool showCheckmark = true,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    ValueChanged<List<MyEnum>?>? onChanged,
    ValueTransformer<List<MyEnum>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.propEnumList;
    return FormBuilderFilterChip<MyEnum>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      key: key,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      name: property.name,
      options: property
              .getFieldValue(Localizations.maybeLocaleOf(context) ??
                  const Locale('en', 'US'))
              ?.map((x) => FormBuilderFieldOption<MyEnum>(
                  value: x, child: Text(x.toString())))
              .toList() ??
          [],
      alignment: alignment,
      backgroundColor: backgroundColor,
      checkmarkColor: checkmarkColor,
      clipBehavior: clipBehavior,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      maxChips: maxChips,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      showCheckmark: showCheckmark,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }

  /// Gets a [FormField] for `propBoolList` property.
  FormBuilderFilterChip<bool> propBoolList(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<bool>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    Color? checkmarkColor,
    Clip clipBehavior = Clip.none,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    int? maxChips,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    bool showCheckmark = true,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    ValueChanged<List<bool>?>? onChanged,
    ValueTransformer<List<bool>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.propBoolList;
    return FormBuilderFilterChip<bool>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      key: key,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      name: property.name,
      options: property
              .getFieldValue(Localizations.maybeLocaleOf(context) ??
                  const Locale('en', 'US'))
              ?.map((x) => FormBuilderFieldOption<bool>(
                  value: x, child: Text(x.toString())))
              .toList() ??
          [],
      alignment: alignment,
      backgroundColor: backgroundColor,
      checkmarkColor: checkmarkColor,
      clipBehavior: clipBehavior,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      maxChips: maxChips,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      showCheckmark: showCheckmark,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }

  /// Gets a [FormField] for `propBoolCheckBox` property.
  FormBuilderCheckbox propBoolCheckBox(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<bool?>? onChanged,
    ValueTransformer<bool?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required Widget title,
    Color? activeColor,
    bool autofocus = false,
    Color? checkColor,
    EdgeInsets contentPadding = EdgeInsets.zero,
    ListTileControlAffinity controlAffinity = ListTileControlAffinity.leading,
    Widget? secondary,
    bool selected = false,
    bool shouldRequestFocus = false,
    Widget? subtitle,
    bool tristate = false,
  }) {
    final property = _presenter.propBoolCheckBox;
    return FormBuilderCheckbox(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none)
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      title: title,
      activeColor: activeColor,
      autofocus: autofocus,
      checkColor: checkColor,
      contentPadding: contentPadding,
      controlAffinity: controlAffinity,
      secondary: secondary,
      selected: selected,
      shouldRequestFocus: shouldRequestFocus,
      subtitle: subtitle,
      tristate: tristate,
    );
  }

  /// Gets a [FormField] for `propEnumListCheckBoxGroup` property.
  FormBuilderCheckboxGroup<MyEnum> propEnumListCheckBoxGroup(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<List<MyEnum>?>? onChanged,
    ValueTransformer<List<MyEnum>?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<FormBuilderFieldOption<MyEnum>>? options,
    Color? activeColor,
    Color? checkColor,
    Color? focusColor,
    Color? hoverColor,
    List<MyEnum>? disabled,
    MaterialTapTargetSize? materialTapTargetSize,
    bool tristate = false,
    Axis wrapDirection = Axis.horizontal,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    double wrapSpacing = 0.0,
    WrapAlignment wrapRunAlignment = WrapAlignment.start,
    double wrapRunSpacing = 0.0,
    WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start,
    TextDirection? wrapTextDirection,
    VerticalDirection wrapVerticalDirection = VerticalDirection.down,
    Widget? separator,
    ControlAffinity controlAffinity = ControlAffinity.leading,
    OptionsOrientation orientation = OptionsOrientation.wrap,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.propEnumListCheckBoxGroup;
    return FormBuilderCheckboxGroup<MyEnum>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      options: property
              .getFieldValue(Localizations.maybeLocaleOf(context) ??
                  const Locale('en', 'US'))
              ?.map((x) => FormBuilderFieldOption<MyEnum>(
                  value: x, child: Text(x.toString())))
              .toList() ??
          [],
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
      shouldRequestFocus: shouldRequestFocus,
    );
  }

  /// Gets a [FormField] for `propEnumChoiceChip` property.
  FormBuilderChoiceChip<MyEnum> propEnumChoiceChip(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<MyEnum>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    VisualDensity? visualDensity,
    ValueChanged<MyEnum?>? onChanged,
    ValueTransformer<MyEnum?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.propEnumChoiceChip;
    return FormBuilderChoiceChip<MyEnum>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      key: key,
      name: property.name,
      options: [MyEnum.one, MyEnum.two]
          .map((x) => FormBuilderFieldOption<MyEnum>(
              value: x, child: Text(x.toString())))
          .toList(),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      alignment: alignment,
      backgroundColor: backgroundColor,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      visualDensity: visualDensity,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }

  /// Gets a [FormField] for `propEnumListFilterChip` property.
  FormBuilderFilterChip<MyEnum> propEnumListFilterChip(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<MyEnum>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    Color? backgroundColor,
    Color? checkmarkColor,
    Clip clipBehavior = Clip.none,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
    Axis direction = Axis.horizontal,
    Color? disabledColor,
    double? elevation,
    EdgeInsets? labelPadding,
    TextStyle? labelStyle,
    MaterialTapTargetSize? materialTapTargetSize,
    int? maxChips,
    EdgeInsets? padding,
    double? pressElevation,
    WrapAlignment runAlignment = WrapAlignment.start,
    double runSpacing = 0.0,
    Color? selectedColor,
    Color? selectedShadowColor,
    Color? shadowColor,
    OutlinedBorder? shape,
    bool shouldRequestFocus = false,
    bool showCheckmark = true,
    double spacing = 0.0,
    TextDirection? textDirection,
    VerticalDirection verticalDirection = VerticalDirection.down,
    ValueChanged<List<MyEnum>?>? onChanged,
    ValueTransformer<List<MyEnum>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.propEnumListFilterChip;
    return FormBuilderFilterChip<MyEnum>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      key: key,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      name: property.name,
      options: property
              .getFieldValue(Localizations.maybeLocaleOf(context) ??
                  const Locale('en', 'US'))
              ?.map((x) => FormBuilderFieldOption<MyEnum>(
                  value: x, child: Text(x.toString())))
              .toList() ??
          [],
      alignment: alignment,
      backgroundColor: backgroundColor,
      checkmarkColor: checkmarkColor,
      clipBehavior: clipBehavior,
      crossAxisAlignment: crossAxisAlignment,
      direction: direction,
      disabledColor: disabledColor,
      elevation: elevation,
      labelPadding: labelPadding,
      labelStyle: labelStyle,
      materialTapTargetSize: materialTapTargetSize,
      maxChips: maxChips,
      padding: padding,
      pressElevation: pressElevation,
      runAlignment: runAlignment,
      runSpacing: runSpacing,
      selectedColor: selectedColor,
      selectedShadowColor: selectedShadowColor,
      shadowColor: shadowColor,
      shape: shape,
      shouldRequestFocus: shouldRequestFocus,
      showCheckmark: showCheckmark,
      spacing: spacing,
      textDirection: textDirection,
      verticalDirection: verticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }

  /// Gets a [FormField] for `propEnumRadioGroup` property.
  FormBuilderRadioGroup<MyEnum> propEnumRadioGroup(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<MyEnum>>? options,
    bool shouldRadioRequestFocus = false,
    Color? activeColor,
    ControlAffinity controlAffinity = ControlAffinity.leading,
    List<MyEnum>? disabled,
    Color? focusColor,
    Color? hoverColor,
    MaterialTapTargetSize? materialTapTargetSize,
    OptionsOrientation orientation = OptionsOrientation.wrap,
    Widget? separator,
    WrapAlignment wrapAlignment = WrapAlignment.start,
    WrapCrossAlignment wrapCrossAxisAlignment = WrapCrossAlignment.start,
    Axis wrapDirection = Axis.horizontal,
    WrapAlignment wrapRunAlignment = WrapAlignment.start,
    double wrapRunSpacing = 0.0,
    double wrapSpacing = 0.0,
    TextDirection? wrapTextDirection,
    VerticalDirection wrapVerticalDirection = VerticalDirection.down,
    ValueChanged<MyEnum?>? onChanged,
    ValueTransformer<MyEnum?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.propEnumRadioGroup;
    return FormBuilderRadioGroup<MyEnum>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      key: key,
      name: property.name,
      options: [MyEnum.one, MyEnum.two]
          .map((x) => FormBuilderFieldOption<MyEnum>(
              value: x, child: Text(x.toString())))
          .toList(),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      shouldRadioRequestFocus: shouldRadioRequestFocus,
      activeColor: activeColor,
      controlAffinity: controlAffinity,
      disabled: disabled,
      focusColor: focusColor,
      hoverColor: hoverColor,
      materialTapTargetSize: materialTapTargetSize,
      orientation: orientation,
      separator: separator,
      wrapAlignment: wrapAlignment,
      wrapCrossAxisAlignment: wrapCrossAxisAlignment,
      wrapDirection: wrapDirection,
      wrapRunAlignment: wrapRunAlignment,
      wrapRunSpacing: wrapRunSpacing,
      wrapSpacing: wrapSpacing,
      wrapTextDirection: wrapTextDirection,
      wrapVerticalDirection: wrapVerticalDirection,
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      onReset: onReset,
    );
  }

  /// Gets a [FormField] for `propEnumSegmentedControl` property.
  FormBuilderSegmentedControl<MyEnum> propEnumSegmentedControl(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<MyEnum?>? onChanged,
    ValueTransformer<MyEnum?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<FormBuilderFieldOption<MyEnum>>? options,
    Color? borderColor,
    Color? selectedColor,
    Color? pressedColor,
    EdgeInsetsGeometry? padding,
    Color? unselectedColor,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.propEnumSegmentedControl;
    return FormBuilderSegmentedControl<MyEnum>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      options: [MyEnum.one, MyEnum.two]
          .map((x) => FormBuilderFieldOption<MyEnum>(
              value: x, child: Text(x.toString())))
          .toList(),
      borderColor: borderColor,
      selectedColor: selectedColor,
      pressedColor: pressedColor,
      padding: padding,
      unselectedColor: unselectedColor,
      shouldRequestFocus: shouldRequestFocus,
    );
  }

  /// Gets a [FormField] for `propDoubleSlider` property.
  FormBuilderSlider propDoubleSlider(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<double?>? onChanged,
    ValueTransformer<double?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required double min,
    required double max,
    int? divisions,
    Color? activeColor,
    Color? inactiveColor,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
    String? label,
    SemanticFormatterCallback? semanticFormatterCallback,
    NumberFormat? numberFormat,
    DisplayValues displayValues = DisplayValues.all,
    TextStyle? minTextStyle,
    TextStyle? textStyle,
    TextStyle? maxTextStyle,
    bool autofocus = false,
    MouseCursor? mouseCursor,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.propDoubleSlider;
    return FormBuilderSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      min: min,
      max: max,
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
      shouldRequestFocus: shouldRequestFocus,
    );
  }

  /// Gets a [FormField] for `propInt` property.
  FormBuilderTextField propInt(
    BuildContext context, {
    Key? key,
    bool readOnly = false,
    InputDecoration? decoration,
    ValueChanged<String?>? onChanged,
    ValueTransformer<String?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    int? maxLines = 1,
    bool obscureText = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    TextInputType? keyboardType,
    TextStyle? style,
    TextEditingController? controller,
    TextInputAction? textInputAction,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    int? maxLength,
    VoidCallback? onEditingComplete,
    ValueChanged<String?>? onSubmitted,
    List<TextInputFormatter>? inputFormatters,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    InputCounterWidgetBuilder? buildCounter,
    bool expands = false,
    int? minLines,
    bool? showCursor,
    GestureTapCallback? onTap,
    bool enableSuggestions = false,
    TextAlignVertical? textAlignVertical,
    DragStartBehavior dragStartBehavior = DragStartBehavior.start,
    ScrollController? scrollController,
    ScrollPhysics? scrollPhysics,
    ui.BoxWidthStyle selectionWidthStyle = ui.BoxWidthStyle.tight,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.propInt;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
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

/// Defines an extension property to get [$TheFormBuilderPresenterFieldFactory] from [TheFormBuilderPresenter].
extension $TheFormBuilderPresenterFieldFactoryExtension
    on TheFormBuilderPresenter {
  /// Gets a [FormField] factory.
  $TheFormBuilderPresenterFieldFactory get fields =>
      $TheFormBuilderPresenterFieldFactory._(this);
}
