import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/db/app_db.dart';
import '../../core/providers.dart';
import 'alarm_format.dart' as fmt;
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

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          if (!repo.notificationsAllowed) const _SilentAlarmsWarning(),
          Expanded(
            child: alarms.isEmpty
                ? const Center(
                    child: Text(
                      'No alarms set',
                      key: ValueKey('alarms-empty'),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 88),
                    itemCount: alarms.length,
                    itemBuilder: (context, i) {
                      final a = alarms[i];
                      return _AlarmTile(
                        key: ValueKey('alarm-${a.id}'),
                        alarm: a,
                        onToggle: (on) => repo.setAlarmEnabled(a.id, on),
                        onEdit: () => _showEditor(context, ref, existing: a),
                        onDelete: () => repo.deleteAlarm(a.id),
                      );
                    },
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
    final label = (alarm.label != null && alarm.label!.isNotEmpty)
        ? alarm.label!
        : null;
    // Time dims when disabled so the on/off state reads at a glance.
    final timeColor =
        alarm.enabled ? null : theme.colorScheme.onSurfaceVariant;

    return ListTile(
      onTap: onEdit,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        fmt.formatTimeOfDay(context, alarm.timeOfDayMinutes),
        style: theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.w300,
          color: timeColor,
        ),
      ),
      subtitle: Text(
        [
          ?label,
          fmt.repeatSummary(alarm.repeatDays),
        ].join(' • '),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            key: ValueKey('delete-alarm-${alarm.id}'),
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
          Switch(
            key: ValueKey('toggle-alarm-${alarm.id}'),
            value: alarm.enabled,
            onChanged: onToggle,
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
                'Notifications are off — alarms will be silent.',
                key: const ValueKey('alarms-silent-warning'),
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
          // Big tappable time.
          InkWell(
            key: const ValueKey('pick-time'),
            onTap: _pickTime,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                timeText,
                key: const ValueKey('editor-time'),
                style: theme.textTheme.displaySmall
                    ?.copyWith(fontWeight: FontWeight.w300),
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
              border: OutlineInputBorder(),
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
