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
        EditableTextContextMenuBuilder,
        FocusNode,
        Icon,
        RouteSettings,
        ScrollController,
        ScrollPhysics,
        Text,
        TextEditingController,
        TextMagnifierConfiguration,
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

import 'package:meta/meta.dart' show immutable, sealed;

import '../l10n/locale_keys.g.dart' show LocaleKeys;

import '../models.dart' show MealType, RoomType;

import 'booking.dart';

/// Defines typed property state accessors
/// for [BookingPresenterTemplate].
@sealed
@immutable
class $BookingPresenterTemplateFormProperties implements FormProperties {
  final FormProperties _underlying;

  /// Gets a [BookingPresenterTemplate] instance which holds this properties state.
  BookingPresenterTemplate get presenter =>
      _underlying.presenter as BookingPresenterTemplate;

  /// Gets a typed [PropertyDescriptor] accessor [$BookingPresenterTemplatePropertyDescriptors]
  /// for [BookingPresenterTemplate].
  late final $BookingPresenterTemplatePropertyDescriptors descriptors;

  /// Gets a typed property value accessor [$BookingPresenterTemplatePropertyValues]
  /// for [BookingPresenterTemplate].
  late final $BookingPresenterTemplatePropertyValues values;

  /// Returns a [$BookingPresenterTemplateFormProperties] which wraps [FormProperties].
  ///
  /// Note that this factory returns [underlying] if [underlying] is
  /// [$BookingPresenterTemplateFormProperties] type.
  factory $BookingPresenterTemplateFormProperties(FormProperties underlying) {
    if (underlying is $BookingPresenterTemplateFormProperties) {
      return underlying;
    }

    if (underlying.presenter is! BookingPresenterTemplate) {
      throw ArgumentError(
        'Specified FormProperties does not hold ${BookingPresenterTemplate} type presenter.',
        'underlying',
      );
    }

    return $BookingPresenterTemplateFormProperties._(underlying);
  }

  $BookingPresenterTemplateFormProperties._(this._underlying) {
    descriptors = $BookingPresenterTemplatePropertyDescriptors._(_underlying);
    values = $BookingPresenterTemplatePropertyValues._(_underlying);
  }

  @override
  bool canSubmit(BuildContext context) => _underlying.canSubmit(context);

  @override
  void Function()? submit(BuildContext context) => _underlying.submit(context);

  @override
  $BookingPresenterTemplateFormProperties copyWithProperties(
    Map<String, Object?> newValues,
  ) {
    final newUnderlying = _underlying.copyWithProperties(newValues);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $BookingPresenterTemplateFormProperties(newUnderlying);
  }

  @override
  $BookingPresenterTemplateFormProperties copyWithProperty(
    String name,
    Object? newValue,
  ) {
    final newUnderlying = _underlying.copyWithProperty(name, newValue);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $BookingPresenterTemplateFormProperties(newUnderlying);
  }

  /// Copies this instance with specified new property values specified via
  /// returned [$BookingPresenterTemplateFormPropertiesBuilder] object.
  ///
  /// You must call [$BookingPresenterTemplateFormPropertiesBuilder.build]
  /// to finish copying.
  $BookingPresenterTemplateFormPropertiesBuilder copyWith() =>
      $BookingPresenterTemplateFormPropertiesBuilder._(this);

  @override
  PropertyDescriptor<P, F> getDescriptor<P extends Object, F extends Object>(
    String name,
  ) =>
      _underlying.getDescriptor<P, F>(name);

  @override
  PropertyDescriptor<P, F>?
      tryGetDescriptor<P extends Object, F extends Object>(
    String name,
  ) =>
          _underlying.tryGetDescriptor(name);

  @override
  Iterable<PropertyDescriptor<Object, Object>> getAllDescriptors() =>
      _underlying.getAllDescriptors();

  @override
  Object? getValue(String name) => _underlying.getValue(name);
}

/// Defines typed [PropertyDescriptor] accessors
/// for [BookingPresenterTemplateFormProperties].
@sealed
class $BookingPresenterTemplatePropertyDescriptors {
  final FormProperties _properties;

  $BookingPresenterTemplatePropertyDescriptors._(this._properties);

  /// Gets a [PropertyDescriptor] of `stay` property.
  PropertyDescriptor<DateTimeRange, DateTimeRange> get stay =>
      _properties.getDescriptor('stay')
          as PropertyDescriptor<DateTimeRange, DateTimeRange>;

  /// Gets a [PropertyDescriptor] of `specialOfferDate` property.
  PropertyDescriptor<DateTime, DateTime> get specialOfferDate =>
      _properties.getDescriptor('specialOfferDate')
          as PropertyDescriptor<DateTime, DateTime>;

  /// Gets a [PropertyDescriptor] of `roomType` property.
  PropertyDescriptor<RoomType, RoomType> get roomType =>
      _properties.getDescriptor('roomType')
          as PropertyDescriptor<RoomType, RoomType>;

  /// Gets a [PropertyDescriptor] of `mealOffers` property.
  PropertyDescriptor<List<MealType>, List<MealType>> get mealOffers =>
      _properties.getDescriptor('mealOffers')
          as PropertyDescriptor<List<MealType>, List<MealType>>;

  /// Gets a [PropertyDescriptor] of `smoking` property.
  PropertyDescriptor<bool, bool> get smoking =>
      _properties.getDescriptor('smoking') as PropertyDescriptor<bool, bool>;

  /// Gets a [PropertyDescriptor] of `persons` property.
  PropertyDescriptor<int, double> get persons =>
      _properties.getDescriptor('persons') as PropertyDescriptor<int, double>;

  /// Gets a [PropertyDescriptor] of `babyBeds` property.
  PropertyDescriptor<int, int> get babyBeds =>
      _properties.getDescriptor('babyBeds') as PropertyDescriptor<int, int>;

  /// Gets a [PropertyDescriptor] of `preferredPrice` property.
  PropertyDescriptor<RangeValues, RangeValues> get preferredPrice =>
      _properties.getDescriptor('preferredPrice')
          as PropertyDescriptor<RangeValues, RangeValues>;

  /// Gets a [PropertyDescriptor] of `donation` property.
  PropertyDescriptor<double, String> get donation =>
      _properties.getDescriptor('donation')
          as PropertyDescriptor<double, String>;

  /// Gets a [PropertyDescriptor] of `note` property.
  PropertyDescriptor<String, String> get note =>
      _properties.getDescriptor('note') as PropertyDescriptor<String, String>;
}

/// Defines typed property value accessors
/// for [BookingPresenterTemplateFormProperties].
@sealed
class $BookingPresenterTemplatePropertyValues {
  final FormProperties _properties;

  $BookingPresenterTemplatePropertyValues._(this._properties);

  /// Gets a current value of `stay` property.
  DateTimeRange get stay => _properties.getValue('stay') as DateTimeRange;

  /// Gets a current value of `specialOfferDate` property.
  DateTime get specialOfferDate =>
      _properties.getValue('specialOfferDate') as DateTime;

  /// Gets a current value of `roomType` property.
  RoomType get roomType => _properties.getValue('roomType') as RoomType;

  /// Gets a current value of `mealOffers` property.
  List<MealType> get mealOffers =>
      _properties.getValue('mealOffers') as List<MealType>;

  /// Gets a current value of `smoking` property.
  bool get smoking => _properties.getValue('smoking') as bool;

  /// Gets a current value of `persons` property.
  int get persons => _properties.getValue('persons') as int;

  /// Gets a current value of `babyBeds` property.
  int get babyBeds => _properties.getValue('babyBeds') as int;

  /// Gets a current value of `preferredPrice` property.
  RangeValues get preferredPrice =>
      _properties.getValue('preferredPrice') as RangeValues;

  /// Gets a current value of `donation` property.
  double get donation => _properties.getValue('donation') as double;

  /// Gets a current value of `note` property.
  String get note => _properties.getValue('note') as String;
}

/// Defines a builder to help [BookingPresenterTemplateFormProperties.copyWith].
@sealed
class $BookingPresenterTemplateFormPropertiesBuilder {
  final $BookingPresenterTemplateFormProperties _properties;
  final Map<String, Object?> _newValues = {};

  $BookingPresenterTemplateFormPropertiesBuilder._(this._properties);

  /// Sets a new value of `stay` property.
  void stay(DateTimeRange value) => _newValues['stay'] = value;

  /// Sets a new value of `specialOfferDate` property.
  void specialOfferDate(DateTime value) =>
      _newValues['specialOfferDate'] = value;

  /// Sets a new value of `roomType` property.
  void roomType(RoomType value) => _newValues['roomType'] = value;

  /// Sets a new value of `mealOffers` property.
  void mealOffers(List<MealType> value) => _newValues['mealOffers'] = value;

  /// Sets a new value of `smoking` property.
  void smoking(bool value) => _newValues['smoking'] = value;

  /// Sets a new value of `persons` property.
  void persons(int value) => _newValues['persons'] = value;

  /// Sets a new value of `babyBeds` property.
  void babyBeds(int value) => _newValues['babyBeds'] = value;

  /// Sets a new value of `preferredPrice` property.
  void preferredPrice(RangeValues value) =>
      _newValues['preferredPrice'] = value;

  /// Sets a new value of `donation` property.
  void donation(double value) => _newValues['donation'] = value;

  /// Sets a new value of `note` property.
  void note(String value) => _newValues['note'] = value;

  $BookingPresenterTemplateFormProperties build() =>
      _properties.copyWithProperties(_newValues);
}

/// Defines typed property accessors as extension properties for [BookingPresenterTemplate].
extension $BookingPresenterTemplatePropertyExtension
    on BookingPresenterTemplate {
  /// Gets a current [$BookingPresenterTemplateFormProperties] which holds properties' values
  /// and their [PropertyDescriptor]s.
  $BookingPresenterTemplateFormProperties get properties =>
      $BookingPresenterTemplateFormProperties(propertiesState);

  /// Resets [properties] (and underlying[CompanionPresenterMixin.propertiesState])
  /// with specified new [$BookingPresenterTemplateFormProperties].
  ///
  /// This method also calls [CompanionPresenterMixin.onPropertiesChanged] callback.
  ///
  /// This method returns passed [FormProperties] for convinience.
  ///
  /// This method is preferred over [CompanionPresenterMixin.resetPropertiesState]
  /// because takes and returns more specific [$BookingPresenterTemplateFormProperties] type.
  $BookingPresenterTemplateFormProperties resetProperties(
    $BookingPresenterTemplateFormProperties newProperties,
  ) {
    resetPropertiesState(newProperties);
    return newProperties;
  }
}

/// Defines [FormField] factory methods for properties of [BookingPresenterTemplate].
class $BookingPresenterTemplateFieldFactory {
  final $BookingPresenterTemplateFormProperties _properties;

  $BookingPresenterTemplateFieldFactory._(this._properties);

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
    bool? obscureText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
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
    final property = _properties.descriptors.stay;
    return FormBuilderDateRangePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.stay_label.tr(),
              hintText: LocaleKeys.stay_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      firstDate: firstDate,
      lastDate: lastDate,
      format: format,
      maxLines: maxLines,
      obscureText: obscureText ?? property.valueTraits.isSensitive,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
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
    bool? obscureText,
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
    TextAlignVertical? textAlignVertical,
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
    final property = _properties.descriptors.specialOfferDate;
    return FormBuilderDateTimePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.specialOfferDate_label.tr(),
              hintText: LocaleKeys.specialOfferDate_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
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
      obscureText: obscureText ?? property.valueTraits.isSensitive,
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
      textAlignVertical: textAlignVertical,
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
    final property = _properties.descriptors.roomType;
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
      initialValue: property.getInitialValue(context),
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
      onChanged: property.onChanged(context, onChanged),
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
    final property = _properties.descriptors.mealOffers;
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
      initialValue: property.getInitialValue(context),
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
      onChanged: property.onChanged(context, onChanged),
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
    final property = _properties.descriptors.smoking;
    return FormBuilderSwitch(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.smoking_label.tr(),
              hintText: LocaleKeys.smoking_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
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
    final property = _properties.descriptors.persons;
    return FormBuilderSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context)!,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.persons_label.tr(),
              hintText: LocaleKeys.persons_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
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
    final property = _properties.descriptors.babyBeds;
    return FormBuilderSegmentedControl<int>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.babyBeds_label.tr(),
              hintText: LocaleKeys.babyBeds_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
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
    final property = _properties.descriptors.preferredPrice;
    return FormBuilderRangeSlider(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.preferredPrice_label.tr(),
              hintText: LocaleKeys.preferredPrice_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
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
    bool? obscureText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    double? cursorHeight,
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
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
  }) {
    final property = _properties.descriptors.donation;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.donation_label.tr(),
              hintText: LocaleKeys.donation_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      maxLines: maxLines,
      obscureText: obscureText ?? property.valueTraits.isSensitive,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
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
      selectionHeightStyle: selectionHeightStyle,
      autofillHints: autofillHints,
      obscuringCharacter: obscuringCharacter,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
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
    bool? obscureText,
    TextCapitalization textCapitalization = TextCapitalization.none,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool enableInteractiveSelection = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    TextAlign textAlign = TextAlign.start,
    bool autofocus = false,
    bool autocorrect = true,
    double cursorWidth = 2.0,
    double? cursorHeight,
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
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
    EditableTextContextMenuBuilder? contextMenuBuilder,
    TextMagnifierConfiguration? magnifierConfiguration,
  }) {
    final property = _properties.descriptors.note;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getInitialValue(context),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.note_label.tr(),
              hintText: LocaleKeys.note_hint.tr()),
      onChanged: property.onChanged(context, onChanged),
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      maxLines: maxLines,
      obscureText: obscureText ?? property.valueTraits.isSensitive,
      textCapitalization: textCapitalization,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      maxLengthEnforcement: maxLengthEnforcement,
      textAlign: textAlign,
      autofocus: autofocus,
      autocorrect: autocorrect,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
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
      selectionHeightStyle: selectionHeightStyle,
      autofillHints: autofillHints,
      obscuringCharacter: obscuringCharacter,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
      magnifierConfiguration: magnifierConfiguration,
    );
  }
}

/// Defines an extension property to get [$BookingPresenterTemplateFieldFactory] from [BookingPresenterTemplate].
extension $BookingPresenterTemplateFormPropertiesFieldFactoryExtension
    on $BookingPresenterTemplateFormProperties {
  /// Gets a [FormField] factory.
  $BookingPresenterTemplateFieldFactory get fields =>
      $BookingPresenterTemplateFieldFactory._(this);
}
