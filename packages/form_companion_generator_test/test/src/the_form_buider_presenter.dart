// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_generator_test_targets/properties.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormBuilderPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  TheFormBuilderPresenter() {
    initializeCompanionMixin(
      // TODO(yfakariya): preferredFieldType
      PropertyDescriptorsBuilder()
        ..add<String>(name: 'propString')
        ..add<MyEnum>(name: 'propEnum')
        ..add<bool>(name: 'propBool')
        ..add<DateTime>(name: 'propDateTime')
        ..add<DateTimeRange>(name: 'propDateTimeRange')
        ..add<RangeValues>(name: 'propRangeValues')
        ..add<List<MyEnum>>(name: 'propEnumList')
        ..add<List<bool>>(name: 'propBoolList'),
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
