// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import '../type_instantiation.dart';

// TODO(yfakariya): Refactoring (It looks there are a lot of dead code).

void _processTypeNullability(DartType type, StringSink sink) {
  if (type.nullabilitySuffix == NullabilitySuffix.question) {
    sink.write('?');
  }
}

void _processAnnotationNullability(TypeAnnotation type, StringSink sink) {
  if (type.question != null) {
    sink.write('?');
  }
}

void _processCollection<T>(
  TypeInstantiationContext context,
  Iterable<T>? arguments,
  void Function(TypeInstantiationContext, T, StringSink) processor,
  StringSink sink,
) {
  if (arguments == null || arguments.isEmpty) {
    return;
  }

  sink.write('<');

  var isFirst = true;
  for (final argument in arguments) {
    if (isFirst) {
      isFirst = false;
    } else {
      sink.write(', ');
    }

    processor(context, argument, sink);
  }

  sink.write('>');
}

void _processTypeArgumentAnnotations(
  TypeInstantiationContext context,
  Iterable<TypeAnnotation> typeArguments,
  StringSink sink,
) =>
    _processCollection(
      context,
      typeArguments,
      _processTypeAnnotation,
      sink,
    );

void _processTypeParameters(
  TypeInstantiationContext context,
  Iterable<TypeParameter>? parameters,
  StringSink sink,
) =>
    _processCollection(
      context,
      parameters,
      _processTypeParameter,
      sink,
    );

void _processTypeParameter(
  TypeInstantiationContext context,
  TypeParameter parameter,
  StringSink sink,
) {
  sink.write(context.getMappedType(parameter.name.name));
}

void _processTypeArguments(
  TypeInstantiationContext context,
  Iterable<DartType> typeArguments,
  StringSink sink,
) =>
    _processCollection(
      context,
      typeArguments,
      processTypeWithValueType,
      sink,
    );

void _processTypeArgumentElements(
  TypeInstantiationContext context,
  Iterable<TypeParameterElement> elements,
  StringSink sink,
) =>
    _processCollection(
      context,
      elements,
      _processTypeArgumentElement,
      sink,
    );

void _processTypeArgumentElement(
  TypeInstantiationContext context,
  TypeParameterElement element,
  StringSink sink,
) {
  // A type parameter should never be imported,
  // so we do not call context.recordUsedXxx() here.

  sink.write(context.getMappedType(element.name));
}

void _processGenericFunctionType(
  TypeInstantiationContext context,
  GenericFunctionType type,
  StringSink sink,
) {
  processTypeAnnotation(
    context,
    type.returnType,
    type.returnType!.type!,
    sink,
  );
  sink.write(' Function');
  _processTypeParameters(context, type.typeParameters?.typeParameters, sink);
  _processFormalParameters(
    context,
    type.parameters.parameters,
    sink,
    forParameterSignature: false,
  );
  _processAnnotationNullability(type, sink);
}

/// Processes spcifieid [FunctionTypedFormalParameter] and emits to [sink].
///
/// If [forParameterSignature] is `true`, the identifier of [FunctionTypedFormalParameter]
/// and its parameters will be emit to the output. Otherwise, these identifiers
/// will be omitted, that is, the output will be pure function type representation.
void processFunctionTypeFormalParameter(
  TypeInstantiationContext context,
  FunctionTypedFormalParameter parameter,
  StringSink sink, {
  required bool forParameterSignature,
}) {
  processTypeAnnotation(
    context,
    parameter.returnType,
    parameter.returnType!.type!,
    sink,
  );
  sink
    ..write(' ')
    ..write(forParameterSignature ? parameter.identifier.name : 'Function');
  _processTypeParameters(
    context,
    parameter.typeParameters?.typeParameters,
    sink,
  );
  sink.write('(');
  for (final parameter in parameter.parameters.parameters) {
    _processFormalParameter(
      context,
      parameter,
      sink,
      forParameterSignature: forParameterSignature,
    );
  }
  sink.write(')');
  if (parameter.question != null) {
    sink.write('?');
  }
}

void _processFunctionType(
  TypeInstantiationContext context,
  FunctionType type,
  StringSink sink,
) {
  processTypeWithValueType(context, type.returnType, sink);
  sink.write(' Function');
  _processTypeArgumentElements(context, type.typeFormals, sink);
  _processParameterElements(
    context,
    type.parameters,
    sink,
    isInFunctionType: true,
  );
  _processTypeNullability(type, sink);
}

/// Processes a specified [TypeAnnotation] and emits to [sink].
///
/// If [parameterTypeAnnotation] is `null`, this method fallbacks to
/// [processTypeWithValueType] with [parameterType].
void processTypeAnnotation(
  TypeInstantiationContext context,
  TypeAnnotation? parameterTypeAnnotation,
  DartType parameterType,
  StringSink sink,
) {
  if (parameterTypeAnnotation == null) {
    return processTypeWithValueType(context, parameterType, sink);
  } else {
    _processTypeAnnotation(
      context,
      parameterTypeAnnotation,
      sink,
    );
  }
}

void _processTypeAnnotation(
  TypeInstantiationContext context,
  TypeAnnotation parameterTypeAnnotation,
  StringSink sink,
) {
  final annotationType = parameterTypeAnnotation.type;
  if (annotationType is TypeParameterType) {
    _processTypeArgumentElement(
      context,
      annotationType.element,
      sink,
    );

    if (parameterTypeAnnotation.question != null) {
      sink.write('?');
    }

    return;
  }

  if (parameterTypeAnnotation is NamedType) {
    final typeArguments = parameterTypeAnnotation.typeArguments;
    sink.write(parameterTypeAnnotation.name);

    if (typeArguments != null && typeArguments.arguments.isNotEmpty) {
      _processTypeArgumentAnnotations(context, typeArguments.arguments, sink);
    }

    _processAnnotationNullability(parameterTypeAnnotation, sink);
  } else {
    assert(
      parameterTypeAnnotation is GenericFunctionType,
      '$parameterTypeAnnotation (${parameterTypeAnnotation.runtimeType}) is not GenericFunctionType.',
    );

    final asFuntionType = parameterTypeAnnotation as GenericFunctionType;
    final alias = asFuntionType.type?.alias;
    if (alias != null) {
      _processAliasedFunctionTypeAnnotation(
        context,
        context.getElementDeclaration<FunctionTypeAlias>(alias.element),
        asFuntionType.type! as FunctionType,
        sink,
      );
    } else {
      _processGenericFunctionType(context, asFuntionType, sink);
    }
  }
}

/// Processes a specified [DartType] and emits to [sink].
void processTypeWithValueType(
  TypeInstantiationContext context,
  DartType parameterType,
  StringSink sink,
) {
  if (parameterType is ParameterizedType) {
    sink.write(parameterType.element!.name);

    if (parameterType.typeArguments.isNotEmpty) {
      _processTypeArguments(context, parameterType.typeArguments, sink);
    }

    _processTypeNullability(parameterType, sink);
    return;
  }

  if (parameterType is TypeParameterType) {
    sink.write(
      context.getMappedType(
        parameterType.getDisplayString(withNullability: false),
      ),
    );

    _processTypeNullability(parameterType, sink);
    return;
  }

  if (parameterType is FunctionType) {
    final alias = parameterType.alias;
    if (alias != null) {
      _processFunctionAliasType(context, alias, parameterType, sink);
    } else {
      _processFunctionType(context, parameterType, sink);
    }

    return;
  }

  // NeverType, DynamicType, and VoidType.
  sink.write(parameterType.getDisplayString(withNullability: true));
}

void _processFunctionAliasType(
  TypeInstantiationContext context,
  InstantiatedTypeAliasElement alias,
  FunctionType parameterType,
  StringSink sink,
) {
  sink.write(alias.element.name);
  _processTypeArguments(context, alias.typeArguments, sink);
  _processTypeNullability(parameterType, sink);
}

void _processAliasedFunctionTypeAnnotation(
  TypeInstantiationContext context,
  FunctionTypeAlias alias,
  FunctionType type,
  StringSink sink,
) {
  sink.write(alias.name);
  _processTypeParameters(context, alias.typeParameters!.typeParameters, sink);
  _processTypeNullability(type, sink);
}

void _processParameterElements(
  TypeInstantiationContext context,
  Iterable<ParameterElement> parameters,
  StringSink sink, {
  bool isInFunctionType = false,
}) {
  sink.write('(');

  var isFirst = true;
  var isRequiredPositional = true;
  var isNamed = false;
  for (final parameter in parameters) {
    if (isFirst) {
      isFirst = false;
    } else {
      sink.write(', ');
    }

    if (!parameter.isRequiredPositional && isRequiredPositional) {
      isRequiredPositional = false;
      if (parameter.isNamed) {
        isNamed = true;
      }

      sink.write(isNamed ? '{' : '[');
    }

    processTypeWithValueType(context, parameter.type, sink);
    if (!isInFunctionType && parameter.name.isNotEmpty) {
      sink
        ..write(' ')
        ..write(parameter.name);
    }

    if (parameter.defaultValueCode != null) {
      sink
        ..write(' = ')
        ..write(parameter.defaultValueCode);
    }
  }

  if (!isRequiredPositional) {
    sink.write(isNamed ? '}' : ']');
  }

  sink.write(')');
}

/// Processes a specified collection of [FormalParameter] and emits them with
/// preceding and trailing punctuations.
///
/// This function also handles braces of named and optional parameters.
void _processFormalParameters(
  TypeInstantiationContext context,
  Iterable<FormalParameter> parameters,
  StringSink sink, {
  required bool forParameterSignature,
}) {
  sink.write('(');

  var isFirst = true;
  var isRequiredPositional = true;
  var isNamed = false;
  for (final parameter in parameters) {
    if (isFirst) {
      isFirst = false;
    } else {
      sink.write(', ');
    }

    if (!parameter.isRequiredPositional && isRequiredPositional) {
      isRequiredPositional = false;
      if (parameter.isNamed) {
        isNamed = true;
      } else {}

      sink.write(isNamed ? '{' : '[');
    }

    _processFormalParameter(
      context,
      parameter,
      sink,
      forParameterSignature: forParameterSignature,
    );
  }

  if (!isRequiredPositional) {
    sink.write(isNamed ? '}' : ']');
  }

  sink.write(')');
}

void _processFormalParameter(
  TypeInstantiationContext context,
  FormalParameter parameter,
  StringSink sink, {
  required bool forParameterSignature,
}) {
  if (parameter is DefaultFormalParameter) {
    _processNormalFormalParameter(
      context,
      parameter.parameter,
      sink,
      forParameterSignature: forParameterSignature,
    );
    sink
      ..write(' = ')
      ..write(parameter.defaultValue);
    return;
  }

  assert(parameter is NormalFormalParameter);
  _processNormalFormalParameter(
    context,
    parameter as NormalFormalParameter,
    sink,
    forParameterSignature: forParameterSignature,
  );
}

void _processNormalFormalParameter(
  TypeInstantiationContext context,
  NormalFormalParameter parameter,
  StringSink sink, {
  required bool forParameterSignature,
}) {
  if (parameter is SimpleFormalParameter) {
    if (parameter.keyword != null) {
      sink
        ..write(parameter.keyword)
        ..write(' ');
    }

    if (parameter.type != null) {
      processTypeAnnotation(
        context,
        parameter.type,
        parameter.type!.type!,
        sink,
      );

      if (parameter.identifier == null || !forParameterSignature) {
        // Parameter of function type does not have identifier
        // such as 'Function(int, String)'.
        return;
      }

      sink.write(' ');
    }

    sink.write(parameter.identifier!.name);
    return;
  }

  if (parameter is FunctionTypedFormalParameter) {
    processFunctionTypeFormalParameter(
      context,
      parameter,
      sink,
      forParameterSignature: false,
    );
    return;
  }

  void processFieldOrSuperFormalParameter(
    TypeInstantiationContext context,
    Token? keyword,
    TypeAnnotation? type,
    String prefix,
    SimpleIdentifier identifier,
    StringSink sink,
  ) {
    if (keyword != null) {
      sink
        ..write(keyword.toString())
        ..write(' ');
    }

    if (type != null) {
      processTypeAnnotation(
        context,
        type,
        type.type!,
        sink,
      );
      sink.write(' ');
    }

    sink
      ..write(prefix)
      ..write('.')
      ..write(identifier);
  }

  if (parameter is FieldFormalParameter) {
    processFieldOrSuperFormalParameter(
      context,
      parameter.keyword,
      parameter.type,
      'this',
      parameter.identifier,
      sink,
    );
    return;
  }

  if (parameter is SuperFormalParameter) {
    processFieldOrSuperFormalParameter(
      context,
      parameter.keyword,
      parameter.type,
      'super',
      parameter.identifier,
      sink,
    );
    return;
  }
}
