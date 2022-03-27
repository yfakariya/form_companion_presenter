// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'dart:collection' as col;
import 'dart:ui' as ui;
import 'dart:ui' show Color, VoidCallback;

import 'package:flutter/material.dart';

typedef NonGenericCallback = int Function(String);
typedef GenericCallback<T> = void Function<T>(T);

class SimpleClass {}

// dummy 'FormField'
abstract class FormField<T> {}

// dummy 'FormBuilderField'
abstract class FormBuilderField<T> extends FormField<T> {}

class ParameterHolder<T> extends FormField<T> {
  final String? nonPrefixed;
  final ui.BoxWidthStyle? prefixed;
  final List<T>? nonPrefixedGeneric;
  final List<int>? instantiatedGeneric;
  final col.Queue<T>? prefixedGeneric;

  ParameterHolder.simple(
    String nonPrefixed,
    ui.BoxWidthStyle prefixed,
    List<T> nonPrefixedGeneric,
    List<int> instantiatedGeneric,
    col.Queue<T> prefixedGeneric,
  )   : this.nonPrefixed = nonPrefixed,
        this.prefixed = prefixed,
        this.nonPrefixedGeneric = nonPrefixedGeneric,
        this.instantiatedGeneric = instantiatedGeneric,
        this.prefixedGeneric = prefixedGeneric;

  ParameterHolder.nullable(
    String? nonPrefixed,
    ui.BoxWidthStyle? prefixed,
    List<T>? nonPrefixedGeneric,
    List<int>? instantiatedGeneric,
    col.Queue<T>? prefixedGeneric,
  )   : this.nonPrefixed = nonPrefixed,
        this.prefixed = prefixed,
        this.nonPrefixedGeneric = nonPrefixedGeneric,
        this.instantiatedGeneric = instantiatedGeneric,
        this.prefixedGeneric = prefixedGeneric;

  ParameterHolder.field(
    this.nonPrefixed,
    this.prefixed,
    this.nonPrefixedGeneric,
    this.instantiatedGeneric,
    this.prefixedGeneric,
  );

  ParameterHolder.named({
    this.nonPrefixed,
    this.prefixed,
    this.nonPrefixedGeneric,
    this.instantiatedGeneric,
    this.prefixedGeneric,
  });

  ParameterHolder.hasDefault([
    String? nonPrefixed = 'default',
    ui.BoxWidthStyle? prefixed = ui.BoxWidthStyle.max,
    List<T>? nonPrefixedGeneric = const [],
    List<int>? instantiatedGeneric = const [],
    col.Queue<T>? prefixedGeneric = null,
  ])  : this.nonPrefixed = nonPrefixed,
        this.prefixed = prefixed,
        this.nonPrefixedGeneric = nonPrefixedGeneric,
        this.instantiatedGeneric = instantiatedGeneric,
        this.prefixedGeneric = prefixedGeneric;

  ParameterHolder.namedHasDefault({
    this.nonPrefixed = 'default',
    this.prefixed = ui.BoxWidthStyle.max,
    this.nonPrefixedGeneric = const [],
    this.instantiatedGeneric = const [],
    this.prefixedGeneric = null,
  });

  void simpleFunction(
    NonGenericCallback alias,
    GenericCallback<T> genericAlias,
    GenericCallback<int> instantiatedAlias,
    ui.VoidCallback prefixedAlias,
    int Function(String) function,
    T Function(T) genericFunction,
    S Function<S>(S) parameterizedFunction,
    List<int> Function(Map<String, int>) instantiatedFunction,
    ui.BoxWidthStyle Function(ui.BoxHeightStyle) prefixedFunction,
    int namedFunction(String p),
    T genericNamedFunction(T p),
    S parameterizedNamedFunction<S>(S p),
    List<int> instantiatedNamedFunction(Map<String, int> p),
    ui.BoxWidthStyle prefixedNamedFunction(ui.BoxHeightStyle p),
  ) {}

  void nullableFunction(
    NonGenericCallback? alias,
    GenericCallback<T>? genericAlias,
    GenericCallback<int>? instantiatedAlias,
    ui.VoidCallback? prefixedAlias,
    int? Function(String?)? function,
    T? Function(T?)? genericFunction,
    S? Function<S>(S?)? parameterizedFunction,
    List<int>? Function(Map<String?, int?>?)? instantiatedFunction,
    ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)? prefixedFunction,
    int? namedFunction(String? p)?,
    T? genericNamedFunction(T? p)?,
    S? parameterizedNamedFunction<S>(S? p)?,
    List<int>? instantiatedNamedFunction(Map<String, int>? p)?,
    ui.BoxWidthStyle? prefixedNamedFunction(ui.BoxHeightStyle? p)?,
  ) {}

  void hasDefaultFunction({
    NonGenericCallback? alias = null,
    GenericCallback<T>? genericAlias = null,
    GenericCallback<int>? instantiatedAlias = null,
    ui.VoidCallback? prefixedAlias = null,
    int? Function(String?)? function = null,
    T? Function(T?)? genericFunction = null,
    S? Function<S>(S?)? parameterizedFunction = null,
    List<int>? Function(Map<String?, int?>?)? instantiatedFunction = null,
    ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)? prefixedFunction = null,
    int? namedFunction(String? p)? = null,
    T? genericNamedFunction(T? p)? = null,
    S? parameterizedNamedFunction<S>(S? p)? = null,
    List<int>? instantiatedNamedFunction(Map<String, int>? p)? = null,
    ui.BoxWidthStyle? prefixedNamedFunction(ui.BoxHeightStyle? p)? = null,
  }) {}

  void complexFunction({
    void Function({required String required, int optional})? hasNamed,
    void Function([int p])? hasDefault,
    void Function(String Function(int Function() f1) f2)? nestedFunction,
    void namedNestedFunction(String Function(int Function() f1) f2)?,
    final void Function()? withKeyword,
  }) {}
}

class ParameterListHolder<T> extends FormBuilderField<List<T>> {
  final List<T>? nonPrefixed;
  final col.Queue<List<T>>? prefixed;

  ParameterListHolder.simple(
    List<T> nonPrefixed,
    col.Queue<List<T>> prefixed,
  )   : this.nonPrefixed = nonPrefixed,
        this.prefixed = prefixed;

  void function(
    GenericCallback<List<T>> alias,
    List<T> Function(List<T>) function,
    List<S> Function<S>(List<S>) parameterizedFunction,
    List<T> namedFunction(List<T> p),
    List<S> parameterizedNamedFunction<S>(List<S> p),
  ) {}
}

class DependencyHolder<T> extends FormField<T> {
  Color? normalImported;
  String? normalDartCore;
  SimpleClass? normalSelf;
  VoidCallback? aliasImported;
  GenericCallback<String>? aliasSelf;
  ui.VoidCallback? prefixedImported;
  ui.VoidCallback Function(Color)? functionHasImported;
  String Function(int)? functionDartCore;
  SimpleClass Function(SimpleClass)? functionHasSelf;

  DependencyHolder.normal({
    this.normalImported,
    this.normalDartCore,
    this.normalSelf,
  });
  DependencyHolder.alias({
    this.aliasImported,
    this.aliasSelf,
  });

  DependencyHolder.prefixed({
    this.prefixedImported,
  });

  DependencyHolder.function({
    this.functionHasImported,
    this.functionDartCore,
    this.functionHasSelf,
  });
}
