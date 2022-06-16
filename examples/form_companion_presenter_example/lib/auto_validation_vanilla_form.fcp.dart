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

import 'package:easy_localization/easy_localization.dart'
    show StringTranslateExtension;

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

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'auto_validation_vanilla_form.dart';

import 'l10n/locale_keys.g.dart' show LocaleKeys;

import 'models.dart' show Gender;

/// Defines typed property accessors as extension properties for [AutoValidationVanillaFormAccountPresenter].
extension $AutoValidationVanillaFormAccountPresenterPropertyExtension
    on AutoValidationVanillaFormAccountPresenter {
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
}

/// Defines [FormField] factory methods for properties of [AutoValidationVanillaFormAccountPresenter].
class $AutoValidationVanillaFormAccountPresenterFieldFactory {
  final AutoValidationVanillaFormAccountPresenter _presenter;

  $AutoValidationVanillaFormAccountPresenterFieldFactory._(this._presenter);

  /// Gets a [FormField] for `id` property.
  TextFormField id(
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
    final property = _presenter.id;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.id_label.tr(),
              hintText: LocaleKeys.id_hint.tr()),
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

  /// Gets a [FormField] for `name` property.
  TextFormField name(
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
    final property = _presenter.name;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.name_label.tr(),
              hintText: LocaleKeys.name_hint.tr()),
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

  /// Gets a [FormField] for `gender` property.
  DropdownButtonFormField<Gender> gender(
    BuildContext context, {
    List<DropdownMenuItem<Gender>>? items,
    DropdownButtonBuilder? selectedItemBuilder,
    Widget? hint,
    Widget? disabledHint,
    ValueChanged<Gender?>? onChanged,
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
    final property = _presenter.gender;
    return DropdownButtonFormField<Gender>(
      key: _presenter.getKey(property.name, context),
      items: [Gender.notKnown, Gender.male, Gender.female, Gender.notApplicable]
          .map((x) => DropdownMenuItem<Gender>(
              value: x, child: Text('gender_${x.name}'.tr())))
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
          InputDecoration(
              labelText: LocaleKeys.gender_label.tr(),
              hintText: LocaleKeys.gender_hint.tr()),
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

  /// Gets a [FormField] for `age` property.
  TextFormField age(
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
    final property = _presenter.age;
    return TextFormField(
      key: _presenter.getKey(property.name, context),
      controller: controller,
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      focusNode: focusNode,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.age_label.tr(),
              hintText: LocaleKeys.age_hint.tr()),
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

/// Defines an extension property to get [$AutoValidationVanillaFormAccountPresenterFieldFactory] from [AutoValidationVanillaFormAccountPresenter].
extension $AutoValidationVanillaFormAccountPresenterFieldFactoryExtension
    on AutoValidationVanillaFormAccountPresenter {
  /// Gets a [FormField] factory.
  $AutoValidationVanillaFormAccountPresenterFieldFactory get fields =>
      $AutoValidationVanillaFormAccountPresenterFieldFactory._(this);
}
