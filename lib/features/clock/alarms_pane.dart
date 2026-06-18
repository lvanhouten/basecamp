import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import '../../core/theme.dart';
import '../../core/tokens.dart';
import 'alarm_format.dart' as fmt;
import 'clock_notice.dart';
import 'data/alarm_recurrence.dart' as recur;

/// The Alarms tool (08-alarm-ui) — index 0 of the ClockScreen tabs. Lists every
/// alarm (time, optional label, repeat summary, enable toggle), and adds / edits
/// / deletes via an editor sheet. Pure UI: it reads [alarmsProvider] (already
/// ordered soonest-first by the DAO) and fires create/update/setEnabled/delete
/// through [ClockRepository] — all scheduling/permission lives there (07).
///
/// Mirrors [TimerPane]'s shape (transparent Scaffold inside the ClockScreen
/// body, FAB to add, an in-app warning when notifications are denied so the user
/// knows alarms will be silent).
class AlarmsPane extends ConsumerWidget {
  const AlarmsPane({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alarms =
        ref.watch(alarmsProvider).asData?.value ?? const <AlarmRow>[];
    final repo = ref.watch(clockRepositoryProvider);

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (!repo.notificationsAllowed) const _SilentAlarmsWarning(),
          Expanded(
            child: alarms.isEmpty
                ? const _AlarmsEmpty()
                : ListView(
                    padding: EdgeInsets.fromLTRB(
                      tokens.spacing.gutter,
                      tokens.spacing.s5,
                      tokens.spacing.gutter,
                      88,
                    ),
                    children: [
                      // One grouped card, rows separated by a single hairline —
                      // the design reference's outlined Card of ListItems.
                      Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerLowest,
                          borderRadius:
                              BorderRadius.circular(tokens.radii.lg),
                          border: Border.all(color: scheme.outlineVariant),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var i = 0; i < alarms.length; i++) ...[
                              if (i > 0)
                                Divider(
                                  height: 1,
                                  thickness: 1,
                                  color: scheme.outlineVariant,
                                  indent: tokens.spacing.s5,
                                  endIndent: tokens.spacing.s5,
                                ),
                              _AlarmTile(
                                key: ValueKey('alarm-${alarms[i].id}'),
                                alarm: alarms[i],
                                onToggle: (on) =>
                                    repo.setAlarmEnabled(alarms[i].id, on),
                                onEdit: () => _showEditor(context, ref,
                                    existing: alarms[i]),
                                onDelete: () => repo.deleteAlarm(alarms[i].id),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add-alarm'),
        // Distinct hero tag: the hub keeps every module (and the Clock module
        // keeps all three tab panes) alive in an IndexedStack, so this FAB and
        // the TimerPane's FAB coexist in the tree. A route push (e.g. the alarm
        // ring screen launching over the hub) animates Heroes across that whole
        // subtree, and two default-tagged FABs would collide. A unique tag keeps
        // them apart.
        heroTag: 'add-alarm-fab',
        onPressed: () => _showEditor(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Alarm'),
      ),
    );
  }

  /// Open the editor for a new alarm ([existing] null) or to edit one. On save
  /// it routes to create/update on the repository (which (re)schedules).
  Future<void> _showEditor(
    BuildContext context,
    WidgetRef ref, {
    AlarmRow? existing,
  }) async {
    final result = await showModalBottomSheet<_AlarmDraft>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AlarmEditorSheet(existing: existing),
    );
    if (result == null) return;
    final repo = ref.read(clockRepositoryProvider);
    if (existing == null) {
      await repo.createAlarm(
        timeOfDayMinutes: result.timeOfDayMinutes,
        repeatDays: result.repeatDays,
        label: result.label,
      );
    } else {
      await repo.updateAlarm(
        existing.id,
        timeOfDayMinutes: result.timeOfDayMinutes,
        repeatDays: result.repeatDays,
        label: result.label,
      );
    }
  }
}

/// One row in the alarms list: time, optional label + repeat summary, and the
/// enable toggle. Tapping the body opens the editor; the trailing switch is the
/// true on/off; a delete affordance removes it.
class _AlarmTile extends StatelessWidget {
  const _AlarmTile({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  final AlarmRow alarm;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;
    final label = (alarm.label != null && alarm.label!.isNotEmpty)
        ? alarm.label!
        : null;
    // Time + subtitle dim when disabled so the on/off state reads at a glance.
    final timeColor =
        alarm.enabled ? scheme.onSurface : scheme.onSurfaceVariant;
    final subtitle = [
      ?label,
      fmt.repeatSummary(alarm.repeatDays),
    ].join(' • ');

    return InkWell(
      onTap: onEdit,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.s5,
          vertical: tokens.spacing.s4,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The alarm time in the brand sans with tabular figures.
                  Text(
                    fmt.formatTimeOfDay(context, alarm.timeOfDayMinutes),
                    style: numericTextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: timeColor,
                    ),
                  ),
                  SizedBox(height: tokens.spacing.s1),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox(width: tokens.spacing.s2),
            IconButton(
              key: ValueKey('delete-alarm-${alarm.id}'),
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              color: scheme.onSurfaceVariant,
              onPressed: onDelete,
            ),
            Switch(
              key: ValueKey('toggle-alarm-${alarm.id}'),
              value: alarm.enabled,
              onChanged: onToggle,
            ),
          ],
        ),
      ),
    );
  }
}

/// The empty state — no alarms set. Calm, encouraging brand voice.
class _AlarmsEmpty extends StatelessWidget {
  const _AlarmsEmpty();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;
    return Center(
      child: Column(
        key: const ValueKey('alarms-empty'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.alarm, size: 40, color: scheme.onSurfaceVariant),
          SizedBox(height: tokens.spacing.s4),
          Text(
            'No alarms set',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          SizedBox(height: tokens.spacing.s1),
          Text(
            'Tap the button below to add one.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

/// In-app notice shown when notification permission is denied: alarms still
/// persist but no full-screen ring will fire — they're silent.
class _SilentAlarmsWarning extends StatelessWidget {
  const _SilentAlarmsWarning();

  @override
  Widget build(BuildContext context) {
    return const ClockSilentNotice(
      messageKey: ValueKey('alarms-silent-warning'),
      message: 'Notifications are off — alarms will be silent.',
    );
  }
}

/// The editor's result: a time-of-day, the 7-bit weekday mask, and an optional
/// label. The pane routes it to create or update.
class _AlarmDraft {
  const _AlarmDraft({
    required this.timeOfDayMinutes,
    required this.repeatDays,
    this.label,
  });

  final int timeOfDayMinutes;
  final int repeatDays;
  final String? label;
}

/// Add / edit sheet: a time picker, a Mon–Sun day selector with
/// Daily / Weekdays / Weekends presets (writing the 7-bit mask), and an optional
/// label. Pops an [_AlarmDraft] on Save. Seeded from [existing] when editing.
class _AlarmEditorSheet extends StatefulWidget {
  const _AlarmEditorSheet({this.existing});

  final AlarmRow? existing;

  @override
  State<_AlarmEditorSheet> createState() => _AlarmEditorSheetState();
}

class _AlarmEditorSheetState extends State<_AlarmEditorSheet> {
  late final TextEditingController _label;
  late TimeOfDay _time;
  late int _mask;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _label = TextEditingController(text: e?.label ?? '');
    _time = e != null
        ? TimeOfDay(hour: e.timeOfDayMinutes ~/ 60, minute: e.timeOfDayMinutes % 60)
        : const TimeOfDay(hour: 7, minute: 0);
    _mask = e?.repeatDays ?? 0;
  }

  @override
  void dispose() {
    _label.dispose();
    super.dispose();
  }

  int get _timeOfDayMinutes => _time.hour * 60 + _time.minute;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  /// Flip one weekday bit (dartWeekday 1..7). Uses the brief-06 convention.
  void _toggleDay(int dartWeekday) {
    setState(() => _mask ^= recur.weekdayBit(dartWeekday));
  }

  /// Apply a preset mask (Daily / Weekdays / Weekends). Tapping the active
  /// preset again clears it back to a one-off ("Once").
  void _applyPreset(int presetMask) {
    setState(() => _mask = _mask == presetMask ? 0 : presetMask);
  }

  void _save() {
    final label = _label.text.trim();
    Navigator.of(context).pop(
      _AlarmDraft(
        timeOfDayMinutes: _timeOfDayMinutes,
        repeatDays: _mask,
        label: label.isEmpty ? null : label,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final insets = MediaQuery.of(context).viewInsets;
    final timeText = fmt.formatTimeOfDay(context, _timeOfDayMinutes);
    const dayAbbr = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.existing == null ? 'New alarm' : 'Edit alarm',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Big tappable time in the brand sans with tabular figures.
          InkWell(
            key: const ValueKey('pick-time'),
            onTap: _pickTime,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                timeText,
                key: const ValueKey('editor-time'),
                style: numericTextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Presets.
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                key: const ValueKey('preset-daily'),
                label: const Text('Daily'),
                selected: _mask == recur.everyDayMask,
                onSelected: (_) => _applyPreset(recur.everyDayMask),
              ),
              ChoiceChip(
                key: const ValueKey('preset-weekdays'),
                label: const Text('Weekdays'),
                selected: _mask == fmt.weekdaysMask,
                onSelected: (_) => _applyPreset(fmt.weekdaysMask),
              ),
              ChoiceChip(
                key: const ValueKey('preset-weekends'),
                label: const Text('Weekends'),
                selected: _mask == fmt.weekendsMask,
                onSelected: (_) => _applyPreset(fmt.weekendsMask),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Per-day toggles, Mon..Sun (dartWeekday 1..7).
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var dartWeekday = 1; dartWeekday <= 7; dartWeekday++)
                _DayToggle(
                  key: ValueKey('day-$dartWeekday'),
                  label: dayAbbr[dartWeekday - 1],
                  selected: recur.maskHasWeekday(_mask, dartWeekday),
                  onTap: () => _toggleDay(dartWeekday),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            key: const ValueKey('alarm-label-field'),
            controller: _label,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Label (optional)',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            key: const ValueKey('save-alarm'),
            onPressed: _save,
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}

/// A single circular weekday toggle (M T W T F S S) in the editor.
class _DayToggle extends StatelessWidget {
  const _DayToggle({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      customBorder: const CircleBorder(),
      onTap: onTap,
      child: CircleAvatar(
        radius: 20,
        backgroundColor: selected
            ? theme.colorScheme.primary
            : theme.colorScheme.surfaceContainerHighest,
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
