// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_companion_generator_test_targets/properties.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormPresenter with CompanionPresenterMixin, FormCompanionMixin {
  TheFormPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<String>(name: 'propString')
        ..add<MyEnum>(name: 'propEnum')
        ..addWithField<List<String>, DropdownButtonFormField<List<String>>>(
          name: 'propStringList',
        )
      // TODO(yfakariya): converter test
      // ..add<int>(
      //   name: 'propInt',
      // )
      ,
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
