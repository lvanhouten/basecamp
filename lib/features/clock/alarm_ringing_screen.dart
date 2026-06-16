import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import 'alarm_format.dart' as fmt;
import 'data/chime_player.dart';

/// Snooze interval for the v1 alarm ring — fixed 9 minutes (ADR-0003 / PRD:
/// per-alarm snooze config is deferred). The data layer already parameterizes
/// `snooze(id, minutes)`; this is the one caller-side value.
const int kSnoozeMinutes = 9;

/// The full-screen alarm ring (08-alarm-ui). Presents ONE ringing alarm with a
/// large Snooze (fixed 9 min) and Dismiss, and plays the looping default chime
/// (the `07` capability via [chimePlayerProvider]) from the moment it opens
/// until the user acts (ADR-0003: continuous ringing is the launched screen's
/// job, not the one-shot notification sound).
///
/// Reached when a full-screen alarm notification launches/resumes the app: the
/// root (`app.dart`) reads the firing notification's `alarm:<id>` payload and
/// pushes this screen for that alarm. It looks the alarm row up from the live
/// [alarmsProvider] for its time/label; if the alarm was deleted out from under
/// the ring it still shows a generic ring (the id is enough to Snooze/Dismiss).
///
/// A [ConsumerStatefulWidget] because it owns the chime lifecycle (start on
/// mount, stop on action / dispose) — that needs State, not a bare build.
class AlarmRingingScreen extends ConsumerStatefulWidget {
  const AlarmRingingScreen({super.key, required this.alarmId});

  /// The firing alarm's row id (decoded from the notification payload).
  final int alarmId;

  @override
  ConsumerState<AlarmRingingScreen> createState() => _AlarmRingingScreenState();
}

class _AlarmRingingScreenState extends ConsumerState<AlarmRingingScreen> {
  /// The chime, captured in [initState] so [dispose] can stop it WITHOUT reading
  /// `ref` (reading a provider via `ref` once the widget is deactivated is unsafe
  /// — Riverpod throws). It's the same instance the provider hands out.
  late final ChimePlayer _chime;

  /// Guards against the chime being stopped twice (e.g. an action tap followed
  /// by dispose) — `stop()` is a no-op when not playing, but we also avoid the
  /// redundant call.
  bool _silenced = false;

  @override
  void initState() {
    super.initState();
    _chime = ref.read(chimePlayerProvider);
    // Start looping the moment the ring screen opens (post-frame so the provider
    // container is fully wired). The notification sound was one-shot; THIS is the
    // continuous ring (ADR-0003).
    WidgetsBinding.instance.addPostFrameCallback((_) => _chime.start());
  }

  Future<void> _silence() async {
    if (_silenced) return;
    _silenced = true;
    await _chime.stop();
  }

  @override
  void dispose() {
    // Defensive: if the screen is torn down without an explicit Snooze/Dismiss
    // (e.g. the route is popped programmatically), the chime must still stop.
    // Uses the captured [_chime], never `ref` (unsafe in dispose).
    if (!_silenced) {
      _silenced = true;
      _chime.stop(); // fire-and-forget; the widget is going away.
    }
    super.dispose();
  }

  Future<void> _snooze() async {
    await _silence();
    await ref.read(clockRepositoryProvider).snooze(widget.alarmId, kSnoozeMinutes);
    _close();
  }

  Future<void> _dismiss() async {
    await _silence();
    await ref.read(clockRepositoryProvider).dismiss(widget.alarmId);
    _close();
  }

  /// Leave the ring screen if it is on a poppable route (it is pushed on the
  /// root navigator when an alarm fires). Guarded so a non-pushed mount (a test
  /// that pumps it as `home:`) doesn't throw.
  void _close() {
    final nav = Navigator.of(context);
    if (nav.canPop()) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Look up the firing alarm for its time/label. The provider is the live
    // ordered list; null (deleted/not-yet-loaded) falls back to a generic ring.
    final alarms =
        ref.watch(alarmsProvider).asData?.value ?? const <AlarmRow>[];
    AlarmRow? alarm;
    for (final a in alarms) {
      if (a.id == widget.alarmId) {
        alarm = a;
        break;
      }
    }

    final label = (alarm?.label != null && alarm!.label!.isNotEmpty)
        ? alarm.label!
        : null;
    final timeText =
        alarm != null ? fmt.formatTimeOfDay(context, alarm.timeOfDayMinutes) : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            children: [
              const Spacer(),
              Icon(
                Icons.alarm,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              if (timeText != null)
                Text(
                  timeText,
                  key: const ValueKey('ringing-time'),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                label ?? 'Alarm',
                key: const ValueKey('ringing-label'),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Large Snooze — the primary, low-friction action for a wake alarm.
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const ValueKey('ringing-snooze'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                    textStyle: theme.textTheme.titleLarge,
                  ),
                  onPressed: _snooze,
                  child: const Text('Snooze 9 min'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  key: const ValueKey('ringing-dismiss'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(72),
                    textStyle: theme.textTheme.titleLarge,
                  ),
                  onPressed: _dismiss,
                  child: const Text('Dismiss'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
