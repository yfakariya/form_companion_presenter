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

import 'dart:ui' as ui show BoxHeightStyle, BoxWidthStyle;

import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;

import 'package:flutter/foundation.dart' show Key, ValueChanged;

import 'package:flutter/gestures.dart'
    show DragStartBehavior, GestureTapCallback;

import 'package:flutter/material.dart'
    show
        DropdownButtonBuilder,
        DropdownMenuItem,
        Icons,
        InputCounterWidgetBuilder,
        InputDecoration,
        MaterialTapTargetSize;

import 'package:flutter/painting.dart'
    show
        AlignmentDirectional,
        AlignmentGeometry,
        Axis,
        BorderRadius,
        CircleBorder,
        EdgeInsets,
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
        ScrollController,
        ScrollPhysics,
        Text,
        TextEditingController,
        ToolbarOptions,
        Widget;

import 'package:flutter_form_builder/flutter_form_builder.dart'
    show
        FormBuilderChipOption,
        FormBuilderDropdown,
        FormBuilderFilterChip,
        FormBuilderTextField,
        ValueTransformer;

import 'package:form_companion_presenter/form_companion_presenter.dart';

import '../l10n/locale_keys.g.dart' show LocaleKeys;

import '../models.dart' show Gender, Region;

import 'account.dart';

/// Defines typed property accessors as extension properties for [AccountPresenterTemplate].
extension $AccountPresenterTemplatePropertyExtension
    on AccountPresenterTemplate {
  /// Gets a [PropertyDescriptor] of `id` property.
  PropertyDescriptor<String, String> get id =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['id']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `name` property.
  PropertyDescriptor<String, String> get name =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['name']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `gender` property.
  PropertyDescriptor<Gender, Gender> get gender =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['gender']! as PropertyDescriptor<Gender, Gender>;

  /// Gets a [PropertyDescriptor] of `age` property.
  PropertyDescriptor<int, String> get age =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['age']! as PropertyDescriptor<int, String>;

  /// Gets a [PropertyDescriptor] of `preferredRegions` property.
  PropertyDescriptor<List<Region>, List<Region>> get preferredRegions =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['preferredRegions']!
          as PropertyDescriptor<List<Region>, List<Region>>;
}

/// Defines [FormField] factory methods for properties of [AccountPresenterTemplate].
class $AccountPresenterTemplateFieldFactory {
  final AccountPresenterTemplate _presenter;

  $AccountPresenterTemplateFieldFactory._(this._presenter);

  /// Gets a [FormField] for `id` property.
  FormBuilderTextField id(
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
    final property = _presenter.id;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr()),
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

  /// Gets a [FormField] for `name` property.
  FormBuilderTextField name(
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
    final property = _presenter.name;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr()),
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

  /// Gets a [FormField] for `gender` property.
  FormBuilderDropdown<Gender> gender(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<Gender?>? onChanged,
    ValueTransformer<Gender?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<DropdownMenuItem<Gender>>? items,
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
    double? itemHeight,
    DropdownButtonBuilder? selectedItemBuilder,
    double? menuMaxHeight,
    bool? enableFeedback,
    BorderRadius? borderRadius,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
  }) {
    final property = _presenter.gender;
    return FormBuilderDropdown<Gender>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.gender_label.tr(),
              hintText: LocaleKeys.gender_hint.tr()),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      items: [Gender.notKnown, Gender.male, Gender.female, Gender.notApplicable]
          .map((x) => DropdownMenuItem<Gender>(
              value: x, child: Text('gender.${x.name}'.tr())))
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
      enableFeedback: enableFeedback,
      borderRadius: borderRadius,
      alignment: alignment,
    );
  }

  /// Gets a [FormField] for `age` property.
  FormBuilderTextField age(
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
    final property = _presenter.age;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.age_label.tr(),
              hintText: LocaleKeys.age_hint.tr()),
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

  /// Gets a [FormField] for `preferredRegions` property.
  FormBuilderFilterChip<Region> preferredRegions(
    BuildContext context, {
    AutovalidateMode? autovalidateMode,
    bool enabled = true,
    FocusNode? focusNode,
    InputDecoration? decoration,
    Key? key,
    List<FormBuilderChipOption<Region>>? options,
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
    ValueChanged<List<Region>?>? onChanged,
    ValueTransformer<List<Region>?>? valueTransformer,
    VoidCallback? onReset,
  }) {
    final property = _presenter.preferredRegions;
    return FormBuilderFilterChip<Region>(
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      enabled: enabled,
      focusNode: focusNode,
      validator: property.getValidator(context),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.preferredRegions_label.tr(),
              hintText: LocaleKeys.preferredRegions_hint.tr()),
      key: key,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US'))!,
      name: property.name,
      options: [
        Region.afurika,
        Region.asia,
        Region.australia,
        Region.europe,
        Region.northAmelica,
        Region.southAmelica
      ]
          .map((x) => FormBuilderChipOption<Region>(
              value: x, child: Text('preferredRegions.${x.name}'.tr())))
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
}

/// Defines an extension property to get [$AccountPresenterTemplateFieldFactory] from [AccountPresenterTemplate].
extension $AccountPresenterTemplateFieldFactoryExtension
    on AccountPresenterTemplate {
  /// Gets a [FormField] factory.
  $AccountPresenterTemplateFieldFactory get fields =>
      $AccountPresenterTemplateFieldFactory._(this);
}
