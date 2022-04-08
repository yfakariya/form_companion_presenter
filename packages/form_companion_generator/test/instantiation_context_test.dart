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
import 'package:tuple/tuple.dart';

Future<void> main() async {
  final logger = Logger('instantiation_context_test');
  Logger.root.level = Level.INFO;
  logger.onRecord.listen(print);

  FutureOr<void> testCore({
    required String code,
    required GenericType Function(LibraryElement) valueTypeProvider,
    required ClassElement Function(LibraryElement) classFinder,
    required void Function(TypeInstantiationContext) assertion,
    List<GenericType> Function(TypeProvider)? formFieldGenericArgumentsProvider,
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
          GenericType.fromDartType(l.typeProvider.stringType),
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
          GenericType.fromDartType(l.typeProvider.stringType),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericType.fromDartType(t.stringType)],
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
      valueTypeProvider: (l) => GenericType.fromDartType(
          l.typeProvider.listType(l.typeProvider.stringType)),
      formFieldGenericArgumentsProvider: (t) =>
          [GenericType.fromDartType(t.stringType)],
      assertion: (x) {
        expect(x.getMappedType('T'), 'String');
      },
    ),
  );

  group('non generic function', () {
    for (final spec in [
      Tuple3('aliased -> non-aliased', 'Callback', 'void Function()'),
      Tuple3('non-aliased -> aliased', 'void Function()', 'Callback'),
      Tuple3('aliased -> aliased', 'Callback', 'Callback'),
      Tuple3(
          'non-aliased -> non-aliased', 'void Function()', 'void Function()'),
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
          classFinder: (l) => l.getType('FunctionFormField')!,
          valueTypeProvider: (l) => GenericType.fromDartType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          assertion: (x) {
            expect(x.getMappedType('T'), 'T');
          },
        ),
      );
    }
  });

  group('simple generic function', () {
    for (final spec in [
      Tuple3(
        'aliased -> non-aliased',
        'Callback<String>',
        'T Function<T>(T)',
      ),
      Tuple3(
        'non-aliased -> aliased',
        'String Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased -> aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased -> non-aliased',
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
          classFinder: (l) => l.getType('FunctionFormField')!,
          valueTypeProvider: (l) => GenericType.fromDartType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          formFieldGenericArgumentsProvider: (t) =>
              [GenericType.fromDartType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('T'), 'String');
          },
        ),
      );
    }
  });

  group('nested generic function', () {
    for (final spec in [
      Tuple3(
        'aliased -> non-aliased',
        'Callback<String>',
        'T Function<T>(T)',
      ),
      Tuple3(
        'non-aliased -> aliased',
        'String Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased -> aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased -> non-aliased',
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
          classFinder: (l) => l.getType('FunctionFormField')!,
          valueTypeProvider: (l) => GenericType.fromDartType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          formFieldGenericArgumentsProvider: (t) =>
              [GenericType.fromDartType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('T'), 'String');
          },
        ),
      );
    }
  });

  group('generic function mapped with return type', () {
    for (final spec in [
      Tuple3(
        'aliased -> non-aliased',
        'Callback<String>',
        'T Function<T>()',
      ),
      Tuple3(
        'non-aliased -> aliased',
        'String Function()',
        'Callback<T>',
      ),
      Tuple3(
        'aliased -> aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased -> non-aliased',
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
          classFinder: (l) => l.getType('FunctionFormField')!,
          valueTypeProvider: (l) => GenericType.fromDartType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          formFieldGenericArgumentsProvider: (t) =>
              [GenericType.fromDartType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('T'), 'String');
          },
        ),
      );
    }
  });

  group('generic function mapped with parameter type', () {
    for (final spec in [
      Tuple3(
        'aliased -> non-aliased',
        'Callback<String>',
        'void Function<T>(T)',
      ),
      Tuple3(
        'non-aliased -> aliased',
        'void Function(String)',
        'Callback<T>',
      ),
      Tuple3(
        'aliased -> aliased',
        'Callback<String>',
        'Callback<T>',
      ),
      Tuple3(
        'non-aliased -> non-aliased',
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
          classFinder: (l) => l.getType('FunctionFormField')!,
          valueTypeProvider: (l) => GenericType.fromDartType(
            l.topLevelElements.whereType<TopLevelVariableElement>().single.type,
          ),
          formFieldGenericArgumentsProvider: (t) =>
              [GenericType.fromDartType(t.stringType)],
          assertion: (x) {
            expect(x.getMappedType('T'), 'String');
          },
        ),
      );
    }
  });
}
