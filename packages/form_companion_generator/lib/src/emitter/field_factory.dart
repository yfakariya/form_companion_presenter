// See LICENCE file in the root.

part of '../emitter.dart';

const _formPropertiesField = '_properties';
const _defaultPropertyDescriptorVariable = 'property';
const _alternativePropertyDescriptorVariable = 'property_';

/// Emits field factories and their holders.
@visibleForTesting
Future<String> emitFieldFactoriesAsync(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Config config,
  Logger logger,
) async {
  assert(data.properties.isNotEmpty);

  return '''
${_emitFieldFactoriesClasses(nodeProvider, data, logger).join('\n')}

/// Defines an extension property to get [\$${data.name}FieldFactory] from [${data.name}].
extension \$${data.name}FormPropertiesFieldFactoryExtension on \$${data.name}FormProperties {
  /// Gets a [FormField] factory.
  \$${data.name}FieldFactory get fields => \$${data.name}FieldFactory._(this);
}''';
}

/// Emits each form factory class lines.
Iterable<String> _emitFieldFactoriesClasses(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Logger logger,
) sync* {
  final propertyWithComplexFormFields =
      data.properties.where((p) => !p.isSimpleFormField).toList();
  final hasSimpleProperties =
      propertyWithComplexFormFields.length != data.properties.length;

  yield '/// Defines [FormField] factory methods for properties of [${data.name}].';
  yield 'class \$${data.name}FieldFactory {';
  if (hasSimpleProperties) {
    yield '  final \$${data.name}FormProperties $_formPropertiesField;';

    // blank line
    yield '';
  }

  for (final property in propertyWithComplexFormFields) {
    yield '  /// Gets a [FormField] factory for `${property.name}` property.';
    yield '  final ${_getNamedFormFactoryClassName(data.name, property)} ${property.name};';

    // For newline after lines.
    yield '';
  }

  // constructor
  if (propertyWithComplexFormFields.isEmpty) {
    yield '  \$${data.name}FieldFactory._(this.$_formPropertiesField);';
  } else {
    yield '  \$${data.name}FieldFactory._(\$${data.name}FormProperties properties) :';
    if (hasSimpleProperties) {
      yield '    $_formPropertiesField = properties,';
    }

    for (var i = 0; i < propertyWithComplexFormFields.length - 1; i++) {
      yield '    ${propertyWithComplexFormFields[i].name} = '
          '${_getNamedFormFactoryClassName(data.name, propertyWithComplexFormFields[i])}'
          '(properties),';
    }

    yield '    ${propertyWithComplexFormFields.last.name} = '
        '${_getNamedFormFactoryClassName(data.name, propertyWithComplexFormFields.last)}'
        '(properties);';
  }

  for (final property in data.properties.where((p) => p.isSimpleFormField)) {
    // For newline before lines.
    yield '';

    yield* emitFieldFactory(nodeProvider, data, property, logger);
  }

  yield* _emitFunctionDefaults(
    data.properties.where((p) => p.isSimpleFormField),
  );

  yield '}';

  if (propertyWithComplexFormFields.isEmpty) {
    return;
  }

  for (final property in propertyWithComplexFormFields) {
    final className = _getNamedFormFactoryClassName(data.name, property);
    // For newline before lines.
    yield '';

    yield '/// A [FormField] factory for `${property.name}` property of [${data.name}].';
    yield 'class $className {';
    yield '  final \$${data.name}FormProperties $_formPropertiesField;';

    // blank line
    yield '';

    yield '  $className._(this.$_formPropertiesField);';

    if (property.warnings.isNotEmpty) {
      // For newline before warnings.
      yield '';
    }

    yield* _emitPropertyWarnings(property);

    for (final constructor in property.formFieldConstructors) {
      // For newline before lines.
      yield '';

      yield* _emitFieldFactoryCore(
        nodeProvider,
        data,
        property,
        constructor,
        logger,
      );
    }

    yield* _emitFunctionDefaults(
      data.properties.where((p) => !p.isSimpleFormField),
    );

    yield '}';
  }
}

String _getNamedFormFactoryClassName(
  String className,
  PropertyAndFormFieldDefinition property,
) {
  late final String pascalPropertyName;
  if (property.name.length < 2) {
    pascalPropertyName = property.name.toUpperCase();
  } else {
    pascalPropertyName = property.name.substring(0, 1).toUpperCase() +
        property.name.substring(1);
  }

  return '\$\$$className${pascalPropertyName}FieldFactory';
}

/// Emits form field factory method lines.
@visibleForTesting
Iterable<String> emitFieldFactory(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  PropertyAndFormFieldDefinition property,
  Logger logger,
) sync* {
  yield* _emitPropertyWarnings(property);

  if (property.formFieldConstructors.isEmpty) {
    return;
  }

  yield* _emitFieldFactoryCore(
    nodeProvider,
    data,
    property,
    property.formFieldConstructors.single,
    logger,
  );
}

Iterable<String> _emitFieldFactoryCore(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  PropertyAndFormFieldDefinition property,
  FormFieldConstructorDefinition constructor,
  Logger logger,
) sync* {
  final instantiationContext = property.instantiationContext;
  if (instantiationContext == null) {
    return;
  }

  final argumentHandler = constructor.argumentsHandler;

  final sink = StringBuffer();
  processTypeWithValueType(
    instantiationContext,
    property.formFieldTypeName,
    property.formFieldType!,
    sink,
  );
  final formFieldType = sink.toString();

  late final String methodName;
  late final String constructorName;
  if (property.isSimpleFormField) {
    yield '  /// Gets a [FormField] for `${property.name}` property.';
    methodName = property.name;
    constructorName = formFieldType;
  } else {
    yield '  /// Gets a [FormField] for `${property.name}` property '
        'with [$formFieldType.${constructor.constructor.name?.lexeme ?? 'new'}] constructor.';
    methodName =
        constructor.constructor.name?.lexeme ?? 'withDefaultConstructor';
    constructorName = constructor.constructor.name == null
        ? formFieldType
        : '$formFieldType.${constructor.constructor.name?.lexeme}';
  }

  yield '  $formFieldType $methodName(';
  yield '    BuildContext context, {';
  for (final parameter in argumentHandler.callerSuppliableParameters) {
    yield '    ${emitParameter(instantiationContext, parameter)},';
  }
  final propertyDescriptorVariable = argumentHandler.callerSuppliableParameters
          .any((p) => p.name == _defaultPropertyDescriptorVariable)
      ? _alternativePropertyDescriptorVariable
      : _defaultPropertyDescriptorVariable;
  yield '  }) {';
  yield '    final $propertyDescriptorVariable = $_formPropertiesField.descriptors.${property.name};';
  yield '    return $constructorName(';
  yield* argumentHandler.emitAssignments(
    data: data,
    buildContext: 'context',
    presenterName: data.name,
    propertyDescriptor: propertyDescriptorVariable,
    itemValue: 'x',
    indent: '      ',
    logger: logger,
  );
  yield '    );';
  yield '  }';
}

Iterable<String> _emitPropertyWarnings(
  PropertyAndFormFieldDefinition property,
) sync* {
  if (property.instantiationContext == null ||
      property.formFieldConstructors.isEmpty) {
    // We cannot handle this pattern.
    yield "  // $_todoHeader ERROR - Cannot generate field factory for '${property.name}' "
        "property, because FormField type '${property.formFieldTypeName}' is unknown.";
    return;
  }

  for (final warning in property.warnings) {
    yield '  // $_todoHeader WARNING - $warning';
  }

  if (property.warnings.isNotEmpty) {
    // blank line.
    yield '';
  }
}

/// Emits specified parameter information with type argument.
///
/// Note that this function assumes that the parameter is in context of named
/// parameters list rather than positional parameters list.
@visibleForTesting
String emitParameter(
  TypeInstantiationContext context,
  ParameterInfo parameter,
) {
  final sink = StringBuffer();

  if (parameter.requirability == ParameterRequirability.required) {
    sink.write('required ');
  }

  if (parameter.keyword != null) {
    sink
      ..write(parameter.keyword)
      ..write(' ');
  }

  final functionTypedParameter = parameter.functionTypedParameter;

  if (functionTypedParameter != null) {
    processFunctionTypeFormalParameter(
      context,
      parameter.declaringTypeName,
      functionTypedParameter,
      EmitParameterContext.methodOrFunctionParameter,
      sink,
    );

    if (functionTypedParameter.question == null &&
        parameter.requirability == ParameterRequirability.forciblyOptional) {
      sink.write('?');
    }
  } else {
    processTypeAnnotation(
      context,
      parameter.declaringTypeName,
      parameter.typeAnnotation!,
      sink,
    );

    if (parameter.type.nullabilitySuffix != NullabilitySuffix.question &&
        parameter.requirability == ParameterRequirability.forciblyOptional) {
      sink.write('?');
    }

    sink
      ..write(' ')
      ..write(parameter.name);
  }

  if (parameter.hasDefaultValue) {
    sink
      ..write(' = ')
      ..write(parameter.defaultValue);
  }

  return sink.toString();
}

/// Emits default value of function typed parameter which require static method
/// declaration. This method actually emits such (non-public) method decaration.
Iterable<String> _emitFunctionDefaults(
  Iterable<PropertyAndFormFieldDefinition> properties,
) sync* {
  for (final entry in properties
      .expand((p) => p.formFieldConstructors)
      .expand((c) => c.argumentsHandler.callerSuppliableParameters)
      .where((p) => p.defaultTargetNonPublicMethod != null)
      .groupFoldBy((p) => p.defaultValue, (previous, element) {
    assert(
      previous == null ||
          (previous is ParameterInfo &&
              previous.defaultValue == element.defaultValue),
    );
    return element;
  }).entries) {
    final method = entry.value.defaultTargetNonPublicMethod!;
    yield '';
    yield '  static ${method.returnType} ${entry.key}(${method.parameters.parameters.join(', ')}) ${method.body}';
  }
}
