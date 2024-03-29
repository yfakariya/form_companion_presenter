// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
/* #PRE_IMPORT# */
import 'package:form_companion_generator_test_targets/enum.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';
/* #POST_IMPORT# */

/* #PART# */

@formCompanion
class TheFormPresenter with CompanionPresenterMixin, FormCompanionMixin {
  TheFormPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(name: 'propString')
        ..enumerated(
          name: 'propEnum',
          enumValues: MyEnum.values,
        )
        ..addWithField<String, String, DropdownButtonFormField<String>>(
          name: 'propString2',
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
