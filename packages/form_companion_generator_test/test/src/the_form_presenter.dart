// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_companion_generator_test_targets/enum.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormPresenter with CompanionPresenterMixin, FormCompanionMixin {
  TheFormPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(name: 'propString')
        ..enumerated<MyEnum>(name: 'propEnum')
        ..addWithField<List<String>, List<String>,
            DropdownButtonFormField<List<String>>>(
          name: 'propStringList',
        )
        ..integerText(
          name: 'propInt',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
