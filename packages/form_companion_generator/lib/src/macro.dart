// See LICENCE file in the root.

import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'config.dart';
import 'macro_keys.dart';

final _macroFinder = RegExp(r'#(?<Macro>[A-Z]+(_[A-Z]+)*)#');

/// Represents macro's context for current argument assignment.
@sealed
class ArgumentMacroContext {
  final Map<String, String> _contextValues;
  final NamedTemplates _namedTemplates;

  // ignore: use_late_for_private_fields_and_variables
  DartType? _parameterType;

  /// Expression for an argument typed `BuildContext`, which is supplied from
  /// form field factory's call site.
  String get buildContext => _contextValues[ContextValueKeys.buildContext]!;

  /// Expression for current "presenter" instance.
  /// The presenter should implement `CompanionPresenterMixin` and
  /// `FormCompanionMixin` (or its subtype).
  String get presenter => _contextValues[ContextValueKeys.presenter]!;

  /// Expression for a local variable which stores current `PropertyDescriptor<P, F>`.
  String get property => _contextValues[ContextValueKeys.property]!;

  /// Expression for an argument of current form field factory for currently assigning
  /// `FormField`'s constructor parameter.
  String get parameter => _contextValues[ContextValueKeys.argument]!;

  /// A type of current assigning constructor parameter.
  DartType get parameterType => _parameterType!;

  /// Initializes a new [ArgumentMacroContext] for current property's form field
  /// factory logic.
  ArgumentMacroContext({
    required String propertyName,
    required String propertyValueType,
    required String fieldValueType,
    required String property,
    required String buildContext,
    required String presenter,
    required String? autovalidateMode,
    required NamedTemplates namedTemplates,
    required String itemValue,
    required String? itemValueType,
    required String? itemValueString,
  })  : _contextValues = {
          ContextValueKeys.propertyName: propertyName,
          ContextValueKeys.propertyValueType: propertyValueType,
          ContextValueKeys.fieldValueType: fieldValueType,
          ContextValueKeys.property: property,
          ContextValueKeys.buildContext: buildContext,
          ContextValueKeys.presenter: presenter,
        },
        _namedTemplates = namedTemplates {
    _contextValues[ContextValueKeys.autoValidateMode] =
        autovalidateMode ?? 'AutovalidateMode.disabled';
    _contextValues[ContextValueKeys.itemValue] = itemValue;

    if (itemValueType != null) {
      _contextValues[ContextValueKeys.itemValueType] = itemValueType;
    }

    if (itemValueString != null) {
      _contextValues[ContextValueKeys.itemValueString] = itemValueString;
    }
  }

  /// Reset this context for newly assigning argument.
  // ignore: avoid_returning_this
  ArgumentMacroContext withArgument({
    required String argument,
    required DartType parameterType,
    required String? defaultValue,
  }) {
    _parameterType = parameterType;
    _contextValues[ContextValueKeys.argument] = argument;
    _contextValues[ContextValueKeys.parameterType] =
        parameterType.getDisplayString(withNullability: true);
    if (defaultValue != null) {
      _contextValues[ContextValueKeys.defaultValue] = defaultValue;
      _contextValues[ContextValueKeys.defaultValueCopyOrNew] =
          '$defaultValue.copyWith';
    } else {
      _contextValues.remove(ContextValueKeys.defaultValue);
      _contextValues[ContextValueKeys.defaultValueCopyOrNew] =
          parameterType.getDisplayString(withNullability: false);
    }

    return this;
  }

  /// Applies macro.
  ///
  /// [context] is context expression for exception message.
  @visibleForTesting
  static String applyMacro(
    String context,
    String input,
    String? Function(String) resolveMacro, {
    bool allowsUnresolved = false,
  }) {
    final buffer = StringBuffer();
    var last = 0;
    for (final match in _macroFinder.allMatches(input)) {
      if (match.start > 0) {
        buffer.write(input.substring(last, match.start));
      }

      final macroKey = match.namedGroup('Macro')!;

      final macroValue = resolveMacro(macroKey);
      if (macroValue == null) {
        if (!allowsUnresolved) {
          throw InvalidGenerationSourceError(
            'Unknown macro `#$macroKey#` in $context, position: ${match.start}.',
            todo: 'Revise template in the `build.yaml` file.',
          );
        } else {
          buffer.write(input.substring(match.start, match.end));
        }
      } else {
        buffer.write(macroValue);
      }
      last = match.end;
    }

    if (last < input.length) {
      buffer.write(input.substring(last));
    }

    return buffer.toString();
  }

  /// Resolves macros in [input].
  ///
  /// [context] is context expression for exception message.
  String resolve(
    String context,
    String input,
  ) =>
      applyMacro(
        context,
        applyMacro(
          context,
          input,
          (v) => _namedTemplates.get(v)?.value,
          allowsUnresolved: true,
        ),
        (k) => _contextValues[k],
      );
}

/// Extract macro keys from specified [value].
Iterable<String> extractMacroKeys(String value) =>
    _macroFinder.allMatches(value).map((m) => m.namedGroup('Macro')!);
