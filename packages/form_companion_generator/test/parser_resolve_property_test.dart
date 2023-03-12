// See LICENCE file in the root.

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/form_field_locator.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/node_provider.dart';
import 'package:form_companion_generator/src/parser/parser_data.dart';
import 'package:form_companion_generator/src/parser/parser_helpers.dart';
import 'package:form_companion_generator/src/parser/resolve_property.dart';
import 'package:logging/logging.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:tuple/tuple.dart';

import 'session_resolver.dart';
import 'test_helpers.dart';

/// 1. Test case
/// 2. [MethodInvocationSpec]
/// 3. Property name
/// 4. Property value type
/// 5. Field value type
/// 6. Preffered form field type name
typedef NormalTestSpec = Tuple6<String, MethodInvocationSpec, String,
    InterfaceType, InterfaceType, String?>;

/// 1. Test case
/// 2. [MethodInvocationSpec]
/// 3. Property name
/// 4. Error message prefix
/// 5. Error message suffix
/// 6. To do message
typedef ErrorTestSpec
    = Tuple6<String, MethodInvocationSpec, String, String, String, String>;

/// 1. context element
/// 2. method invocation
typedef MethodInvocationSpec = Tuple2<Element, MethodInvocation>;

class _MethodInvocationsFinder extends RecursiveAstVisitor<void> {
  final List<MethodInvocation> founds = [];

  _MethodInvocationsFinder();

  @override
  void visitMethodInvocation(MethodInvocation node) {
    founds.add(node);
    super.visitMethodInvocation(node);
  }
}

Config get _emptyConfig => Config(<String, dynamic>{});

Future<void> main() async {
  final logger = Logger('parser_resolve_property_test');
  Logger.root.level = Level.INFO;
  // ignore: avoid_print
  logger.onRecord.listen(print);

  final libraryResult =
      await getResolvedLibraryResult('resolve_method_targets.dart');
  final library = libraryResult.element;
  final resolver = SessionResolver(library);
  final nodeProvider = NodeProvider(SessionResolver(library));
  final typeProvider = library.typeProvider;
  final typeSystem = library.typeSystem;
  final formFieldLocator =
      await FormFieldLocator.createAsync(resolver, [], logger);

  final myEnumType = await getMyEnumType();

  List<MethodInvocationSpec> findMethodInvocations(
    String enclosingFunctionName,
  ) {
    final element = library.topLevelElements
        .whereType<FunctionElement>()
        .where((e) => e.name == enclosingFunctionName)
        .single;
    final visitor = _MethodInvocationsFinder();
    libraryResult
        .getElementDeclaration(element)!
        .node
        .childEntities
        .whereType<AstNode>()
        .forEach((e) => e.accept(visitor));
    return visitor.founds.map((m) => MethodInvocationSpec(element, m)).toList();
  }

  final builtIns = findMethodInvocations('builtin');
  final add = builtIns[0];
  final withInferred = builtIns[1];
  final addWithField = builtIns[2];
  final boolean = builtIns[3];
  final stringConvertible = builtIns[4];
  final enumerated = builtIns[5];
  final id = findMethodInvocations('id').single;
  final withTextField = findMethodInvocations('withTextField').single;
  final withBlockBody = findMethodInvocations('withBlockBody').single;
  final withNoChainExpression =
      findMethodInvocations('withNoChainExpression').single;
  final withNever = findMethodInvocations('withNever').single;
  final withNeverList = findMethodInvocations('withNeverList').single;

  Future<void> testResolvePropertyDefinitionAsync(
    Element contextElement,
    MethodInvocation invocation, {
    required String propertyName,
    required String propertyType,
    required String fieldType,
    String? preferredFormFieldTypeName,
    void Function(List<String>)? warningsAssertion,
    void Function(Object)? errorAssertion,
    required bool isFormBuilder,
  }) async {
    final targetClass = lookupTargetClass(contextElement, invocation);
    late final PropertyDefinitionWithSource result;
    try {
      result = await resolvePropertyDefinitionAsync(
        context: ParseContext(
          library.languageVersion,
          _emptyConfig,
          logger,
          nodeProvider,
          formFieldLocator,
          typeProvider,
          typeSystem,
          [],
          isFormBuilder: isFormBuilder,
        ),
        contextElement: contextElement,
        methodInvocation: invocation,
        targetClass: targetClass,
        propertyName: null,
        typeArguments: invocation.typeArgumentTypes
                ?.map((t) => GenericType.fromDartType(t, contextElement))
                .toList() ??
            [],
        originalMethodInvocation: invocation,
        isInferred: invocation.typeArguments?.length !=
            invocation.typeArgumentTypes?.length,
      );
    }
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      if (errorAssertion == null) {
        rethrow;
      }

      errorAssertion(e);
      return;
    }

    if (errorAssertion != null) {
      fail('Success.');
    }

    expect(result.source, same(invocation));
    expect(result.property.name, propertyName);
    expect(
      result.property.propertyType.getDisplayString(withNullability: true),
      propertyType,
    );
    expect(
      result.property.fieldType.getDisplayString(withNullability: true),
      fieldType,
    );
    expect(
      result.property.preferredFormFieldType
          ?.getDisplayString(withNullability: true),
      preferredFormFieldTypeName,
    );
    (warningsAssertion ?? (w) => expect(w, isEmpty))(result.property.warnings);
  }

  group('normal cases', () {
    for (final spec in [
      NormalTestSpec(
        'add with type arguments',
        add,
        'add',
        typeProvider.intType,
        typeProvider.stringType,
        null,
      ),
      NormalTestSpec(
        'add with infer',
        withInferred,
        'withInferred',
        typeProvider.intType,
        typeProvider.stringType,
        null,
      ),
      NormalTestSpec(
        'add with field',
        addWithField,
        'addWithField',
        typeProvider.intType,
        typeProvider.stringType,
        'DropdownButtonFormField<String>',
      ),
      NormalTestSpec(
        'type arguments specified in method',
        boolean,
        'boolean',
        typeProvider.boolType,
        typeProvider.boolType,
        null,
      ),
      NormalTestSpec(
        'type arguments specified in method and inferred',
        stringConvertible,
        'stringConvertible',
        typeProvider.doubleType,
        typeProvider.stringType,
        null,
      ),
      NormalTestSpec(
        'type arguments are inferred at once',
        enumerated,
        'enumerated',
        myEnumType,
        myEnumType,
        null,
      ),
      NormalTestSpec(
        'field type is specified in method',
        withTextField,
        'withTextField',
        typeProvider.intType,
        typeProvider.stringType,
        'TextFormField',
      ),
      NormalTestSpec(
        'via non generic method',
        id,
        'id',
        typeProvider.stringType,
        typeProvider.stringType,
        null,
      ),
    ]) {
      test(
        spec.item1,
        () async => testResolvePropertyDefinitionAsync(
          spec.item2.item1,
          spec.item2.item2,
          propertyName: spec.item3,
          propertyType: spec.item4.getDisplayString(withNullability: true),
          fieldType: spec.item5.getDisplayString(withNullability: true),
          preferredFormFieldTypeName: spec.item6,
          isFormBuilder: false,
        ),
      );
    }
  });

  group('error cases', () {
    for (final spec in [
      ErrorTestSpec(
        'method is block bodied',
        withBlockBody,
        'withBlockBody',
        "PropertyDescriptorsBuilder's extension method must have expression body, "
            "but method 'void withBlockBody"
            "<P extends Object, F extends Object>({required String name})' at",
        ' is not.',
        "Declare method 'void withBlockBody"
            "<P extends Object, F extends Object>({required String name})' as "
            'an expression bodied method.',
      ),
      ErrorTestSpec(
        'method does not call chain for `add`',
        withNoChainExpression,
        'withNoChainExpression',
        "PropertyDescriptorsBuilder's extension method must have expression "
            "body with another PropertyDescriptorsBuilder's (extension) method "
            "invocation, but expresion 'throw UnimplementedError('intentionally')' at",
        ' is not.',
        "Declare method 'void withNoChainExpression"
            "<P extends Object, F extends Object>({required String name})' as "
            'an expression bodied method with another '
            "PropertyDescriptorsBuilder's (extension) method invocation.",
      ),
      ErrorTestSpec(
        'method contains unsupported type argument',
        withNever,
        'withNever',
        'Failed to parse complex source code '
            "'add<Never, Never>(name: name)' (MethodInvocationImpl) at ",
        '.',
        'Avoid using this expression or statement here, or file the issue for '
            'this message if you truly want to use this code.',
      ),
      ErrorTestSpec(
        'method contains type argument with unsupported type argument',
        withNeverList,
        'withNeverList',
        'Failed to parse complex source code '
            "'add<List<Never>, List<Never>>(name: name)' (MethodInvocationImpl) at ",
        '.',
        'Avoid using this expression or statement here, or file the issue for '
            'this message if you truly want to use this code.',
      ),
    ]) {
      test(
        spec.item1,
        () async => testResolvePropertyDefinitionAsync(
          spec.item2.item1,
          spec.item2.item2,
          propertyName: spec.item3,
          propertyType: '__ERROR__',
          fieldType: '__ERROR__',
          isFormBuilder: false,
          errorAssertion: (e) {
            expect(e, isA<InvalidGenerationSourceError>());
            expect(
              (e as InvalidGenerationSourceError).message,
              startsWith(spec.item4),
            );
            expect(e.message, endsWith(spec.item5));
            expect(e.todo, spec.item6);
          },
        ),
      );
    }
  });
}
