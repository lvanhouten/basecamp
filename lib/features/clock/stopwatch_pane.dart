import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import 'data/stopwatch_state.dart';

/// The single Stopwatch tool — start / pause / lap / reset over a large
/// monospace elapsed readout and an ordered lap list.
///
/// The persisted [StopwatchState] (a `ModuleData` record) is the SOURCE OF
/// TRUTH; this pane never holds the elapsed value itself. It runs an in-memory
/// display [Ticker] that only nudges `_now` forward each frame while running —
/// the shown value is always re-derived by `clock_math` from the record +
/// `_now` ([StopwatchState.elapsedAt]). That is what makes the display correct
/// after backgrounding and after a cold start: on resume (or first build) `_now`
/// is re-stamped to the wall clock and the record is re-read, so the readout
/// jumps straight to `accumulatedMs + (now − startedAt)` with no drift. The
/// record is written only on the four transitions, never per frame.
class StopwatchPane extends ConsumerStatefulWidget {
  const StopwatchPane({super.key});

  @override
  ConsumerState<StopwatchPane> createState() => StopwatchPaneState();
}

class StopwatchPaneState extends ConsumerState<StopwatchPane>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  /// The wall clock as of the latest display frame. Only advances the readout;
  /// it is NOT a record of elapsed truth (that's [StopwatchState]).
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    // A frame-driven ticker: cheap, display-only. We re-stamp `_now` each tick
    // and rebuild; the value is recomputed from the persisted record so a missed
    // frame (backgrounded) self-corrects on the next tick rather than drifting.
    _ticker = createTicker((_) {
      setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    // Stop before dispose: a Ticker that is still active when disposed throws.
    _ticker.stop();
    _ticker.dispose();
    super.dispose();
  }

  /// Re-sync the display to the wall clock. Called by the module's resume hook
  /// (`_ClockScreenState._onResume`) so a stopwatch that ran while backgrounded
  /// snaps to the correct elapsed the instant the app returns, even before the
  /// next ticker frame.
  void resync() {
    if (!mounted) return;
    setState(() => _now = DateTime.now());
  }

  /// Start/stop the display ticker to match the persisted run state. Idempotent
  /// — safe to call on every build as the watched state changes.
  void _syncTicker(bool isRunning) {
    if (isRunning && !_ticker.isActive) {
      _now = DateTime.now();
      _ticker.start();
    } else if (!isRunning && _ticker.isActive) {
      _ticker.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stopwatchStateProvider).asData?.value ??
        StopwatchState.idle;
    _syncTicker(state.isRunning);

    final repo = ref.read(clockRepositoryProvider);
    final elapsed = state.elapsedAt(_now);
    final hasElapsed = elapsed > Duration.zero || state.laps.isNotEmpty;

    return Column(
      children: [
        const SizedBox(height: 24),
        Text(
          _format(elapsed),
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                fontWeight: FontWeight.w300,
              ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lap while running; doubles as Reset when stopped & there's data.
            if (state.isRunning)
              _RoundButton(
                key: const ValueKey('lap'),
                label: 'Lap',
                onPressed: () => repo.lapStopwatch(),
              )
            else
              _RoundButton(
                key: const ValueKey('reset'),
                label: 'Reset',
                onPressed: hasElapsed ? () => repo.resetStopwatch() : null,
              ),
            const SizedBox(width: 48),
            if (state.isRunning)
              _RoundButton(
                key: const ValueKey('pause'),
                label: 'Pause',
                filled: true,
                onPressed: () => repo.pauseStopwatch(),
              )
            else
              _RoundButton(
                key: const ValueKey('start'),
                label: 'Start',
                filled: true,
                onPressed: () => repo.startStopwatch(),
              ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(height: 1),
        Expanded(
          child: state.laps.isEmpty
              ? const SizedBox.shrink()
              : ListView.builder(
                  // Newest lap on top; the label keeps the original 1-based tap
                  // order so the list reads "Lap N … Lap 1" top-to-bottom.
                  reverse: true,
                  itemCount: state.laps.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      dense: true,
                      title: Text('Lap ${i + 1}'),
                      trailing: Text(
                        _format(state.laps[i]),
                        style: const TextStyle(
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// `mm:ss.cc` (centiseconds) below an hour; `h:mm:ss.cc` once it crosses one.
  static String _format(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final cs = d.inMilliseconds.remainder(1000) ~/ 10;
    String two(int n) => n.toString().padLeft(2, '0');
    final tail = '${two(s)}.${two(cs)}';
    return h > 0 ? '$h:${two(m)}:$tail' : '${two(m)}:$tail';
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      shape: const WidgetStatePropertyAll(CircleBorder()),
      minimumSize: const WidgetStatePropertyAll(Size(84, 84)),
    );
    return filled
        ? FilledButton(onPressed: onPressed, style: style, child: Text(label))
        : OutlinedButton(onPressed: onPressed, style: style, child: Text(label));
  }
}
