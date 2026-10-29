import 'package:test/test.dart';
import 'package:patterns/src/command/command.dart';

class _TestCommand implements ICommand {
  final void Function() _execute;
  _TestCommand(this._execute);
  @override
  void execute() => _execute();
}

class _TestUndoableCommand implements IUndoableCommand {
  final void Function() _execute;
  final void Function() _undo;
  _TestUndoableCommand(this._execute, this._undo);
  @override
  void execute() => _execute();
  @override
  void undo() => _undo();
}

void main() {
  group('Command', () {
    test('should execute command', () {
      var executed = false;
      final command = _TestCommand(() {
        executed = true;
      });
      command.execute();
      expect(executed, isTrue);
    });
    group('UndoableCommand', () {
      test('should execute and undo command', () {
        var executed = false;
        var undone = false;
        final command = _TestUndoableCommand(() {
          executed = true;
        }, () {
          undone = true;
        });
        command.execute();
        expect(executed, isTrue);
        command.undo();
        expect(undone, isTrue);
      });
    });
  });
}