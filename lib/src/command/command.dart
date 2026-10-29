/// Represents a command that can be executed.
abstract interface class Command {
  void execute();
}

/// Represents a command that can be undone.
abstract interface class UndoableCommand implements Command {
  /// Undoes the command.
  void undo();
}