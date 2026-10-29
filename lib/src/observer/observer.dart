abstract interface class Observer<T> {
  /// Called when subject is updated.
  void update(T subject);
}
