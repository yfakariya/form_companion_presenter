// See LICENCE file in the root.

import 'dart:async';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:form_companion_generator/src/model.dart';
import 'package:form_companion_generator/src/type_instantiation.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

Future<void> main() async {
  final logger = Logger('instantiation_context_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  FutureOr<void> testCore({
    required String code,
    required GenericInterfaceType Function(LibraryElement) valueTypeProvider,
    required ClassElement Function(LibraryElement) classFinder,
    required void Function(TypeInstantiationContext) assertion,
    List<GenericInterfaceType> Function(TypeProvider)?
        formFieldGenericArgumentsProvider,
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
          preferredFormFieldType: GenericInterfaceType(
            formFieldType.thisType,
            formFieldGenericArgumentsProvider?.call(library.typeProvider) ?? [],
          ),
          warnings: [],
        ),
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
      classFinder: (l) => l.getType('TextFormField')!,
      valueTypeProvider: (l) =>
          GenericInterfaceType(l.typeProvider.stringType, []),
      assertion: (x) {
        expect(x.getMappedType('T'), 'T');
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
      classFinder: (l) => l.getType('DropdownButtonFormField')!,
      valueTypeProvider: (l) =>
          GenericInterfaceType(l.typeProvider.stringType, []),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericInterfaceType(t.stringType, [])],
      assertion: (x) {
        expect(x.getMappedType('T'), 'String');
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
      classFinder: (l) => l.getType('FormBuilderCheckBoxGroup')!,
      valueTypeProvider: (l) => GenericInterfaceType(
          l.typeProvider.listType(l.typeProvider.stringType), []),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericInterfaceType(t.stringType, [])],
      assertion: (x) {
        expect(x.getMappedType('T'), 'String');
      },
    ),
  );

  test(
    'non generic function',
    () => testCore(
      code: '''
typedef Callback = void Function();
const Type callbackType = Callback;
class FormField<T> {}
class FunctionFormField extends FormField<Callback> {}
''',
      classFinder: (l) => l.getType('FunctionFormField')!,
      valueTypeProvider: (l) => GenericInterfaceType(
        l.topLevelElements.whereType<TypeAliasElement>().single.aliasedType,
        [],
      ),
      assertion: (x) {
        expect(x.getMappedType('T'), 'T');
      },
    ),
  );

  test(
    'simple generic function',
    () => testCore(
      code: '''
typedef Callback<T> = T Function<T>();
const Type callbackType = Callback<String>;
class FormField<T> {}
class FunctionFormField<T> extends FormField<Callback<T>> {}
''',
      classFinder: (l) => l.getType('FunctionFormField')!,
      valueTypeProvider: (l) => GenericInterfaceType(
        l.topLevelElements.whereType<TypeAliasElement>().single.aliasedType,
        [GenericInterfaceType(l.typeProvider.stringType, [])],
      ),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericInterfaceType(t.stringType, [])],
      assertion: (x) {
        expect(x.getMappedType('T'), 'String');
      },
    ),
  );

  test(
    'nested generic function',
    () => testCore(
      code: '''
typedef Callback<T> = void Function<T>(T);
const Type callbackType = Callback<String>;
class FormField<T> {}
class FunctionFormField<T> extends FormField<List<Callback<T>>>> {}
''',
      classFinder: (l) => l.getType('FunctionFormField')!,
      valueTypeProvider: (l) => GenericInterfaceType(
        l.typeProvider.listElement.thisType,
        [
          GenericInterfaceType(
            l.topLevelElements.whereType<TypeAliasElement>().single.aliasedType,
            [GenericInterfaceType(l.typeProvider.stringType, [])],
          ),
        ],
      ),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericInterfaceType(t.stringType, [])],
      assertion: (x) {
        expect(x.getMappedType('T'), 'String');
      },
    ),
  );
}
