// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:source_gen/source_gen.dart';

// Defines utilities.

/// A method name of `initializeCompanionMixin`.
const initializeCompanionMixinMethodName = 'initializeCompanionMixin';

/// A type name of `PropertyDescriptorsBuilder`.
const pdbTypeName = 'PropertyDescriptorsBuilder';

/// Defines extensions for [Iterable] of [Future].
extension FutureIterableExtensions<T> on Iterable<Future<T>> {
  /// Awaits each element of specified [Iterable] and returns as list asynchronously.
  /// This function is different from [Stream.fromFutures] in point of guarantee
  /// of source orders. This ensures returned items order are same as this.
  Future<List<T>> toListAsync() async {
    final result = <T>[];
    for (final item in this) {
      result.add(await item);
    }

    return result;
  }
}

/// Defines extensions for [Iterable] of [FutureOr].
extension FutureOrIterableExtensions<T> on Iterable<FutureOr<T>> {
  /// Awaits each element of specified [Iterable] and returns as list asynchronously.
  /// This function is different from [Stream.fromFutures] in point of guarantee
  /// of source orders. This ensures returned items order are same as this.
  FutureOr<List<T>> toListAsync() async {
    final result = <T>[];
    for (final item in this) {
      result.add(await item);
    }

    return result;
  }
}

/// Throws [InvalidGenerationSourceError].
Never throwError({
  required String message,
  String? todo,
  Element? element,
}) =>
    todo == null
        ? throw InvalidGenerationSourceError(message, element: element)
        : throw InvalidGenerationSourceError(
            message,
            element: element,
            todo: todo,
          );

/// Throws [InvalidGenerationSourceError] which says like "this syntax is not supported yet.".
Never throwNotSupportedYet({
  required AstNode node,
  Element? element,
  required Element contextElement,
}) =>
    throwError(
      message: element == null
          ? "Failed to parse complex source code '$node' (${node.runtimeType}) at ${getNodeLocation(node, contextElement)}."
          : "Failed to parse complex source code '$node' (${node.runtimeType}) for element '$element' (${element.runtimeType}) at ${getNodeLocation(node, contextElement)}.",
      todo:
          'Avoid using this expression or statement here, or file the issue for this message if you truly want to use this code.',
      element: contextElement,
    );

/// Gets stringified node location for diagnostics to specified [node].
/// [contextElement] is [Element] for [AstNode] which should declare [node].
String? getNodeLocation(AstNode node, Element contextElement) {
  final library = contextElement.library;
  if (library == null) {
    return '(unknown):(unknown)';
  }

  final libraryResult =
      contextElement.session?.getParsedLibraryByElement(library);
  if (libraryResult is! ParsedLibraryResult) {
    return '(unknown):(unknown)';
  }

  final unit = libraryResult
      .getElementDeclaration(contextElement.nonSynthetic)
      ?.parsedUnit;

  return '${unit?.path ?? '(unknown)'}:${unit?.lineInfo.getLocation(node.offset) ?? '(unknown)'}';
}

/// Determines that whether [type] is collection type in context of [element].
bool isCollectionType(DartType type, Element element) {
  final library = element.library;
  if (library == null) {
    // maybe Never, etc.
    return false;
  }

  return library.typeSystem.isAssignableTo(
    library.typeSystem.promoteToNonNull(type),
    library.typeProvider.iterableDynamicType,
  );
}

/// Determines that whether [type] is enum type in context of [element].
bool isEnumType(DartType type, Element element) {
  final library = element.library;
  if (library == null) {
    // maybe Never, etc.
    return false;
  }

  return library.typeSystem.isAssignableTo(
    library.typeSystem.promoteToNonNull(type),
    library.typeProvider.enumType!,
  );
}

/// Returns [DartType] when the [type] is collection type in context of [element].
/// This function returns `null` for non-collection [type].
DartType? getCollectionElementType(DartType type, Element element) {
  if (type is! InterfaceType || !isCollectionType(type, element)) {
    return null;
  }

  final library = element.library!;
  if (type.element == library.typeProvider.iterableElement) {
    return type.typeArguments.single;
  }

  for (final superClass in type.allSupertypes) {
    final found = getCollectionElementType(superClass, element);
    if (found != null) {
      return found;
    }
  }

  return null;
}

class _CodePoint {
  static const underScore = 0x5F;
  static const asciiUpperA = 0x41;
  static const asciiUpperZ = 0x5A;
}

/// Determines that whether specified identifier may be type name or not.
bool isTypeName(String mayBeTypeName) {
  final codePoint = (mayBeTypeName.length > 1 &&
          mayBeTypeName.codeUnitAt(0) == _CodePoint.underScore)
      ? mayBeTypeName.codeUnitAt(1)
      : mayBeTypeName.codeUnitAt(0);
  return codePoint >= _CodePoint.asciiUpperA &&
      codePoint <= _CodePoint.asciiUpperZ;
}

/// Determines that whether [type] has any uninsitantiated generic type parameters.
bool isInstantiated(DartType type) =>
    type is! TypeParameterType &&
    (type is! ParameterizedType || type.typeArguments.every(isInstantiated));
