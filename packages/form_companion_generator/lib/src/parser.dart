// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'dependency.dart';
import 'form_field_locator.dart';
import 'model.dart';
import 'node_provider.dart';
import 'parser_data.dart';
import 'parser_node.dart';
import 'type_instantiation.dart';
import 'utilities.dart';

part 'parser/assignment.dart';
part 'parser/expression.dart';
part 'parser/form_field.dart';
part 'parser/helpers.dart';
part 'parser/identifier.dart';
part 'parser/invocation_analysis.dart';
part 'parser/presenter_constructor.dart';
part 'parser/statement.dart';

/// Parses specified [ClassElement] of the presenter.
FutureOr<PresenterDefinition> parseElementAsync(
  NodeProvider nodeProvider,
  FormFieldLocator formFieldLocator,
  ClassElement element,
  FormCompanionAnnotation annotation,
  Logger logger,
) async {
  final constructor = findConstructor(element);

  final mixinType = detectMixinType(element);
  if (mixinType == null) {
    throw InvalidGenerationSourceError(
      'A target of @formCompanion must be mix-ined with the either of FormCompanionPresenterMixin or FormBuilderPresenterMixin. Class name: ${element.name}',
      element: element,
    );
  }

  final isFormBuilder = mixinType == MixinType.formBuilderCompanionMixin;
  final warnings = <String>[];
  final properties = await getPropertiesAsync(
    nodeProvider,
    formFieldLocator,
    constructor,
    warnings,
    logger,
    isFormBuilder: isFormBuilder,
  );

  return PresenterDefinition(
    name: element.name,
    isFormBuilder: isFormBuilder,
    doAutovalidate: annotation.autovalidate,
    warnings: warnings,
    imports: await collectDependenciesAsync(
      element.library,
      properties.values,
      nodeProvider,
      logger,
    ),
    properties: properties,
  );
}

/// Detects mixin type of the presenter
/// from specified [ClassElement] of the presenter.
@visibleForTesting
MixinType? detectMixinType(ClassElement classElement) {
  final isFormCompanion = classElement.mixins.any(
    (element) =>
        element.getDisplayString(withNullability: false) ==
        'FormCompanionMixin',
  );
  final isFormBuilderCompanion = classElement.mixins.any(
    (element) =>
        element.getDisplayString(withNullability: false) ==
        'FormBuilderCompanionMixin',
  );

  if (isFormCompanion && isFormBuilderCompanion) {
    throwError(
      message:
          'Both of FormCompanionMixin and FormBuilderCompanionMixin cannot be specified together. Class: ${classElement.name}',
      todo:
          'Specify either of FormCompanionMixin or FormBuilderCompanionMixin.',
      element: classElement,
    );
  }

  if (isFormCompanion) {
    return MixinType.formCompanionMixin;
  } else if (isFormBuilderCompanion) {
    return MixinType.formBuilderCompanionMixin;
  } else {
    return null;
  }
}

/// Find an appropriate [ConstructorElement] from specified [ClassElement] of
/// the presenter.
/// The returned constructor must be non factory, unique anonymous constructor,
/// which should call `initializeCompanionMixin`.
///
/// If such constructors are declared multiply, or are not declared at all,
/// an [InvalidGenerationSourceError] will be thrown.
@visibleForTesting
ConstructorElement findConstructor(
  ClassElement classElement,
) {
  final nonRedirectedConstructors = classElement.constructors
      .where(
        (ctor) =>
            !ctor.isFactory &&
            // Not a implicit default constructor -- it never has initializeCompanionMixin call.
            !ctor.isSynthetic &&
            // Filter out constructors which only redirect to another one -- they never have initializeCompanionMixin call.
            ctor.redirectedConstructor == null,
      )
      .toList();

  if (nonRedirectedConstructors.isEmpty) {
    throw InvalidGenerationSourceError(
      'No constructors which have their body are found. Class name: ${classElement.name}',
      todo:
          'Modify to ensure only one constructor has body and others are redirected constructors or factories.',
      element: classElement,
    );
  }

  if (nonRedirectedConstructors.length > 1) {
    throw InvalidGenerationSourceError(
      'This generator only supports presenter class which has only one constructor which has body. '
      'Class name: ${classElement.name}, found constructors: [${nonRedirectedConstructors.map((c) => c.name).join(', ')}]',
      todo:
          'Modify to ensure only one constructor has body and others are redirected constructors or factories.',
      element: classElement,
    );
  }

  return nonRedirectedConstructors.single;
}

/// Extracts unorderd map of [PropertyDefinition] where keys are names of the
/// properties from specified presenter's [ConstructorElement].
///
/// If any global warnings is issued, the message will be added to [globalWarnings].
@visibleForTesting
FutureOr<Map<String, PropertyAndFormFieldDefinition>> getPropertiesAsync(
  NodeProvider nodeProvider,
  FormFieldLocator formFieldLocator,
  ConstructorElement constructor,
  List<String> globalWarnings,
  Logger logger, {
  required bool isFormBuilder,
}) async {
  final context = ParseContext(
    logger,
    nodeProvider,
    formFieldLocator,
    constructor.library.typeProvider,
    constructor.library.typeSystem,
    globalWarnings,
  );
  final ast = await context.nodeProvider
      .getElementDeclarationAsync<ConstructorDeclaration>(constructor);

  final pdbArgument =
      await _detectArgumentOfLastInitializeCompanionMixinInvocationAsync(
    context,
    ast,
    constructor,
  );

  logger.fine(
    'Detects $pdbTypeName argument in ${constructor.enclosingElement.name} class: ${pdbArgument.runtimeType}',
  );

  // constructor always has block.
  await _parseBlockAsync(
    context,
    constructor,
    (ast.body as BlockFunctionBody).block,
  );

  late final PropertyDescriptorsBuilding building;
  if (pdbArgument is SimpleIdentifier) {
    // Try to get building assuming that pdbArgument is local variable,
    // then assuming that it is direct reference to top level variable or field.
    building = context.buildings[pdbArgument.name] ??
        context.initializeCompanionMixinArgument!;
  } else {
    building = context.initializeCompanionMixinArgument!;
  }

  if (building.isEmpty) {
    // Constructor without inline initialization means empty
    context.addGlobalWarning(
      "initializeCompanionMixin($pdbTypeName) is called with empty $pdbTypeName in class '${constructor.enclosingElement.name}'.",
    );
  }

  final result = <String, PropertyAndFormFieldDefinition>{};

  for (final source in _parseMethodInvocations(
    context,
    building.buildings,
    constructor,
    isFormBuilder: isFormBuilder,
  )) {
    result[source.name] = await resolveFormFieldAsync(
      context,
      source,
      isFormBuilder: isFormBuilder,
    );
  }

  return result;
}

/// Collects dependencies as a list of [LibraryImport] from `FormField`s
/// constructor parameters in [properties].
///
/// Of course, dependency for the library which declares the presenter, that is,
/// dependency for [thisLibrary] will be ignored.
FutureOr<List<LibraryImport>> collectDependenciesAsync(
  LibraryElement thisLibrary,
  Iterable<PropertyAndFormFieldDefinition> properties,
  NodeProvider nodeProvider,
  Logger logger,
) async {
  final collector =
      DependentLibraryCollector(nodeProvider, logger, thisLibrary);
  for (final property in properties) {
    final fieldConstructor = property.fieldConstructor;
    if (fieldConstructor != null) {
      collector.reset(
        fieldConstructor.declaredElement!.enclosingElement,
        property.warnings,
      );
      fieldConstructor.accept(collector);
      await collector.endAsync();
    }
  }

  return collector.imports.toList();
}
