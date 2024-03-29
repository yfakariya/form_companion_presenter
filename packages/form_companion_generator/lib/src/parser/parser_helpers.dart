// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

import '../utilities.dart';

/// Determines that whether a specified [DartType] represents
/// `PropertyDescriptorsBuilder` class.
bool isPropertyDescriptorsBuilder(DartType? type) =>
    type?.getDisplayString(withNullability: false) == pdbTypeName;

/// Look-ups method invocation target class including extension method.
///
/// [callerElement] is the [Element] which contains [method], which has scope
/// to resolve extension method.
InterfaceElement? lookupTargetClass(
  Element callerElement,
  MethodInvocation method,
) {
  final target = method.realTarget?.staticType?.element as ClassElement?;
  if (target != null) {
    return target;
  }

  // For extension -> instance method pattern
  final callerType =
      callerElement.thisOrAncestorOfType<ExtensionElement>()?.extendedType;
  if (callerType is InterfaceType) {
    return callerType.element;
  } else {
    return null;
  }
}

/// Lookups [ExecutableElement] of [targetClass].[methodName] method.
///
/// If [targetClass] is `null`, this function lookups as top-level function.
///
/// This function also resolves extension method.
ExecutableElement lookupMethod(
  Element contextElement,
  InterfaceElement? targetClass,
  String methodName,
  AstNode invocation,
) {
  final found =
      targetClass?.lookUpMethod(methodName, contextElement.library!) ??
          contextElement.library!.accessibleExtensions
              .where((x) => x.extendedType == targetClass?.thisType)
              .expand<MethodElement?>((x) => x.methods)
              .firstWhere(
                (m) => m?.name == methodName,
                orElse: () => null,
              ) ??
          contextElement.library!.scope.lookup(methodName).getter
              as ExecutableElement?;

  assert(
    found != null,
    // coverage:ignore-start
    "Failed to lookup method or function '$invocation' in context of "
    '${contextElement.library} at ${getNodeLocation(invocation, contextElement)}.',
    // coverage:ignore-end
  );

  return found!;
}
