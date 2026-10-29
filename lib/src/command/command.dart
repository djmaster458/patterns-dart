/// Represents a command that can be executed.
abstract interface class ICommand {
  void execute();
}

/// Represents a command that can be undone.
abstract interface class IUndoableCommand implements ICommand {
  /// Undoes the command.
  void undo();
}