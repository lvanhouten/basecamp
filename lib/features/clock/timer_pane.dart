import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import 'clock_math.dart' as clock_math;

/// The countdown Timer tool — create one or more timers (a duration + optional
/// label), watch them count down concurrently, and pause / resume / cancel each.
/// A timer that reaches zero parks in a "time's up" ringing state with a Dismiss
/// affordance until the user clears it.
///
/// Persistence, OS-notification scheduling, and the contextual permission
/// request all live in [ClockRepository] (`04-timer-data`) — this pane is pure
/// UI: it reads [runningTimersProvider] (already ordered soonest `endsAt` first,
/// then creation order) and fires create/pause/resume/cancel through the repo.
///
/// Like the StopwatchPane, the displayed remaining is NEVER held here. Truth is
/// the persisted `endsAt`; an in-memory display [Ticker] only nudges `_now`
/// forward each frame and the shown value is re-derived by `clock_math` from
/// `endsAt + _now`. That is what makes the countdown correct across
/// backgrounding and cold start: on resume (or first build) `_now` re-stamps to
/// the wall clock, so the readout jumps straight to the right remaining with no
/// drift. The ticker runs only while at least one timer is still counting down
/// (a finished/paused-only list has nothing to animate).
class TimerPane extends ConsumerStatefulWidget {
  const TimerPane({super.key});

  @override
  ConsumerState<TimerPane> createState() => TimerPaneState();
}

class TimerPaneState extends ConsumerState<TimerPane>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// The wall clock as of the latest display frame. Only advances the readouts;
  /// it is NOT a record of remaining truth (that's each row's `endsAt`).
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Frame-driven, display-only: re-stamp `_now` each tick and rebuild. A
    // missed frame (backgrounded) self-corrects on the next tick because the
    // value is recomputed from `endsAt`, never accumulated.
    _ticker = createTicker((_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  /// Re-sync the display to the wall clock. Wired to the module's resume hook
  /// (`_ClockScreenState._onResume`) so countdowns that ran while backgrounded
  /// snap to the correct remaining the instant the app returns, before the next
  /// ticker frame. Cheap and idempotent.
  void resync() {
    if (!mounted) return;
    setState(() => _now = DateTime.now());
  }

  /// Run the display ticker only while something is actually counting down.
  /// Idempotent — safe to call on every build as the watched list changes.
  void _syncTicker(bool anyRunning) {
    if (anyRunning && !_ticker.isActive) {
      _now = DateTime.now();
      _ticker.start();
    } else if (!anyRunning && _ticker.isActive) {
      _ticker.stop();
    }
  }

  /// A timer is finished once its `endsAt` is set but in the (clamped) past.
  bool _isFinished(TimerRow t) =>
      t.endsAt != null && !t.endsAt!.isAfter(_now);

  /// Counting down: `endsAt` set and still in the future.
  bool _isCountingDown(TimerRow t) =>
      t.endsAt != null && t.endsAt!.isAfter(_now);

  Future<void> _showCreateSheet() async {
    final result = await showModalBottomSheet<_NewTimer>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateTimerSheet(),
    );
    if (result == null) return;
    await ref
        .read(clockRepositoryProvider)
        .createTimer(result.duration, label: result.label);
  }

  @override
  Widget build(BuildContext context) {
    final timers =
        ref.watch(runningTimersProvider).asData?.value ?? const <TimerRow>[];
    _syncTicker(timers.any(_isCountingDown));

    final repo = ref.read(clockRepositoryProvider);

    return Scaffold(
      // Transparent so the tab's themed surface shows through; the pane lives
      // inside the ClockScreen Scaffold's body.
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Surfaced only after a denial — timers still run, just silently.
          if (!repo.notificationsAllowed)
            const _SilentTimersWarning(),
          Expanded(
            child: timers.isEmpty
                ? const Center(
                    child: Text(
                      'No timers running',
                      key: ValueKey('timer-empty'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: timers.length,
                    itemBuilder: (context, i) {
                      final t = timers[i];
                      return _TimerTile(
                        key: ValueKey('timer-${t.id}'),
                        timer: t,
                        finished: _isFinished(t),
                        now: _now,
                        onPause: () => repo.pauseTimer(t.id),
                        onResume: () => repo.resumeTimer(t.id),
                        onCancel: () => repo.cancelTimer(t.id),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-timer'),
        onPressed: _showCreateSheet,
        icon: const Icon(Icons.add),
        label: const Text('Timer'),
      ),
    );
  }
}

/// One row in the running list. Renders the optional label, the live remaining
/// (re-derived from `endsAt` via clock-math), and the per-state controls:
///   - running  → Pause + Cancel
///   - paused   → Resume + Cancel
///   - finished → "Time's up" + Dismiss
class _TimerTile extends StatelessWidget {
  const _TimerTile({
    super.key,
    required this.timer,
    required this.finished,
    required this.now,
    required this.onPause,
    required this.onResume,
    required this.onCancel,
  });

  final TimerRow timer;
  final bool finished;
  final DateTime now;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onCancel;

  bool get _paused => timer.endsAt == null && timer.remainingMs != null;

  /// Displayed remaining. While running it derives from `endsAt + now` via
  /// clock-math (the acceptance criterion's exact rule); while paused the frozen
  /// captured `remainingMs` is shown; finished reads 00:00.
  Duration get _remaining {
    if (timer.endsAt != null) {
      return clock_math.countdownRemaining(endsAt: timer.endsAt!, now: now);
    }
    if (timer.remainingMs != null) {
      return Duration(milliseconds: timer.remainingMs!);
    }
    return Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = (timer.label != null && timer.label!.isNotEmpty)
        ? timer.label!
        : null;

    final Widget primary;
    if (finished) {
      primary = Text(
        "Time's up",
        key: const ValueKey('finished-label'),
        style: theme.textTheme.headlineSmall
            ?.copyWith(color: theme.colorScheme.error),
      );
    } else {
      primary = Text(
        _format(_remaining),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
          fontWeight: FontWeight.w300,
          color: _paused ? theme.colorScheme.onSurfaceVariant : null,
        ),
      );
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: primary,
      subtitle: Text(
        [
          ?label,
          if (_paused && !finished) 'Paused',
          '${_format(Duration(milliseconds: timer.durationMs))} timer',
        ].join(' • '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (finished)
            TextButton(
              key: const ValueKey('dismiss'),
              onPressed: onCancel,
              child: const Text('Dismiss'),
            )
          else ...[
            if (_paused)
              IconButton(
                key: const ValueKey('resume'),
                tooltip: 'Resume',
                icon: const Icon(Icons.play_arrow),
                onPressed: onResume,
              )
            else
              IconButton(
                key: const ValueKey('pause'),
                tooltip: 'Pause',
                icon: const Icon(Icons.pause),
                onPressed: onPause,
              ),
            IconButton(
              key: const ValueKey('cancel'),
              tooltip: 'Cancel',
              icon: const Icon(Icons.close),
              onPressed: onCancel,
            ),
          ],
        ],
      ),
    );
  }

  /// `mm:ss` below an hour; `h:mm:ss` once it crosses one.
  static String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    return h > 0 ? '$h:${two(m)}:${two(s)}' : '${two(m)}:${two(s)}';
  }
}

/// One-time in-app notice shown when the user has denied notification
/// permission: the timer still runs, but no OS alert will fire when it ends.
class _SilentTimersWarning extends StatelessWidget {
  const _SilentTimersWarning();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.notifications_off,
                color: theme.colorScheme.onErrorContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Notifications are off — timers will finish silently.',
                key: const ValueKey('silent-warning'),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The result of the create sheet: a non-zero [duration] and an optional label.
class _NewTimer {
  const _NewTimer(this.duration, this.label);
  final Duration duration;
  final String? label;
}

/// Duration entry (hours / minutes / seconds) plus an optional label, returning
/// a [_NewTimer] on Start. The Start action is disabled until the duration is
/// non-zero (a zero-length timer can't count down).
class _CreateTimerSheet extends StatefulWidget {
  const _CreateTimerSheet();

  @override
  State<_CreateTimerSheet> createState() => _CreateTimerSheetState();
}

class _CreateTimerSheetState extends State<_CreateTimerSheet> {
  final _label = TextEditingController();
  int _hours = 0;
  int _minutes = 0;
  int _seconds = 0;

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  Duration get _duration =>
      Duration(hours: _hours, minutes: _minutes, seconds: _seconds);

  void _start() {
    final label = _label.text.trim();
    Navigator.of(context).pop(
      _NewTimer(_duration, label.isEmpty ? null : label),
    );
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('New timer', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _UnitField(
                  key: const ValueKey('hours-field'),
                  label: 'hrs',
                  value: _hours,
                  max: 99,
                  onChanged: (v) => setState(() => _hours = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _UnitField(
                  key: const ValueKey('minutes-field'),
                  label: 'min',
                  value: _minutes,
                  max: 59,
                  onChanged: (v) => setState(() => _minutes = v),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _UnitField(
                  key: const ValueKey('seconds-field'),
                  label: 'sec',
                  value: _seconds,
                  max: 59,
                  onChanged: (v) => setState(() => _seconds = v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('label-field'),
            controller: _label,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('start-timer'),
            onPressed: _duration > Duration.zero ? _start : null,
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }
}

/// A single labelled numeric field (hrs/min/sec) for the duration entry. Parses
/// to an int clamped to `[0, max]`; empty reads as 0.
class _UnitField extends StatelessWidget {
  const _UnitField({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (raw) {
        final parsed = int.tryParse(raw.trim()) ?? 0;
        onChanged(parsed.clamp(0, max));
      },
    );
  }
}
