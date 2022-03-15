// See LICENCE file in the root.

import 'dart:async';

import 'package:form_companion_generator_test_targets/properties.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

@formCompanion
class TheFormPresenter with CompanionPresenterMixin, FormCompanionMixin {
  TheFormPresenter() {
    initializeCompanionMixin(
      // TODO(yfakariya): preferredFieldType
      PropertyDescriptorsBuilder()
        ..add<String>(name: 'propString')
        ..add<MyEnum>(name: 'propEnum'),
    );
  }

  @override
  FutureOr<void> doSubmit() {
    // do nothing
  }
}
