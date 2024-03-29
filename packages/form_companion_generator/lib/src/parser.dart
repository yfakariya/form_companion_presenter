// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:logging/logging.dart' show Logger;
import 'package:meta/meta.dart';
import 'package:source_gen/source_gen.dart';

import 'arguments_handler.dart';
import 'config.dart';
import 'dependency.dart';
import 'form_field_locator.dart';
import 'macro.dart';
import 'model.dart';
import 'node_provider.dart';
import 'parser/parser_data.dart';
import 'parser/parser_helpers.dart';
import 'parser/parser_node.dart';
import 'parser/resolve_property.dart';
import 'type_instantiation.dart';
import 'utilities.dart';

part 'parser/assignment.dart';
part 'parser/expression.dart';
part 'parser/form_field.dart';
part 'parser/identifier.dart';
part 'parser/presenter_initializer.dart';
part 'parser/statement.dart';

/// Parses specified [ClassElement] of the presenter.
FutureOr<PresenterDefinition> parseElementAsync(
  Config config,
  NodeProvider nodeProvider,
  FormFieldLocator formFieldLocator,
  ClassElement element,
  FormCompanionAnnotation annotation,
  Logger logger,
) async {
  final mixinType = detectMixinType(element);
  if (mixinType == null) {
    throw InvalidGenerationSourceError(
      'A target of `@formCompanion` must be mix-ined with the either of '
      '`FormCompanionMixin` or `FormBuilderCompanionMixin` in '
      "'${element.name}' class.",
      element: element,
    );
  }

  final isFormBuilder = mixinType == MixinType.formBuilderCompanionMixin;
  final globalWarnings = <String>[];

  final context = ParseContext(
    element.library.languageVersion,
    config,
    logger,
    nodeProvider,
    formFieldLocator,
    element.library.typeProvider,
    element.library.typeSystem,
    globalWarnings,
    isFormBuilder: isFormBuilder,
  );

  final initializer = await findInitializerAsync(context, element);

  logger.fine(
    'Detects $pdbTypeName argument in ${initializer.element.displayName} '
    'class: ${initializer.propertyDescriptorBuilderTypedArgument.runtimeType}',
  );

  final properties = await getPropertiesAsync(context, initializer);

  return PresenterDefinition(
    name: element.name,
    isFormBuilder: isFormBuilder,
    doAutovalidate: annotation.autovalidate ?? config.autovalidateByDefault,
    warnings: globalWarnings,
    imports: await collectDependenciesAsync(
      element.library,
      config,
      properties,
      nodeProvider,
      logger,
      isFormBuilder: isFormBuilder,
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
      message: 'Both of `FormCompanionMixin` and `FormBuilderCompanionMixin` '
          "cannot be specified together for '${classElement.name}' class.",
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

/// Find an appropriate [Initializer] from specified [ClassElement] of
/// the presenter.
/// The returned initializer should calls `initializeCompanionMixin` only once.
///
/// If such members are declared multiply, or are not declared at all,
/// an [InvalidGenerationSourceError] will be thrown.
@visibleForTesting
FutureOr<Initializer> findInitializerAsync(
  ParseContext context,
  ClassElement classElement,
) async {
  final constructorCandidates = <Initializer>[];
  for (final constructor in classElement.constructors.where(
    (ctor) =>
        // Not a implicit default constructor -- they never have initializeCompanionMixin call.
        !ctor.isSynthetic &&
        // Filter out constructors which only redirect to another one -- they never have initializeCompanionMixin call.
        ctor.redirectedConstructor == null,
  )) {
    final ast = await context.nodeProvider
        .getElementDeclarationAsync<ConstructorDeclaration>(constructor);
    final pdbArgument =
        await _findArgumentOfLastInitializeCompanionMixinInvocationAsync(
      context,
      ast,
      constructor,
    );
    if (pdbArgument != null) {
      constructorCandidates
          .add(Initializer(constructor, ast.body, pdbArgument));
    }
  }

  // We don't support initializeCompanionMixin call in non constructor members
  // because it introduces extra complexity to state transition, and not required.
  // However, some people should put it in build() of [Async]Notifier, so we believe that
  // detecting and reporting of the situation are useful.
  final methodCandidates = <Initializer>[];
  for (final method in classElement.methods.where(
    (m) =>
        // Not a implicit methods -- they should not have initializeCompanionMixin call.
        !m.isSynthetic &&
        // Filter static methods -- they never have initializeCompanionMixin call.
        !m.isStatic,
  )) {
    final ast = await context.nodeProvider
        .getElementDeclarationAsync<MethodDeclaration>(method);
    final pdbArgument =
        await _findArgumentOfLastInitializeCompanionMixinInvocationAsync(
      context,
      ast,
      method,
    );
    if (pdbArgument != null) {
      methodCandidates.add(Initializer(method, ast.body, pdbArgument));
    }
  }

  if (constructorCandidates.isEmpty) {
    throw InvalidGenerationSourceError(
      'No constructors which call `initializeCompanionMixin(PropertyDescriptorsBuilder)` '
      "are found in '${classElement.name}' class.",
      todo: 'Modify to ensure only one constructor which has body '
          'with `initializeCompanionMixin(PropertyDescriptorsBuilder)` call.',
      element: classElement,
    );
  }

  if (constructorCandidates.length > 1 || methodCandidates.isNotEmpty) {
    throw InvalidGenerationSourceError(
      'This generator only supports presenter class which has only one constructor '
      'which has body with `initializeCompanionMixin(PropertyDescriptorsBuilder)` call.'
      'Class name: ${classElement.name}, found members: [${[
        ...constructorCandidates,
        ...methodCandidates
      ].map((c) => c.element.displayName).join(', ')}]',
      todo:
          'Modify to ensure only one constructor has body with `initializeCompanionMixin(PropertyDescriptorsBuilder)` call.',
      element: classElement,
    );
  }

  return constructorCandidates.single;
}

/// Extracts unorderd map of [PropertyDefinition] where keys are names of the
/// properties from specified presenter's [ConstructorElement].
///
/// If any global warnings is issued, the message will be added to [context].
@visibleForTesting
FutureOr<List<PropertyAndFormFieldDefinition>> getPropertiesAsync(
  ParseContext context,
  Initializer initializer,
) async {
  final body = initializer.ast;
  assert(
    body is BlockFunctionBody,
    'initializeCompanionMixin() is called out of constructor.', // coverage:ignore-line
  );

  // Parse block to find real pdb argument.
  await _parseBlockAsync(
    context,
    initializer.element,
    (body as BlockFunctionBody).block,
  );

  final pdbArgument = initializer.propertyDescriptorBuilderTypedArgument;
  final parsedBuilding = context.initializeCompanionMixinArgument;

  late final PropertyDescriptorsBuilding building;
  if (pdbArgument is SimpleIdentifier) {
    // First, try to get building assuming that pdbArgument is local variable,
    // then assuming that it is direct reference to top level variable or field.
    building = context.buildings[pdbArgument.name] ?? parsedBuilding!;
  } else if (parsedBuilding == null) {
    // Unexpected complex body.
    // coverage:ignore-start
    throwNotSupportedYet(node: body, contextElement: initializer.element);
    // coverage:ignore-end
  } else {
    building = parsedBuilding;
  }

  if (building.isEmpty) {
    // Constructor without inline initialization means empty
    context.addGlobalWarning(
      "initializeCompanionMixin($pdbTypeName) is called with empty $pdbTypeName in class '${initializer.element.displayName}'.",
    );
  }

  return _toUniquePropertyDefinitions(
    context,
    building.buildings,
    initializer.element,
    isFormBuilder: context.isFormBuilder,
  )
      .map(
        (m) async => await resolveFormFieldAsync(
          context,
          m,
          isFormBuilder: context.isFormBuilder,
        ),
      )
      .toListAsync();
}

Iterable<PropertyDefinition> _toUniquePropertyDefinitions(
  ParseContext context,
  Iterable<PropertyDefinitionWithSource> definitions,
  Element contextElement, {
  required bool isFormBuilder,
}) sync* {
  final names = <String>{};
  for (final definition in definitions) {
    final property = definition.property;
    if (!names.add(property.name)) {
      final element = _getDeclaringElement(definition.source);
      throwError(
        message:
            "Property '${property.name}' is defined more than once at ${getNodeLocation(definition.source, element)}.",
        todo: 'Fix to define each properties only once for given $pdbTypeName.',
        element: element,
      );
    }

    yield property;
  }
}

Element _getDeclaringElement(MethodInvocation expression) {
  for (AstNode? node = expression; node != null; node = node.parent) {
    if (node is Declaration && node is! VariableDeclaration) {
      // Any declaration other than local variable
      if (node is TopLevelVariableDeclaration) {
        // Manually look up because declaredElement is always null
        return (node.root as CompilationUnit)
            .declaredElement!
            .library
            .scope
            .lookup(node.variables.variables.first.name.lexeme)
            .getter!;
      } else {
        return node.declaredElement!;
      }
    }
  }

  // coverage:ignore-start
  assert(false, "Failed to get declered element of '$expression'.");
  throw Exception("Failed to get declered element of '$expression'.");
  // coverage:ignore-end
}

/// Collects dependencies as a list of [LibraryImport] from `FormField`s
/// constructor parameters in [properties].
///
/// Of course, dependency for the library which declares the presenter, that is,
/// dependency for [presenterLibrary] will be ignored.
FutureOr<List<LibraryImport>> collectDependenciesAsync(
  LibraryElement presenterLibrary,
  Config config,
  Iterable<PropertyAndFormFieldDefinition> properties,
  NodeProvider nodeProvider,
  Logger logger, {
  required bool isFormBuilder,
}) async {
  Iterable<TemplateImports> getImports(
    PropertyAndFormFieldDefinition property,
    ParameterInfo parameter,
  ) {
    final argumentTemplate = config.argumentTemplates
        .get(property.formFieldTypeName, parameter.name);
    final usedMacros = extractMacroKeys(
      argumentTemplate.itemTemplate ?? argumentTemplate.value ?? '',
    );

    return [
      ...argumentTemplate.imports,
      ...usedMacros.expand((m) => config.namedTemplates[m]?.imports ?? [])
    ];
  }

  final collector = DependentLibraryCollector(
    await nodeProvider.libraries.toList(),
    logger,
    presenterLibrary,
  );

  for (final property in properties) {
    for (final formFieldConstructor in property.formFieldConstructors) {
      final argumentsHandler = formFieldConstructor.argumentsHandler;

      collector.reset(
        formFieldConstructor.constructor.declaredElement!.enclosingElement,
        property.warnings,
      );
      // Visit only parameters instead of constructor to avoid collecting
      // types used in super invocation, initializers, and body.
      // Also, this loop filters verbose import for "intrinsic" parameters.
      argumentsHandler.callerSuppliableParameters
          .forEach(collector.collectDependencyForParameter);

      // Add form field itself.
      final classDeclaration =
          formFieldConstructor.constructor.parent! as ClassDeclaration;
      collector
        ..recordTypeName(
          classDeclaration.declaredElement,
          classDeclaration.name.lexeme,
        )
        // Add property value
        ..processGenericType(property.propertyValueType)
        // Add field value
        ..processGenericType(property.fieldValueType);
      if (!isFormBuilder) {
        // Add getFieldValue/setFieldValue related.
        collector
          ..recordTypeIdDirect('dart:ui', 'Locale')
          ..recordTypeIdDirect(
            'package:flutter/widgets.dart',
            'Localizations',
          );
      }

      for (final import in argumentsHandler.allParameters.expand(
        (p) => getImports(property, p),
      )) {
        if (import.prefix.isEmpty) {
          if (import.types.isEmpty) {
            collector.recordLibraryImport(import.uri);
          } else {
            for (final type in import.types) {
              collector.recordTypeIdDirect(import.uri, type);
            }
          }
        } else {
          // NOTE: Currently, template imports in build.yaml cannot specify
          //       library import with prefix, because prefixes are specified
          //       in keys which represent types to be imported, so types
          //       always specified when any prefixes are specified.
          assert(import.types.isNotEmpty);
          for (final type in import.types) {
            collector.recordTypeIdDirectWithLibraryPrefix(
              import.uri,
              import.prefix,
              type,
            );
          }
        }
      }
    }
  }

  collector
    ..recordTypeIdDirect('package:flutter/widgets.dart', 'BuildContext')
    // @sealed and @immutable for typed FormProperties
    ..recordTypeIdDirect('package:meta/meta.dart', 'sealed')
    ..recordTypeIdDirect('package:meta/meta.dart', 'immutable');

  return [
    ...collector.imports,
  ];
}
