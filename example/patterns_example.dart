import 'package:patterns/patterns.dart';

class Counter {
  int value = 0;

  final SynchronousEvent<int> changes = SynchronousEvent<int>();

  void changeBy(int amount) {
    value += amount;
    changes.onChange(value);
  }
}

class ChangeLogger implements Observer<int> {
  final String name;

  ChangeLogger(this.name);

  @override
  void update(int value) {
    print('$name observed counter value: $value');
  }
}

class ChangeCounterCommand implements IUndoableCommand {
  final Counter counter;
  final int amount;

  ChangeCounterCommand(this.counter, this.amount);

  @override
  void execute() => counter.changeBy(amount);

  @override
  void undo() => counter.changeBy(-amount);
}

void main() {
  final counter = Counter();
  final screen = ChangeLogger('Screen');
  final auditLog = ChangeLogger('Audit log');

  counter.changes
    ..addObserver(screen)
    ..addObserver(auditLog);

  final increment = ChangeCounterCommand(counter, 3);
  increment.execute();
  increment.undo();

  counter.changes.dispose();
}
