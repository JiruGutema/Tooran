import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  static const _features = [
    ['Categories', 'A folder for the things you keep close.'],
    ['Tasks', 'Names, descriptions, gentle progress.'],
    ['Drag & drop', 'Long-press to lift. Drop anywhere.'],
    ['History', 'Deleted categories are recoverable.'],
    ['Themes', 'Warm paper by day. Deep ink by night.'],
    ['Local-first', 'No cloud, no sign-in, no telemetry.'],
  ];

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink2 = dark ? AppTheme.dInk2 : AppTheme.lInk2;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    final primary = Theme.of(context).colorScheme.primary;

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
                  Text('ABOUT', style: AppTheme.eyebrow(ink3)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: AppTheme.display(size: 56, color: ink),
                      children: [
                        const TextSpan(text: 'tooran'),
                        TextSpan(
                          text: '.',
                          style: AppTheme.display(size: 56, color: primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('VERSION 1.6.1', style: AppTheme.eyebrow(ink3)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Text(
                'Tooran is a local-first task organizer. Categories hold tasks. Tasks have descriptions. Nothing leaves your device. Productivity, in a quieter key.',
                style: AppTheme.body(size: 16, color: ink2).copyWith(height: 1.55),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text('WHAT IT DOES', style: AppTheme.eyebrow(ink3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  for (final f in _features) _row(context, f[0], f[1]),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text('CRAFTED BY', style: AppTheme.eyebrow(ink3)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
              child: Text(
                'Jiru Gutema, Addis Ababa University. Made with care, in Flutter, on a quiet evening.',
                style: AppTheme.body(size: 14, color: ink2).copyWith(height: 1.55),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: AppTheme.hairline(dark), width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('© 2025 TOORAN', style: AppTheme.mono(size: 11, color: ink3)),
                    Text('ALL RIGHTS RESERVED', style: AppTheme.mono(size: 11, color: ink3)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, String k, String v) {
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
