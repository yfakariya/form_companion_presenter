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
        AdaptiveTextSelectionToolbar,
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
        EditableTextContextMenuBuilder,
        EditableTextState,
        FocusNode,
        Localizations,
        ScrollController,
        ScrollPhysics,
        TapRegionCallback,
        Text,
        TextEditingController,
        TextSelectionControls,
        Widget;

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'package:meta/meta.dart' show immutable, sealed;

import 'l10n/locale_keys.g.dart' show LocaleKeys;

import 'manual_validation_vanilla_form.dart';

import 'models.dart' show Gender;

/// Defines typed property state accessors
/// for [ManualValidationVanillaFormAccountPresenter].
@sealed
@immutable
class $ManualValidationVanillaFormAccountPresenterFormProperties
    implements FormProperties {
  final FormProperties _underlying;

  /// Gets a [ManualValidationVanillaFormAccountPresenter] instance which holds this properties state.
  ManualValidationVanillaFormAccountPresenter get presenter =>
      _underlying.presenter as ManualValidationVanillaFormAccountPresenter;

  /// Gets a typed [PropertyDescriptor] accessor [$ManualValidationVanillaFormAccountPresenterPropertyDescriptors]
  /// for [ManualValidationVanillaFormAccountPresenter].
  late final $ManualValidationVanillaFormAccountPresenterPropertyDescriptors
      descriptors;

  /// Gets a typed property value accessor [$ManualValidationVanillaFormAccountPresenterPropertyValues]
  /// for [ManualValidationVanillaFormAccountPresenter].
  late final $ManualValidationVanillaFormAccountPresenterPropertyValues values;

  /// Returns a [$ManualValidationVanillaFormAccountPresenterFormProperties] which wraps [FormProperties].
  ///
  /// Note that this factory returns [underlying] if [underlying] is
  /// [$ManualValidationVanillaFormAccountPresenterFormProperties] type.
  factory $ManualValidationVanillaFormAccountPresenterFormProperties(
      FormProperties underlying) {
    if (underlying
        is $ManualValidationVanillaFormAccountPresenterFormProperties) {
      return underlying;
    }

    if (underlying.presenter is! ManualValidationVanillaFormAccountPresenter) {
      throw ArgumentError(
        'Specified FormProperties does not hold ${ManualValidationVanillaFormAccountPresenter} type presenter.',
        'underlying',
      );
    }

    return $ManualValidationVanillaFormAccountPresenterFormProperties
        ._(underlying);
  }

  $ManualValidationVanillaFormAccountPresenterFormProperties._(
      this._underlying) {
    descriptors =
        $ManualValidationVanillaFormAccountPresenterPropertyDescriptors
            ._(_underlying);
    values = $ManualValidationVanillaFormAccountPresenterPropertyValues
        ._(_underlying);
  }

  @override
  bool canSubmit(BuildContext context) => _underlying.canSubmit(context);

  @override
  void Function()? submit(BuildContext context) => _underlying.submit(context);

  @override
  $ManualValidationVanillaFormAccountPresenterFormProperties copyWithProperties(
    Map<String, Object?> newValues,
  ) {
    final newUnderlying = _underlying.copyWithProperties(newValues);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $ManualValidationVanillaFormAccountPresenterFormProperties(
        newUnderlying);
  }

  @override
  $ManualValidationVanillaFormAccountPresenterFormProperties copyWithProperty(
    String name,
    Object? newValue,
  ) {
    final newUnderlying = _underlying.copyWithProperty(name, newValue);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $ManualValidationVanillaFormAccountPresenterFormProperties(
        newUnderlying);
  }

  /// Copies this instance with specified new property values specified via
  /// returned [$ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder] object.
  ///
  /// You must call [$ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder.build]
  /// to finish copying.
  $ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder
      copyWith() =>
          $ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder
              ._(this);

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
/// for [ManualValidationVanillaFormAccountPresenterFormProperties].
@sealed
class $ManualValidationVanillaFormAccountPresenterPropertyDescriptors {
  final FormProperties _properties;

  $ManualValidationVanillaFormAccountPresenterPropertyDescriptors._(
      this._properties);

  /// Gets a [PropertyDescriptor] of `id` property.
  PropertyDescriptor<String, String> get id =>
      _properties.getDescriptor('id') as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `name` property.
  PropertyDescriptor<String, String> get name =>
      _properties.getDescriptor('name') as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `gender` property.
  PropertyDescriptor<Gender, Gender> get gender =>
      _properties.getDescriptor('gender') as PropertyDescriptor<Gender, Gender>;

  /// Gets a [PropertyDescriptor] of `age` property.
  PropertyDescriptor<int, String> get age =>
      _properties.getDescriptor('age') as PropertyDescriptor<int, String>;
}

/// Defines typed property value accessors
/// for [ManualValidationVanillaFormAccountPresenterFormProperties].
@sealed
class $ManualValidationVanillaFormAccountPresenterPropertyValues {
  final FormProperties _properties;

  $ManualValidationVanillaFormAccountPresenterPropertyValues._(
      this._properties);

  /// Gets a current value of `id` property.
  String get id => _properties.getValue('id') as String;

  /// Gets a current value of `name` property.
  String get name => _properties.getValue('name') as String;

  /// Gets a current value of `gender` property.
  Gender get gender => _properties.getValue('gender') as Gender;

  /// Gets a current value of `age` property.
  int get age => _properties.getValue('age') as int;
}

/// Defines a builder to help [ManualValidationVanillaFormAccountPresenterFormProperties.copyWith].
@sealed
class $ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder {
  final $ManualValidationVanillaFormAccountPresenterFormProperties _properties;
  final Map<String, Object?> _newValues = {};

  $ManualValidationVanillaFormAccountPresenterFormPropertiesBuilder._(
      this._properties);

  /// Sets a new value of `id` property.
  void id(String value) => _newValues['id'] = value;

  /// Sets a new value of `name` property.
  void name(String value) => _newValues['name'] = value;

  /// Sets a new value of `gender` property.
  void gender(Gender value) => _newValues['gender'] = value;

  /// Sets a new value of `age` property.
  void age(int value) => _newValues['age'] = value;

  $ManualValidationVanillaFormAccountPresenterFormProperties build() =>
      _properties.copyWithProperties(_newValues);
}

/// Defines typed property accessors as extension properties for [ManualValidationVanillaFormAccountPresenter].
extension $ManualValidationVanillaFormAccountPresenterPropertyExtension
    on ManualValidationVanillaFormAccountPresenter {
  /// Gets a current [$ManualValidationVanillaFormAccountPresenterFormProperties] which holds properties' values
  /// and their [PropertyDescriptor]s.
  $ManualValidationVanillaFormAccountPresenterFormProperties get properties =>
      $ManualValidationVanillaFormAccountPresenterFormProperties(
          propertiesState);

  /// Resets [properties] (and underlying[CompanionPresenterMixin.propertiesState])
  /// with specified new [$ManualValidationVanillaFormAccountPresenterFormProperties].
  ///
  /// This method also calls [CompanionPresenterMixin.onPropertiesChanged] callback.
  ///
  /// This method returns passed [FormProperties] for convinience.
  ///
  /// This method is preferred over [CompanionPresenterMixin.resetPropertiesState]
  /// because takes and returns more specific [$ManualValidationVanillaFormAccountPresenterFormProperties] type.
  $ManualValidationVanillaFormAccountPresenterFormProperties resetProperties(
    $ManualValidationVanillaFormAccountPresenterFormProperties newProperties,
  ) {
    resetPropertiesState(newProperties);
    return newProperties;
  }
}

/// Defines [FormField] factory methods for properties of [ManualValidationVanillaFormAccountPresenter].
class $ManualValidationVanillaFormAccountPresenterFieldFactory {
  final $ManualValidationVanillaFormAccountPresenterFormProperties _properties;

  $ManualValidationVanillaFormAccountPresenterFieldFactory._(this._properties);

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
    TapRegionCallback? onTapOutside,
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
    EditableTextContextMenuBuilder? contextMenuBuilder =
        _default_TextFormField__defaultContextMenuBuilder,
  }) {
    final property = _properties.descriptors.id;
    return TextFormField(
      key: _properties.presenter.getKey(property.name, context),
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
      onTapOutside: onTapOutside,
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
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
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
    TapRegionCallback? onTapOutside,
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
    EditableTextContextMenuBuilder? contextMenuBuilder =
        _default_TextFormField__defaultContextMenuBuilder,
  }) {
    final property = _properties.descriptors.name;
    return TextFormField(
      key: _properties.presenter.getKey(property.name, context),
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
      onTapOutside: onTapOutside,
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
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
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
    final property = _properties.descriptors.gender;
    return DropdownButtonFormField<Gender>(
      key: _properties.presenter.getKey(property.name, context),
      items: [Gender.notKnown, Gender.male, Gender.female, Gender.notApplicable]
          .map((x) => DropdownMenuItem<Gender>(
              value: x, child: Text('gender.${x.name}'.tr())))
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
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
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
    TapRegionCallback? onTapOutside,
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
    EditableTextContextMenuBuilder? contextMenuBuilder =
        _default_TextFormField__defaultContextMenuBuilder,
  }) {
    final property = _properties.descriptors.age;
    return TextFormField(
      key: _properties.presenter.getKey(property.name, context),
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
      onTapOutside: onTapOutside,
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
      autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
      scrollController: scrollController,
      restorationId: restorationId,
      enableIMEPersonalizedLearning: enableIMEPersonalizedLearning,
      mouseCursor: mouseCursor,
      contextMenuBuilder: contextMenuBuilder,
    );
  }

  static Widget _default_TextFormField__defaultContextMenuBuilder(
      BuildContext context, EditableTextState editableTextState) {
    return AdaptiveTextSelectionToolbar.editableText(
        editableTextState: editableTextState);
  }
}

/// Defines an extension property to get [$ManualValidationVanillaFormAccountPresenterFieldFactory] from [ManualValidationVanillaFormAccountPresenter].
extension $ManualValidationVanillaFormAccountPresenterFormPropertiesFieldFactoryExtension
    on $ManualValidationVanillaFormAccountPresenterFormProperties {
  /// Gets a [FormField] factory.
  $ManualValidationVanillaFormAccountPresenterFieldFactory get fields =>
      $ManualValidationVanillaFormAccountPresenterFieldFactory._(this);
}
