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
          typeProvider.iterableDynamicType.element2,
        ),
        isTrue,
      ),
    );

    test(
      'List: true',
      () => expect(
        isCollectionType(
          typeProvider.listType(typeProvider.dynamicType),
          typeProvider.listType(typeProvider.dynamicType).element2,
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
              .element2,
        ),
        isFalse,
      ),
    );

    test(
      'String: false',
      () => expect(
        isCollectionType(
          typeProvider.stringType,
          typeProvider.stringType.element2,
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
          nullableIterable.element2!,
        ),
        isTrue,
      ),
    );

    test(
      'List?: true',
      () => expect(
        isCollectionType(
          nullableList,
          nullableList.element2!,
        ),
        isTrue,
      ),
    );

    test(
      'Custom Iterable?: true',
      () => expect(
        isCollectionType(nullableMyCollection, nullableMyCollection.element2!),
        isTrue,
      ),
    );

    test(
      'Custom List?: true',
      () => expect(
        isCollectionType(nullableMyList, nullableMyList.element2!),
        isTrue,
      ),
    );
  });
}
