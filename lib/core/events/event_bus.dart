import 'dart:async';

import 'domain_event.dart';

/// A process-wide, in-memory pub/sub channel. Publishers and subscribers are
/// mutually blind — coupled only to the event *type*. Runtime-only: nothing
/// here survives a process kill (by design).
///
/// Hosted as a singleton by `eventBusProvider`, so Riverpod owns its lifecycle.
class EventBus {
  final StreamController<DomainEvent> _controller =
      StreamController<DomainEvent>.broadcast();

  void publish(DomainEvent event) => _controller.add(event);

  /// Typed subscription: `bus.on<WorkoutCompleted>().listen(...)`.
  Stream<T> on<T extends DomainEvent>() =>
      _controller.stream.where((e) => e is T).cast<T>();

  void dispose() => _controller.close();
}
