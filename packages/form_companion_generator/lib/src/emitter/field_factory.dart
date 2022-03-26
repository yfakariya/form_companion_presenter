// See LICENCE file in the root.

part of '../emitter.dart';

const _presenterField = '_presenter';

/// Emits field factories and their holders.
@visibleForTesting
Future<String> emitFieldFactoriesAsync(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  Config config,
) async {
  Iterable<String> emitLines(
    Iterable<PropertyAndFormFieldDefinition> properties,
  ) sync* {
    // Note: async generator keeps the order.

    for (final lines in properties.map((p) => emitFieldFactory(
          nodeProvider,
          data,
          p,
        ))) {
      yield* lines;
    }
  }

  return '''
class \$${data.name}FieldFactories {
  final ${data.name} $_presenterField;

  \$${data.name}FieldFactories._(this.$_presenterField);
${data.properties.isEmpty ? '\n  // No properties were found.' : (emitLines(data.properties)).join('\n')}
}

extension \$${data.name}FieldFactoryExtension on ${data.name} {
  /// Gets a form field factories.
  \$${data.name}FieldFactories get fields => \$${data.name}FieldFactories._(this);
}
''';
}

/// Emits a field factory method lines.
@visibleForTesting
Iterable<String> emitFieldFactory(
  NodeProvider nodeProvider,
  PresenterDefinition data,
  PropertyAndFormFieldDefinition property,
) sync* {
  // For newline before lines.
  yield '';

  final formFieldConstructor = property.formFieldConstructor;
  final instantiationContext = property.instantiationContext;
  if (instantiationContext == null || formFieldConstructor == null) {
    // We cannot handle this pattern.
    yield "  // $_todoHeader ERROR - Cannot generate field factory for '${property.name}' "
        "property, because FormField type '${property.formFieldTypeName}' is unknown.";
    return;
  }

  final argumentHandler = property.argumentsHandler!;

  for (final warning in property.warnings) {
    yield '  // $_todoHeader WARNING - $warning';
  }

  final sink = StringBuffer();
  processTypeWithValueType(
    instantiationContext,
    property.formFieldType!,
    sink,
  );
  final formFieldType = sink.toString();

  yield '  /// Gets a [FormField] for ${property.name} property.';
  yield '  $formFieldType ${property.name}(';
  yield '    BuildContext context, {';
  for (final parameter in argumentHandler.callerSuppliableParameters) {
    yield '    ${emitParameter(instantiationContext, parameter)},';
  }
  yield '  }) {';
  yield '    final property = $_presenterField.${property.name};';
  yield '    return $formFieldType(';
  yield* argumentHandler.emitAssignments(
    data: data,
    buildContext: 'context',
    presenter: _presenterField,
    propertyDescriptor: 'property',
    indent: '      ',
  );
  yield '    );';
  yield '  }';
}

/// Emits specified parameter information with type argument.
@visibleForTesting
String emitParameter(
  TypeInstantiationContext context,
  ParameterInfo parameter,
) {
  final sink = StringBuffer();

  if (parameter.requirability == ParameterRequirability.required) {
    sink.write('required ');
  }

  final functionTypedParameter = parameter.functionTypedParameter;

  if (functionTypedParameter != null) {
    processFunctionTypeFormalParameter(
      context,
      functionTypedParameter,
      sink,
      forParameterSignature: true,
    );

    if (functionTypedParameter.question == null &&
        parameter.requirability == ParameterRequirability.forciblyOptional) {
      sink.write('?');
    }
  } else {
    // This method is partially a clone of a processFormalParameter function
    // in instantiation.dart, but this block have ParameterRequirability.forciblyOptional
    // between type emit and name emit.

    processTypeAnnotation(
      context,
      parameter.typeAnnotation,
      parameter.type,
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
