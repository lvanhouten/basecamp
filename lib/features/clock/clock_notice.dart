import 'package:flutter/material.dart';

import '../../core/tokens.dart';

/// A soft in-app warning banner shown when notification permission is denied —
/// timers finish silently / alarms won't ring. Design-language surface: a
/// rounded danger-tint card with the error-container colours and a hairline,
/// rather than a hard full-bleed Material bar. Presentational only; the warning
/// condition (`notificationsAllowed`) is owned by the repository (unchanged).
class ClockSilentNotice extends StatelessWidget {
  const ClockSilentNotice({
    super.key,
    required this.message,
    this.messageKey,
  });

  /// The notice text (already in brand voice, sentence case).
  final String message;

  /// Optional key carried by the message [Text] so tests can target it.
  final Key? messageKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        tokens.spacing.gutter,
        tokens.spacing.s4,
        tokens.spacing.gutter,
        0,
      ),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.spacing.s5,
          vertical: tokens.spacing.s4,
        ),
        decoration: BoxDecoration(
          color: scheme.errorContainer,
          borderRadius: BorderRadius.circular(tokens.radii.md),
        ),
        child: Row(
          children: [
            Icon(Icons.notifications_off,
                color: scheme.onErrorContainer, size: 20),
            SizedBox(width: tokens.spacing.s4),
            Expanded(
              child: Text(
                message,
                key: messageKey,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: scheme.onErrorContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
