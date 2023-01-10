// See LICENCE file in the root.

// This is simple examples.
// See {auto|bulk_auto|manual}_validation_{form_builder|vanilla}... files for
// full examples. They are organized with Form autoValidationMode and usage of
// flutter_form_builder.
// They also use riverpod for state and dependency management.

import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'l10n/locale_keys.g.dart';
import 'routes.dart';
import 'screen.dart';
import 'validators.dart';

class SimpleAccountPage extends Screen {
  /// Constructor.
  const SimpleAccountPage({Key? key}) : super(key: key);

  @override
  String get title => LocaleKeys.simple_title.tr();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) =>
      // You can use FormBuilder if you prefer flutter_form_builder.
      Form(
        autovalidateMode: AutovalidateMode.disabled,
        child: _SimpleAccountPane(),
      );
}

class _SimpleAccountPane extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final idProperty = _simpleAccountPresenter.propertiesState
        .getDescriptor<String, String>('id');
    final nameProperty = _simpleAccountPresenter.propertiesState
        .getDescriptor<String, String>('name');
    final locale =
        Localizations.maybeLocaleOf(context) ?? const Locale('en-US');

    return AnimatedBuilder(
      animation: _simpleAccountPresenter,
      builder: (context, _) => SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              key: _simpleAccountPresenter.getKey('id', context),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'ID',
                hintText: 'Input your email for ID',
              ),
              validator: idProperty.getValidator(context),
              initialValue: idProperty.getFieldValue(locale),
              onSaved: (v) => idProperty.setFieldValue(v, locale),
            ),
            TextFormField(
              key: _simpleAccountPresenter.getKey('name', context),
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Input your name',
              ),
              validator: nameProperty.getValidator(context),
              initialValue: nameProperty.getFieldValue(locale),
              onSaved: (v) => nameProperty.setFieldValue(v, locale),
            ),
            ElevatedButton(
              onPressed: _simpleAccountPresenter.submit(context),
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

final _simpleAccountPresenter = SimpleAccountPresenter();

/// Presenter which holds form properties.
class SimpleAccountPresenter
    // You can use StateNotifier<FormProperties> instead.
    extends ChangeNotifier
    with
        CompanionPresenterMixin,
        // You can use FormBuilderCompanionMixin if you prefer flutter_form_builder.
        FormCompanionMixin {
  // You want to restore or get initial value and take it as constructor parameter.
  // If you use StateNotifier, pass it to super().
  SimpleAccountPresenter() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..string(
          name: 'id',
          validatorFactories: [
            // If you prefer flutter_form_builder, use lamda expression like
            // `(_) => FormBuilderValidators.required()` here.
            Validator.required,
            Validator.email,
          ],
        )
        ..string(
          name: 'name',
          validatorFactories: [
            Validator.required,
          ],
        ),
    );
  }

  @override
  void onPropertiesChanged(OnPropertiesChangedEvent event) {
    // If you use StateNofier<T>,
    // replace next line with `state = event.newProperties;`.
    notifyListeners();
  }

  @override
  FutureOr<void> doSubmit() {
    // You want to store input value in server or global state here...

    router.go('/');
  }
}
