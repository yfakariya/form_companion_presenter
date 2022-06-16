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
        Color,
        Locale,
        Radius,
        TextAlign,
        TextDirection,
        VoidCallback;

import 'package:flutter/foundation.dart' show ValueChanged;

import 'package:flutter/gestures.dart' show GestureTapCallback;

import 'package:flutter/material.dart'
    show
        DropdownButtonBuilder,
        DropdownButtonFormField,
        DropdownMenuItem,
        InputCounterWidgetBuilder,
        InputDecoration,
        TextFormField;

import 'package:flutter/painting.dart'
    show
        AlignmentDirectional,
        AlignmentGeometry,
        BorderRadius,
        EdgeInsets,
        StrutStyle,
        TextAlignVertical,
        TextStyle;

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
        Localizations,
        ScrollController,
        ScrollPhysics,
        Text,
        TextEditingController,
        TextSelectionControls,
        ToolbarOptions,
        Widget;

import 'package:form_companion_generator_test_targets/enum.dart' show MyEnum;

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'the_form_presenter.dart';

/// Defines typed property accessors as extension properties for [TheFormPresenter].
extension $TheFormPresenterPropertyExtension on TheFormPresenter {
  /// Gets a [PropertyDescriptor] of `propString` property.
  PropertyDescriptor<String, String> get propString =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propString']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `propEnum` property.
  PropertyDescriptor<MyEnum, MyEnum> get propEnum =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propEnum']! as PropertyDescriptor<MyEnum, MyEnum>;

  /// Gets a [PropertyDescriptor] of `propString2` property.
  PropertyDescriptor<String, String> get propString2 =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propString2']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `propInt` property.
  PropertyDescriptor<int, String> get propInt =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['propInt']! as PropertyDescriptor<int, String>;
}

/// Defines [FormField] factory methods for properties of [TheFormPresenter].
class $TheFormPresenterFieldFactory {
  final TheFormPresenter _presenter;

  $TheFormPresenterFieldFactory._(this._presenter);

  /// Gets a [FormField] for `propString` property.
  TextFormField propString(
    BuildContext context, {
    TextEditingController? controller,
    FocusNode? focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    String? restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.propString;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      readOnly: readOnly,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: (v) => property.setFieldValue(
          v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
    );
  }

  /// Gets a [FormField] for `propEnum` property.
  DropdownButtonFormField<MyEnum> propEnum(
    BuildContext context, {
    List<DropdownMenuItem<MyEnum>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    ValueChanged<MyEnum?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  }) {
    final property = _presenter.propEnum;
    return DropdownButtonFormField<MyEnum>(
      key: _presenter.getKey(property.name, context),
      items: [MyEnum.one, MyEnum.two]
          .map((x) => DropdownMenuItem<MyEnum>(value: x, child: Text(x.name)))
          .toList(),
      selectedItemBuilder: selectedItemBuilder,
      value: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged ?? (_) {},
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      decoration: decoration ??
          InputDecoration(labelText: property.name, hintText: null),
      onSaved: (v) => property.setFieldValue(
          v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
    );
  }

  /// Gets a [FormField] for `propString2` property.
  DropdownButtonFormField<String> propString2(
    BuildContext context, {
    required List<DropdownMenuItem<String>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    ValueChanged<String?>? onChanged,
    VoidCallback? onTap,
    int elevation = 8,
    TextStyle? style,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
    double iconSize = 24.0,
    bool isDense = true,
    bool isExpanded = false,
    double? itemHeight,
    Color? focusColor,
    FocusNode? focusNode,
    bool autofocus = false,
    Color? dropdownColor,
    InputDecoration? decoration,
    AutovalidateMode? autovalidateMode,
    double? menuMaxHeight,
    bool? enableFeedback,
    AlignmentGeometry alignment = AlignmentDirectional.centerStart,
    BorderRadius? borderRadius,
  }) {
    final property = _presenter.propString2;
    return DropdownButtonFormField<String>(
      key: _presenter.getKey(property.name, context),
      items: items,
      selectedItemBuilder: selectedItemBuilder,
      value: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      hint: hint,
      disabledHint: disabledHint,
      onChanged: onChanged ?? (_) {},
      onTap: onTap,
      elevation: elevation,
      style: style,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
      iconSize: iconSize,
      isDense: isDense,
      isExpanded: isExpanded,
      itemHeight: itemHeight,
      focusColor: focusColor,
      focusNode: focusNode,
      autofocus: autofocus,
      dropdownColor: dropdownColor,
      decoration: decoration ??
          InputDecoration(labelText: property.name, hintText: null),
      onSaved: (v) => property.setFieldValue(
          v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      menuMaxHeight: menuMaxHeight,
      enableFeedback: enableFeedback,
      alignment: alignment,
      borderRadius: borderRadius,
    );
  }

  /// Gets a [FormField] for `propInt` property.
  TextFormField propInt(
    BuildContext context, {
    TextEditingController? controller,
    FocusNode? focusNode,
    InputDecoration? decoration,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    TextInputAction? textInputAction,
    TextStyle? style,
    StrutStyle? strutStyle,
    TextDirection? textDirection,
    TextAlign textAlign = TextAlign.start,
    TextAlignVertical? textAlignVertical,
    bool autofocus = false,
    bool readOnly = false,
    ToolbarOptions? toolbarOptions,
    bool? showCursor,
    String obscuringCharacter = '•',
    bool obscureText = false,
    bool autocorrect = true,
    SmartDashesType? smartDashesType,
    SmartQuotesType? smartQuotesType,
    bool enableSuggestions = true,
    MaxLengthEnforcement? maxLengthEnforcement,
    int? maxLines = 1,
    int? minLines,
    bool expands = false,
    int? maxLength,
    ValueChanged<String>? onChanged,
    GestureTapCallback? onTap,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    List<TextInputFormatter>? inputFormatters,
    bool? enabled,
    double cursorWidth = 2.0,
    double? cursorHeight,
    Radius? cursorRadius,
    Color? cursorColor,
    Brightness? keyboardAppearance,
    EdgeInsets scrollPadding = const EdgeInsets.all(20.0),
    bool? enableInteractiveSelection,
    TextSelectionControls? selectionControls,
    InputCounterWidgetBuilder? buildCounter,
    ScrollPhysics? scrollPhysics,
    Iterable<String>? autofillHints,
    AutovalidateMode? autovalidateMode,
    ScrollController? scrollController,
    String? restorationId,
    bool enableIMEPersonalizedLearning = true,
    MouseCursor? mouseCursor,
  }) {
    final property = _presenter.propInt;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration()
              .copyWith(labelText: property.name, hintText: null),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      textInputAction: textInputAction,
      style: style,
      strutStyle: strutStyle,
      textDirection: textDirection,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofocus: autofocus,
      readOnly: readOnly,
      toolbarOptions: toolbarOptions,
      showCursor: showCursor,
      obscuringCharacter: obscuringCharacter,
      obscureText: obscureText,
      autocorrect: autocorrect,
      smartDashesType: smartDashesType,
      smartQuotesType: smartQuotesType,
      enableSuggestions: enableSuggestions,
      maxLengthEnforcement: maxLengthEnforcement,
      maxLines: maxLines,
      minLines: minLines,
      expands: expands,
      maxLength: maxLength,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      onSaved: (v) => property.setFieldValue(
          v, Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      validator: property.getValidator(context),
      inputFormatters: inputFormatters,
      enabled: enabled,
      cursorWidth: cursorWidth,
      cursorHeight: cursorHeight,
      cursorRadius: cursorRadius,
      cursorColor: cursorColor,
      keyboardAppearance: keyboardAppearance,
      scrollPadding: scrollPadding,
      enableInteractiveSelection: enableInteractiveSelection,
      selectionControls: selectionControls,
      buildCounter: buildCounter,
      scrollPhysics: scrollPhysics,
      autofillHints: autofillHints,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
    );
  }
}

/// Defines an extension property to get [$TheFormPresenterFieldFactory] from [TheFormPresenter].
extension $TheFormPresenterFieldFactoryExtension on TheFormPresenter {
  /// Gets a [FormField] factory.
  $TheFormPresenterFieldFactory get fields =>
      $TheFormPresenterFieldFactory._(this);
}
