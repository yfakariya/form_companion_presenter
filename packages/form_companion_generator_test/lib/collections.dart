// See LICENCE file in the root.
// ignore_for_file: public_member_api_docs

abstract class MyList<E> extends List<E> {
  factory MyList() => throw UnimplementedError();
}

abstract class MyCollection<E> extends Iterable<E> {}

final Iterable<dynamic>? nullableIterable = null;
final List<dynamic>? nullableList = null;

final MyCollection<dynamic>? nullableMyCollection = null;
final MyList<dynamic>? nullableMyList = null;
