extension ExtendedIterable<T> on Iterable<T> {
  /// returns a list containing all elements that are not null
  List<T> removeNull() {
    return where((element) => element != null).toList();
  }
}
