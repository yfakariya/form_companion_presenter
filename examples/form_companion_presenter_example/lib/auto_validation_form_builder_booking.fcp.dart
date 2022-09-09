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
        Offset,
        Radius,
        TextAlign,
        TextDirection,
        VoidCallback;

import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle, TextDirection;

import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;

import 'package:flutter/foundation.dart' show Key, ValueChanged;

import 'package:flutter/gestures.dart'
    show DragStartBehavior, GestureTapCallback;

import 'package:flutter/material.dart'
    show
        DatePickerEntryMode,
        DatePickerMode,
        DateTimeRange,
        EntryModeChangeCallback,
        Icons,
        InputCounterWidgetBuilder,
        InputDecoration,
        ListTileControlAffinity,
        MaterialTapTargetSize,
        RangeLabels,
        RangeValues,
        SelectableDayPredicate,
        SemanticFormatterCallback,
        TimeOfDay,
        TimePickerEntryMode;

import 'package:flutter/painting.dart'
    show
        Axis,
        CircleBorder,
        EdgeInsets,
        EdgeInsetsGeometry,
        ImageProvider,
        OutlinedBorder,
        ShapeBorder,
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
        FormBuilderChipOption,
        FormBuilderDateRangePicker,
        FormBuilderDateTimePicker,
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

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'package:intl/intl.dart' show DateFormat, NumberFormat;

import 'package:intl/intl.dart' as intl show DateFormat;

import 'auto_validation_form_builder_booking.dart';

import 'l10n/locale_keys.g.dart' show LocaleKeys;

import 'models.dart' show MealType, RoomType;

/// Defines typed property accessors as extension properties for [AutoValidationFormBuilderBookingPresenter].
extension $AutoValidationFormBuilderBookingPresenterPropertyExtension
    on AutoValidationFormBuilderBookingPresenter {
  /// Gets a [PropertyDescriptor] of `stay` property.
  PropertyDescriptor<DateTimeRange, DateTimeRange> get stay =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['stay']! as PropertyDescriptor<DateTimeRange, DateTimeRange>;

  /// Gets a [PropertyDescriptor] of `specialOfferDate` property.
  PropertyDescriptor<DateTime, DateTime> get specialOfferDate =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['specialOfferDate']! as PropertyDescriptor<DateTime, DateTime>;

  /// Gets a [PropertyDescriptor] of `roomType` property.
  PropertyDescriptor<RoomType, RoomType> get roomType =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['roomType']! as PropertyDescriptor<RoomType, RoomType>;

  /// Gets a [PropertyDescriptor] of `mealOffers` property.
  PropertyDescriptor<List<MealType>, List<MealType>> get mealOffers =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['mealOffers']!
          as PropertyDescriptor<List<MealType>, List<MealType>>;

  /// Gets a [PropertyDescriptor] of `smoking` property.
  PropertyDescriptor<bool, bool> get smoking =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['smoking']! as PropertyDescriptor<bool, bool>;

  /// Gets a [PropertyDescriptor] of `persons` property.
  PropertyDescriptor<int, double> get persons =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['persons']! as PropertyDescriptor<int, double>;

  /// Gets a [PropertyDescriptor] of `babyBeds` property.
  PropertyDescriptor<int, int> get babyBeds =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['babyBeds']! as PropertyDescriptor<int, int>;

  /// Gets a [PropertyDescriptor] of `preferredPrice` property.
  PropertyDescriptor<RangeValues, RangeValues> get preferredPrice =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['preferredPrice']!
          as PropertyDescriptor<RangeValues, RangeValues>;

  /// Gets a [PropertyDescriptor] of `donation` property.
  PropertyDescriptor<double, String> get donation =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['donation']! as PropertyDescriptor<double, String>;

  /// Gets a [PropertyDescriptor] of `note` property.
  PropertyDescriptor<String, String> get note =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['note']! as PropertyDescriptor<String, String>;
}

/// Defines [FormField] factory methods for properties of [AutoValidationFormBuilderBookingPresenter].
class $AutoValidationFormBuilderBookingPresenterFieldFactory {
  final AutoValidationFormBuilderBookingPresenter _presenter;

  $AutoValidationFormBuilderBookingPresenterFieldFactory._(this._presenter);

  /// Gets a [FormField] for `stay` property.
  FormBuilderDateRangePicker stay(
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
    bool allowClear = false,
    Widget? clearIcon,
  }) {
    final property = _presenter.stay;
    return FormBuilderDateRangePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.stay_label.tr(),
              hintText: LocaleKeys.stay_hint.tr()),
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
      allowClear: allowClear,
      clearIcon: clearIcon,
    );
  }

  /// Gets a [FormField] for `specialOfferDate` property.
  FormBuilderDateTimePicker specialOfferDate(
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
    Widget? resetIcon = const Icon(Icons.close),
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
    Offset? anchorPoint,
    EntryModeChangeCallback? onEntryModeChanged,
  }) {
    final property = _presenter.specialOfferDate;
    return FormBuilderDateTimePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.specialOfferDate_label.tr(),
              hintText: LocaleKeys.specialOfferDate_hint.tr()),
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
      anchorPoint: anchorPoint,
      onEntryModeChanged: onEntryModeChanged,
    );
  }

  /// Gets a [FormField] for `roomType` property.
  FormBuilderRadioGroup<RoomType> roomType(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderFieldOption<RoomType>>? options,
    bool shouldRadioRequestFocus = false,
    Color? activeColor,
    ControlAffinity controlAffinity = ControlAffinity.leading,
    List<RoomType>? disabled,
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
    ValueChanged<RoomType?>? onChanged,
    ValueTransformer<RoomType?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.roomType;
    return FormBuilderRadioGroup<RoomType>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.roomType_label.tr(),
              hintText: LocaleKeys.roomType_hint.tr()),
      key: key,
      name: property.name,
      options: [RoomType.standard, RoomType.delux, RoomType.suite]
          .map((x) => FormBuilderFieldOption<RoomType>(
              value: x, child: Text('roomType.${x.name}'.tr())))
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

  /// Gets a [FormField] for `mealOffers` property.
  FormBuilderFilterChip<MealType> mealOffers(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderChipOption<MealType>>? options,
    WrapAlignment alignment = WrapAlignment.start,
    ShapeBorder avatarBorder = const CircleBorder(),
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
    ValueChanged<List<MealType>?>? onChanged,
    ValueTransformer<List<MealType>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.mealOffers;
    return FormBuilderFilterChip<MealType>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.mealOffers_label.tr(),
              hintText: LocaleKeys.mealOffers_hint.tr()),
      key: key,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      name: property.name,
      options: [MealType.vegan, MealType.halal]
          .map((x) => FormBuilderChipOption<MealType>(
              value: x, child: Text('mealOffers.${x.name}'.tr())))
          .toList(),
      alignment: alignment,
      avatarBorder: avatarBorder,
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

  /// Gets a [FormField] for `smoking` property.
  FormBuilderSwitch smoking(
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
    final property = _presenter.smoking;
    return FormBuilderSwitch(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.smoking_label.tr(),
              hintText: LocaleKeys.smoking_hint.tr()),
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

  /// Gets a [FormField] for `persons` property.
  FormBuilderSlider persons(
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
    final property = _presenter.persons;
    return FormBuilderSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.persons_label.tr(),
              hintText: LocaleKeys.persons_hint.tr()),
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

  /// Gets a [FormField] for `babyBeds` property.
  FormBuilderSegmentedControl<int> babyBeds(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<int?>? onChanged,
    ValueTransformer<int?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    required List<FormBuilderFieldOption<int>> options,
    Color? borderColor,
    Color? selectedColor,
    Color? pressedColor,
    EdgeInsetsGeometry? padding,
    Color? unselectedColor,
    bool shouldRequestFocus = false,
  }) {
    final property = _presenter.babyBeds;
    return FormBuilderSegmentedControl<int>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.babyBeds_label.tr(),
              hintText: LocaleKeys.babyBeds_hint.tr()),
      onChanged: onChanged,
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      options: options,
      borderColor: borderColor,
      selectedColor: selectedColor,
      pressedColor: pressedColor,
      padding: padding,
      unselectedColor: unselectedColor,
      shouldRequestFocus: shouldRequestFocus,
    );
  }

  /// Gets a [FormField] for `preferredPrice` property.
  FormBuilderRangeSlider preferredPrice(
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
    final property = _presenter.preferredPrice;
    return FormBuilderRangeSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.preferredPrice_label.tr(),
              hintText: LocaleKeys.preferredPrice_hint.tr()),
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

  /// Gets a [FormField] for `donation` property.
  FormBuilderTextField donation(
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
    final property = _presenter.donation;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.donation_label.tr(),
              hintText: LocaleKeys.donation_hint.tr()),
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

  /// Gets a [FormField] for `note` property.
  FormBuilderTextField note(
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
    final property = _presenter.note;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.note_label.tr(),
              hintText: LocaleKeys.note_hint.tr()),
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

/// Defines an extension property to get [$AutoValidationFormBuilderBookingPresenterFieldFactory] from [AutoValidationFormBuilderBookingPresenter].
extension $AutoValidationFormBuilderBookingPresenterFieldFactoryExtension
    on AutoValidationFormBuilderBookingPresenter {
  /// Gets a [FormField] factory.
  $AutoValidationFormBuilderBookingPresenterFieldFactory get fields =>
      $AutoValidationFormBuilderBookingPresenterFieldFactory._(this);
}
