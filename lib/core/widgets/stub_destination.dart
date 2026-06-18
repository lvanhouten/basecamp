import 'package:flutter/material.dart';

import '../tokens.dart';

/// A calm, styled body for a **bar-destination stub** (Calendar / Activity).
///
/// Matches the design kit's screen head + empty-state voice: a left-aligned
/// screen [title] (the `bc-screenhead__title` role) sitting at the top of a
/// gutter-padded column, with one quiet [emptyLine] centred in the remaining
/// space (the brand's single calm empty-state line — sentence case, no emoji,
/// no fabricated data). Supersedes the centred `BarDestinationPlaceholder` for
/// the two stub destinations now that they reach their for-now form (brief 07).
///
/// A plain body (no Scaffold/AppBar): the bar destinations are persistent tab
/// bodies hosted inside the launcher shell's single Scaffold, not pushed routes.
class StubDestinationBody extends StatelessWidget {
  const StubDestinationBody({
    super.key,
    required this.title,
    required this.emptyLine,
  });

  /// The screen heading (e.g. "Calendar", "Activity") — the title role.
  final String title;

  /// The single calm empty-state line (e.g. "Nothing here yet.").
  final String emptyLine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tokens = theme.extension<BasecampTokens>()!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: tokens.spacing.gutter),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: tokens.spacing.s7),
            Text(title, style: theme.textTheme.titleLarge),
            Expanded(
              child: Center(
                child: Text(
                  emptyLine,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
