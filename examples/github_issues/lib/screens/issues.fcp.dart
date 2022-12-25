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
        DropdownButtonBuilder,
        DropdownMenuItem,
        EntryModeChangeCallback,
        Icons,
        InputCounterWidgetBuilder,
        InputDecoration,
        SelectableDayPredicate,
        TimeOfDay,
        TimePickerEntryMode;

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
        FormBuilderDateTimePicker,
        FormBuilderDropdown,
        FormBuilderTextField,
        InputType,
        ValueTransformer;

import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'package:intl/intl.dart' show DateFormat;

import '../l10n/locale_keys.g.dart' show LocaleKeys;

import '../models/issues.dart' show IssueListSortKey, IssueState, ListDirection;

import 'issues.dart';

/// Defines typed property accessors as extension properties for [IssuesPresenter].
extension $IssuesPresenterPropertyExtension on IssuesPresenter {
  /// Gets a [PropertyDescriptor] of `repository` property.
  PropertyDescriptor<String, String> get repository =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['repository']! as PropertyDescriptor<String, String>;

  /// Gets a [PropertyDescriptor] of `sortKey` property.
  PropertyDescriptor<IssueListSortKey, IssueListSortKey> get sortKey =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['sortKey']!
          as PropertyDescriptor<IssueListSortKey, IssueListSortKey>;

  /// Gets a [PropertyDescriptor] of `issueState` property.
  PropertyDescriptor<IssueState, IssueState> get issueState =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['issueState']! as PropertyDescriptor<IssueState, IssueState>;

  /// Gets a [PropertyDescriptor] of `direction` property.
  PropertyDescriptor<ListDirection, ListDirection> get direction =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['direction']!
          as PropertyDescriptor<ListDirection, ListDirection>;

  /// Gets a [PropertyDescriptor] of `since` property.
  PropertyDescriptor<DateTime, DateTime> get since =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['since']! as PropertyDescriptor<DateTime, DateTime>;

  /// Gets a [PropertyDescriptor] of `issuesPerPages` property.
  PropertyDescriptor<int, String> get issuesPerPages =>
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      properties['issuesPerPages']! as PropertyDescriptor<int, String>;
}

/// Defines [FormField] factory methods for properties of [IssuesPresenter].
class $IssuesPresenterFieldFactory {
  final IssuesPresenter _presenter;

  $IssuesPresenterFieldFactory._(this._presenter);

  /// Gets a [FormField] for `repository` property.
  FormBuilderTextField repository(
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
    final property = _presenter.repository;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_repository_label.tr(),
              hintText: LocaleKeys.formFields_repository_hint.tr()),
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

  /// Gets a [FormField] for `sortKey` property.
  FormBuilderDropdown<IssueListSortKey> sortKey(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<IssueListSortKey?>? onChanged,
    ValueTransformer<IssueListSortKey?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<DropdownMenuItem<IssueListSortKey>>? items,
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
    final property = _presenter.sortKey;
    return FormBuilderDropdown<IssueListSortKey>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_sortKey_label.tr(),
              hintText: LocaleKeys.formFields_sortKey_hint.tr()),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      items: [
        IssueListSortKey.created,
        IssueListSortKey.updated,
        IssueListSortKey.comments
      ]
          .map((x) => DropdownMenuItem<IssueListSortKey>(
              value: x, child: Text('formFields.sortKey.${x.name}'.tr())))
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

  /// Gets a [FormField] for `issueState` property.
  FormBuilderDropdown<IssueState> issueState(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<IssueState?>? onChanged,
    ValueTransformer<IssueState?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<DropdownMenuItem<IssueState>>? items,
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
    final property = _presenter.issueState;
    return FormBuilderDropdown<IssueState>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_issueState_label.tr(),
              hintText: LocaleKeys.formFields_issueState_hint.tr()),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      items: [IssueState.open, IssueState.closed, IssueState.all]
          .map((x) => DropdownMenuItem<IssueState>(
              value: x, child: Text('formFields.issueState.${x.name}'.tr())))
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

  /// Gets a [FormField] for `direction` property.
  FormBuilderDropdown<ListDirection> direction(
    BuildContext context, {
    Key? key,
    InputDecoration? decoration,
    ValueChanged<ListDirection?>? onChanged,
    ValueTransformer<ListDirection?>? valueTransformer,
    bool enabled = true,
    AutovalidateMode? autovalidateMode,
    VoidCallback? onReset,
    FocusNode? focusNode,
    List<DropdownMenuItem<ListDirection>>? items,
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
    final property = _presenter.direction;
    return FormBuilderDropdown<ListDirection>(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_direction_label.tr(),
              hintText: LocaleKeys.formFields_direction_hint.tr()),
      onChanged: onChanged ?? (_) {},
      valueTransformer: valueTransformer,
      enabled: enabled,
      autovalidateMode: autovalidateMode ?? AutovalidateMode.onUserInteraction,
      onReset: onReset,
      focusNode: focusNode,
      items: [ListDirection.asc, ListDirection.desc]
          .map((x) => DropdownMenuItem<ListDirection>(
              value: x, child: Text('formFields.direction.${x.name}'.tr())))
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

  /// Gets a [FormField] for `since` property.
  FormBuilderDateTimePicker since(
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
    final property = _presenter.since;
    return FormBuilderDateTimePicker(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_since_label.tr(),
              hintText: LocaleKeys.formFields_since_hint.tr()),
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

  /// Gets a [FormField] for `issuesPerPages` property.
  FormBuilderTextField issuesPerPages(
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
    final property = _presenter.issuesPerPages;
    return FormBuilderTextField(
      key: key,
      name: property.name,
      validator: property.getValidator(context),
      initialValue: property.getFieldValue(
          Localizations.maybeLocaleOf(context) ?? const Locale('en', 'US')),
      readOnly: readOnly,
      decoration: decoration ??
          const InputDecoration().copyWith(
              labelText: LocaleKeys.formFields_issuesPerPages_label.tr(),
              hintText: LocaleKeys.formFields_issuesPerPages_hint.tr()),
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
}

/// Defines an extension property to get [$IssuesPresenterFieldFactory] from [IssuesPresenter].
extension $IssuesPresenterFieldFactoryExtension on IssuesPresenter {
  /// Gets a [FormField] factory.
  $IssuesPresenterFieldFactory get fields =>
      $IssuesPresenterFieldFactory._(this);
}
