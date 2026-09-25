import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/common.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  List<List<String>> _gestures(BuildContext context) {
    final l = context.l10n;
    return [
      [l.helpGestureTapCategory, l.helpGestureTapCategoryBody],
      [l.helpGestureCircle, l.helpGestureCircleBody],
      [l.helpGestureTapTask, l.helpGestureTapTaskBody],
      [l.helpGestureLongPress, l.helpGestureLongPressBody],
      [l.helpGestureSwipe, l.helpGestureSwipeBody],
      [l.helpGestureChecklist, l.helpGestureChecklistBody],
      [l.helpMarkdown, l.helpMarkdownBody],
    ];
  }

  List<List<String>> _faq(BuildContext context) {
    final l = context.l10n;
    return [
      [l.helpFaqMissing, l.helpFaqMissingBody],
      [l.helpFaqTheme, l.helpFaqThemeBody],
      [l.helpFaqReorder, l.helpFaqReorderBody],
      [l.helpFaqReminders, l.helpFaqRemindersBody],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 14, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 18),
                    color: ink2,
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(context.l10n.helpTitle, style: AppTheme.eyebrow(ink3)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  for (final row in _gestures(context)) _kvRow(context, row[0], row[1]),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text(context.l10n.helpTroubleshooting, style: AppTheme.eyebrow(ink3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  for (final row in _faq(context)) _kvRow(context, row[0], row[1]),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 28, 22, 36),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.hairline(dark), width: 1),
                  ),
                ),
                child: Text(
                  context.l10n.helpLocalFirst,
                  style: AppTheme.body(size: 13, color: ink3).copyWith(height: 1.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kvRow(BuildContext context, String k, String v) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(k.toUpperCase(), style: AppTheme.eyebrow(ink3)),
          ),
          Expanded(
            child: Text(v,
                style: AppTheme.body(size: 14.5, color: ink).copyWith(height: 1.45)),
          ),
        ],
      ),
    );
  }
}
