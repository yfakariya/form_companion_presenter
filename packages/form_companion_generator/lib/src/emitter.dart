// See LICENCE file in the root.

import 'package:meta/meta.dart';

import 'config.dart';
import 'model.dart';

const _todoHeader = 'TODO(CompanionGenerator):';

/// Emits lines for specified data.
Iterable<Object> emitFromData(PresenterDefinition data, Config config) sync* {
  for (final global in emitGlobal(data, config)) {
    yield global;
  }

  yield emitPropertyAccessor(data.name, data.properties.values, config);
  if (!config.suppressFieldFactory) {
    yield emitFieldFactories(data, config);
  }
}

/// Emits global parts.
@visibleForTesting
Iterable<String> emitGlobal(
  PresenterDefinition data,
  Config config,
) sync* {
  for (final warning in data.warnings) {
    yield '// $_todoHeader WARNING - $warning';
  }
}

/// Emits property accessors and a their holder.
@visibleForTesting
String emitPropertyAccessor(
  String baseName,
  Iterable<PropertyDefinition> properties,
  Config config,
) {
  return '''
extension \$${baseName}PropertyExtension on $baseName {
${properties.isEmpty ? '  // No properties were found.' : _emitPropertyAccessors(properties).join('\n')}
}
''';
}

/// Emits each property accessor lines.
Iterable<String> _emitPropertyAccessors(
  Iterable<PropertyDefinition> properties,
) sync* {
  var isFirst = true;
  for (final property in properties) {
    if (isFirst) {
      isFirst = false;
    } else {
      // empty line
      yield '';
    }

    yield '  /// Gets a [PropertyDescriptor] of ${property.name} property.';
    yield '  PropertyDescriptor<${property.type}> get ${property.name} => '
        "this.properties['${property.name}'] as PropertyDescriptor<${property.type}>;";
  }
}

/// Emits field factories and their holders.
@visibleForTesting
String emitFieldFactories(
  PresenterDefinition data,
  Config config,
) {
  return '''
class \$${data.name}FieldFactories {
  final Map<String, PropertyDescriptor<Object>> _properties;

  \$${data.name}FieldFactories._(this._properties);
${data.properties.isEmpty ? '\n  // No properties were found.' : data.properties.values.map((p) => emitFieldFactory(data, p).join('\n')).join('\n')}
}

extension \$${data.name}FieldFactoryExtension on ${data.name} {
  /// Gets a form field factories.
  \$${data.name}FieldFactories get fields => \$${data.name}FieldFactories(this.properties);
}
''';
}

/// Emits a field factory method lines.
@visibleForTesting
Iterable<String> emitFieldFactory(
  PresenterDefinition data,
  PropertyDefinition property,
) sync* {
  // For newline before lines.
  yield '';

  final rawFormFieldType =
      property.getRawFormFieldType(isFormBuilder: data.isFormBuilder);
  final formFieldBuilderType =
      property.getFormFieldBuilderType(isFormBuilder: data.isFormBuilder);

  final setupEmitterFactory = _setupEmitterFactories[rawFormFieldType];
  if (setupEmitterFactory == null && !data.isFormBuilder) {
    // We cannot handle this pattern.
    yield "  // $_todoHeader ERROR - Cannot generate field factory for '${property.name}' "
        "property, because FormField type '$rawFormFieldType' is unknown.";
    return;
  }

  for (final warning in property.warnings) {
    yield '  // $_todoHeader WARNING - $warning';
  }

  yield '  /// Gets a [FormField] for ${property.name} property.';
  if (setupEmitterFactory == null) {
    yield "  /// This takes [customFactory] because FormField type '$rawFormFieldType' is unknown.";
  }

  yield '  FormField ${property.name}(';
  if (setupEmitterFactory != null) {
    if (!data.isFormBuilder) {
      yield '    BuildContext context,';
      yield '    FormCompanionPresenterMixin presenter, [';
    } else {
      yield '    BuildContext context, [';
    }
    yield '    void Function($formFieldBuilderType)? setup,';
    yield '  ]) {';
    yield '    final property = this.${property.name};';
    for (final line
        in setupEmitterFactory(property.type).emit(data, property)) {
      yield line;
    }
    yield '    setup?.call(builder);';
    yield '    return builder.build();';
    yield '  }';
  } else {
    assert(data.isFormBuilder);
    yield '    BuildContext context,';
    // Unknown FormBuilderFields should be able to be handled as 'generic'
    // but the instance should be instanciated via custom factory.
    yield '    FormField Function(GenericFormBuilderFieldBuilder<${property.type}>, PropertyDescriptor<${property.type}>) customFactory,';
    yield '  ) {';
    yield '    final property = this.${property.name};';
    for (final line
        in _fallbackFormBuilderFieldBuilderEmitterFactory(property.type)
            .emit(data, property)) {
      yield line;
    }
    yield '    return customFactory(builder, property);';
    yield '  }';
  }
}

/// A mapping of raw name of `FormField`s and factories of [_SetupEmitter].
/// The parameter of factories are a name of a generic type argument of the `FormField`.
final _setupEmitterFactories = <String, _SetupEmitter Function(String)>{
  'TextFormField': (_) => const _TextFormFieldBuilderSetupEmitter(),
  'DropdownButtonFormField': _DropdownButtonFormFieldBuilderSetupEmitter.new,
  'FormBuilderTextField': (_) =>
      const _FormBuilderTextFieldBuilderSetupEmitter(),
  'FormBuilderDropdown': _FormBuilderDropdownBuilderSetupEmitter.new,
  'FormBuilderCheckbox': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderCheckbox'),
  'FormBuilderCheckboxGroup': (t) =>
      _GenericFormBuilderSetupEmitter('FormBuilderCheckboxGroup', t),
  'FormBuilderChoiceChip': (t) =>
      _GenericFormBuilderSetupEmitter('FormBuilderChoiceChip', t),
  'FormBuilderDateTimePicker': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderDateTimePicker'),
  'FormBuilderDateRangePicker': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderDateRangePicker'),
  'FormBuilderFilterChip': (t) =>
      _GenericFormBuilderSetupEmitter('FormBuilderFilterChip', t),
  'FormBuilderRadioGroup': (t) =>
      _GenericFormBuilderSetupEmitter('FormBuilderRadioGroup', t),
  'FormBuilderRangeSlider': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderRangeSlider'),
  'FormBuilderSegmentedControl': (t) =>
      _GenericFormBuilderSetupEmitter('FormBuilderSegmentedControl', t),
  'FormBuilderSlider': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderSlider'),
  'FormBuilderSwitch': (_) =>
      const _GenericFormBuilderSetupEmitter('FormBuilderSwitch'),
};

/// Returns a [_SetupEmitter] for `FormBuilder` as fallback value.
_SetupEmitter _fallbackFormBuilderFieldBuilderEmitterFactory(String t) =>
    _GenericFormBuilderSetupEmitter('GenericFormBuilderField', t);

/// Emits builder setup lines for type of the target `FormField` class.
abstract class _SetupEmitter {
  const _SetupEmitter();

  String get builderName;

  Iterable<String> emit(
      PresenterDefinition data, PropertyDefinition property) sync* {
    // TODO(yfakariya): FormBuilderFields requires required argument...
    yield '    final builder = $builderName()';
    if (data.fieldAutovalidateMode != null) {
      yield '      ..autovalidateMode = ${data.fieldAutovalidateMode}';
    }
    for (final line in emitChainedAssignments(property)) {
      yield line;
    }
  }

  Iterable<String> emitChainedAssignments(PropertyDefinition property);
}

abstract class _VanillaFormFieldSetupEmitter extends _SetupEmitter {
  const _VanillaFormFieldSetupEmitter();

  @override
  @nonVirtual
  Iterable<String> emitChainedAssignments(PropertyDefinition property) sync* {
    yield '      ..key = presenter.getKey(property.name, context)';
    yield '      ..onSaved = property.savePropertyValue';
    yield '      ..decoration = InputDecoration(';
    yield '        labelText: property.name,';
    yield '      )';
    for (final line in emitChainedAssignmentsCore(property)) {
      yield line;
    }
  }

  Iterable<String> emitChainedAssignmentsCore(PropertyDefinition property);
}

@sealed
class _TextFormFieldBuilderSetupEmitter extends _VanillaFormFieldSetupEmitter {
  const _TextFormFieldBuilderSetupEmitter();

  @override
  String get builderName => 'TextFormFieldBuilder';

  @override
  Iterable<String> emitChainedAssignmentsCore(
      PropertyDefinition property) sync* {
    yield '      ..initialValue = property.value.toString()';
    yield '      ..validator = property.getValidator(context);';
  }
}

@sealed
class _DropdownButtonFormFieldBuilderSetupEmitter
    extends _VanillaFormFieldSetupEmitter {
  _DropdownButtonFormFieldBuilderSetupEmitter(this._typeName);

  final String _typeName;

  @override
  String get builderName => 'DropdownButtonFormFieldBuilder<$_typeName>';

  @override
  Iterable<String> emitChainedAssignmentsCore(
      PropertyDefinition property) sync* {
    yield '      ..value = property.value';
    yield '      // Tip: required to work correctly';
    yield '      ..onChanged = (_) {};';
  }
}

abstract class _FormBuilderFieldSetupEmitter extends _SetupEmitter {
  const _FormBuilderFieldSetupEmitter();

  @override
  @nonVirtual
  Iterable<String> emitChainedAssignments(PropertyDefinition property) sync* {
    yield '      ..name = property.name';
    yield '      ..decoration = InputDecoration(';
    yield '        labelText: property.name,';
    yield '      )';
    for (final line in emitChainedAssignmentsCore(property)) {
      yield line;
    }
  }

  Iterable<String> emitChainedAssignmentsCore(PropertyDefinition property);
}

@sealed
class _FormBuilderTextFieldBuilderSetupEmitter
    extends _FormBuilderFieldSetupEmitter {
  const _FormBuilderTextFieldBuilderSetupEmitter();

  @override
  String get builderName => 'FormBuilderTextFieldBuilder';

  @override
  Iterable<String> emitChainedAssignmentsCore(
      PropertyDefinition property) sync* {
    yield '      ..initialValue = property.value.toString()';
    yield '      ..validator = property.getValidator(context);';
  }
}

@sealed
class _FormBuilderDropdownBuilderSetupEmitter
    extends _FormBuilderFieldSetupEmitter {
  _FormBuilderDropdownBuilderSetupEmitter(this._typeName);

  final String _typeName;

  @override
  String get builderName => 'FormBuilderDropdownBuilder<$_typeName>';

  @override
  Iterable<String> emitChainedAssignmentsCore(
      PropertyDefinition property) sync* {
    yield '      ..initialValue = property.value';
    yield '      // Tip: required to work correctly';
    yield '      ..onChanged = (_) {};';
  }
}

@sealed
class _GenericFormBuilderSetupEmitter extends _FormBuilderFieldSetupEmitter {
  const _GenericFormBuilderSetupEmitter(String fieldName, [String? typeName])
      : builderName = typeName == null
            ? '${fieldName}Builder'
            : '${fieldName}Builder<$typeName>';

  @override
  final String builderName;

  @override
  Iterable<String> emitChainedAssignmentsCore(
      PropertyDefinition property) sync* {
    yield '      ..initialValue = property.value;';
  }
}
