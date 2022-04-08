// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import '../type_instantiation.dart';

/// Represents context when the parameter is emitted.
enum EmitParameterContext {
  /// Parameter is normal, formal parameter of
  /// declared method or function signature.
  methodOrFunctionParameter,

  /// Parameter is in formal parameter list of another function type.
  /// Names will be omitted except for named parameters, and default values
  /// should be omitted because noone can specify them.
  functionTypeParameter,
}

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

void _processTypeArgumentKinds<T>(
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
    _processTypeArgumentKinds(
      context,
      typeArguments,
      processTypeAnnotation,
      sink,
    );

void _processTypeParameters(
  TypeInstantiationContext context,
  Iterable<TypeParameter>? parameters,
  StringSink sink,
) =>
    _processTypeArgumentKinds(
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
    _processTypeArgumentKinds(
      context,
      typeArguments,
      processTypeWithValueType,
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
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  processTypeAnnotation(
    context,
    type.returnType!,
    sink,
  );
  sink.write(' Function');

  if (type.typeParameters?.typeParameters
          .any((t) => !context.isMapped(t.name.name)) ??
      false) {
    _processTypeParameters(context, type.typeParameters?.typeParameters, sink);
  }

  _processGenericFunctionTypeFormalParameters(
    context,
    type.parameters.parameters,
    emitParameterContext,
    sink,
  );
  _processAnnotationNullability(type, sink);
}

/// Processes spcifieid [FunctionTypedFormalParameter] and emits to [sink].
void processFunctionTypeFormalParameter(
  TypeInstantiationContext context,
  FunctionTypedFormalParameter parameter,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  processTypeAnnotation(
    context,
    parameter.returnType!,
    sink,
  );
  sink
    ..write(' ')
    ..write(
        emitParameterContext == EmitParameterContext.methodOrFunctionParameter
            ? parameter.identifier.name
            : 'Function');
  _processTypeParameters(
    context,
    parameter.typeParameters?.typeParameters,
    sink,
  );
  sink.write('(');
  for (final parameter in parameter.parameters.parameters) {
    _processGenericFunctionTypeFormalParameter(
      context,
      parameter,
      emitParameterContext,
      sink,
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

  if (type.typeFormals.any((t) => !context.isMapped(t.name))) {
    _processTypeArgumentKinds(
      context,
      type.typeFormals,
      _processTypeArgumentElement,
      sink,
    );
  }

  _processParameterElementsOfFunctionType(
    context,
    type.parameters,
    sink,
  );

  _processTypeNullability(type, sink);
}

void _processParameterElementsOfFunctionType(
  TypeInstantiationContext context,
  Iterable<ParameterElement> parameters,
  StringSink sink,
) {
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

    if (parameter.isRequiredNamed) {
      sink.write('required ');
    }

    processTypeWithValueType(context, parameter.type, sink);

    // This function should not emit parameter names without named parameters.
    if (parameter.isNamed) {
      sink
        ..write(' ')
        ..write(parameter.name);
    }

    // NOTE: Parameter in function type signature never have default value.
  }

  if (!isRequiredPositional) {
    sink.write(isNamed ? '}' : ']');
  }

  sink.write(')');
}

/// Processes a specified [TypeAnnotation] and emits to [sink].
void processTypeAnnotation(
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
    // TypeAnnotation in parameter always be NamedType or GenericFunctionType.
    _processGenericFunctionType(
      context,
      parameterTypeAnnotation as GenericFunctionType,
      EmitParameterContext.functionTypeParameter,
      sink,
    );
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

/// Processes a specified collection of [FormalParameter] and emits them with
/// preceding and trailing punctuations.
///
/// This function also handles braces of named and optional parameters.
void _processGenericFunctionTypeFormalParameters(
  TypeInstantiationContext context,
  Iterable<FormalParameter> parameters,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
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

    _processGenericFunctionTypeFormalParameter(
      context,
      parameter,
      emitParameterContext,
      sink,
    );
  }

  if (!isRequiredPositional) {
    sink.write(isNamed ? '}' : ']');
  }

  sink.write(')');
}

void _processGenericFunctionTypeFormalParameter(
  TypeInstantiationContext context,
  FormalParameter parameter,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  if (parameter is DefaultFormalParameter) {
    _processGenericFunctionTypeNormalFormalParameter(
      context,
      parameter.parameter,
      emitParameterContext,
      sink,
    );

    // NOTE: defaultValue should be emitted only if the formal parameter
    //       is in declared method or function parameter list, not in formal
    //       parameter list of function type.
    return;
  }

  // Formal parameter in function type signature never be FieldFormalParameter
  // nor SuperFormalParameter, so parameter is always NormalFormalParameter here.
  _processGenericFunctionTypeNormalFormalParameter(
    context,
    parameter as NormalFormalParameter,
    emitParameterContext,
    sink,
  );
}

void _processGenericFunctionTypeNormalFormalParameter(
  TypeInstantiationContext context,
  NormalFormalParameter parameter,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  // NOTE: FieldFormalParameter or SuperFormalParameter never appear in
  //       formal parameter list of generic function type.
  //       In addition, "nested" function type parameter in function type's
  //       formal parameter list never becomes FunctionTypedFormalParameter
  //       because they must be represented as
  //       `R Function(...) p` (SimpleFormalParameter with function type)
  //       instead of `R p(...)` (FunctionTypedFormalParameter).

  if (parameter is SimpleFormalParameter) {
    // NOTE: Function type's formal parameter cannot have keyword like `final`.
    //       So, omit keyword emit here, but requiredKeyword is required.
    if (parameter.requiredKeyword != null) {
      sink.write('required ');
    }

    if (parameter.type != null) {
      processTypeAnnotation(
        context,
        parameter.type!,
        sink,
      );

      if (parameter.identifier == null) {
        // Parameter of function type may not have identifier
        // such as 'Function(int, String)'.
        return;
      }

      sink.write(' ');
    }

    sink.write(parameter.identifier!.name);
  }
}
