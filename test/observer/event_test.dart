import 'package:patterns/src/observer/observer.dart';
import 'package:test/test.dart';
import 'package:patterns/src/observer/event.dart';

class _TestObserver<T> implements Observer<T> {
  final void Function(T) _onUpdate;

  _TestObserver(void Function(T) onUpdate) : _onUpdate = onUpdate;

  @override
  void update(T subject) {
    _onUpdate(subject);
  }
}

void main() {
  group('SynchronousEvent', () {
    test('should notify observers on change', () {
      var notified = false;
      final event = SynchronousEvent<int>();
      final observer = _TestObserver<int>((subject) {
        notified = true;
      });
      event.addObserver(observer);
      event.onChange(1);
      expect(notified, isTrue);
    });

    test('should notify multiple observers on change', () {
      var notified1 = false;
      var notified2 = false;
      final event = SynchronousEvent<int>();
      final observer1 = _TestObserver<int>((subject) {
        notified1 = true;
      });
      final observer2 = _TestObserver<int>((subject) {
        notified2 = true;
      });
      event.addObserver(observer1);
      event.addObserver(observer2);
      event.onChange(1);
      expect(notified1, isTrue);
      expect(notified2, isTrue);
    });

    test('should not notify removed observers', () {
      var notified = false;
      final event = SynchronousEvent<int>();
      final observer = _TestObserver<int>((subject) {
        notified = true;
      });
      event.addObserver(observer);
      event.removeObserver(observer);
      event.onChange(1);
      expect(notified, isFalse);
    });

    test('should allow for multiple removals of observers', () {
      var notified1 = false;
      var notified2 = false;
      final event = SynchronousEvent<int>();
      final observer1 = _TestObserver<int>((subject) {
        notified1 = true;
      });
      final observer2 = _TestObserver<int>((subject) {
        notified2 = true;
      });
      event.addObserver(observer1);
      event.addObserver(observer2);
      event.removeObserver(observer1);
      event.removeObserver(observer2);
      event.onChange(1);
      expect(notified1, isFalse);
      expect(notified2, isFalse);
    });

    test(
      'adding the same observer multiple times should notify it only once',
      () {
        var notified = 0;
        final event = SynchronousEvent<int>();
        final observer = _TestObserver<int>((subject) {
          notified++;
        });
        event.addObserver(observer);
        event.addObserver(observer);
        event.onChange(1);
        expect(notified, 1);
      },
    );

    test('dispose clears observers', () {
      var notified = false;
      final event = SynchronousEvent<int>();
      final observer = _TestObserver<int>((subject) {
        notified = true;
      });
      event.addObserver(observer);
      event.dispose();
      event.onChange(1);
      expect(notified, isFalse);
    });
  });

  group('SingleSubscriberSynchronousEvent', () {
    test('should notify the single observer on change', () {
      var notified = false;
      final event = SingleSubscriberSynchronousEvent<int>();
      final observer = _TestObserver<int>((subject) {
        notified = true;
      });
      event.addObserver(observer);
      event.onChange(1);
      expect(notified, isTrue);
    });

    test('adding a new observer replaces the existing one', () {
      var notified1 = false;
      var notified2 = false;
      final event = SingleSubscriberSynchronousEvent<int>();
      final observer1 = _TestObserver<int>((subject) {
        notified1 = true;
      });
      final observer2 = _TestObserver<int>((subject) {
        notified2 = true;
      });
      event.addObserver(observer1);
      event.addObserver(observer2);
      event.onChange(1);
      expect(notified1, isFalse);
      expect(notified2, isTrue);
    });

    test('dispose clears the single observer', () {
      var notified = false;
      final event = SingleSubscriberSynchronousEvent<int>();
      final observer = _TestObserver<int>((subject) {
        notified = true;
      });
      event.addObserver(observer);
      event.dispose();
      event.onChange(1);
      expect(notified, isFalse);
    });
  });
}
