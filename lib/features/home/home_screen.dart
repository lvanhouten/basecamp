import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_module.dart';
import '../../core/db/app_db.dart';
import '../../core/module_navigation.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import '../../core/widgets/components.dart';
import '../../features/clock/alarm_format.dart' as fmt;
import '../../features/clock/clock_math.dart' as clock_math;
import '../../features/clock/data/alarm_recurrence.dart' as recur;
import '../../features/profile/profile_screen.dart';

/// The **Brief** — the launcher shell's first bar destination (ADR-0005), now the
/// real forward-looking daily digest (brief 05). A bar-destination body inside
/// the launcher shell: it carries **no Scaffold of its own** (the shell owns the
/// Scaffold + bar) and no navigation drawer or module grid (both moved/retired in
/// ADR-0005 — the module grid now lives in Modules, brief 06).
///
/// Three things, all in the brand voice (sentence case, no emoji, encouraging):
///  - a hero: a time-based greeting, a date eyebrow, and a top-right avatar that
///    pushes [ProfileScreen];
///  - a progress card: a [ProgressRing] over today's Lists completion with an
///    "N of M done today" line and an encouraging caption, derived from the Lists
///    open/done counts via the lists contract read models (reused, not redefined);
///  - an "Up next today" group of the only genuinely time-bound items — today's
///    enabled Alarms (wall-clock times) and running Timers (finish time) — as
///    design-system rows that open the relevant module on tap. The mockup's
///    "Later this week" section is omitted (no scheduling model exists).
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = theme.extension<BasecampTokens>()!;

    final now = DateTime.now();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.gutter,
        tokens.spacing.s6,
        tokens.spacing.gutter,
        tokens.spacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(now: now),
          SizedBox(height: tokens.spacing.s7),
          const _ProgressCard(),
          SizedBox(height: tokens.spacing.s7),
          _UpNextSection(now: now),
        ],
      ),
    );
  }
}

/// The hero: the date eyebrow + profile avatar on one line, the greeting below.
class _Hero extends StatelessWidget {
  const _Hero({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _dateEyebrow(now),
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            _ProfileAvatarButton(),
          ],
        ),
        SizedBox(height: tokens.spacing.s4),
        Text(
          _greeting(now),
          style: theme.textTheme.displaySmall,
        ),
      ],
    );
  }
}

/// The top-right avatar that opens Profile (CONTEXT.md). Pushes [ProfileScreen]
/// (which brings its own Scaffold + AppBar) over the shell — not wrapped again.
class _ProfileAvatarButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      key: const ValueKey('brief-profile-avatar'),
      customBorder: const CircleBorder(),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
      ),
      child: Semantics(
        button: true,
        label: 'Profile',
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.person_outline,
            color: scheme.primary,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// The progress card: a [ProgressRing] over today's Lists completion plus an
/// "N of M done today" line and an encouraging caption.
///
/// **What's measurable here.** The lists contract exposes exactly two scalars —
/// the list count and the open-item count — and this brief must reuse them
/// without redefining or adding read models, and without Drift changes. An
/// *item*-level "done of total" is not derivable from those two (there is no
/// done-item or total-item count anywhere in the lists surface). So progress is
/// measured at the **list** level: M = total lists, N = lists with no open items
/// ("cleared" today). N comes from the already-defined `listsProvider`
/// (`TrackedListWithCount.openCount` per list) — a reuse, not a new model; the
/// open-item-count read model feeds the caption. With no lists (M == 0) it shows
/// a calm zero-state and a full, restful ring. (Deviation recorded for the
/// orchestrator: the brief's literal "items" framing isn't derivable, so the
/// ring is list-cleared progress.)
class _ProgressCard extends ConsumerWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    // Reuse existing read models — never redefined here. `listsProvider` (the
    // per-list open counts) gives total lists + how many are cleared;
    // `openItemCountProvider` (the lists contract) drives the caption. We read
    // `listsProvider` via type inference (no `features/lists` import) so the
    // Brief never names a Lists-internal type — staying within hard rule 1's
    // import boundary while reusing the existing provider.
    final lists = ref.watch(listsProvider).asData?.value;
    final openItems = ref.watch(openItemCountProvider).asData?.value ?? 0;

    final totalLists = lists?.length ?? 0;
    final clearedLists =
        lists?.where((l) => l.openCount == 0).length ?? 0;

    final hasLists = totalLists > 0;
    final fraction = hasLists ? clearedLists / totalLists : 0.0;
    final percent = (fraction * 100).round();

    final headline = hasLists
        ? '$clearedLists of $totalLists done today'
        : 'Nothing due today';
    final caption = _progressCaption(
      hasLists: hasLists,
      openItems: openItems,
      cleared: clearedLists,
      total: totalLists,
    );

    return Container(
      padding: EdgeInsets.all(tokens.spacing.s5),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          ProgressRing(
            value: hasLists ? fraction : 1.0,
            size: 64,
            label: Text(
              hasLists ? '$percent%' : '—',
              style: numericTextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ),
          SizedBox(width: tokens.spacing.s5),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: theme.textTheme.titleSmall),
                SizedBox(height: tokens.spacing.s1),
                Text(
                  caption,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Up next today" group: today's enabled Alarms (wall-clock times) and
/// running Timers (finish time) only — the genuinely time-bound items. Rendered
/// as a [BcListGroup]; tapping a row opens the relevant module via [pushModule]
/// (so a running-timer row lands on Clock's Timer tool, an alarm row on Alarms).
/// With nothing, one calm line.
class _UpNextSection extends ConsumerWidget {
  const _UpNextSection({required this.now});

  final DateTime now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    // Keep Clock's count providers warm so `pushModule`'s entry-precedence
    // (ADR-0004: Stopwatch > Timer > Alarms) has live, settled values when a row
    // is tapped — otherwise landing falls back to Alarms (handoff 04).
    ref.watch(stopwatchRunningProvider);
    ref.watch(runningTimerCountProvider);
    ref.watch(todaysAlarmCountProvider);

    // Reuse the existing streams (not redefined): all alarms (filtered here to
    // today's enabled via the pure recurrence math) and running timers.
    final alarms = ref.watch(alarmsProvider).asData?.value ?? const <AlarmRow>[];
    final timers =
        ref.watch(runningTimersProvider).asData?.value ?? const <TimerRow>[];

    final todaysEnabledAlarms = alarms
        .where((a) =>
            a.enabled && recur.ringsToday(a.timeOfDayMinutes, a.repeatDays, now))
        .toList();

    // Surface only running timers (an `endsAt` set, even if just-finished); a
    // paused timer is not time-bound "up next". Finished-but-undismissed timers
    // read "Finishing now" via the clamped countdown math.
    final runningTimers = timers.where((t) => t.endsAt != null).toList();

    final rows = <BcListItem>[
      for (final t in runningTimers)
        BcListItem(
          key: ValueKey('brief-timer-${t.id}'),
          leading: const BcListItemIcon(Icons.timer_outlined),
          title: (t.label != null && t.label!.isNotEmpty) ? t.label! : 'Timer',
          subtitle: _timerSubtitle(t, now),
          trailing: const Icon(Icons.chevron_right, size: 18),
          onTap: () => pushModule(context, ref, AppModule.clock),
        ),
      for (final a in todaysEnabledAlarms)
        BcListItem(
          key: ValueKey('brief-alarm-${a.id}'),
          leading: const BcListItemIcon(Icons.alarm_outlined),
          title: (a.label != null && a.label!.isNotEmpty) ? a.label! : 'Alarm',
          subtitle: fmt.repeatSummary(a.repeatDays),
          trailing: Text(
            fmt.formatTimeOfDay(context, a.timeOfDayMinutes),
            style: numericTextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          onTap: () => pushModule(context, ref, AppModule.clock),
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Up next today',
          style: theme.textTheme.titleSmall
              ?.copyWith(color: scheme.onSurface),
        ),
        SizedBox(height: tokens.spacing.s4),
        if (rows.isEmpty)
          _UpNextEmpty()
        else
          BcListGroup(children: rows),
      ],
    );
  }
}

/// The calm one-line empty state for "Up next today".
class _UpNextEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Container(
      key: const ValueKey('brief-upnext-empty'),
      padding: EdgeInsets.symmetric(
        horizontal: tokens.spacing.s5,
        vertical: tokens.spacing.s5,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(tokens.radii.lg),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        'Nothing time-bound ahead — enjoy the open road.',
        style: theme.textTheme.bodyMedium
            ?.copyWith(color: scheme.onSurfaceVariant),
      ),
    );
  }
}

// ===========================================================================
// Copy / formatting helpers — pure, sentence-case, emoji-free, encouraging.
// ===========================================================================

/// Time-of-day greeting: morning < 12:00, afternoon < 18:00, else evening.
String _greeting(DateTime now) {
  final hour = now.hour;
  if (hour < 12) return 'Good morning';
  if (hour < 18) return 'Good afternoon';
  return 'Good evening';
}

/// The date eyebrow, e.g. "Tuesday · Jun 16".
String _dateEyebrow(DateTime now) {
  const weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  final weekday = weekdays[now.weekday - 1];
  final month = months[now.month - 1];
  return '$weekday · $month ${now.day}';
}

/// An encouraging caption for the progress card, never nagging. Speaks in terms
/// of the open items still ahead (via the open-item-count read model), with a
/// calm line for the empty and all-clear states.
String _progressCaption({
  required bool hasLists,
  required int openItems,
  required int cleared,
  required int total,
}) {
  if (!hasLists) return 'Your lists are clear.';
  if (openItems == 0) return 'All done — nice work.';
  if (cleared == 0) {
    return openItems == 1
        ? 'One thing to start with.'
        : 'A fresh start awaits.';
  }
  return openItems == 1
      ? 'Nice pace — one thing left.'
      : 'Nice pace — $openItems things left.';
}

/// A running timer's subtitle: its remaining time (mm:ss / h:mm:ss), clamped at
/// zero via the shared clock-math, e.g. "4:32 left" or "Finishing now".
String _timerSubtitle(TimerRow t, DateTime now) {
  final remaining = clock_math.countdownRemaining(endsAt: t.endsAt!, now: now);
  if (remaining == Duration.zero) return 'Finishing now';
  return '${_formatRemaining(remaining)} left';
}

/// Formats a positive [Duration] as mm:ss, or h:mm:ss past an hour.
String _formatRemaining(Duration d) {
  final hours = d.inHours;
  final minutes = d.inMinutes.remainder(60);
  final seconds = d.inSeconds.remainder(60);
  String two(int n) => n.toString().padLeft(2, '0');
  if (hours > 0) return '$hours:${two(minutes)}:${two(seconds)}';
  return '$minutes:${two(seconds)}';
}
