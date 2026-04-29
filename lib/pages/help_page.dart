import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  static const _gestures = [
    ['Tap a category', 'Expands the list of tasks beneath it.'],
    ['Tap the circle', 'Marks a task complete. The line strikes through.'],
    ['Tap a task', 'Opens the full description and details.'],
    ['Long press', 'Picks up the row to reorder.'],
    ['Swipe right', 'Edit. Swipe left to delete.'],
  ];

  static const _faq = [
    [
      'My tasks disappeared',
      'Tasks save automatically. If a category is missing, check History — deleted categories can be restored from there.',
    ],
    [
      'Theme not switching',
      'Tap the sun/moon icon in the top bar. Your choice is remembered.',
    ],
    [
      'Can\'t reorder',
      'Long-press a row first, then drag. Categories must be expanded to reorder their tasks.',
    ],
  ];

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
                  Text('HELP', style: AppTheme.eyebrow(ink3)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  for (final row in _gestures) _kvRow(context, row[0], row[1]),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text('TROUBLESHOOTING', style: AppTheme.eyebrow(ink3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  for (final row in _faq) _kvRow(context, row[0], row[1]),
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
                  'Tooran is local-first. Your lists never leave your device unless you say so.',
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
