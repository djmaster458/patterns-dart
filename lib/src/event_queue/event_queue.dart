import 'dart:collection';

/// A handler failure recorded by [EventQueue.dispatchContinuing].
class EventDispatchFailure<T> {
  const EventDispatchFailure({
    required this.event,
    required this.error,
    required this.stackTrace,
  });

  /// The event whose handler failed.
  final T event;

  /// The object thrown by the handler.
  final Object error;

  /// The stack trace captured when the handler failed.
  final StackTrace stackTrace;
}

/// The outcome of [EventQueue.dispatchContinuing].
class EventDispatchResult<T> {
  EventDispatchResult({
    required this.processedCount,
    required Iterable<EventDispatchFailure<T>> failures,
  }) : failures = List.unmodifiable(failures);

  /// Number of events removed from the queue and passed to the handler.
  final int processedCount;

  /// Handler failures in the order they occurred.
  final List<EventDispatchFailure<T>> failures;

  /// Number of events whose handlers completed successfully.
  int get succeededCount => processedCount - failures.length;

  /// Whether any handler failed.
  bool get hasErrors => failures.isNotEmpty;
}

/// A FIFO queue for delivering events at a later point in the program.
///
/// Events enqueued while [dispatch] is running are left for the next call.
class EventQueue<T> {
  final Queue<T> _events = Queue<T>();
  bool _isDispatching = false;

  /// The number of events waiting to be dispatched.
  int get pendingCount => _events.length;

  /// Whether there are no events waiting to be dispatched.
  bool get isEmpty => _events.isEmpty;

  /// Adds [event] to the end of the queue.
  void enqueue(T event) {
    _events.addLast(event);
  }

  /// Dispatches events that were queued when this call began, in FIFO order.
  ///
  /// Returns the number of events dispatched. Events enqueued by [handler]
  /// remain queued for the next call. Calling [dispatch] recursively throws a
  /// [StateError]. If [handler] throws, that event has already been removed;
  /// remaining events stay queued and the error is rethrown.
  int dispatch(void Function(T event) handler) {
    if (_isDispatching) {
      throw StateError('Cannot dispatch an event queue recursively.');
    }

    _isDispatching = true;
    final eventsToDispatch = _events.length;
    var dispatched = 0;
    try {
      while (dispatched < eventsToDispatch) {
        handler(_events.removeFirst());
        dispatched++;
      }
      return dispatched;
    } finally {
      _isDispatching = false;
    }
  }

  /// Dispatches the current batch in FIFO order, continuing after handler errors.
  ///
  /// Returns counts and failures, including the event, error, and stack trace
  /// for each failed handler. Events enqueued by [handler] remain queued for
  /// the next call. Recursive dispatch still throws a [StateError].
  EventDispatchResult<T> dispatchContinuing(void Function(T event) handler) {
    if (_isDispatching) {
      throw StateError('Cannot dispatch an event queue recursively.');
    }

    _isDispatching = true;
    final eventsToDispatch = _events.length;
    var processed = 0;
    final failures = <EventDispatchFailure<T>>[];
    try {
      while (processed < eventsToDispatch) {
        final event = _events.removeFirst();
        processed++;
        try {
          handler(event);
        } on Object catch (error, stackTrace) {
          failures.add(
            EventDispatchFailure<T>(
              event: event,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }

      return EventDispatchResult<T>(
        processedCount: processed,
        failures: failures,
      );
    } finally {
      _isDispatching = false;
    }
  }

  /// Removes all events currently waiting in the queue.
  ///
  /// Calling this while [dispatch] is running throws a [StateError].
  void clear() {
    if (_isDispatching) {
      throw StateError('Cannot clear an event queue while dispatching.');
    }
    _events.clear();
  }
}
