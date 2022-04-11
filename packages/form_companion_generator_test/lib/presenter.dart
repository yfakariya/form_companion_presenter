// coverage:ignore-file
// See LICENCE file in the root.
// ignore_for_file: type=lint, unused_element

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_annotation.dart';
import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';
import 'package:form_companion_presenter/form_companion_annotation.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

import 'enum.dart';
import 'properties.dart';
import 'properties.dart' as pr;

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

class InvalidCompanionPresenterFeatures extends CompanionPresenterFeatures {
  const InvalidCompanionPresenterFeatures();

  @override
  FormStateAdapter? maybeFormStateOf(BuildContext context) => null;
}

@formCompanion
class InvalidCompanionPresenter with CompanionPresenterMixin {
  @override
  CompanionPresenterFeatures get presenterFeatures =>
      const InvalidCompanionPresenterFeatures();

  InvalidCompanionPresenter() {
    initializeCompanionMixin(PropertyDescriptorsBuilder());
  }

  @override
  bool canSubmit(BuildContext context) => true;

  @override
  FutureOr<void> doSubmit() {}
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
class InlineWithCascading
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  InlineWithCascading() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class ExtensionMethod with CompanionPresenterMixin, FormBuilderCompanionMixin {
  ExtensionMethod() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..addWithField<double, double, FormBuilderSlider>(name: 'propDouble')
        ..addWithField<List<MyEnum>, List<MyEnum>,
            FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumList',
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class InferredTypes with CompanionPresenterMixin, FormBuilderCompanionMixin {
  InferredTypes() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..add(
          name: 'addWithValueConverter',
          valueConverter: intStringConverter,
        )
        ..stringConvertible(
          name: 'addStringWithStringConverter',
          stringConverter: bigIntStringConverter,
        )
        ..stringConvertible(
          name: 'addStringWithInitialValue',
          initialValue: 1.23,
          stringConverter: doubleStringConverter,
        )
        ..enumerated(
          name: 'addEnumWithInitialValue',
          initialValue: MyEnum.one,
        )
        ..enumeratedList(
          name: 'addEnumListWithInitialValue',
          initialValues: [MyEnum.one],
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddVanilla with CompanionPresenterMixin, FormCompanionMixin {
  RawAddVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..add(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddWithFieldVanilla with CompanionPresenterMixin, FormCompanionMixin {
  RawAddWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..addWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddBigIntWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddBigIntWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..bigIntWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddBoolWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddBoolWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..booleanWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddDoubleWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddDoubleWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..realWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddEnumWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddEnumWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..enumeratedWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddIntWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddIntWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..integerWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddStringWithFieldVanilla
    with CompanionPresenterMixin, FormCompanionMixin {
  RawAddStringWithFieldVanilla() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..stringConvertibleWithField(
          name: 'propRaw',
          stringConverter: StringConverter.fromCallbacks(
            stringify: (v, l) => v.toString(),
            parse: (v, l) => ConversionResult<Object>(null),
          ),
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..add(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..addWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddBigIntWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddBigIntWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..bigIntWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddBoolListWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddBoolListWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..booleanListWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddBoolWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddBoolWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..booleanWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddDoubleWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddDoubleWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..realWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddEnumListWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddEnumListWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..enumeratedListWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddEnumWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddEnumWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..enumeratedWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddIntWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddIntWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..integerWithField(name: 'propRaw'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RawAddStringWithFieldFormBuilder
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  RawAddStringWithFieldFormBuilder() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..stringConvertibleWithField(
          name: 'propRaw',
          stringConverter: StringConverter.fromCallbacks(
            stringify: (v, l) => v.toString(),
            parse: (v, l) => ConversionResult<Object>(null),
          ),
        ),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class ConvinientExtensionMethod
    with CompanionPresenterMixin, FormBuilderCompanionMixin {
  ConvinientExtensionMethod() {
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()
        ..integerText(name: 'propInt')
        ..string(name: 'propString')
        ..boolean(name: 'propBool')
        ..enumerated<MyEnum>(name: 'propEnum')
        ..enumeratedList<MyEnum>(name: 'propEnumList')
        ..realWithField<FormBuilderSlider>(name: 'propDouble')
        ..enumeratedListWithField<MyEnum, FormBuilderCheckboxGroup<MyEnum>>(
          name: 'propEnumList2',
        ),
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
class CallsCascadingFactoryGetter
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsCascadingFactoryGetter() {
    initializeCompanionMixin(cascadingFactoryGetter);
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
    initializeCompanionMixin(PropertyDescriptors.inlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldWithNoAddition
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldWithNoAddition() {
    initializeCompanionMixin(PropertyDescriptors.noAddition);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForInlineInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForInlineInitialized() {
    initializeCompanionMixin(PropertyDescriptors.refersInlineInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForFactoryInitialized
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForFactoryInitialized() {
    initializeCompanionMixin(PropertyDescriptors.refersFactoryInitialized);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldGetterForFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldGetterForFactoryMethod() {
    initializeCompanionMixin(PropertyDescriptors.refersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldCascadingFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldCascadingFactoryMethod() {
    initializeCompanionMixin(PropertyDescriptors.withCascadingFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldClassicFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldClassicFactoryMethod() {
    initializeCompanionMixin(PropertyDescriptors.withClassicFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class RefersStaticFieldWithHelpersFactoryMethod
    with CompanionPresenterMixin, FormCompanionMixin {
  RefersStaticFieldWithHelpersFactoryMethod() {
    initializeCompanionMixin(PropertyDescriptors.withWithHelpersFactory);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodCascadingFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodCascadingFactory() {
    initializeCompanionMixin(PropertyDescriptors.cascadingFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodClassicFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodClassicFactory() {
    initializeCompanionMixin(PropertyDescriptors.classicFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class CallsStaticMethodWithHelperFactory
    with CompanionPresenterMixin, FormCompanionMixin {
  CallsStaticMethodWithHelperFactory() {
    initializeCompanionMixin(PropertyDescriptors.withHelpersFactory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithLocalFunction with CompanionPresenterMixin, FormCompanionMixin {
  WithLocalFunction() {
    PropertyDescriptorsBuilder setup() => PropertyDescriptorsBuilder()
      ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
      ..add<String, String>(name: 'propString')
      ..add<bool, bool>(name: 'propBool')
      ..add<MyEnum, MyEnum>(name: 'propEnum')
      ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithExtraBlock with CompanionPresenterMixin, FormCompanionMixin {
  WithExtraBlock() {
    PropertyDescriptorsBuilder setup() {
      final pdb = PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString');
      {
        pdb
          ..add<bool, bool>(name: 'propBool')
          ..add<MyEnum, MyEnum>(name: 'propEnum')
          ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
      }

      return pdb;
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithLateFinalVariable with CompanionPresenterMixin, FormCompanionMixin {
  WithLateFinalVariable() {
    PropertyDescriptorsBuilder setup() {
      late final PropertyDescriptorsBuilder pdb;

      pdb = PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');

      return pdb;
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithExtraConstructs with CompanionPresenterMixin, FormCompanionMixin {
  WithExtraConstructs() {
    PropertyDescriptorsBuilder setup() {
      final pdb = PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
      final extraVariable = DateTime.now();
      // extra invocation
      print(extraVariable);
      // extra property access
      print(Colors.amber);
      return pdb;
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithEarlyReturn with CompanionPresenterMixin, FormCompanionMixin {
  WithEarlyReturn() {
    PropertyDescriptorsBuilder setup() {
      final pdb = PropertyDescriptorsBuilder()
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
      return pdb;

      // ignore: dead_code
      pdb..add<String, String>(name: 'extra');
      return pdb;
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithEarlyReturnHelper with CompanionPresenterMixin, FormCompanionMixin {
  WithEarlyReturnHelper() {
    void setup(PropertyDescriptorsBuilder pdb) {
      pdb
        ..add<int, String>(name: 'propInt', valueConverter: intStringConverter)
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
      return;

      // ignore: dead_code
      pdb..add<String, String>(name: 'extra');
    }

    final builder = PropertyDescriptorsBuilder();
    setup(builder);
    initializeCompanionMixin(builder);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithPrefixedReferenceExpression
    with CompanionPresenterMixin, FormCompanionMixin {
  WithPrefixedReferenceExpression() {
    PropertyDescriptorsBuilder setup() {
      return pr.PropertyDescriptors.inlineInitialized;
    }

    initializeCompanionMixin(setup());
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
      ..add<int, String>(name: 'propInt')
      ..add<String, String>(name: 'propString')
      ..add<bool, bool>(name: 'propBool')
      ..add<MyEnum, MyEnum>(name: 'propEnum')
      ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
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
    builder.add<String, String>(name: 'extra');
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
    builder.add<String, String>(name: 'extra');
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
    builder.add<String, String>(name: 'extra');
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
    builder.add<String, String>(name: 'extra');
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
    builder.add<String, String>(name: 'extra');
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
    builder.add<int, String>(name: 'propInt');
    helper(builder);
    builder.add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList');
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
      ..add<int, String>(name: 'propInt')
      ..add<int, String>(name: 'propInt');
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
      PropertyDescriptorsBuilder()..add<int, String>(name: 'prop1'),
    );
    initializeCompanionMixin(
      PropertyDescriptorsBuilder()..add<String, String>(name: 'prop2'),
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
        ..add<int, String>(name: 'prop${Platform.numberOfProcessors}'),
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
        ..add<int, String>(name: 'propInt')
        ..add<String, String>(name: 'propString')
        ..add<bool, bool>(name: 'propBool')
        ..add<MyEnum, MyEnum>(name: 'propEnum')
        ..add<List<MyEnum>, List<MyEnum>>(name: 'propEnumList')
        ..add<String, String>(name: 'propInt'),
    );
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class FieldWithoutInitialization
    with CompanionPresenterMixin, FormCompanionMixin {
  PropertyDescriptorsBuilder? builder;
  FieldWithoutInitialization() {
    builder = PropertyDescriptorsBuilder()..add<int, int>(name: 'propInt');
    initializeCompanionMixin(builder!);
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithFunctionExpression with CompanionPresenterMixin, FormCompanionMixin {
  WithFunctionExpression() {
    PropertyDescriptorsBuilder Function() setup() {
      return () => cascadingFactory();
    }

    final factory = setup();

    initializeCompanionMixin(factory());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithFunctionInvocationExpression
    with CompanionPresenterMixin, FormCompanionMixin {
  WithFunctionInvocationExpression() {
    PropertyDescriptorsBuilder setup() {
      return (cascadingFactory)();
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}

@formCompanion
class WithControlExpression with CompanionPresenterMixin, FormCompanionMixin {
  WithControlExpression() {
    PropertyDescriptorsBuilder setup() {
      throw UnimplementedError();
    }

    initializeCompanionMixin(setup());
  }

  @override
  FutureOr<void> doSubmit() {}
}
