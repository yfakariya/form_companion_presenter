// See LICENCE file in the root.

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:form_companion_presenter/src/form_companion_mixin.dart';
import 'package:form_companion_presenter/src/internal_utils.dart';

class DummyBuildContext extends BuildContext {
  DummyBuildContext();

  @override
  bool get debugDoingBuild => throw UnimplementedError();

  @override
  InheritedWidget dependOnInheritedElement(
    InheritedElement ancestor, {
    Object? aspect,
  }) {
    throw UnimplementedError();
  }

  @override
  T? dependOnInheritedWidgetOfExactType<T extends InheritedWidget>({
    Object? aspect,
  }) {
    // Required for getLocale() test.
    return null;
  }

  @override
  DiagnosticsNode describeElement(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
    throw UnimplementedError();
  }

  @override
  List<DiagnosticsNode> describeMissingAncestor({
    required Type expectedAncestorType,
  }) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeOwnershipChain(String name) {
    throw UnimplementedError();
  }

  @override
  DiagnosticsNode describeWidget(
    String name, {
    DiagnosticsTreeStyle style = DiagnosticsTreeStyle.errorProperty,
  }) {
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

class FixedFormStateAdapter implements FormStateAdapter {
  final AutovalidateMode _autovalidateMode;
  final VoidCallback _onSave;
  final bool Function() _onValidate;

  FixedFormStateAdapter({
    AutovalidateMode? autovalidateMode,
    VoidCallback? onSave,
    bool Function()? onValidate,
  })  : _autovalidateMode = autovalidateMode ?? AutovalidateMode.disabled,
        _onSave = (onSave ?? () {}),
        _onValidate = (onValidate ?? () => true);

  @override
  AutovalidateMode get autovalidateMode => _autovalidateMode;

  @override
  Locale get locale => defaultLocale;

  @override
  bool get mounted => true;

  @override
  void save() => _onSave();

  @override
  bool validate() => _onValidate();
}
