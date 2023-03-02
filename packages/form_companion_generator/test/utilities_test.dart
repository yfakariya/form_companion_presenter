// See LICENCE file in the root.

import 'package:analyzer/dart/element/element.dart';
import 'package:form_companion_generator/src/utilities.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final collectionsLibrary = await getResolvedLibraryResult('collections.dart');
  final myCollection = collectionsLibrary.element.getClass('MyCollection')!;
  final myList = collectionsLibrary.element.getClass('MyList')!;
  final nullableIterable = collectionsLibrary.element.topLevelElements
      .whereType<TopLevelVariableElement>()
      .singleWhere((e) => e.name == 'nullableIterable')
      .type;
  final nullableList = collectionsLibrary.element.topLevelElements
      .whereType<TopLevelVariableElement>()
      .singleWhere((e) => e.name == 'nullableList')
      .type;
  final nullableMyCollection = collectionsLibrary.element.topLevelElements
      .whereType<TopLevelVariableElement>()
      .singleWhere((e) => e.name == 'nullableMyCollection')
      .type;
  final nullableMyList = collectionsLibrary.element.topLevelElements
      .whereType<TopLevelVariableElement>()
      .singleWhere((e) => e.name == 'nullableMyList')
      .type;

  final typeProvider = collectionsLibrary.typeProvider;

  group('isCollectionType', () {
    test(
      'Iterable: true',
      () => expect(
        isCollectionType(
          typeProvider.iterableDynamicType,
          typeProvider.iterableDynamicType.element,
        ),
        isTrue,
      ),
    );

    test(
      'List: true',
      () => expect(
        isCollectionType(
          typeProvider.listType(typeProvider.dynamicType),
          typeProvider.listType(typeProvider.dynamicType).element,
        ),
        isTrue,
      ),
    );

    test(
      'Map: false',
      () => expect(
        isCollectionType(
          typeProvider.mapType(
            typeProvider.dynamicType,
            typeProvider.dynamicType,
          ),
          typeProvider
              .mapType(
                typeProvider.dynamicType,
                typeProvider.dynamicType,
              )
              .element,
        ),
        isFalse,
      ),
    );

    test(
      'String: false',
      () => expect(
        isCollectionType(
          typeProvider.stringType,
          typeProvider.stringType.element,
        ),
        isFalse,
      ),
    );

    test(
      'Custom Iterable: true',
      () => expect(
        isCollectionType(myCollection.thisType, myCollection),
        isTrue,
      ),
    );

    test(
      'Custom List: true',
      () => expect(
        isCollectionType(myList.thisType, myList),
        isTrue,
      ),
    );

    test(
      'Iterable?: true',
      () => expect(
        isCollectionType(
          nullableIterable,
          nullableIterable.element!,
        ),
        isTrue,
      ),
    );

    test(
      'List?: true',
      () => expect(
        isCollectionType(
          nullableList,
          nullableList.element!,
        ),
        isTrue,
      ),
    );

    test(
      'Custom Iterable?: true',
      () => expect(
        isCollectionType(nullableMyCollection, nullableMyCollection.element!),
        isTrue,
      ),
    );

    test(
      'Custom List?: true',
      () => expect(
        isCollectionType(nullableMyList, nullableMyList.element!),
        isTrue,
      ),
    );
  });

  group('isTypeName', () {
    test(
      'Starts with upper case -> true',
      () => expect(isTypeName('Ab'), isTrue),
    );

    test(
      'Starts with lower case -> false',
      () => expect(isTypeName('ab'), isFalse),
    );

    test(
      'Starts with underscore following upper case -> true',
      () => expect(isTypeName('_Ab'), isTrue),
    );

    test(
      'Starts with underscore following lower case -> false',
      () => expect(isTypeName('_ab'), isFalse),
    );

    test(
      'One upper case -> true',
      () => expect(isTypeName('A'), isTrue),
    );

    test(
      'One lower case -> false',
      () => expect(isTypeName('a'), isFalse),
    );

    test(
      'One underscore -> false',
      () => expect(isTypeName('_'), isFalse),
    );

    test(
      'One dollar -> false',
      () => expect(isTypeName('\$'), isFalse),
    );

    test(
      'Dollars and underscores only -> false',
      () => expect(isTypeName('\$__\$'), isFalse),
    );

    test(
      'Starts with dollar following upper case -> true',
      () => expect(isTypeName('\$Ab'), isTrue),
    );

    test(
      'Starts with dollar following lower case -> false',
      () => expect(isTypeName('\$ab'), isFalse),
    );

    test(
      'Starts with dollar and underscore following upper case -> true',
      () => expect(isTypeName('_\$Ab'), isTrue),
    );

    test(
      'Starts with dollar and underscore following lower case -> false',
      () => expect(isTypeName('_\$ab'), isFalse),
    );

    test(
      'Starts with double dollar following upper case -> true',
      () => expect(isTypeName('\$\$Ab'), isTrue),
    );

    test(
      'Starts with double dollar following lower case -> false',
      () => expect(isTypeName('\$\$ab'), isFalse),
    );

    test(
      'Starts with double dollar and double underscore following upper case -> true',
      () => expect(isTypeName('__\$\$Ab'), isTrue),
    );

    test(
      'Starts with double dollar and double underscore following lower case -> false',
      () => expect(isTypeName('__\$\$ab'), isFalse),
    );
  });
}
