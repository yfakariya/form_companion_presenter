// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'properties.dart';

// for detectMixinType() / getProperties() testing

@formCompanion
class FormPresenter with CompanionPresenterMixin, FormCompanionMixin {
  FormPresenter() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class FormBuilderPresenter
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  FormBuilderPresenter() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class DualPresenter
    with
        CompanionPresenterMixin,
        FormCompanionMixin,
        FormBuilderCompanionMixin {
  DualPresenter() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class VanillaPresenter {}

@formCompanion
class InvalidCompanionPresenter with CompanionPresenterMixin {
  InvalidCompanionPresenter() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  bool canSubmit(BuildContext context) => true;

  @override
  FutureOr<void> doSubmit() {}

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) => null;
}

// for findConstructor() testing

@formCompanion
class WithPrivateConstructor with CompanionPresenterMixin, FormCompanionMixin {
  WithPrivateConstructor._() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithDelegatingConstructors
    with CompanionPresenterMixin, FormCompanionMixin {
  WithDelegatingConstructors._() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  WithDelegatingConstructors() : this._();

  WithDelegatingConstructors.something() : this._();

  WithDelegatingConstructors._anything() : this();

  factory WithDelegatingConstructors.factory() =>
      WithDelegatingConstructors._();

  factory WithDelegatingConstructors._factory() => WithDelegatingConstructors();

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class NoDefaultConstructors with CompanionPresenterMixin, FormCompanionMixin {
  factory NoDefaultConstructors.something() =>
      NoDefaultConstructors.toBeDetected();

  NoDefaultConstructors() : this.toBeDetected();

  NoDefaultConstructors._() : this.toBeDetected();

  NoDefaultConstructors.named() : this.toBeDetected();

  NoDefaultConstructors.toBeDetected() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithoutConstructor with CompanionPresenterMixin, FormCompanionMixin {
  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class MultipleConstructorBody with CompanionPresenterMixin, FormCompanionMixin {
  MultipleConstructorBody() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  MultipleConstructorBody._() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

// for tryGetProperties testing

@formCompanion
class InlineWithCascading with CompanionPresenterMixin, FormCompanionMixin {
  InlineWithCascading() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<int>(name: 'propInt')
        ..add<String>(name: 'propString')
        ..add<bool>(name: 'propBool')
        ..add<MyEnum>(name: 'propEnum')
        ..add(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InlineWithNoAddition with CompanionPresenterMixin, FormCompanionMixin {
  InlineWithNoAddition() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsCascadingFactory with CompanionPresenterMixin, FormCompanionMixin {
  CallsCascadingFactory() {
    initializeCompanionMixin(cascadingFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsClassicFactory with CompanionPresenterMixin, FormCompanionMixin {
  CallsClassicFactory() {
    initializeCompanionMixin(classicFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsWithHelperFactory with CompanionPresenterMixin, FormCompanionMixin {
  CallsWithHelperFactory() {
    initializeCompanionMixin(withHelpersFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

// -- refers field

@formCompanion
class RefersStaticFieldInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldInlineInitialized() {
    initializeCompanionMixin(PropertyDescritptors.inlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldWithNoAddition
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldWithNoAddition() {
    initializeCompanionMixin(PropertyDescritptors.noAddition);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForInlineInitialized() {
    initializeCompanionMixin(PropertyDescritptors.refersInlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForFactoryInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForFactoryInitialized() {
    initializeCompanionMixin(PropertyDescritptors.refersFactoryInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForFactoryMethod() {
    initializeCompanionMixin(PropertyDescritptors.refersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldCascadingFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldCascadingFactoryMethod() {
    initializeCompanionMixin(PropertyDescritptors.withCascadingFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldClassicFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldClassicFactoryMethod() {
    initializeCompanionMixin(PropertyDescritptors.withClassicFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldWithHelpersFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldWithHelpersFactoryMethod() {
    initializeCompanionMixin(PropertyDescritptors.withWithHelpersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodCascadingFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodCascadingFactory() {
    initializeCompanionMixin(PropertyDescritptors.cascadingFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodClassicFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodClassicFactory() {
    initializeCompanionMixin(PropertyDescritptors.classicFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodWithHelperFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodWithHelperFactory() {
    initializeCompanionMixin(PropertyDescritptors.withHelpersFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

// -- refers global variable

@formCompanion
class RefersGlobalVariableInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableInlineInitialized() {
    initializeCompanionMixin(inlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableWithNoAddition
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableWithNoAddition() {
    initializeCompanionMixin(noAddition);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableGetterForInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableGetterForInlineInitialized() {
    initializeCompanionMixin(refersInlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableGetterForFactoryInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableGetterForFactoryInitialized() {
    initializeCompanionMixin(refersFactoryInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableGetterForFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableGetterForFactoryMethod() {
    initializeCompanionMixin(refersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableCascadingFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableCascadingFactoryMethod() {
    initializeCompanionMixin(withCascadingFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableClassicFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableClassicFactoryMethod() {
    initializeCompanionMixin(withClassicFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersGlobalVariableWithHelpersFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersGlobalVariableWithHelpersFactoryMethod() {
    initializeCompanionMixin(withWithHelpersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsGlobalFunctionCascadingFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsGlobalFunctionCascadingFactory() {
    initializeCompanionMixin(cascadingFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsGlobalFunctionClassicFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsGlobalFunctionClassicFactory() {
    initializeCompanionMixin(classicFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsGlobalFunctionWithHelperFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsGlobalFunctionWithHelperFactory() {
    initializeCompanionMixin(withHelpersFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

// -- local variable patterns

@formCompanion
class LocalVariableInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableInlineInitialized() {
    final builder = PropertyDescriptorsBuilder()
      ..add<int>(name: 'propInt')
      ..add<String>(name: 'propString')
      ..add<bool>(name: 'propBool')
      ..add<MyEnum>(name: 'propEnum')
      ..add(name: 'propRaw');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableNoAddition with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableNoAddition() {
    final builder = PropertyDescriptorsBuilder();
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersField
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersField() {
    final builder = inlineInitialized;
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersFieldWithModification
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersFieldWithModification() {
    final builder = inlineInitialized;
    builder.add<String>(name: 'extra');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersGetter
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersGetter() {
    final builder = refersInlineInitialized;
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersAlwaysSameGetterWithModification
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersAlwaysSameGetterWithModification() {
    final builder = refersInlineInitialized;
    builder.add<String>(name: 'extra');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersAlwaysNewGetterWithModification
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersAlwaysNewGetterWithModification() {
    final builder = refersFactory;
    builder.add<String>(name: 'extra');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersFactoryMethod() {
    final builder = withHelpersFactory();
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersAlwaysSameFactoryMethodWithMofidication
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersAlwaysSameFactoryMethodWithMofidication() {
    final builder = singletonFactory();
    builder.add<String>(name: 'extra');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableRefersAlwaysNewFactoryMethodWithMofidication
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableRefersAlwaysNewFactoryMethodWithMofidication() {
    final builder = withHelpersFactory();
    builder.add<String>(name: 'extra');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class LocalVariableCallsHelpers
    with CompanionPresenterMixin, FormCompanionMixin {
  LocalVariableCallsHelpers() {
    final builder = PropertyDescriptorsBuilder();
    builder.add<int>(name: 'propInt');
    helper(builder);
    builder.add(name: 'propRaw');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidLocalVariableWithDuplication
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidLocalVariableWithDuplication() {
    final builder = factoryWithDuplication();
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidLocalVariableWithDuplicationHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidLocalVariableWithDuplicationHelper() {
    final builder = PropertyDescriptorsBuilder();
    helperWithDuplication(builder);
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidLocalVariableInitializationWithDuplication
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidLocalVariableInitializationWithDuplication() {
    final builder = PropertyDescriptorsBuilder()
      ..add<int>(name: 'propInt')
      ..add<int>(name: 'propInt');
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

// -- error cases

@formCompanion
class NoInitializeCompanionMixin
    with CompanionPresenterMixin, FormCompanionMixin {
  NoInitializeCompanionMixin() {}

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class MultipleInitializeCompanionMixin
    with CompanionPresenterMixin, FormCompanionMixin {
  MultipleInitializeCompanionMixin() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..add<int>(name: 'prop1'),
    );
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..add<String>(name: 'prop2'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class DynamicPropertyName with CompanionPresenterMixin, FormCompanionMixin {
  DynamicPropertyName() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<int>(name: 'prop${Platform.numberOfProcessors}'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithIf with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithIf() {
    initializeCompanionMixin(factoryWithIf());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithFor with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithFor() {
    initializeCompanionMixin(factoryWithFor());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithWhile with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithWhile() {
    initializeCompanionMixin(factoryWithWhile());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithDo with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithDo() {
    initializeCompanionMixin(factoryWithDo());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithTry with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithTry() {
    initializeCompanionMixin(factoryWithTry());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithIfHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithIfHelper() {
    initializeCompanionMixin(factoryCallsWithIf());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithForHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithForHelper() {
    initializeCompanionMixin(factoryCallsWithFor());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithWhileHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithWhileHelper() {
    initializeCompanionMixin(factoryCallsWithWhile());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithDoHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithDoHelper() {
    initializeCompanionMixin(factoryCallsWithDo());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithTryHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithTryHelper() {
    initializeCompanionMixin(factoryCallsWithTry());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithDuplication
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithDuplication() {
    initializeCompanionMixin(factoryWithDuplication());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidFactoryWithDuplicationHelper
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidFactoryWithDuplicationHelper() {
    initializeCompanionMixin(factoryCallsWithDuplication());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InvalidInitializationWithDuplication
    with CompanionPresenterMixin, FormCompanionMixin {
  InvalidInitializationWithDuplication() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<int>(name: 'propInt')
        ..add<String>(name: 'propString')
        ..add<bool>(name: 'propBool')
        ..add<MyEnum>(name: 'propEnum')
        ..add(name: 'propRaw')
        ..add<String>(name: 'propInt'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}
