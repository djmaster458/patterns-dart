/// An interface for an object pool that manages a number of reusable objects.
abstract interface class IObjectPool<T> {
  /// The number of objects currently available to acquire.
  int get availableCount;

  /// Acquires an object, or returns `null` when the pool is empty.
  T? acquire();

  /// Returns an owned object to the pool if it is not already available.
  void release(T object);
}

/// A fixed-capacity object pool that preallocates a set number of unique objects and manages their reuse.
class FixedCapacityObjectPool<T> implements IObjectPool<T> {
  FixedCapacityObjectPool(
    T Function() factory, {
    int capacity = 1,
  }) : _capacity = capacity {
    if (capacity < 0) {
      throw ArgumentError.value(capacity, 'capacity', 'Must be non-negative.');
    }

    for (var i = 0; i < capacity; i++) {
      final object = factory();
      if (_owned.containsKey(object)) {
        throw StateError('The factory must create a unique object each time.');
      }
      _owned[object] = true;
      _pool.add(object);
    }
  }

  final List<T> _pool = [];
  final Map<T, bool> _owned = Map<T, bool>.identity();
  final int _capacity;

  /// The number of objects currently available to acquire.
  @override
  int get availableCount => _pool.length;

  /// Acquires an object, or returns `null` when the pool is empty.
  @override
  T? acquire() {
    if (_pool.isEmpty) return null;
    final object = _pool.removeLast();
    _owned[object] = false;
    return object;
  }

  /// Returns an owned object to the pool if it is not already available.
  @override
  void release(T object) {
    final isAvailable = _owned[object];
    if (isAvailable == null || isAvailable) return;
    if (_pool.length < _capacity) {
      _owned[object] = true;
      _pool.add(object);
    }
  }
}