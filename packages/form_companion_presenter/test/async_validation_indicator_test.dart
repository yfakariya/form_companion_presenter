// See LICENCE file in the root.

@Timeout(Duration(seconds: 3))

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/async_validation_indicator.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';
import 'package:form_companion_presenter/src/presenter_extension.dart';

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
    )));

class Presenter with CompanionPresenterMixin, FormCompanionMixin {
  final FutureOr<void> Function() _doSubmitCalled;

  Presenter(
      {required PropertyDescriptorsBuilder properties,
      FutureOr<void> Function()? doSubmitCalled})
      : _doSubmitCalled = (doSubmitCalled ?? () {}) {
    initializeCompanionMixin(properties);
  }

  @override
  FutureOr<void> doSubmit() => _doSubmitCalled();
}

class DummyBuildContext extends BuildContext {
  DummyBuildContext();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(InheritedElement ancestor,
      {Object? aspect}) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>(
      {Object? aspect}) {
    // Required for getLocale() test.
    return null;
  }

  @override
  DiagnosticsNode describeElement(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor(
      {required Type expectedAncestorType}) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(String name,
      {DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty}) {
    throw UnimplementedError();
  }

  @override
  T? findAncestorRenderObjectOfType<T extends RenderObject>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  T? findAncestorWidgetOfExactType<T extends Widget>() {
    throw UnimplementedError();
  }

  @override
  RenderObject? findRenderObject() {
    throw UnimplementedError();
  }

  @override
  T? findRootAncestorStateOfType<T extends State<StatefulWidget>>() {
    throw UnimplementedError();
  }

  @override
  InheritedElement?
      getElementForInheritedWidgetOfExactType<T extends InheritedWidget>() {
    throw UnimplementedError();
  }

  @override
  BuildOwner? get owner => throw UnimplementedError();

  @override
  Size? get size => throw UnimplementedError();

  @override
  void visitAncestorElements(bool Function(Element element) visitor) {
    throw UnimplementedError();
  }

  @override
  void visitChildElements(ElementVisitor visitor) {
    throw UnimplementedError();
  }

  @override
  Widget get widget => throw UnimplementedError();

  @override
  void dispatchNotification(Notification notification) {
    throw UnimplementedError();
  }
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
      presenter.getPropertyValidator<String>('prop', lastContext!)(null);
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
      presenter.getPropertyValidator<String>('prop', lastContext!)(null);
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
      presenter.getPropertyValidator<String>('prop', lastContext!)(null);
      await tester.pump();

      expect(find.text(text), findsOneWidget);
    });
  });
}
