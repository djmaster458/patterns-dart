import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

class _EqualObject {
  final int value;

  _EqualObject(this.value);

  @override
  bool operator ==(Object other) =>
      other is _EqualObject && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

void main() {
  group('FixedCapacityObjectPool', () {
    test('preallocates the requested number of unique objects', () {
      var factoryCalls = 0;
      final pool = FixedCapacityObjectPool<Object>(() {
        factoryCalls++;
        return Object();
      }, capacity: 2);

      expect(factoryCalls, 2);
      expect(pool.availableCount, 2);
      expect(pool.acquire(), isNot(same(pool.acquire())));
    });

    test('returns null when empty and does not create more objects', () {
      var factoryCalls = 0;
      final pool = FixedCapacityObjectPool<Object>(() {
        factoryCalls++;
        return Object();
      }, capacity: 1);

      expect(pool.acquire(), isNotNull);
      expect(pool.acquire(), isNull);
      expect(factoryCalls, 1);
    });

    test('ignores objects the pool does not own', () {
      final pool = FixedCapacityObjectPool<_EqualObject>(() => _EqualObject(1));
      final owned = pool.acquire()!;
      final equalButUnowned = _EqualObject(1);

      pool.release(equalButUnowned);

      expect(pool.availableCount, 0);
      pool.release(owned);
      expect(pool.acquire(), same(owned));
    });

    test('does not add the same object more than once', () {
      final pool = FixedCapacityObjectPool<Object>(Object.new);
      final object = pool.acquire()!;

      pool
        ..release(object)
        ..release(object);

      expect(pool.availableCount, 1);
      expect(pool.acquire(), same(object));
      expect(pool.acquire(), isNull);
    });

    test('allows zero capacity and rejects negative capacity', () {
      final pool = FixedCapacityObjectPool<Object>(Object.new, capacity: 0);

      expect(pool.availableCount, 0);
      expect(pool.acquire(), isNull);
      expect(
        () => FixedCapacityObjectPool<Object>(Object.new, capacity: -1),
        throwsArgumentError,
      );
    });

    test('requires the factory to create distinct instances', () {
      final object = Object();

      expect(
        () => FixedCapacityObjectPool<Object>(() => object, capacity: 2),
        throwsStateError,
      );
    });
  });
}