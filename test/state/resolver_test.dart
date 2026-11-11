import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  group('Resolver', () {
    test('uses the default value when there are no requests', () {
      final resolver = Resolver<String>(defaultValue: 'default');

      expect(resolver.value, 'default');
      expect(resolver.winningWriterId, isNull);
      expect(resolver.winningPriority, isNull);
      expect(resolver.hasRequests, isFalse);
    });

    test('the highest priority request wins', () {
      final resolver = Resolver<String>(defaultValue: 'default')
        ..request(1, 'low value', priority: 1)
        ..request(2, 'high value', priority: 10)
        ..request(3, 'medium value', priority: 5);

      expect(resolver.value, 'high value');
      expect(resolver.winningWriterId, 2);
      expect(resolver.winningPriority, 10);
    });

    test('the most recent request wins when priorities tie', () {
      final resolver = Resolver<String>(defaultValue: 'default')
        ..request(1, 'first value', priority: 3)
        ..request(2, 'second value', priority: 3);

      expect(resolver.value, 'second value');
      expect(resolver.winningWriterId, 2);
    });

    test(
      'a writer can replace its request and take the latest tie position',
      () {
        final resolver = Resolver<String>(defaultValue: 'default')
          ..request(1, 'first value', priority: 3)
          ..request(2, 'second value', priority: 3)
          ..request(1, 'updated value', priority: 3);

        expect(resolver.value, 'updated value');
        expect(resolver.winningWriterId, 1);
      },
    );

    test('releasing the winner selects the next request or default', () {
      final resolver = Resolver<String>(defaultValue: 'default')
        ..request(1, 'first value', priority: 1)
        ..request(2, 'second value', priority: 2);

      expect(resolver.release(2), isTrue);
      expect(resolver.value, 'first value');
      expect(resolver.release(1), isTrue);
      expect(resolver.value, 'default');
      expect(resolver.release(1), isFalse);
    });

    test('clear removes all requests', () {
      final resolver = Resolver<int>(defaultValue: 0)
        ..request(1, 1)
        ..request(2, 2);

      resolver.clear();

      expect(resolver.hasRequests, isFalse);
      expect(resolver.value, 0);
    });
  });
}