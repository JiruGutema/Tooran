import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/categories_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Slide-in navigation panel for the mobile layout.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.onExpandAll,
    required this.onCollapseAll,
  });

  final VoidCallback onExpandAll;
  final VoidCallback onCollapseAll;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final provider = context.watch<CategoriesProvider>();
    final due = provider.dueTodayOrOverdue().length;
    final hasCategories = provider.categories.isNotEmpty;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    void go(String route) {
      Navigator.pop(context);
      if (route != currentRoute) Navigator.pushNamed(context, route);
    }

    void run(VoidCallback action) {
      Navigator.pop(context);
      action();
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 4, 18),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.primary,
                      borderRadius: BorderRadius.circular(AppTheme.rSm),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      't',
                      style: AppTheme.display(size: 26, color: Theme.of(context).colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tooran', style: AppTheme.display(size: 24, color: context.ink)),
                        Text(
                          fmtDate(context, DateTime.now(), withYear: true),
                          style: AppTheme.body(size: 12.5, color: context.ink3),
                        ),
                      ],
                    ),
                  ),
                  Consumer<ThemeProvider>(
                    builder: (_, tp, __) => IconBtn(
                      icon: tp.isDarkMode ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                      tooltip: l.tooltipTheme,
                      onTap: tp.toggleTheme,
                    ),
                  ),
                ],
              ),
            ),
            _Item(
              icon: Icons.today_outlined,
              label: l.menuToday,
              badge: due > 0 ? '$due' : null,
              onTap: () => go('/today'),
            ),
            _Item(icon: Icons.search, label: l.menuSearch, onTap: () => go('/search')),
            if (provider.hasLedgers)
              _Item(icon: Icons.people_outline, label: l.menuPeople, onTap: () => go('/people')),
            _Item(icon: Icons.history, label: l.menuHistory, onTap: () => go('/history')),
            if (hasCategories) ...[
              const _Divider(),
              _Item(icon: Icons.unfold_more, label: l.menuExpandAll, onTap: () => run(onExpandAll)),
              _Item(icon: Icons.unfold_less, label: l.menuCollapseAll, onTap: () => run(onCollapseAll)),
            ],
            const _Divider(),
            _Item(icon: Icons.settings_outlined, label: l.menuSettings, onTap: () => go('/settings')),
            _Item(icon: Icons.help_outline, label: l.menuHelp, onTap: () => go('/help')),
            _Item(icon: Icons.mail_outline, label: l.menuContact, onTap: () => go('/contact')),
            _Item(icon: Icons.info_outline, label: l.menuAbout, onTap: () => go('/about')),
            _Item(
              icon: Icons.system_update_outlined,
              label: l.menuUpdates,
              onTap: () => run(() => launchUrl(Uri.parse('https://tooran.vercel.app'))),
            ),
          ],
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.icon, required this.label, required this.onTap, this.badge});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: ListTile(
        leading: Icon(icon, color: context.ink2),
        title: Text(label, style: AppTheme.body(size: 15, color: context.ink, weight: FontWeight.w500)),
        trailing: badge == null
            ? null
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  badge!,
                  style: AppTheme.mono(size: 11, color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
        onTap: onTap,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Divider(height: 1, color: AppTheme.hairline(context.dark)),
    );
  }
}
