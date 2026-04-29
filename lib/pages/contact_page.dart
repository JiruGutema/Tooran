import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _open(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _copy(BuildContext ctx, String text, String label) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$label copied')));
    }
  }

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
                  Text('CONTACT', style: AppTheme.eyebrow(ink3)),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Column(
                children: [
                  _LinkRow(
                    label: 'EMAIL',
                    value: 'jirudagutema@gmail.com',
                    detail: 'For questions and support',
                    onTap: () => _open('mailto:jirudagutema@gmail.com?subject=Tooran'),
                    onLongPress: () => _copy(context, 'jirudagutema@gmail.com', 'Email'),
                  ),
                  _LinkRow(
                    label: 'WEBSITE',
                    value: 'tooran.vercel.app',
                    detail: 'Updates and news',
                    onTap: () => _open('https://tooran.vercel.app'),
                    onLongPress: () => _copy(context, 'https://tooran.vercel.app', 'URL'),
                  ),
                  _LinkRow(
                    label: 'SOURCE',
                    value: 'github.com/jirugutema/tooran',
                    detail: 'Read the code, send a patch',
                    onTap: () => _open('https://github.com/jirugutema/tooran'),
                    onLongPress: () => _copy(context, 'https://github.com/jirugutema/tooran', 'URL'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
              child: Text('THE DEVELOPER', style: AppTheme.eyebrow(ink3)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 36),
              child: Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.rMd),
                  border: Border.all(color: AppTheme.hairline(dark), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Jiru Gutema',
                        style: AppTheme.display(size: 24, color: ink)),
                    const SizedBox(height: 2),
                    Text('Software developer · Addis Ababa University',
                        style: AppTheme.body(size: 13, color: ink3)),
                    const SizedBox(height: 14),
                    Text(
                      'Building tools that feel calm. Open to feedback and collaboration.',
                      style: AppTheme.body(size: 14, color: ink2).copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: () => _open('https://jirugutema.vercel.app'),
                      child: Text(
                        'PORTFOLIO →',
                        style: AppTheme.mono(size: 11, color: primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  const _LinkRow({
    required this.label,
    required this.value,
    required this.detail,
    required this.onTap,
    required this.onLongPress,
  });
  final String label;
  final String value;
  final String detail;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final ink = dark ? AppTheme.dInk : AppTheme.lInk;
    final ink3 = dark ? AppTheme.dInk3 : AppTheme.lInk3;
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.hairline(dark), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 90, child: Text(label, style: AppTheme.eyebrow(ink3))),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value, style: AppTheme.body(size: 15, color: ink, weight: FontWeight.w500)),
                  const SizedBox(height: 2),
                  Text(detail, style: AppTheme.body(size: 12.5, color: ink3)),
                ],
              ),
            ),
            Icon(Icons.arrow_outward, size: 16, color: ink3),
          ],
        ),
      ),
    );
  }
}
