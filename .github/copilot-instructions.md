# Project Overview
The project is setup with modules that provide basic building blocks for common programming patterns. Goal is a reusable library for Dart or Flutter applications.

## Tech Stack & Versions
- **Language/Runtime:** Dart 3.x
- **Testing:** Dart's `test` package
- **Styling:** Dart's `dart format` and `dart analyze` options

## Project Structure
- `lib/allocation/` — Allocation utilities and patterns
- `lib/command/` — Command object pattern
- `lib/component/` — Entity componentry
- `lib/event_queue/` — Event queue utilities and patterns
- `lib/observer/` — Observer pattern utilities and implementations
- `lib/state/` — State management such as multiple writer resolvers and state machines
- `test` - Unit tests for the project

## Key Commands
Always use these scripts to verify changes before finishing a task:
- **Install dependencies:** `dart pub get`
- **Run linter & typecheck:** `dart analyze`
- **Run tests:** `dart test`

## Coding Standards & Conventions
- **Use consistent naming conventions** for variables, functions, components, and files.
- **Use consistent formatting** with `dart format` and the project's analysis options
- **Use consistent ordering** for imports, class members, and function definitions.

## Pitfalls & Anti-Patterns
- **Do not** introduce new third-party dependencies without explicitly prompted
