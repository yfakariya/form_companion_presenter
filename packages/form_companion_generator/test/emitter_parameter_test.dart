// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/emitter.dart';
import 'package:form_companion_generator/src/emitter/instantiation.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parameter.dart';
import 'package:form_companion_generator/src/type_instantiation.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final nodeProvider = NodeProvider();
  final library = await getParametersLibrary();
  final holder = library.getType('ParameterHolder')!;
  final holderNode =
      await nodeProvider.getElementDeclarationAsync<ClassDeclaration>(holder);
  final constructorParameters = {
    for (final c in holder.constructors)
      c.name: {for (final p in c.parameters) p.name: p}
  };
  final methodParameters = {
    for (final m in holder.methods)
      m.name: {for (final p in m.parameters) p.name: p}
  };
  final constructorParameterNodes = {
    for (final c
        in holderNode.childEntities.whereType<ConstructorDeclaration>())
      c.name!.name: {
        for (final p in c.parameters.parameters) p.identifier!.name: p
      }
  };
  final methodParameterNodes = {
    for (final m in holderNode.childEntities.whereType<MethodDeclaration>())
      m.name.name: {
        for (final p in m.parameters!.parameters) p.identifier!.name: p
      }
  };

  final listHolder = library.getType('ParameterListHolder')!;
  final listHolderNode = await nodeProvider
      .getElementDeclarationAsync<ClassDeclaration>(listHolder);
  final listConstructorParameters = {
    for (final p in listHolder.constructors.single.parameters) p.name: p
  };
  final listMethodParameters = {
    for (final p in listHolder.methods.single.parameters) p.name: p
  };
  final listConstructorParameterNodes = {
    for (final p in listHolderNode.childEntities
        .whereType<ConstructorDeclaration>()
        .single
        .parameters
        .parameters)
      p.identifier!.name: p
  };
  final listMethodParameterNodes = {
    for (final p in listHolderNode.childEntities
        .whereType<MethodDeclaration>()
        .single
        .parameters!
        .parameters)
      p.identifier!.name: p
  };

  PropertyDefinition makeProperty(InterfaceType valueType) =>
      PropertyDefinition(
        name: 'prop',
        type: valueType,
        preferredFieldType: null,
        warnings: [],
      );

  group('emitParameter', () {
    for (final constructorSpec in constructorParameters.entries) {
      for (final parameterSpec in constructorSpec.value.entries) {
        final description = '${constructorSpec.key}, ${parameterSpec.key}';
        final expected = constructorExpected[
            constructorExpectedTypes[constructorSpec.key]]![parameterSpec.key];

        test(description, () async {
          final element = parameterSpec.value;
          final node = await nodeProvider
              .getElementDeclarationAsync<FormalParameter>(element);
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          expect(
            emitParameter(
              context,
              await ParameterInfo.fromNodeAsync(nodeProvider, node),
            ),
            equals(expected),
          );
        });
      }
    }

    for (final methodSpec in methodParameters.entries) {
      for (final parameterSpec in methodSpec.value.entries) {
        final description = '${methodSpec.key}, ${parameterSpec.key}';
        final expected = functionExpected[methodSpec.key]![parameterSpec.key];

        test(description, () async {
          final element = parameterSpec.value;
          final node = await nodeProvider
              .getElementDeclarationAsync<FormalParameter>(element);
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          expect(
            emitParameter(
              context,
              await ParameterInfo.fromNodeAsync(nodeProvider, node),
            ),
            equals(expected),
          );
        });
      }
    }

    for (final parameterSpec in listConstructorParameters.entries) {
      final description = 'generic list, ${parameterSpec.key}';
      final expected = listExpected[parameterSpec.key];

      test(description, () async {
        final element = parameterSpec.value;
        final node = await nodeProvider
            .getElementDeclarationAsync<FormalParameter>(element);
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        expect(
          emitParameter(
            context,
            await ParameterInfo.fromNodeAsync(nodeProvider, node),
          ),
          equals(expected),
        );
      });
    }

    for (final parameterSpec in listMethodParameters.entries) {
      final description = 'generic list, ${parameterSpec.key}';
      final expected = listExpected[parameterSpec.key];

      test(description, () async {
        final element = parameterSpec.value;
        final node = await nodeProvider
            .getElementDeclarationAsync<FormalParameter>(element);
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        expect(
          emitParameter(
            context,
            await ParameterInfo.fromNodeAsync(nodeProvider, node),
          ),
          equals(expected),
        );
      });
    }
  });

  group('processTypeWithValueType', () {
    for (final nullability in ['simple', 'nullable']) {
      for (final constructorSpec
          in constructorParameters[nullability]!.entries) {
        final description = '$nullability, ${constructorSpec.key}';
        final expected =
            typeExpected['normal']![nullability]![constructorSpec.key];

        test(description, () {
          final element = constructorSpec.value;
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          final sink = StringBuffer();

          processTypeWithValueType(
            context,
            element.type,
            sink,
          );
          expect(
            sink.toString(),
            equals(expected),
          );
        });
      }
    }

    for (final nullability in ['simple', 'nullable']) {
      for (final parameterSpec
          in methodParameters['${nullability}Function']!.entries) {
        final description = '$nullability, ${parameterSpec.key}';
        final expected =
            typeExpected['function']![nullability]![parameterSpec.key];

        test(description, () {
          final element = parameterSpec.value;
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          final sink = StringBuffer();

          processTypeWithValueType(
            context,
            element.type,
            sink,
          );
          expect(
            sink.toString(),
            equals(expected),
          );
        });
      }
    }

    for (final typeKind in [
      'nonPrefixed',
      'prefixed',
    ]) {
      final description = 'generic list, $typeKind';
      final expected = listTypeForFormFieldTypeExpected[typeKind];

      test(description, () {
        final element = listConstructorParameters[typeKind]!;
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        final sink = StringBuffer();

        processTypeWithValueType(
          context,
          element.type,
          sink,
        );
        expect(
          sink.toString(),
          equals(expected),
        );
      });
    }

    for (final typeKind in [
      'alias',
      'parameterizedFunction',
      'namedFunction',
      'parameterizedNamedFunction',
    ]) {
      final description = 'generic list, $typeKind';
      final expected = listTypeForFormFieldTypeExpected[typeKind];

      test(description, () {
        final element = listMethodParameters[typeKind]!;
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        final sink = StringBuffer();

        processTypeWithValueType(
          context,
          element.type,
          sink,
        );
        expect(
          sink.toString(),
          equals(expected),
        );
      });
    }
  });

  group('processTypeAnnotationWithValueType', () {
    for (final nullability in ['simple', 'nullable']) {
      for (final constructorSpec
          in constructorParameters[nullability]!.entries) {
        final description = '$nullability, ${constructorSpec.key}';
        final expected = typeAnnotationExpected['normal']![nullability]![
            constructorSpec.key];

        test(description, () async {
          final node =
              constructorParameterNodes[nullability]![constructorSpec.key]!;
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          final parameterInfo =
              await ParameterInfo.fromNodeAsync(nodeProvider, node);
          final sink = StringBuffer();

          processTypeAnnotation(
            context,
            parameterInfo.typeAnnotation,
            parameterInfo.type,
            sink,
          );
          expect(
            sink.toString(),
            equals(expected),
          );
        });
      }
    }

    for (final nullability in ['simple', 'nullable']) {
      for (final parameterSpec
          in methodParameters['${nullability}Function']!.entries) {
        final description = '$nullability, ${parameterSpec.key}';
        final expected = typeAnnotationExpected['function']![nullability]![
            parameterSpec.key];

        test(description, () async {
          final node = methodParameterNodes['${nullability}Function']![
              parameterSpec.key]!;
          final context = TypeInstantiationContext.create(
            nodeProvider,
            makeProperty(library.typeProvider.boolType),
            holder.thisType,
          );
          final parameterInfo =
              await ParameterInfo.fromNodeAsync(nodeProvider, node);

          final sink = StringBuffer();
          if (parameterInfo.functionTypedParameter != null) {
            processFunctionTypeFormalParameter(
              context,
              parameterInfo.functionTypedParameter!,
              sink,
              forParameterSignature: false,
            );
          } else {
            processTypeAnnotation(
              context,
              parameterInfo.typeAnnotation,
              parameterInfo.type,
              sink,
            );
          }

          expect(
            sink.toString(),
            equals(expected),
          );
        });
      }
    }

    for (final typeKind in [
      'nonPrefixed',
      'prefixed',
    ]) {
      final description = 'generic list, $typeKind';
      final expected = listTypeForParameterTypeExpected[typeKind];

      test(description, () async {
        final node = listConstructorParameterNodes[typeKind]!;
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        final parameterInfo =
            await ParameterInfo.fromNodeAsync(nodeProvider, node);
        final sink = StringBuffer();

        processTypeAnnotation(
          context,
          parameterInfo.typeAnnotation,
          parameterInfo.type,
          sink,
        );
        expect(
          sink.toString(),
          equals(expected),
        );
      });
    }

    for (final typeKind in [
      'alias',
      'parameterizedFunction',
      'namedFunction',
      'parameterizedNamedFunction',
    ]) {
      final description = 'generic list, $typeKind';
      final expected = listTypeForParameterTypeExpected[typeKind];
      test(description, () async {
        final node = listMethodParameterNodes[typeKind]!;
        final context = TypeInstantiationContext.create(
          nodeProvider,
          makeProperty(library.typeProvider.boolType),
          holder.thisType,
        );
        final parameterInfo =
            await ParameterInfo.fromNodeAsync(nodeProvider, node);
        final sink = StringBuffer();

        processTypeAnnotation(
          context,
          parameterInfo.typeAnnotation,
          parameterInfo.type,
          sink,
        );
        expect(
          sink.toString(),
          equals(expected),
        );
      });
    }
  });
}

const constructorExpectedTypes = {
  'simple': 'simple',
  'nullable': 'nullable',
  'field': 'nullable',
  'named': 'nullable',
  'hasDefault': 'hasDefault',
  'namedHasDefault': 'hasDefault',
};

const constructorExpected = {
  'simple': {
    'nonPrefixed': 'String nonPrefixed',
    'prefixed': 'ui.BoxWidthStyle prefixed',
    'nonPrefixedGeneric': 'List<bool> nonPrefixedGeneric',
    'instantiatedGeneric': 'List<int> instantiatedGeneric',
    'prefixedGeneric': 'col.Queue<bool> prefixedGeneric',
  },
  'nullable': {
    'nonPrefixed': 'String? nonPrefixed',
    'prefixed': 'ui.BoxWidthStyle? prefixed',
    'nonPrefixedGeneric': 'List<bool>? nonPrefixedGeneric',
    'instantiatedGeneric': 'List<int>? instantiatedGeneric',
    'prefixedGeneric': 'col.Queue<bool>? prefixedGeneric',
  },
  'hasDefault': {
    'nonPrefixed': 'String? nonPrefixed = \'default\'',
    'prefixed': 'ui.BoxWidthStyle? prefixed = ui.BoxWidthStyle.max',
    'nonPrefixedGeneric': 'List<bool>? nonPrefixedGeneric = const []',
    'instantiatedGeneric': 'List<int>? instantiatedGeneric = const []',
    'prefixedGeneric': 'col.Queue<bool>? prefixedGeneric = null',
  },
};

const functionExpected = {
  'simpleFunction': {
    'alias': 'NonGenericCallback alias',
    'genericAlias': 'GenericCallback<bool> genericAlias',
    'instantiatedAlias': 'GenericCallback<int> instantiatedAlias',
    'prefixedAlias': 'ui.VoidCallback prefixedAlias',
    'function': 'int Function(String) function',
    'genericFunction': 'bool Function(bool) genericFunction',
    'parameterizedFunction': 'S Function<S>(S) parameterizedFunction',
    'instantiatedFunction':
        'List<int> Function(Map<String, int>) instantiatedFunction',
    'prefixedFunction':
        'ui.BoxWidthStyle Function(ui.BoxHeightStyle) prefixedFunction',
    'namedFunction': 'int namedFunction(String p)',
    'genericNamedFunction': 'bool genericNamedFunction(bool p)',
    'parameterizedNamedFunction': 'S parameterizedNamedFunction<S>(S p)',
    'instantiatedNamedFunction':
        'List<int> instantiatedNamedFunction(Map<String, int> p)',
    'prefixedNamedFunction':
        'ui.BoxWidthStyle prefixedNamedFunction(ui.BoxHeightStyle p)',
  },
  'nullableFunction': {
    'alias': 'NonGenericCallback? alias',
    'genericAlias': 'GenericCallback<bool>? genericAlias',
    'instantiatedAlias': 'GenericCallback<int>? instantiatedAlias',
    'prefixedAlias': 'ui.VoidCallback? prefixedAlias',
    'function': 'int? Function(String?)? function',
    'genericFunction': 'bool? Function(bool?)? genericFunction',
    'parameterizedFunction': 'S? Function<S>(S?)? parameterizedFunction',
    'instantiatedFunction':
        'List<int>? Function(Map<String?, int?>?)? instantiatedFunction',
    'prefixedFunction':
        'ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)? prefixedFunction',
    'namedFunction': 'int? namedFunction(String? p)?',
    'genericNamedFunction': 'bool? genericNamedFunction(bool? p)?',
    'parameterizedNamedFunction': 'S? parameterizedNamedFunction<S>(S? p)?',
    'instantiatedNamedFunction':
        'List<int>? instantiatedNamedFunction(Map<String, int>? p)?',
    'prefixedNamedFunction':
        'ui.BoxWidthStyle? prefixedNamedFunction(ui.BoxHeightStyle? p)?',
  },
  'hasDefaultFunction': {
    'alias': 'NonGenericCallback? alias = null',
    'genericAlias': 'GenericCallback<bool>? genericAlias = null',
    'instantiatedAlias': 'GenericCallback<int>? instantiatedAlias = null',
    'prefixedAlias': 'ui.VoidCallback? prefixedAlias = null',
    'function': 'int? Function(String?)? function = null',
    'genericFunction': 'bool? Function(bool?)? genericFunction = null',
    'parameterizedFunction': 'S? Function<S>(S?)? parameterizedFunction = null',
    'instantiatedFunction':
        'List<int>? Function(Map<String?, int?>?)? instantiatedFunction = null',
    'prefixedFunction':
        'ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)? prefixedFunction = null',
    'namedFunction': 'int? namedFunction(String? p)? = null',
    'genericNamedFunction': 'bool? genericNamedFunction(bool? p)? = null',
    'parameterizedNamedFunction':
        'S? parameterizedNamedFunction<S>(S? p)? = null',
    'instantiatedNamedFunction':
        'List<int>? instantiatedNamedFunction(Map<String, int>? p)? = null',
    'prefixedNamedFunction':
        'ui.BoxWidthStyle? prefixedNamedFunction(ui.BoxHeightStyle? p)? = null',
  }
};

const typeExpected = {
  'normal': {
    'simple': {
      'nonPrefixed': 'String',
      'prefixed': 'BoxWidthStyle',
      'nonPrefixedGeneric': 'List<bool>',
      'instantiatedGeneric': 'List<int>',
      'prefixedGeneric': 'Queue<bool>',
    },
    'nullable': {
      'nonPrefixed': 'String?',
      'prefixed': 'BoxWidthStyle?',
      'nonPrefixedGeneric': 'List<bool>?',
      'instantiatedGeneric': 'List<int>?',
      'prefixedGeneric': 'Queue<bool>?',
    }
  },
  'function': {
    'simple': {
      'alias': 'NonGenericCallback',
      'genericAlias': 'GenericCallback<bool>',
      'instantiatedAlias': 'GenericCallback<int>',
      'prefixedAlias': 'VoidCallback',
      'function': 'int Function(String)',
      'genericFunction': 'bool Function(bool)',
      'parameterizedFunction': 'S Function<S>(S)',
      'instantiatedFunction': 'List<int> Function(Map<String, int>)',
      'prefixedFunction': 'BoxWidthStyle Function(BoxHeightStyle)',
      'namedFunction': 'int Function(String)',
      'genericNamedFunction': 'bool Function(bool)',
      'parameterizedNamedFunction': 'S Function<S>(S)',
      'instantiatedNamedFunction': 'List<int> Function(Map<String, int>)',
      'prefixedNamedFunction': 'BoxWidthStyle Function(BoxHeightStyle)',
    },
    'nullable': {
      'alias': 'NonGenericCallback?',
      'genericAlias': 'GenericCallback<bool>?',
      'instantiatedAlias': 'GenericCallback<int>?',
      'prefixedAlias': 'VoidCallback?',
      'function': 'int? Function(String?)?',
      'genericFunction': 'bool? Function(bool?)?',
      'parameterizedFunction': 'S? Function<S>(S?)?',
      'instantiatedFunction': 'List<int>? Function(Map<String?, int?>?)?',
      'prefixedFunction': 'BoxWidthStyle? Function(BoxHeightStyle?)?',
      'namedFunction': 'int? Function(String?)?',
      'genericNamedFunction': 'bool? Function(bool?)?',
      'parameterizedNamedFunction': 'S? Function<S>(S?)?',
      'instantiatedNamedFunction': 'List<int>? Function(Map<String, int>?)?',
      'prefixedNamedFunction': 'BoxWidthStyle? Function(BoxHeightStyle?)?',
    },
  }
};

const typeAnnotationExpected = {
  'normal': {
    'simple': {
      'nonPrefixed': 'String',
      'prefixed': 'ui.BoxWidthStyle',
      'nonPrefixedGeneric': 'List<bool>',
      'instantiatedGeneric': 'List<int>',
      'prefixedGeneric': 'col.Queue<bool>',
    },
    'nullable': {
      'nonPrefixed': 'String?',
      'prefixed': 'ui.BoxWidthStyle?',
      'nonPrefixedGeneric': 'List<bool>?',
      'instantiatedGeneric': 'List<int>?',
      'prefixedGeneric': 'col.Queue<bool>?',
    }
  },
  'function': {
    'simple': {
      'alias': 'NonGenericCallback',
      'genericAlias': 'GenericCallback<bool>',
      'instantiatedAlias': 'GenericCallback<int>',
      'prefixedAlias': 'ui.VoidCallback',
      'function': 'int Function(String)',
      'genericFunction': 'bool Function(bool)',
      'parameterizedFunction': 'S Function<S>(S)',
      'instantiatedFunction': 'List<int> Function(Map<String, int>)',
      'prefixedFunction': 'ui.BoxWidthStyle Function(ui.BoxHeightStyle)',
      'namedFunction': 'int Function(String)',
      'genericNamedFunction': 'bool Function(bool)',
      'parameterizedNamedFunction': 'S Function<S>(S)',
      'instantiatedNamedFunction': 'List<int> Function(Map<String, int>)',
      'prefixedNamedFunction': 'ui.BoxWidthStyle Function(ui.BoxHeightStyle)',
    },
    'nullable': {
      'alias': 'NonGenericCallback?',
      'genericAlias': 'GenericCallback<bool>?',
      'instantiatedAlias': 'GenericCallback<int>?',
      'prefixedAlias': 'ui.VoidCallback?',
      'function': 'int? Function(String?)?',
      'genericFunction': 'bool? Function(bool?)?',
      'parameterizedFunction': 'S? Function<S>(S?)?',
      'instantiatedFunction': 'List<int>? Function(Map<String?, int?>?)?',
      'prefixedFunction': 'ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)?',
      'namedFunction': 'int? Function(String?)?',
      'genericNamedFunction': 'bool? Function(bool?)?',
      'parameterizedNamedFunction': 'S? Function<S>(S?)?',
      'instantiatedNamedFunction': 'List<int>? Function(Map<String, int>?)?',
      'prefixedNamedFunction':
          'ui.BoxWidthStyle? Function(ui.BoxHeightStyle?)?',
    },
  }
};

const listExpected = {
  'nonPrefixed': 'List<bool> nonPrefixed',
  'prefixed': 'col.Queue<List<bool>> prefixed',
  'alias': 'GenericCallback<List<bool>> alias',
  'function': 'List<bool> Function(List<bool>) function',
  'parameterizedFunction': 'List<S> Function<S>(List<S>) parameterizedFunction',
  'namedFunction': 'List<bool> namedFunction(List<bool> p)',
  'parameterizedNamedFunction':
      'List<S> parameterizedNamedFunction<S>(List<S> p)',
};

const listTypeForFormFieldTypeExpected = {
  'nonPrefixed': 'List<bool>',
  'prefixed': 'Queue<List<bool>>',
  'alias': 'GenericCallback<List<bool>>',
  'function': 'List<bool> Function(List<bool>)',
  'parameterizedFunction': 'List<S> Function<S>(List<S>)',
  'namedFunction': 'List<bool> Function(List<bool>)',
  'parameterizedNamedFunction': 'List<S> Function<S>(List<S>)',
};

const listTypeForParameterTypeExpected = {
  'nonPrefixed': 'List<bool>',
  'prefixed': 'col.Queue<List<bool>>',
  'alias': 'GenericCallback<List<bool>>',
  'function': 'List<bool> Function(List<bool>)',
  'parameterizedFunction': 'List<S> Function<S>(List<S>)',
  'namedFunction': 'List<bool> Function(List<bool>)',
  'parameterizedNamedFunction': 'List<S> Function<S>(List<S>)',
};
