// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

import 'model.dart';
import 'node_provider.dart';
import 'parameter.dart';
import 'utilities.dart';

/// Represents context information for emitter functions.
@sealed
class AssignmentContext {
  /// [PresenterDefinition].
  final PresenterDefinition data;

  /// A name of a local variable storing `PropertyDescriptor<T>`, which holds
  /// validator, saved value, etc.
  final String propertyDescriptor;

  /// A name of a parameter typed `BuildContext` to access widget tree data.
  final String buildContext;

  /// A name of a field which stores presenter instance which provides key
  /// creation.
  final String presenter;

  String _parameterName = '';

  /// Gets a current parameter name.
  String get parameterName => _parameterName;

  /// Gets a current parameter type;
  late DartType parameterType;

  String? _defaultValue;

  /// Gets a default value of the assigned parameter.
  String? get defaultValue => _defaultValue;

  /// Initializes a new [AssignmentContext] instance.
  AssignmentContext({
    required this.data,
    required this.propertyDescriptor,
    required this.buildContext,
    required this.presenter,
  });

  /// Refresh instance for new parameter with specified informations.
  // ignore: avoid_returning_this
  AssignmentContext withParameter(
    String name,
    DartType type,
    String? defaultValue,
  ) {
    _parameterName = name;
    parameterType = type;
    _defaultValue = defaultValue;
    return this;
  }
}

/// Handles arguments for a constructor of form field
/// and a form field factory which wraps the constructor.
@sealed
class ArgumentsHandler {
  final bool _isFormBuilder;
  final List<ParameterInfo> _fieldConstructorParameters;

  /// Gets a collection of parameters which can be supplied by caller of the
  /// field factory method.
  Iterable<ParameterInfo> get callerSuppliableParameters sync* {
    for (final parameter in _fieldConstructorParameters) {
      if (_isIntrinsic(parameter)) {
        continue;
      }

      if (_mightMakeOmittable(parameter)) {
        if (parameter.requirability == ParameterRequirability.required) {
          yield ParameterInfo(
            parameter.node,
            parameter.name,
            parameter.type,
            parameter.typeAnnotation,
            parameter.functionTypedParameter,
            null,
            ParameterRequirability.forciblyOptional,
          );
          continue;
        }
        if (parameter.hasDefaultValue) {
          yield ParameterInfo(
            parameter.node,
            parameter.name,
            parameter.type,
            parameter.typeAnnotation,
            parameter.functionTypedParameter,
            null,
            ParameterRequirability.forciblyOptional,
          );
          continue;
        }
      }

      yield parameter;
    }
  }

  /// Gets a collection of all parameters of `FormField`'s constructor.
  Iterable<ParameterInfo> get allParameters => _fieldConstructorParameters;

  /// Initializes a new [ArgumentsHandler] instance.
  ArgumentsHandler._(
    this._fieldConstructorParameters, {
    required bool isFormBuilder,
  }) : _isFormBuilder = isFormBuilder;

  /// Creates a new [ArgumentsHandler] instance for specified [constructor].
  static FutureOr<ArgumentsHandler> createAsync(
    ConstructorDeclaration constructor,
    NodeProvider nodeProvider, {
    required bool isFormBuilder,
  }) async =>
      ArgumentsHandler._(
        await constructor.parameters.parameters
            .where((p) => !p.declaredElement!.hasDeprecated)
            .map((p) => ParameterInfo.fromNodeAsync(nodeProvider, p))
            .toListAsync(),
        isFormBuilder: isFormBuilder,
      );

  bool _isIntrinsic(ParameterInfo parameter) {
    if (_isFormBuilder) {
      return _intrinsicBuilderAssignmentEmitters.containsKey(parameter.name);
    } else {
      return _intrinsicVanillaAssignmentEmitters.containsKey(parameter.name);
    }
  }

  bool _mightMakeOmittable(ParameterInfo parameter) {
    if (_isFormBuilder) {
      return _factorySuppliedBuilderAssignmentEmitters
          .containsKey(parameter.name);
    } else {
      return _factorySuppliedVanillaAssignmentEmitters
          .containsKey(parameter.name);
    }
  }

  /// Emits assignment lines with specified data.
  ///
  /// [propertyDescriptor], [buildContext], and [presenter] parameters represent
  /// local variable or parameter names.
  Iterable<String> emitAssignments({
    required PresenterDefinition data,
    required String propertyDescriptor,
    required String buildContext,
    required String presenter,
    required String indent,
  }) sync* {
    final assignmentContext = AssignmentContext(
      data: data,
      propertyDescriptor: propertyDescriptor,
      buildContext: buildContext,
      presenter: presenter,
    );

    for (final parameter in allParameters) {
      late final Iterable<String>? Function(AssignmentContext) emitter;
      if (_isFormBuilder) {
        emitter = _intrinsicBuilderAssignmentEmitters[parameter.name] ??
            _factorySuppliedBuilderAssignmentEmitters[parameter.name] ??
            _defaultAssignmentEmitter;
      } else {
        emitter = _intrinsicVanillaAssignmentEmitters[parameter.name] ??
            _factorySuppliedVanillaAssignmentEmitters[parameter.name] ??
            _defaultAssignmentEmitter;
      }

      final contents = emitter(assignmentContext.withParameter(
        parameter.name,
        parameter.type,
        parameter.defaultValue,
      ));
      if (contents != null) {
        for (final content in contents) {
          if (content.isEmpty) {
            yield '';
          } else {
            yield '$indent$content';
          }
        }
      }
    }
  }
}

Iterable<String>? _assignAutovalidateMode(AssignmentContext context) =>
    context.data.fieldAutovalidateMode == null
        ? ['autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,']
        : [
            'autovalidateMode: autovalidateMode ?? ${context.data.fieldAutovalidateMode},'
          ];

Iterable<String>? _assignDecoration(AssignmentContext context) =>
    context.defaultValue == null
        ? [
            'decoration: decoration ?? InputDecoration(',
            '  labelText: ${context.propertyDescriptor}.name,',
            '),',
          ]
        : [
            'decoration: decoration ?? ${context.defaultValue}.copyWith(',
            '  labelText: ${context.propertyDescriptor}.name,',
            '),',
          ];

Iterable<String>? _assignInitialValue(AssignmentContext context) =>
    ['initialValue: ${_assignValueCore(context)},'];

Iterable<String>? _assignValue(AssignmentContext context) =>
    ['value: ${_assignValueCore(context)},'];

String _assignValueCore(AssignmentContext context) {
  final nullabilitySuffix =
      context.parameterType.nullabilitySuffix == NullabilitySuffix.none
          ? '!'
          : '';
  return "${context.propertyDescriptor}.getFieldValue(Localizations.maybeLocaleOf(${context.buildContext}) ?? const Locale('en', 'US'))$nullabilitySuffix";
}

Iterable<String>? _assignValidator(AssignmentContext context) => [
      'validator: ${context.propertyDescriptor}.getValidator(${context.buildContext}),'
    ];

Iterable<String>? _onChangedWorkaround(AssignmentContext _) =>
    ['onChanged: onChanged ?? (_) {}, // Tip: required to work correctly'];

final _intrinsicBuilderAssignmentEmitters =
    <String, Iterable<String>? Function(AssignmentContext)>{
  'initialValue': _assignInitialValue,
  'onSaved': (_) => [], // nop
  'name': (context) => ['name: ${context.propertyDescriptor}.name,'],
  'validator': _assignValidator,
  'value': _assignValue,
};

final _intrinsicVanillaAssignmentEmitters =
    <String, Iterable<String>? Function(AssignmentContext)>{
  'key': (context) => [
        'key: ${context.presenter}.getKey(${context.propertyDescriptor}.name, ${context.buildContext}),'
      ],
  'initialValue': _assignInitialValue,
  'onSaved': (context) => [
        "onSaved: (v) => ${context.propertyDescriptor}.setFieldValue(v, Localizations.maybeLocaleOf(${context.buildContext}) ?? const Locale('en', 'US')),"
      ],
  'validator': _assignValidator,
  'value': _assignValue,
};

final _factorySuppliedBuilderAssignmentEmitters =
    <String, Iterable<String>? Function(AssignmentContext)>{
  'autovalidateMode': _assignAutovalidateMode,
  'onChanged': _onChangedWorkaround,
  'decoration': _assignDecoration,
};

final _factorySuppliedVanillaAssignmentEmitters =
    <String, Iterable<String>? Function(AssignmentContext)>{
  'autovalidateMode': _assignAutovalidateMode,
  'onChanged': _onChangedWorkaround,
  'decoration': _assignDecoration,
};

Iterable<String>? _defaultAssignmentEmitter(AssignmentContext context) =>
    ['${context.parameterName}: ${context.parameterName},'];
