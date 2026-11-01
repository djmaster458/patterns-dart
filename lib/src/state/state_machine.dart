/// Represents a state in a state machine.
/// Each state has an [onEnter] and [onExit] callback.
/// Each state has an [update] method that is called to perform state-specific logic.
/// [update] may receive parameters as needed for state-specific logic.
/// [T] represents the type of signal the state can handle.
/// [C] represents the type of context that may be passed to the state.
abstract interface class State<T, C> {
  /// Called when the state receives a signal.
  void onSignal(T signal, [C? context]);

  /// Called when this state becomes active.
  void onEnter();

  /// Called when this state stops being active.
  void onExit();
}

/// A simple state machine that manages transitions between states and sends signals to the current state.
/// [T] represents the type of signal the state machine can handle.
/// [C] represents the type of context that may be passed along with signals.
class SimpleStateMachine<T, C> {
  State<T, C>? _currentState;
  bool _isTransitioning = false;

  /// The currently active state, or `null` if the machine is stopped.
  State<T, C>? get currentState => _currentState;

  /// Whether the machine currently has an active state.
  bool get isActive => _currentState != null;

  /// Replaces the active state, calling its exit and enter callbacks.
  ///
  /// Changing to the already active state exits and re-enters it. State
  /// transitions from within an `onEnter` or `onExit` callback are rejected.
  void changeState(State<T, C> newState) {
    _ensureNotTransitioning();

    _isTransitioning = true;
    try {
      final previousState = _currentState;
      _currentState = null;
      previousState?.onExit();
      _currentState = newState;
      newState.onEnter();
    } finally {
      _isTransitioning = false;
    }
  }

  /// Stops the machine and calls the active state's `onExit` callback.
  void stop() {
    if (_currentState == null) return;
    _ensureNotTransitioning();

    _isTransitioning = true;
    try {
      final previousState = _currentState;
      _currentState = null;
      previousState?.onExit();
    } finally {
      _isTransitioning = false;
    }
  }

  /// Sends a signal to the active state. Signals are ignored while stopped.
  void sendSignal(T signal, [C? context]) {
    _currentState?.onSignal(signal, context);
  }

  void _ensureNotTransitioning() {
    if (_isTransitioning) {
      throw StateError('Cannot change state during an enter or exit callback.');
    }
  }
}
