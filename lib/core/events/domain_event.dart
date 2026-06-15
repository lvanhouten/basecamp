/// Shared cross-module vocabulary. A `sealed` base means exhaustive `switch`
/// handling and one obvious place to see every event the app can raise.
/// Events are transient signals — never persisted. If an effect must survive a
/// restart, the handler writes it to the database.
sealed class DomainEvent {
  const DomainEvent();
}

/// Raised when a list item's checked state flips. Carried as an example of a
/// publish site; future modules (e.g. a brief or stats module) can subscribe.
final class ListItemToggled extends DomainEvent {
  const ListItemToggled({required this.itemId, required this.done});
  final int itemId;
  final bool done;
}

// Future, when the Workouts module lands:
//   final class WorkoutCompleted extends DomainEvent { ... }
