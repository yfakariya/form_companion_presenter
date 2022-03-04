// See LICENCE file in the root.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';

// Defines utilities.

/// A method name of `initializeCompanionMixin`.
const initializeCompanionMixinMethodName = 'initializeCompanionMixin';

/// A type name of `PropertyDescriptorsBuilder`.
const pdbTypeName = 'PropertyDescriptorsBuilder';

/// Throws [InvalidGenerationSourceError].
Never throwError({
  required String message,
  String? todo,
  required Element element,
}) =>
    todo == null
        ? throw InvalidGenerationSourceError(message, element: element)
        : throw InvalidGenerationSourceError(message,
            element: element, todo: todo);

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

  final unit = libraryResult.getElementDeclaration(contextElement)?.parsedUnit;

  return '${unit?.path ?? '(unknown)'}:${unit?.lineInfo.getLocation(node.offset) ?? '(unknown)'}';
}
