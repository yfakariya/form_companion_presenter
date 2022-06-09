// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import 'config.dart';
import 'macro.dart';
import 'model.dart';
import 'node_provider.dart';
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
  final PropertyDefinition _property;
  final bool _isFormBuilder;
  final String _formFieldType;
  final List<ParameterInfo> _fieldConstructorParameters;
  final ArgumentTemplates _templates;
  final NamedTemplates _namedTemplates;
  final String? _constantItemValues;
  final String? _itemValueType;

  /// Gets a collection of parameters which can be supplied by caller of the
  /// field factory method.
  Iterable<ParameterInfo> get callerSuppliableParameters sync* {
    for (final parameter in _fieldConstructorParameters) {
      if (_isIntrinsic(parameter)) {
        continue;
      }

      if (_mightMakeOmittable(parameter)) {
        if (parameter.requirability == ParameterRequirability.required ||
            parameter.hasDefaultValue) {
          yield parameter.asForciblyOptional();
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
    this._formFieldType,
    this._property,
    this._fieldConstructorParameters,
    this._templates,
    this._namedTemplates, {
    required bool isFormBuilder,
  })  : _isFormBuilder = isFormBuilder,
        _itemValueType = _tryGetItemValueType(_property),
        _constantItemValues = _tryGetConstantItemValues(_property);

  static String? _tryGetItemValueType(PropertyDefinition property) {
    final type = property.fieldType;
    if (type.isEnumType || type.isBoolType) {
      return type.getDisplayString(withNullability: true);
    } else {
      return type.collectionItemType?.getDisplayString(withNullability: true);
    }
  }

  static String? _tryGetConstantItemValues(PropertyDefinition property) {
    final type = property.fieldType;
    if (type.isEnumType) {
      final members = (type.rawType.element! as ClassElement)
          .fields
          .where((f) => f.type == type.rawType && f.isConst && f.isStatic)
          .map((f) =>
              '${f.type.getDisplayString(withNullability: false)}.${f.name}')
          .join(', ');
      return type.isNullable ? '[$members, null]' : '[$members]';
    } else if (type.isBoolType) {
      return type.isNullable ? '[true, false, null]' : '[true, false]';
    } else {
      return null;
    }
  }

  String? _tryGetItemValueAsStringExpression(
    PropertyDefinition property,
    String? itemValue,
  ) {
    if (_itemValueType == null) {
      return null;
    }

    final type = property.fieldType.collectionItemType ?? property.fieldType;
    if (type.isStringType) {
      return type.isNullable ? "$itemValue ?? ''" : itemValue;
    } else {
      return type.isNullable
          ? "$itemValue?.toString() ?? ''"
          : '$itemValue.toString()';
    }
  }

  /// Creates a new [ArgumentsHandler] instance for specified [constructor].
  static FutureOr<ArgumentsHandler> createAsync(
    ConstructorDeclaration constructor,
    PropertyDefinition property,
    NodeProvider nodeProvider,
    Config config, {
    required bool isFormBuilder,
  }) async =>
      ArgumentsHandler._(
        constructor.returnType.name,
        property,
        await constructor.parameters.parameters
            .where((p) => !p.declaredElement!.hasDeprecated)
            .map((p) => ParameterInfo.fromNodeAsync(nodeProvider, p))
            .toListAsync(),
        config.argumentTemplates,
        config.namedTemplates,
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
    if (!_templates.contains(_formFieldType, parameter.name)) {
      return false;
    }

    if (_templates.get(_formFieldType, parameter.name).itemTemplate != null &&
        _itemValueType == null) {
      // itemTemplate is specified for non-collection, non-enum, non-bool property/field type.
      return false;
    }

    return true;
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
    required String itemValue,
    required String indent,
    required Logger logger,
  }) sync* {
    final macroContext = ArgumentMacroContext(
      propertyName: _property.name,
      propertyValueType:
          _property.propertyType.getDisplayString(withNullability: true),
      fieldValueType:
          _property.fieldType.getDisplayString(withNullability: true),
      property: propertyDescriptor,
      buildContext: buildContext,
      presenter: presenter,
      autovalidateMode: data.fieldAutovalidateMode,
      namedTemplates: _namedTemplates,
      itemValue: itemValue,
      itemValueType: _itemValueType,
      itemValueString: _tryGetItemValueAsStringExpression(_property, itemValue),
    );

    Iterable<String> emitDefault(ArgumentMacroContext context) sync* {
      final template = _templates.get(_formFieldType, context.parameter);
      final itemTemplate = template.itemTemplate;
      final resolveContext =
          '${context.parameter} (${context.parameterType.getDisplayString(withNullability: true)})';
      if (itemTemplate != null) {
        if (_itemValueType == null) {
          logger.fine(
            'Use `template` instead of `item_template` because type of '
            '`${_property.name}` property of presenter `${data.name}` is not '
            'collection, enum, or bool type. '
            'The type is `${_property.fieldType.getDisplayString(withNullability: true)}`.',
          );
        } else {
          if (_constantItemValues != null) {
            yield* '${context.parameter}: $_constantItemValues.map(($itemValue) => '
                    '${context.resolve(resolveContext, itemTemplate)}).toList(),'
                .split(r'\r?\n');
          } else {
            yield* '${context.parameter}: ${_assignValueCore(context, ignoresNullability: true)}?.map(($itemValue) => '
                    '${context.resolve(resolveContext, itemTemplate)}).toList() ?? [],'
                .split(r'\r?\n');
          }

          return;
        }
      }

      yield* '${context.parameter}: ${context.resolve(resolveContext, template.value ?? '#ARGUMENT#')},'
          .split(r'\r?\n');
    }

    final intrinsicEmitters = _isFormBuilder
        ? _intrinsicBuilderAssignmentEmitters
        : _intrinsicVanillaAssignmentEmitters;
    for (final parameter in allParameters) {
      final emitter = intrinsicEmitters[parameter.name] ?? emitDefault;

      final contents = emitter(
        macroContext.withArgument(
          argument: parameter.name,
          parameterType: parameter.type,
          defaultValue: parameter.defaultValue,
        ),
      );
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

Iterable<String> _assignInitialValue(ArgumentMacroContext context) =>
    ['initialValue: ${_assignValueCore(context, ignoresNullability: false)},'];

Iterable<String> _assignValue(ArgumentMacroContext context) => [
      'value: ${_assignValueCore(
        context,
        ignoresNullability: false,
      )},'
    ];

String _assignValueCore(
  ArgumentMacroContext context, {
  required bool ignoresNullability,
}) {
  final nullabilitySuffix = (!ignoresNullability &&
          context.parameterType.nullabilitySuffix == NullabilitySuffix.none)
      ? '!'
      : '';
  return "${context.property}.getFieldValue(Localizations.maybeLocaleOf(${context.buildContext}) ?? const Locale('en', 'US'))$nullabilitySuffix";
}

Iterable<String> _assignValidator(ArgumentMacroContext context) =>
    ['validator: ${context.property}.getValidator(${context.buildContext}),'];

final _intrinsicBuilderAssignmentEmitters =
    <String, Iterable<String> Function(ArgumentMacroContext)>{
  'initialValue': _assignInitialValue,
  'onSaved': (_) => [], // nop
  'name': (context) => ['name: ${context.property}.name,'],
  'validator': _assignValidator,
  'value': _assignValue,
};

final _intrinsicVanillaAssignmentEmitters =
    <String, Iterable<String>? Function(ArgumentMacroContext)>{
  'key': (context) => [
        'key: ${context.presenter}.getKey(${context.property}.name, ${context.buildContext}),'
      ],
  'initialValue': _assignInitialValue,
  'onSaved': (context) => [
        "onSaved: (v) => ${context.property}.setFieldValue(v, Localizations.maybeLocaleOf(${context.buildContext}) ?? const Locale('en', 'US')),"
      ],
  'validator': _assignValidator,
  'value': _assignValue,
};
