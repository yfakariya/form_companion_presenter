// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'package:flutter/material.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'enum.dart';

void builtin() {
  PropertyDescriptorsBuilder()
    ..add<int, String>(
      name: 'add',
      initialValue: 123,
      valueConverter: intStringConverter,
    )
    ..add(
      name: 'withInferred',
      initialValue: 123,
      valueConverter: intStringConverter,
    )
    ..addWithField<int, String, DropdownButtonFormField<String>>(
      name: 'addWithField',
      valueConverter: intStringConverter,
    )
    ..boolean(name: 'boolean')
    ..stringConvertible(
      name: 'stringConvertible',
      stringConverter: doubleStringConverter,
    )
    ..enumerated(
      name: 'enumerated',
      initialValue: MyEnum.one,
      enumValues: MyEnum.values,
    );
}

void id() {
  PropertyDescriptorsBuilder()..id();
}

void withTextField() {
  PropertyDescriptorsBuilder()
    ..withTextField(name: 'withTextField', valueConverter: intStringConverter);
}

void withBlockBody() {
  PropertyDescriptorsBuilder()..withBlockBody(name: 'withBlockBody');
}

void withNoChainExpression() {
  PropertyDescriptorsBuilder()
    ..withNoChainExpression(name: 'withNoChainExpression');
}

void withNever() {
  PropertyDescriptorsBuilder()..withNever(name: 'withNever');
}

void withNeverList() {
  PropertyDescriptorsBuilder()..withNeverList(name: 'withNeverList');
}

extension _CustomExtensions on PropertyDescriptorsBuilder {
  void withTextField<P extends Object>({
    required String name,
    P? initialValue,
    required ValueConverter<P, String> valueConverter,
  }) =>
      addWithField<P, String, TextFormField>(
        name: name,
        initialValue: initialValue,
        valueConverter: valueConverter,
      );

  // via non generic method
  void id() => string(name: 'id');

  void withBlockBody<P extends Object, F extends Object>({
    required String name,
  }) {
    add<P, F>(name: name);
  }

  void withNoChainExpression<P extends Object, F extends Object>({
    required String name,
  }) =>
      throw UnimplementedError('intentionally');

  void withNever({required String name}) => add<Never, Never>(name: name);

  void withNeverList({required String name}) =>
      add<List<Never>, List<Never>>(name: name);
}
