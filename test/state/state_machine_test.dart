import 'package:patterns/patterns.dart';
import 'package:test/test.dart';

class _TestInput {
  final String signal;
  final int? context;

  _TestInput(this.signal, [this.context]);
}

class _RecordingState implements State<_TestInput> {
  final List<String> calls = [];
  String? lastSignal;
  int? lastContext;

  @override
  void onEnter() => calls.add('enter');

  @override
  void onExit() => calls.add('exit');

  @override
  void handleInput(_TestInput input) {
    calls.add('signal');
    lastSignal = input.signal;
    lastContext = input.context;
  }
}

class _AnotherRecordingState implements State<_TestInput> {
  final List<String> calls = [];

  @override
  void onEnter() => calls.add('enter');

  @override
  void onExit() => calls.add('exit');

  @override
  void handleInput(_TestInput input) {
    calls.add('signal');
  }
}

void main() {
  group('SimpleStateMachine', () {
    test('enters, signals, and exits states', () {
      final machine = SimpleStateMachine<_TestInput>();
      final state = _RecordingState();

      machine.changeState(state);
      machine.sendInput(_TestInput('advance', 42));

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
      final machine = SimpleStateMachine<_TestInput>();
      final firstState = _RecordingState();
      final secondState = _RecordingState();

      machine.changeState(firstState);
      machine.changeState(secondState);

      expect(firstState.calls, ['enter', 'exit']);
      expect(secondState.calls, ['enter']);
      expect(machine.currentState, same(secondState));
    });

    test('changing to the current state exits and re-enters it', () {
      final machine = SimpleStateMachine<_TestInput>();
      final state = _RecordingState();

      machine.changeState(state);
      machine.changeState(state);

      expect(state.calls, ['enter', 'exit', 'enter']);
      expect(machine.currentState, same(state));
    });

    test('ignores signals while stopped', () {
      final machine = SimpleStateMachine<_TestInput>();
      final state = _RecordingState();

      machine.sendInput(_TestInput('ignored'));
      machine.changeState(state);
      machine.stop();
      machine.sendInput(_TestInput('also ignored'));

      expect(state.calls, ['enter', 'exit']);
    });

    test('allows repeated stopping', () {
      final machine = SimpleStateMachine<_TestInput>();
      final state = _RecordingState();

      machine.changeState(state);
      machine.stop();
      machine.stop();

      expect(state.calls, ['enter', 'exit']);
      expect(machine.isActive, isFalse);
      expect(machine.currentState, isNull);
    });

    test('handles multiple states correctly', () {
      final machine = SimpleStateMachine<_TestInput>();
      final firstState = _RecordingState();
      final secondState = _AnotherRecordingState();

      machine.changeState(firstState);
      machine.sendInput(_TestInput('first'));
      machine.changeState(secondState);
      machine.sendInput(_TestInput('second'));
      machine.stop();

      expect(firstState.calls, ['enter', 'signal', 'exit']);
      expect(secondState.calls, ['enter', 'signal', 'exit']);
    });
  });
}
