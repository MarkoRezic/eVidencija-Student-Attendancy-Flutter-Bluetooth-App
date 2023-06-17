extension ExtendedIterable<E> on Iterable<E> {
  /// Like Iterable<T>.map but returns Iterable as List
  List<T> mapToList<T>(T Function(E e) f) {
    return map((e) => f(e)).toList();
  }

  /// Like Iterable<T>.map but the callback has index as second argument
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    int i = 0;
    return map((e) => f(e, i++));
  }

  /// Like mapIndexed but returns iterable as List
  List<T> mapIndexedToList<T>(T Function(E e, int i) f) {
    int i = 0;
    return map((e) => f(e, i++)).toList();
  }

  /// Like mapToList but returns the list with a separator between each element
  List<T> mapToListWithSeparator<T>(T Function(E e) f, {required T separator}) {
    List<T> mappedList = map((e) => f(e)).toList();
    List<T> mappedListWithSeparator = [...mappedList];
    int index = 0;
    for (var element in mappedList) {
      if (index == mappedList.length - 1) {
        break;
      }
      mappedListWithSeparator.insert(index * 2 + 1, separator);
      index++;
    }
    return mappedListWithSeparator;
  }

  /// Like mapToListWithSeparator but the callback has index as second argument
  List<T> mapToListWithSeparatorIndexed<T>(T Function(E e, int i) f,
      {required T separator}) {
    int i = 0;
    List<T> mappedList = map((e) => f(e, i++)).toList();
    List<T> mappedListWithSeparator = [...mappedList];
    int index = 0;
    for (var element in mappedList) {
      if (index == mappedList.length - 1) {
        break;
      }
      mappedListWithSeparator.insert(index * 2 + 1, separator);
      index++;
    }
    return mappedListWithSeparator;
  }
}
