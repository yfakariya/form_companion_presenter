// See LICENCE file in the root.

part of '../parser.dart';

// Defines helper constructs.

bool _isPropertyDescriptorsBuilder(DartType? type) =>
    type!.getDisplayString(withNullability: false) == pdbTypeName;

DartType? _getVariableType(VariableDeclarationStatement statement) {
  // Use initializer's type instead of variables.type
  // because variables.type only be set when the variable was
  // declared explicitly typed like 'int i' instead of 'var i' or 'final i',
  // and most sources do not use explicitly typed variable declration.
  for (final variable
      in statement.variables.variables.where((v) => v.initializer != null)) {
    return variable.initializer!.staticType;
  }

  // without any initializers.
  return null;
}

ClassElement? _getTargetClass(MethodInvocation method) =>
    method.realTarget?.staticType?.element as ClassElement?;
