// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/type_instantiation.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final logger = Logger('instantiation_context_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  final nullableStringType = await getNullableStringType();

  FutureOr<void> testCore({
    required String code,
    required GenericType Function(LibraryElement) valueTypeProvider,
    required ClassElement Function(LibraryElement) classFinder,
    required void Function(TypeInstantiationContext) assertion,
    List<GenericType> Function(TypeProvider)? formFieldGenericArgumentsProvider,
    // Required if leaf type had non-generic type argument to super.
    InterfaceType Function(LibraryElement)? instantiatedFormFieldTypeProvider,
  }) async {
    final disposeResolver = Completer<void>();
    try {
      late final Resolver resolver;
      await resolveSource(
        '''
library _library;

$code
''',
        (r) {
          resolver = r;
        },
        tearDown: disposeResolver.future,
      );

      final library = await resolver.findLibraryByName('_library');

      if (library == null) {
        fail('Failed to find library.');
      }
      final formFieldType = classFinder(library);
      final valueType = valueTypeProvider(library);

      final result = TypeInstantiationContext.create(
        PropertyDefinition(
          name: 'prop',
          propertyType: valueType,
          fieldType: valueType,
          preferredFormFieldType: GenericType.generic(
            formFieldType.thisType,
            formFieldGenericArgumentsProvider?.call(library.typeProvider) ?? [],
            formFieldType,
          ),
          warnings: [],
        ),
        instantiatedFormFieldTypeProvider?.call(library) ??
            formFieldType.thisType,
        logger,
      );

      assertion(result);
    } finally {
      disposeResolver.complete();
    }
  }

  test(
    'non generic',
    () => testCore(
      code: '''
class FormField<T> {}
class TextFormField extends FormField<String> {}
''',
      classFinder: (l) => l.getClass('TextFormField')!,
      valueTypeProvider: (l) => toGenericType(l.typeProvider.stringType),
      assertion: (x) {
        expect(x.getMappedType('FormField', 'T'), 'String');
      },
    ),
  );

  test(
    'simple generic',
    () => testCore(
      code: '''
class FormField<T> {}
class DropdownButtonFormField<T> extends FormField<T> {}
''',
      classFinder: (l) => l.getClass('DropdownButtonFormField')!,
      valueTypeProvider: (l) => toGenericType(l.typeProvider.stringType),
      formFieldGenericArgumentsProvider: (t) => [toGenericType(t.stringType)],
      assertion: (x) {
        expect(x.getMappedType('DropdownButtonFormField', 'T'), 'String');
        expect(x.getMappedType('FormField', 'T'), 'String');
      },
    ),
  );

  test(
    'nullable generic',
    () => testCore(
      code: '''
class FormField<T> {}
class DropdownButtonFormField<T> extends FormField<T> {}
''',
      classFinder: (l) => l.getClass('DropdownButtonFormField')!,
      valueTypeProvider: (l) => toGenericType(nullableStringType),
      formFieldGenericArgumentsProvider: (_) =>
          [toGenericType(nullableStringType)],
      assertion: (x) {
        expect(x.getMappedType('DropdownButtonFormField', 'T'), 'String?');
        expect(x.getMappedType('FormField', 'T'), 'String?');
      },
    ),
  );

  test(
    'nested generic',
    () => testCore(
      code: '''
class FormField<T> {}
class FormBuilderCheckBoxGroup<T> extends FormField<List<T>> {}
''',
      classFinder: (l) => l.getClass('FormBuilderCheckBoxGroup')!,
      valueTypeProvider: (l) =>
          toGenericType(l.typeProvider.listType(l.typeProvider.stringType)),
      formFieldGenericArgumentsProvider: (t) => [toGenericType(t.stringType)],
      assertion: (x) {
        expect(x.getMappedType('FormBuilderCheckBoxGroup', 'T'), 'String');
        expect(x.getMappedType('FormField', 'T'), 'List<String>');
      },
    ),
  );

  group('non generic function', () {
    for (final spec in [
      Tuple3('aliased - non-aliased', 'Callback', 'void Function()'),
      Tuple3('non-aliased - aliased', 'void Function()', 'Callback'),
      Tuple3('aliased - aliased', 'Callback', 'Callback'),
      Tuple3(
        'non-aliased - non-aliased',
        'void Function()',
        'void Function()',
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: '''
typedef Callback = void Function();
class FormField<T> {}
class FunctionFormField extends FormField<${spec.item3}> {}
final ${spec.item2} callback = () {};
''',
          classFinder: (l) => l.getClass('FunctionFormField')!,
          valueTypeProvider: (l) {
            final variable =
                l.topLevelElements.whereType<TopLevelVariableElement>().single;
            return GenericType.fromDartType(variable.type, variable);
          },
          assertion: (x) {
            // Specified (field type) is always preferred.
            expect(x.getMappedType('FormField', 'T'), spec.item2);
          },
        ),
      );
    }
  });

  group('simple generic function', () {
    for (final spec in [
      Tuple3(
        'aliased - non-aliased',
        'Callback<String>',
        'T Function<T>(T)',
      ),
      Tuple3(
        'non-aliased - aliased',
        'String Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased - aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased - non-aliased',
        'String Function(String)',
        'T Function<T>(T)',
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: '''
typedef Callback<T> = T Function(T);
class FormField<T> {}
class FunctionFormField<T> extends FormField<${spec.item3}> {}
final ${spec.item2} callback = (_) => '';
''',
          classFinder: (l) => l.getClass('FunctionFormField')!,
          valueTypeProvider: (l) {
            final variable =
                l.topLevelElements.whereType<TopLevelVariableElement>().single;
            return GenericType.fromDartType(variable.type, variable);
          },
          formFieldGenericArgumentsProvider: (t) =>
              [toGenericType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('FunctionFormField', 'T'), 'String');
            expect(x.getMappedType('FormField', 'T'), spec.item2);
          },
        ),
      );
    }
  });

  group('nested generic function', () {
    for (final spec in [
      Tuple3(
        'aliased - non-aliased',
        'Callback<String>',
        'T Function<T>(T)',
      ),
      Tuple3(
        'non-aliased - aliased',
        'String Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased - aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased - non-aliased',
        'String Function(String)',
        'T Function<T>(T)',
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: '''
typedef Callback<T> = T Function(T);
class FormField<T> {}
class FunctionFormField<T> extends FormField<List<${spec.item3}>> {}
final List<${spec.item2}> callback = [];
''',
          classFinder: (l) => l.getClass('FunctionFormField')!,
          valueTypeProvider: (l) => toGenericType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          formFieldGenericArgumentsProvider: (t) =>
              [toGenericType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('FunctionFormField', 'T'), 'String');
            expect(x.getMappedType('FormField', 'T'), 'List<${spec.item2}>');
          },
        ),
      );
    }
  });

  group('generic function mapped with return type', () {
    for (final spec in [
      Tuple3(
        'aliased - non-aliased',
        'Callback<String>',
        'T Function<T>()',
      ),
      Tuple3(
        'non-aliased - aliased',
        'String Function()',
        'Callback<T>',
      ),
      Tuple3(
        'aliased - aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased - non-aliased',
        'String Function()',
        'T Function<T>()',
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: '''
typedef Callback<T> = T Function();
class FormField<T> {}
class FunctionFormField<T> extends FormField<${spec.item3}> {}
final ${spec.item2} callback = () => '';
''',
          classFinder: (l) => l.getClass('FunctionFormField')!,
          valueTypeProvider: (l) {
            final variable =
                l.topLevelElements.whereType<TopLevelVariableElement>().single;
            return GenericType.fromDartType(variable.type, variable);
          },
          formFieldGenericArgumentsProvider: (t) =>
              [toGenericType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('FunctionFormField', 'T'), 'String');
            expect(x.getMappedType('FormField', 'T'), spec.item2);
          },
        ),
      );
    }
  });

  group('generic function mapped with parameter type', () {
    for (final spec in [
      Tuple3(
        'aliased - non-aliased',
        'Callback<String>',
        'void Function<T>(T)',
      ),
      Tuple3(
        'non-aliased - aliased',
        'void Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased - aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased - non-aliased',
        'void Function(String)',
        'void Function<T>(T)',
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: '''
typedef Callback<T> = void Function(T);
class FormField<T> {}
class FunctionFormField<T> extends FormField<${spec.item3}> {}
final ${spec.item2} callback = (_) {};
''',
          classFinder: (l) => l.getClass('FunctionFormField')!,
          valueTypeProvider: (l) {
            final variable =
                l.topLevelElements.whereType<TopLevelVariableElement>().single;
            return GenericType.fromDartType(variable.type, variable);
          },
          formFieldGenericArgumentsProvider: (t) =>
              [toGenericType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('FunctionFormField', 'T'), 'String');
            expect(x.getMappedType('FormField', 'T'), spec.item2);
          },
        ),
      );
    }
  });

  group('generic type resolution', () {
    // 1. case
    // 2. code
    // 3. target class name
    // 4. target class generic arguments
    // 5. expected (map)
    // All field types are List<String> in following.
    for (final spec in [
      Tuple5(
        'super parameter in ancestors',
        '''
$_baseTypes
$_baseGeneric1

const Type target = DerviedParameterListHolder<String>;
''',
        'DerviedParameterListHolder',
        // ignore: avoid_types_on_closure_parameters
        (TypeProvider t) => [toGenericType(t.stringType)],
        {
          'FormField': {'T': 'List<String>'},
          'FormBuilderField': {'T': 'List<String>'},
          'BaseParameterListHolder': {'T': 'String'},
          'DerviedParameterListHolder': {'T': 'String'},
        },
      ),
      Tuple5(
        'super parameters in ancestors',
        '''
$_baseTypes
$_baseGeneric2Fully

const Type target = DerviedParameterListHolderFullyGeneric<String, String>;
''',
        'DerviedParameterListHolderFullyGeneric',
        // ignore: avoid_types_on_closure_parameters
        (TypeProvider t) => [
          toGenericType(t.stringType),
          toGenericType(t.stringType),
        ],
        {
          'FormField': {'T': 'List<String>'},
          'FormBuilderField': {'T': 'List<String>'},
          'BaseParameterListHolder2': {
            'T1': 'String',
            'T2': 'String',
          },
          'DerviedParameterListHolderFullyGeneric': {
            'T1': 'String',
            'T2': 'String',
          },
        },
      ),
      Tuple5(
        'super parameter in ancestors partially instantiated',
        '''
$_baseTypes
$_baseGeneric2Partially

const Type target = DerviedParameterListHolderPartiallyGeneric<String>;
''',
        'DerviedParameterListHolderPartiallyGeneric',
        // ignore: avoid_types_on_closure_parameters
        (TypeProvider t) => [toGenericType(t.stringType)],
        {
          'FormField': {'T': 'List<String>'},
          'FormBuilderField': {'T': 'List<String>'},
          'BaseParameterListHolder2': {
            'T1': 'String',
            'T2': 'bool',
          },
          'DerviedParameterListHolderPartiallyGeneric': {
            'T': 'String',
          },
        },
      ),
    ]) {
      test(
        spec.item1,
        () => testCore(
          code: spec.item2,
          classFinder: (l) => l.getClass(spec.item3)!,
          valueTypeProvider: (l) =>
              toGenericType(l.typeProvider.listType(l.typeProvider.stringType)),
          formFieldGenericArgumentsProvider: spec.item4,
          instantiatedFormFieldTypeProvider: (l) =>
              l.lookupTypeFromTopLevelVariable('target'),
          assertion: (x) {
            for (final typeAndMapping in spec.item5.entries) {
              for (final mappingEntry in typeAndMapping.value.entries) {
                expect(
                  x.getMappedType(typeAndMapping.key, mappingEntry.key),
                  mappingEntry.value,
                );
              }
            }
          },
        ),
      );
    }
  });
}

const _baseTypes = '''
abstract class FormField<T> {}

abstract class FormBuilderField<T> extends FormField<T> {}

''';

const _baseGeneric1 = '''
class BaseParameterListHolder<T> extends FormBuilderField<List<T>> {}

// With intermediate
class DerviedParameterListHolder<T> extends BaseParameterListHolder<T> {}
''';

const _baseGeneric2Fully = '''
class BaseParameterListHolder2<T1, T2> extends FormBuilderField<List<T1>> {}

// With intermediate, multiple generic type parameters/arguments
class DerviedParameterListHolderFullyGeneric<T1, T2>
    extends BaseParameterListHolder2<T1, T2> {}
''';

const _baseGeneric2Partially = '''
class BaseParameterListHolder2<T1, T2> extends FormBuilderField<List<T1>> {}

// With intermediate, with non-generic type argument
class DerviedParameterListHolderPartiallyGeneric<T>
    extends BaseParameterListHolder2<T, bool> {}
''';
