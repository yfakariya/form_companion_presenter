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

import 'package:meta/meta.dart' show immutable, sealed;

import 'bulk_auto_validation_form_builder_account.dart';

import 'l10n/locale_keys.g.dart' show LocaleKeys;

import 'models.dart' show Gender, Region;

/// Defines typed property state accessors
/// for [BulkAutoValidationFormBuilderAccountPresenter].
@sealed
@immutable
class $BulkAutoValidationFormBuilderAccountPresenterFormProperties
    implements FormProperties {
  final FormProperties _underlying;

  /// Gets a [BulkAutoValidationFormBuilderAccountPresenter] instance which holds this properties state.
  BulkAutoValidationFormBuilderAccountPresenter get presenter =>
      _underlying.presenter as BulkAutoValidationFormBuilderAccountPresenter;

  /// Gets a typed [PropertyDescriptor] accessor [$BulkAutoValidationFormBuilderAccountPresenterPropertyDescriptors]
  /// for [BulkAutoValidationFormBuilderAccountPresenter].
  late final $BulkAutoValidationFormBuilderAccountPresenterPropertyDescriptors
      descriptors;

  /// Gets a typed property value accessor [$BulkAutoValidationFormBuilderAccountPresenterPropertyValues]
  /// for [BulkAutoValidationFormBuilderAccountPresenter].
  late final $BulkAutoValidationFormBuilderAccountPresenterPropertyValues
      values;

  /// Returns a [$BulkAutoValidationFormBuilderAccountPresenterFormProperties] which wraps [FormProperties].
  ///
  /// Note that this factory returns [underlying] if [underlying] is
  /// [$BulkAutoValidationFormBuilderAccountPresenterFormProperties] type.
  factory $BulkAutoValidationFormBuilderAccountPresenterFormProperties(
      FormProperties underlying) {
    if (underlying
        is $BulkAutoValidationFormBuilderAccountPresenterFormProperties) {
      return underlying;
    }

    if (underlying.presenter
        is! BulkAutoValidationFormBuilderAccountPresenter) {
      throw ArgumentError(
        'Specified FormProperties does not hold ${BulkAutoValidationFormBuilderAccountPresenter} type presenter.',
        'underlying',
      );
    }

    return $BulkAutoValidationFormBuilderAccountPresenterFormProperties
        ._(underlying);
  }

  $BulkAutoValidationFormBuilderAccountPresenterFormProperties._(
      this._underlying) {
    descriptors =
        $BulkAutoValidationFormBuilderAccountPresenterPropertyDescriptors
            ._(_underlying);
    values = $BulkAutoValidationFormBuilderAccountPresenterPropertyValues
        ._(_underlying);
  }

  @override
  bool canSubmit(BuildContext context) => _underlying.canSubmit(context);

  @override
  void Function()? submit(BuildContext context) => _underlying.submit(context);

  @override
  $BulkAutoValidationFormBuilderAccountPresenterFormProperties
      copyWithProperties(
    Map<String, Object?> newValues,
  ) {
    final newUnderlying = _underlying.copyWithProperties(newValues);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $BulkAutoValidationFormBuilderAccountPresenterFormProperties(
        newUnderlying);
  }

  @override
  $BulkAutoValidationFormBuilderAccountPresenterFormProperties copyWithProperty(
    String name,
    Object? newValue,
  ) {
    final newUnderlying = _underlying.copyWithProperty(name, newValue);
    if (identical(newUnderlying, _underlying)) {
      return this;
    }

    return $BulkAutoValidationFormBuilderAccountPresenterFormProperties(
        newUnderlying);
  }

  /// Copies this instance with specified new property values specified via
  /// returned [$BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder] object.
  ///
  /// You must call [$BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder.build]
  /// to finish copying.
  $BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder
      copyWith() =>
          $BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder
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
/// for [BulkAutoValidationFormBuilderAccountPresenterFormProperties].
@sealed
class $BulkAutoValidationFormBuilderAccountPresenterPropertyDescriptors {
  final FormProperties _properties;

  $BulkAutoValidationFormBuilderAccountPresenterPropertyDescriptors._(
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

  /// Gets a [PropertyDescriptor] of `preferredRegions` property.
  PropertyDescriptor<List<Region>, List<Region>> get preferredRegions =>
      _properties.getDescriptor('preferredRegions')
          as PropertyDescriptor<List<Region>, List<Region>>;
}

/// Defines typed property value accessors
/// for [BulkAutoValidationFormBuilderAccountPresenterFormProperties].
@sealed
class $BulkAutoValidationFormBuilderAccountPresenterPropertyValues {
  final FormProperties _properties;

  $BulkAutoValidationFormBuilderAccountPresenterPropertyValues._(
      this._properties);

  /// Gets a current value of `id` property.
  String get id => _properties.getValue('id') as String;

  /// Gets a current value of `name` property.
  String get name => _properties.getValue('name') as String;

  /// Gets a current value of `gender` property.
  Gender get gender => _properties.getValue('gender') as Gender;

  /// Gets a current value of `age` property.
  int get age => _properties.getValue('age') as int;

  /// Gets a current value of `preferredRegions` property.
  List<Region> get preferredRegions =>
      _properties.getValue('preferredRegions') as List<Region>;
}

/// Defines a builder to help [BulkAutoValidationFormBuilderAccountPresenterFormProperties.copyWith].
@sealed
class $BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder {
  final $BulkAutoValidationFormBuilderAccountPresenterFormProperties
      _properties;
  final Map<String, Object?> _newValues = {};

  $BulkAutoValidationFormBuilderAccountPresenterFormPropertiesBuilder._(
      this._properties);

  /// Sets a new value of `id` property.
  void id(String value) => _newValues['id'] = value;

  /// Sets a new value of `name` property.
  void name(String value) => _newValues['name'] = value;

  /// Sets a new value of `gender` property.
  void gender(Gender value) => _newValues['gender'] = value;

  /// Sets a new value of `age` property.
  void age(int value) => _newValues['age'] = value;

  /// Sets a new value of `preferredRegions` property.
  void preferredRegions(List<Region> value) =>
      _newValues['preferredRegions'] = value;

  $BulkAutoValidationFormBuilderAccountPresenterFormProperties build() =>
      _properties.copyWithProperties(_newValues);
}

/// Defines typed property accessors as extension properties for [BulkAutoValidationFormBuilderAccountPresenter].
extension $BulkAutoValidationFormBuilderAccountPresenterPropertyExtension
    on BulkAutoValidationFormBuilderAccountPresenter {
  /// Gets a current [$BulkAutoValidationFormBuilderAccountPresenterFormProperties] which holds properties' values
  /// and their [PropertyDescriptor]s.
  $BulkAutoValidationFormBuilderAccountPresenterFormProperties get properties =>
      $BulkAutoValidationFormBuilderAccountPresenterFormProperties(
          propertiesState);

  /// Resets [properties] (and underlying[CompanionPresenterMixin.propertiesState])
  /// with specified new [$BulkAutoValidationFormBuilderAccountPresenterFormProperties].
  ///
  /// This method also calls [CompanionPresenterMixin.onPropertiesChanged] callback.
  ///
  /// This method returns passed [FormProperties] for convinience.
  ///
  /// This method is preferred over [CompanionPresenterMixin.resetPropertiesState]
  /// because takes and returns more specific [$BulkAutoValidationFormBuilderAccountPresenterFormProperties] type.
  $BulkAutoValidationFormBuilderAccountPresenterFormProperties resetProperties(
    $BulkAutoValidationFormBuilderAccountPresenterFormProperties newProperties,
  ) {
    resetPropertiesState(newProperties);
    return newProperties;
  }
}

/// Defines [FormField] factory methods for properties of [BulkAutoValidationFormBuilderAccountPresenter].
class $BulkAutoValidationFormBuilderAccountPresenterFieldFactory {
  final $BulkAutoValidationFormBuilderAccountPresenterFormProperties
      _properties;

  $BulkAutoValidationFormBuilderAccountPresenterFieldFactory._(
      this._properties);

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
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _properties.descriptors.id;
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
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _properties.descriptors.name;
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
    TextStyle? style,
    Widget? disabledHint,
    Widget? icon,
    Color? iconDisabledColor,
    Color? iconEnabledColor,
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
    final property = _properties.descriptors.gender;
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
      style: style,
      disabledHint: disabledHint,
      icon: icon,
      iconDisabledColor: iconDisabledColor,
      iconEnabledColor: iconEnabledColor,
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
    ToolbarOptions? toolbarOptions,
    ui.BoxHeightStyle selectionHeightStyle = ui.BoxHeightStyle.tight,
    Iterable<String>? autofillHints,
    String obscuringCharacter = '•',
    MouseCursor? mouseCursor,
  }) {
    final property = _properties.descriptors.age;
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
    final property = _properties.descriptors.preferredRegions;
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
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
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

/// Defines an extension property to get [$BulkAutoValidationFormBuilderAccountPresenterFieldFactory] from [BulkAutoValidationFormBuilderAccountPresenter].
extension $BulkAutoValidationFormBuilderAccountPresenterFormPropertiesFieldFactoryExtension
    on $BulkAutoValidationFormBuilderAccountPresenterFormProperties {
  /// Gets a [FormField] factory.
  $BulkAutoValidationFormBuilderAccountPresenterFieldFactory get fields =>
      $BulkAutoValidationFormBuilderAccountPresenterFieldFactory._(this);
}
