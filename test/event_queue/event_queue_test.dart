import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  group('EventQueue', () {
    test('dispatches queued events in FIFO order', () {
      final queue = EventQueue<String>()
        ..enqueue('first')
        ..enqueue('second')
        ..enqueue('third');
      final received = <String>[];

      final dispatched = queue.dispatch(received.add);

      expect(dispatched, 3);
      expect(received, ['first', 'second', 'third']);
      expect(queue.isEmpty, isTrue);
      expect(queue.pendingCount, 0);
    });

    test('leaves events enqueued during dispatch for the next call', () {
      final queue = EventQueue<int>()..enqueue(1);
      final received = <int>[];

      final dispatched = queue.dispatch((event) {
        received.add(event);
        queue.enqueue(2);
      });

      expect(dispatched, 1);
      expect(received, [1]);
      expect(queue.pendingCount, 1);

      queue.dispatch(received.add);
      expect(received, [1, 2]);
    });

    test('dispatch on an empty queue returns zero', () {
      final queue = EventQueue<int>();

      expect(queue.dispatch((_) => fail('No event should be dispatched')), 0);
    });

    test('clear removes pending events', () {
      final queue = EventQueue<int>()
        ..enqueue(1)
        ..enqueue(2);

      queue.clear();

      expect(queue.isEmpty, isTrue);
      expect(queue.pendingCount, 0);
    });

    test('rejects recursive dispatch and remains usable', () {
      final queue = EventQueue<int>()..enqueue(1);

      expect(
        () => queue.dispatch((_) => queue.dispatch((_) {})),
        throwsStateError,
      );
      expect(queue.pendingCount, 0);

      queue.enqueue(2);
      expect(queue.dispatch((_) {}), 1);
    });

    test('rejects clearing during dispatch and remains usable', () {
      final queue = EventQueue<int>()
        ..enqueue(1)
        ..enqueue(2);

      expect(() => queue.dispatch((_) => queue.clear()), throwsStateError);
      expect(queue.pendingCount, 1);
      expect(queue.dispatch((_) {}), 1);
    });

    test('keeps undispatched events when a handler throws', () {
      final queue = EventQueue<int>()
        ..enqueue(1)
        ..enqueue(2);
      final received = <int>[];

      expect(
        () => queue.dispatch((event) {
          received.add(event);
          throw StateError('handler failed');
        }),
        throwsStateError,
      );

      expect(received, [1]);
      expect(queue.pendingCount, 1);
      expect(queue.dispatch(received.add), 1);
      expect(received, [1, 2]);
    });

    test('continues after errors and reports each failed event', () {
      final queue = EventQueue<int>()
        ..enqueue(1)
        ..enqueue(2)
        ..enqueue(3);
      final received = <int>[];

      final result = queue.dispatchContinuing((event) {
        if (event == 2) throw StateError('handler failed');
        received.add(event);
      });

      expect(received, [1, 3]);
      expect(result.processedCount, 3);
      expect(result.succeededCount, 2);
      expect(result.hasErrors, isTrue);
      expect(result.failures, hasLength(1));
      expect(result.failures.single.event, 2);
      expect(result.failures.single.error, isA<StateError>());
      expect(result.failures.single.stackTrace, isA<StackTrace>());
      expect(queue.isEmpty, isTrue);
    });

    test('defers newly enqueued events when continuing after errors', () {
      final queue = EventQueue<int>()..enqueue(1);
      final received = <int>[];

      final result = queue.dispatchContinuing((event) {
        received.add(event);
        queue.enqueue(2);
      });

      expect(result.processedCount, 1);
      expect(received, [1]);
      expect(queue.pendingCount, 1);

      queue.dispatch(received.add);
      expect(received, [1, 2]);
    });
  });
}
