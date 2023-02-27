// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';

import '../type_instantiation.dart';

// TODO'yfakariya): generic type instantiation should be handled in parser instead of emitter.

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
  String contextTypeName,
  Iterable<T>? arguments,
  void Function(TypeInstantiationContext, String, T, StringSink) processor,
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

    processor(context, contextTypeName, argument, sink);
  }

  sink.write('>');
}

void _processTypeArgumentAnnotations(
  TypeInstantiationContext context,
  String contextTypeName,
  Iterable<TypeAnnotation> typeArguments,
  StringSink sink,
) =>
    _processTypeArgumentKinds(
      context,
      contextTypeName,
      typeArguments,
      processTypeAnnotation,
      sink,
    );

void _processTypeParameters(
  TypeInstantiationContext context,
  String contextTypeName,
  Iterable<TypeParameter>? parameters,
  StringSink sink,
) =>
    _processTypeArgumentKinds(
      context,
      contextTypeName,
      parameters,
      _processTypeParameter,
      sink,
    );

void _processTypeParameter(
  TypeInstantiationContext context,
  String contextTypeName,
  TypeParameter parameter,
  StringSink sink,
) {
  sink.write(context.getMappedType(contextTypeName, parameter.name.lexeme));
}

void _processTypeArguments(
  TypeInstantiationContext context,
  String contextTypeName,
  Iterable<DartType> typeArguments,
  StringSink sink,
) =>
    _processTypeArgumentKinds(
      context,
      contextTypeName,
      typeArguments,
      processTypeWithValueType,
      sink,
    );

void _processTypeArgumentElement(
  TypeInstantiationContext context,
  String contextTypeName,
  TypeParameterElement element,
  StringSink sink,
) {
  // A type parameter should never be imported,
  // so we do not call context.recordUsedXxx() here.
  sink.write(
    context.getMappedType(
      contextTypeName,
      element.name,
    ),
  );
}

void _processGenericFunctionType(
  TypeInstantiationContext context,
  String contextTypeName,
  GenericFunctionType type,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  processTypeAnnotation(
    context,
    contextTypeName,
    type.returnType!,
    sink,
  );
  sink.write(' Function');

  if (type.typeParameters?.typeParameters
          .any((t) => !context.isMapped(contextTypeName, t.name.lexeme)) ??
      false) {
    _processTypeParameters(
      context,
      contextTypeName,
      type.typeParameters?.typeParameters,
      sink,
    );
  }

  _processGenericFunctionTypeFormalParameters(
    context,
    contextTypeName,
    type.parameters.parameters,
    emitParameterContext,
    sink,
  );
  _processAnnotationNullability(type, sink);
}

/// Processes spcifieid [FunctionTypedFormalParameter] and emits to [sink].
void processFunctionTypeFormalParameter(
  TypeInstantiationContext context,
  String contextTypeName,
  FunctionTypedFormalParameter parameter,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  processTypeAnnotation(
    context,
    contextTypeName,
    parameter.returnType!,
    sink,
  );
  sink
    ..write(' ')
    ..write(
      emitParameterContext == EmitParameterContext.methodOrFunctionParameter
          ? parameter.name.lexeme
          : 'Function',
    );
  _processTypeParameters(
    context,
    contextTypeName,
    parameter.typeParameters?.typeParameters,
    sink,
  );
  sink.write('(');
  for (final parameter in parameter.parameters.parameters) {
    _processGenericFunctionTypeFormalParameter(
      context,
      contextTypeName,
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
  String contextTypeName,
  FunctionType type,
  StringSink sink,
) {
  processTypeWithValueType(context, contextTypeName, type.returnType, sink);
  sink.write(' Function');

  if (type.typeFormals.any((t) => !context.isMapped(contextTypeName, t.name))) {
    _processTypeArgumentKinds(
      context,
      contextTypeName,
      type.typeFormals,
      _processTypeArgumentElement,
      sink,
    );
  }

  _processParameterElementsOfFunctionType(
    context,
    contextTypeName,
    type.parameters,
    sink,
  );

  _processTypeNullability(type, sink);
}

void _processParameterElementsOfFunctionType(
  TypeInstantiationContext context,
  String contextTypeName,
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

    processTypeWithValueType(context, contextTypeName, parameter.type, sink);

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
  String contextTypeName,
  TypeAnnotation parameterTypeAnnotation,
  StringSink sink,
) {
  final annotationType = parameterTypeAnnotation.type;
  if (annotationType is TypeParameterType) {
    final typeNameSink = StringBuffer();
    _processTypeArgumentElement(
      context,
      contextTypeName,
      annotationType.element,
      typeNameSink,
    );

    final typeName = typeNameSink.toString();
    sink.write(typeName);

    if (parameterTypeAnnotation.question != null && !typeName.endsWith('?')) {
      sink.write('?');
    }

    return;
  }

  if (parameterTypeAnnotation is NamedType) {
    final typeArguments = parameterTypeAnnotation.typeArguments;
    sink.write(parameterTypeAnnotation.name);

    if (typeArguments != null && typeArguments.arguments.isNotEmpty) {
      _processTypeArgumentAnnotations(
        context,
        contextTypeName,
        typeArguments.arguments,
        sink,
      );
    }

    _processAnnotationNullability(parameterTypeAnnotation, sink);
  } else {
    // TypeAnnotation in parameter always be NamedType or GenericFunctionType.
    _processGenericFunctionType(
      context,
      contextTypeName,
      parameterTypeAnnotation as GenericFunctionType,
      EmitParameterContext.functionTypeParameter,
      sink,
    );
  }
}

/// Processes a specified [DartType] and emits to [sink].
void processTypeWithValueType(
  TypeInstantiationContext context,
  String contextTypeName,
  DartType parameterType,
  StringSink sink,
) {
  if (parameterType is ParameterizedType) {
    sink.write(parameterType.element!.name);

    if (parameterType.typeArguments.isNotEmpty) {
      _processTypeArguments(
        context,
        contextTypeName,
        parameterType.typeArguments,
        sink,
      );
    }

    _processTypeNullability(parameterType, sink);
    return;
  }

  if (parameterType is TypeParameterType) {
    sink.write(
      context.getMappedType(
        contextTypeName,
        parameterType.getDisplayString(withNullability: false),
      ),
    );

    _processTypeNullability(parameterType, sink);
    return;
  }

  if (parameterType is FunctionType) {
    final alias = parameterType.alias;
    if (alias != null) {
      _processFunctionAliasType(
        context,
        contextTypeName,
        alias,
        parameterType,
        sink,
      );
    } else {
      _processFunctionType(context, contextTypeName, parameterType, sink);
    }

    return;
  }

  // NeverType, DynamicType, and VoidType.
  sink.write(parameterType.getDisplayString(withNullability: true));
}

void _processFunctionAliasType(
  TypeInstantiationContext context,
  String contextTypeName,
  InstantiatedTypeAliasElement alias,
  FunctionType parameterType,
  StringSink sink,
) {
  sink.write(alias.element.name);
  _processTypeArguments(context, contextTypeName, alias.typeArguments, sink);
  _processTypeNullability(parameterType, sink);
}

/// Processes a specified collection of [FormalParameter] and emits them with
/// preceding and trailing punctuations.
///
/// This function also handles braces of named and optional parameters.
void _processGenericFunctionTypeFormalParameters(
  TypeInstantiationContext context,
  String contextTypeName,
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
      contextTypeName,
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
  String contextTypeName,
  FormalParameter parameter,
  EmitParameterContext emitParameterContext,
  StringSink sink,
) {
  if (parameter is DefaultFormalParameter) {
    _processGenericFunctionTypeNormalFormalParameter(
      context,
      contextTypeName,
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
    contextTypeName,
    parameter as NormalFormalParameter,
    emitParameterContext,
    sink,
  );
}

void _processGenericFunctionTypeNormalFormalParameter(
  TypeInstantiationContext context,
  String contextTypeName,
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
        contextTypeName,
        parameter.type!,
        sink,
      );

      if (parameter.name == null) {
        // Parameter of function type may not have identifier
        // such as 'Function(int, String)'.
        return;
      }

      sink.write(' ');
    }

    sink.write(parameter.name!.lexeme);
  }
}
