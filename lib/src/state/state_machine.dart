/// Represents a state in a state machine.
/// Each state has an [onEnter] and [onExit] callback.
/// Each state has an [handleInput] method that is called to perform state-specific logic.
/// [T] represents the type of input the state can handle.
abstract interface class State<T> {
  /// Called when the state receives a signal.
  void handleInput(T input);

  /// Called when this state becomes active.
  void onEnter();

  /// Called when this state stops being active.
  void onExit();
}

/// A simple state machine that manages transitions between states and sends signals to the current state.
/// [T] represents the type of input the state machine can handle.
class SimpleStateMachine<T> {
  State<T>? _currentState;

  /// The currently active state, or `null` if the machine is stopped.
  State<T>? get currentState => _currentState;

  /// Whether the machine currently has an active state.
  bool get isActive => _currentState != null;

  /// Replaces the active state, calling its exit and enter callbacks.
  /// Can be called on the current state to exit and re-enter it.
  void changeState(State<T> newState) {
    _currentState?.onExit();
    _currentState = newState;
    newState.onEnter();
  }

  /// Stops the machine and calls the active state's `onExit` callback.
  void stop() {
    _currentState?.onExit();
    _currentState = null;
  }

  /// Sends a signal to the active state. Signals are ignored while stopped.
  void sendInput(T input) {
    _currentState?.handleInput(input);
  }
}
