
import 'package:patterns/src/observer/observer.dart';

/// Represents an event that can be observed by one or more observers.
abstract interface class IEvent<T> {
  /// Adds an observer to the event.
  /// [observer] The observer to add to the event.
  void addObserver(Observer<T> observer);
  /// Removes an observer from the event.
  void removeObserver(Observer<T> observer);
  /// Notifies all observers of a change.
  void onChange(T subject);
}

/// A synchronous event that notifies all registered observers when it changes.
/// Duplicate addObserver calls for the same observer will only notify it once.
/// [dispose] should be called to clear all registered observers when the event is no longer needed.
class SynchronousEvent<T> implements IEvent<T> {
  final List<Observer<T>> _observers = [];

  @override
  void addObserver(Observer<T> observer) {
    if (!_observers.contains(observer)) {
      _observers.add(observer);
    }
  }

  @override
  void removeObserver(Observer<T> observer) {
    _observers.remove(observer);
  }

  @override
  void onChange(T subject) {
    for (final observer in _observers) {
      observer.update(subject);
    }
  }

  /// Call when the event is no longer needed to clear all registered observers.
  void dispose() {
    _observers.clear();
  }
}

/// A synchronous event that allows only a single subscriber.
/// Adding a new observer will replace the existing one.
/// [dispose] should be called to clear the subscriber when the event is no longer needed.
class SingleSubscriberSynchronousEvent<T> implements IEvent<T> {
  Observer<T>? _observer;

  @override
  void addObserver(Observer<T> observer) {
    _observer = observer;
  }

  @override
  void removeObserver(Observer<T> observer) {
    if (_observer == observer) {
      _observer = null;
    }
  }

  @override
  void onChange(T subject) {
    _observer?.update(subject);
  }

  void dispose() {
    _observer = null;
  }
}