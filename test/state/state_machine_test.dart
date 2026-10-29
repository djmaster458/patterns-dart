import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

class _RecordingState implements State<String, int> {
  final List<String> calls = [];
  String? lastSignal;
  int? lastContext;

  @override
  void onEnter() => calls.add('enter');

  @override
  void onExit() => calls.add('exit');

  @override
  void onSignal(String signal, [int? context]) {
    calls.add('signal');
    lastSignal = signal;
    lastContext = context;
  }
}

void main() {
  group('SimpleStateMachine', () {
    test('enters, signals, and exits states', () {
      final machine = SimpleStateMachine<String, int>();
      final state = _RecordingState();

      machine.changeState(state);
      machine.sendSignal('advance', 42);

      expect(machine.isActive, isTrue);
      expect(machine.currentState, same(state));
      expect(state.calls, ['enter', 'signal']);
      expect(state.lastSignal, 'advance');
      expect(state.lastContext, 42);

      machine.stop();

      expect(machine.isActive, isFalse);
      expect(machine.currentState, isNull);
      expect(state.calls, ['enter', 'signal', 'exit']);
    });

    test('exits the old state before entering the new state', () {
      final machine = SimpleStateMachine<String, int>();
      final firstState = _RecordingState();
      final secondState = _RecordingState();

      machine.changeState(firstState);
      machine.changeState(secondState);

      expect(firstState.calls, ['enter', 'exit']);
      expect(secondState.calls, ['enter']);
      expect(machine.currentState, same(secondState));
    });

    test('changing to the current state exits and re-enters it', () {
      final machine = SimpleStateMachine<String, int>();
      final state = _RecordingState();

      machine.changeState(state);
      machine.changeState(state);

      expect(state.calls, ['enter', 'exit', 'enter']);
      expect(machine.currentState, same(state));
    });

    test('ignores signals while stopped and allows stopping repeatedly', () {
      final machine = SimpleStateMachine<String, int>();
      final state = _RecordingState();

      machine.sendSignal('ignored');
      machine.changeState(state);
      machine.stop();
      machine.stop();
      machine.sendSignal('also ignored');

      expect(state.calls, ['enter', 'exit']);
    });
  });
}
