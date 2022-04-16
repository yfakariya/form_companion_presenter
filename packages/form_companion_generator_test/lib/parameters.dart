// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'dart:collection' as col;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

typedef NonGenericCallback = int Function(String);
typedef GenericCallback<T> = void Function<T>(T);

typedef AString = String;
typedef AList<E> = List<E>;

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
    GenericCallback<int?>? instantiatedAlias,
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

  void simpleInterface(
    AString alias,
    AList<T> genericAlias,
    AList<int> instantiatedAlias,
    String interface,
    List<T> genericInterface,
    List<int> instantiatedInterface,
  ) {}

  void nullableInterface(
    AString? alias,
    AList<T>? genericAlias,
    AList<int?>? instantiatedAlias,
    String? interface,
    List<T?>? genericInterface,
    List<int?>? instantiatedInterface,
  ) {}
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

typedef ParameterFunction<T> = int Function(T, T);

class ParameterFunctionHolder<T>
    extends FormBuilderField<int Function<T>(T, T)> {
  final int Function<T>(T, T)? nonAlias;
  final ParameterFunction<T> alias;

  ParameterFunctionHolder.simple(
    int Function<T>(T, T) nonAlias,
    ParameterFunction<T> alias,
  )   : this.nonAlias = nonAlias,
        this.alias = alias;
}

typedef MultiGenericFunction<T, R> = R Function<T, R>(T);
typedef InstantiatedMultiGenericFunction = MultiGenericFunction<int, String>;
typedef StringIntMap = Map<String, int>;
typedef AMap<K, V> = Map<K, V>;

class ComplexGenericTypeHolder<T1, T2> {
  void function(
    MultiGenericFunction<int, String> multiParameterAliasFunction,
    StringIntMap instantiatedMultiGenericType,
    AMap<String, int> multiParameterGenericType,
    InstantiatedMultiGenericFunction instantiatedMultiGenericFunction,
    T1 Function<S>(S) mixedParameterGenericFunction,
    R Function<S, R>(S) multiParameterGenericFunction,
    T2 Function(T1) multiContextParameterGenericFunction,
  ) {}
}

class DependencyHolder<T> extends FormField<T> {
  Color? normalImported;
  String? normalDartCore;
  SimpleClass? normalSelf;
  VoidCallback? aliasImported;
  GenericCallback<String>? aliasSelf;
  ui.VoidCallback? prefixedImported;
  ui.Clip? prefixedImportedEnum;
  ui.VoidCallback Function(Color)? functionHasImported;
  String Function(int)? functionDartCore;
  SimpleClass Function(SimpleClass)? functionHasSelf;
  var untypedDartCore = 0;
  var untypedImported = Clip.antiAlias;

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
    this.prefixedImportedEnum = ui.Clip.antiAlias,
  });

  DependencyHolder.function({
    this.functionHasImported,
    this.functionDartCore,
    this.functionHasSelf,
  });

  DependencyHolder.untyped({
    required this.untypedDartCore,
    required this.untypedImported,
  });
}

class OnlyAnonymousFactory extends FormField<String> {
  OnlyAnonymousFactory._();

  factory OnlyAnonymousFactory({
    InputDecoration? inputDecoration,
    String? factoryParameter,
  }) =>
      OnlyAnonymousFactory._();
}

class OnlyNamedConstructor extends FormField<String> {
  OnlyNamedConstructor._();

  OnlyNamedConstructor.generative({
    InputDecoration? inputDecoration,
    String? namedConstructorParameter,
  }) {}
}

class OnlyNamedFactory extends FormField<String> {
  OnlyNamedFactory._();

  factory OnlyNamedFactory.factory({
    InputDecoration? inputDecoration,
    String? namedFactoryParameter,
  }) =>
      OnlyNamedFactory._();
}

class ConstructorWithNamedConstructors extends FormField<String> {
  ConstructorWithNamedConstructors({
    InputDecoration? inputDecoration,
    String? constructorParameter,
  });

  ConstructorWithNamedConstructors.generative({
    InputDecoration? inputDecoration,
    String? namedConstructorParameter,
  }) {}

  factory ConstructorWithNamedConstructors.factory({
    InputDecoration? inputDecoration,
    String? namedFactoryParameter,
  }) =>
      ConstructorWithNamedConstructors();
}

class FactoryWithNamedConstructors extends FormField<String> {
  FactoryWithNamedConstructors._();

  factory FactoryWithNamedConstructors({
    InputDecoration? inputDecoration,
    String? factoryParameter,
  }) =>
      FactoryWithNamedConstructors._();

  FactoryWithNamedConstructors.generative({
    InputDecoration? inputDecoration,
    String? namedConstructorParameter,
  }) {}

  factory FactoryWithNamedConstructors.factory({
    InputDecoration? inputDecoration,
    String? namedFactoryParameter,
  }) =>
      FactoryWithNamedConstructors._();
}

class ConstructorWithMultipleNamedConstructors extends FormField<String> {
  ConstructorWithMultipleNamedConstructors({
    InputDecoration? inputDecoration,
    String? constructorParameter,
  });

  ConstructorWithMultipleNamedConstructors.generative1({
    InputDecoration? inputDecoration,
    String? namedConstructorParameter1,
  }) {}

  ConstructorWithMultipleNamedConstructors.generative2({
    InputDecoration? inputDecoration,
    String? namedConstructorParameter2,
  }) {}

  factory ConstructorWithMultipleNamedConstructors.factory1({
    InputDecoration? inputDecoration,
    String? namedFactoryParameter1,
  }) =>
      ConstructorWithMultipleNamedConstructors();

  factory ConstructorWithMultipleNamedConstructors.factory2({
    InputDecoration? inputDecoration,
    String? namedFactoryParameter2,
  }) =>
      ConstructorWithMultipleNamedConstructors();
}
