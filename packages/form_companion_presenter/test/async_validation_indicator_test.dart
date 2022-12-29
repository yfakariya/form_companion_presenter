// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/async_validation_indicator.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';

class FormHost extends StatelessWidget {
  final Widget _child;
  final void Function(BuildContext) _onBuilding;
  const FormHost(
    this._child,
    this._onBuilding, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Form(
        child: WidgetHost(_child, _onBuilding),
      );
}

class WidgetHost extends StatelessWidget {
  final Widget _child;
  final void Function(BuildContext) _onBuilding;
  const WidgetHost(
    this._child,
    this._onBuilding, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _onBuilding(context);
    return _child;
  }
}

Widget _app(
  Widget child,
  void Function(BuildContext) onBuilding,
) =>
    MaterialApp(
      home: Scaffold(
        body: FormHost(
          child,
          onBuilding,
        ),
      ),
    );

class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  final FutureOr<void> Function() _doSubmitCalled;
  final void Function(OnPropertiesChangedEvent) _onPropertiesChangedCalled;

  Presenter({
    required PropertyDescriptorsBuilder properties,
    FutureOr<void> Function()? doSubmitCalled,
    void Function(OnPropertiesChangedEvent)? onPropertiesChangedCalled,
  })  : _doSubmitCalled = (doSubmitCalled ?? () {}),
        _onPropertiesChangedCalled = (onPropertiesChangedCalled ?? (_) {}) {
    initializeCompanionMixin(properties);
  }

  @override
  void onPropertiesChanged(OnPropertiesChangedEvent event) =>
      _onPropertiesChangedCalled(event);

  @override
  FutureOr<void> doSubmit() => _doSubmitCalled();
}

void main() {
  group('behavior', () {
    testWidgets(
        'indicator is shown when and only when an async validation is in progress.',
        (tester) async {
      final validationStarter = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    await validationStarter.future;
                    return null;
                  }
            ],
          ),
      );
      BuildContext? lastContext;

      await tester.pumpWidget(
        _app(
            AsyncValidationIndicator(
              presenter: presenter,
              propertyName: 'prop',
            ), (context) {
          lastContext = context;
        }),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      presenter.propertiesState
          .getFieldValidator<String>('prop', lastContext!)(null);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      validationStarter.complete();
      await tester.pump();
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('constructor', () {
    test('default values.', () {
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
          ),
      );

      final target = AsyncValidationIndicator(
        presenter: presenter,
        propertyName: 'prop',
      );

      expect(target.key, isNull);
      expect(target.text, isNull);
    });

    test('keys is used.', () {
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
          ),
      );

      final key = GlobalKey();
      final target = AsyncValidationIndicator(
        key: key,
        presenter: presenter,
        propertyName: 'prop',
      );

      expect(target.key, same(key));
    });

    testWidgets('default text is used.', (tester) async {
      const defaultText = 'Validating...';

      final validationStarter = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    await validationStarter.future;
                    return null;
                  }
            ],
          ),
      );
      BuildContext? lastContext;
      await tester.pumpWidget(
        _app(
          AsyncValidationIndicator(
            presenter: presenter,
            propertyName: 'prop',
          ),
          (context) {
            lastContext = context;
          },
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      presenter.propertiesState
          .getFieldValidator<String>('prop', lastContext!)(null);
      await tester.pump();

      expect(find.text(defaultText), findsOneWidget);
    });

    testWidgets('specified text is used.', (tester) async {
      const text = 'Can we take rest today?';

      final validationStarter = Completer<void>();
      final presenter = Presenter(
        properties: PropertyDescriptorsBuilder()
          ..add<String, String>(
            name: 'prop',
            asyncValidatorFactories: [
              (context) => (value, options) async {
                    await validationStarter.future;
                    return null;
                  }
            ],
          ),
      );
      BuildContext? lastContext;
      await tester.pumpWidget(
        _app(
          AsyncValidationIndicator(
            presenter: presenter,
            propertyName: 'prop',
            text: text,
          ),
          (context) {
            lastContext = context;
          },
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      presenter.propertiesState
          .getFieldValidator<String>('prop', lastContext!)(null);
      await tester.pump();

      expect(find.text(text), findsOneWidget);
    });
  });
}
