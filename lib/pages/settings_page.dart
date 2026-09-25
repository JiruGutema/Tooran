import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/categories_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/backup_service.dart';
import '../services/data_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';
import '../l10n/gen/app_localizations.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import '../widgets/lock_gate.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool? _lockAvailable;

  @override
  void initState() {
    super.initState();
    AppLock.available().then((v) {
      if (mounted) setState(() => _lockAvailable = v);
    });
  }

  Future<void> _toggleReminders(bool on) async {
    final settings = context.read<SettingsProvider>();
    final l = context.l10n;
    if (on) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted && mounted && NotificationService.supported) {
        showToast(context, l.settingsNotificationsDenied);
      }
    }
    settings.remindersEnabled = on;
  }

  Future<void> _toggleDigest(bool on) async {
    if (on) await NotificationService.instance.requestPermission();
    if (mounted) context.read<SettingsProvider>().weeklyDigest = on;
  }

  Future<void> _toggleLock(bool on) async {
    final settings = context.read<SettingsProvider>();
    final l = context.l10n;
    if (on) {
      if (_lockAvailable != true) {
        showToast(context, l.settingsAppLockUnavailable);
        return;
      }
      // Prove it works before turning it on, so nobody locks themselves out.
      if (!await AppLock.authenticate(l.lockReason)) return;
    }
    settings.appLock = on;
  }

  Future<void> _export() async {
    try {
      await BackupService().exportAndShare(subject: context.l10n.exportSubject);
    } catch (_) {
      if (mounted) showToast(context, context.l10n.errorSave);
    }
  }

  Future<void> _import() async {
    final l = context.l10n;
    BackupContents? backup;
    try {
      backup = await BackupService().pickBackup();
    } catch (_) {
      if (mounted) showToast(context, l.importInvalid);
      return;
    }
    if (backup == null || !mounted) return;
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.importPreviewTitle),
        content: Text('${l.importPreviewBody(backup!.categories.length, backup.taskCount)}\n\n${l.importMergeBody}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, 'replace'),
            child: Text(l.importReplace, style: TextStyle(color: ctx.danger)),
          ),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, 'merge'), child: Text(l.importMerge)),
        ],
      ),
    );
    if (choice == null || !mounted) return;
    await context.read<CategoriesProvider>().importBackup(backup, replace: choice == 'replace');
    if (mounted) showToast(context, l.importDone);
  }

  Future<void> _backupNow() async {
    final settings = context.read<SettingsProvider>();
    final l = context.l10n;
    final when = await BackupService().autoBackupIfDue(null);
    settings.lastAutoBackup = when;
    if (mounted) showToast(context, l.settingsBackupDone);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final s = context.watch<SettingsProvider>();
    final theme = context.watch<ThemeProvider>();
    final categories = context.watch<CategoriesProvider>().categories;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 22, 8),
              child: Row(
                children: [
                  IconBtn(icon: Icons.arrow_back, onTap: () => Navigator.pop(context)),
                  const SizedBox(width: 4),
                  Text(l.settingsTitle, style: AppTheme.eyebrow(context.ink3)),
                ],
              ),
            ),

            _Section(l.settingsAppearance),
            _ChoiceTile<ThemeMode>(
              title: l.settingsTheme,
              value: theme.themeMode,
              options: {
                ThemeMode.system: l.settingsThemeSystem,
                ThemeMode.light: l.settingsThemeLight,
                ThemeMode.dark: l.settingsThemeDark,
              },
              onChanged: theme.setThemeMode,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(l.settingsColorTheme, style: AppTheme.body(size: 15, color: context.ink)),
            ),
            SizedBox(
              height: 118,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final p in themePresets)
                    _PresetCard(
                      preset: p,
                      name: _presetName(l, p.id),
                      selected: s.themePreset == p.id,
                      onTap: () => s.themePreset = p.id,
                    ),
                ],
              ),
            ),
            _ChoiceTile<CornerStyle>(
              title: l.settingsCorners,
              value: s.corners,
              options: {
                CornerStyle.theme: l.cornersTheme,
                CornerStyle.sharp: l.cornersSharp,
                CornerStyle.rounded: l.cornersRounded,
                CornerStyle.round: l.cornersRound,
              },
              onChanged: (v) => s.corners = v,
            ),
            _ChoiceTile<CardStyle?>(
              title: l.settingsCardStyle,
              value: s.cardStyle,
              options: {
                null: l.cardsTheme,
                CardStyle.outlined: l.cardsOutlined,
                CardStyle.elevated: l.cardsElevated,
                CardStyle.filled: l.cardsFilled,
              },
              onChanged: (v) => s.cardStyle = v,
            ),
            _ChoiceTile<String?>(
              title: l.settingsLanguage,
              value: s.locale?.languageCode,
              options: {
                null: l.settingsLanguageSystem,
                'en': 'English',
                'am': 'አማርኛ',
                'om': 'Afaan Oromoo',
              },
              onChanged: (v) => s.localeCode = v,
            ),
            SwitchListTile(
              title: Text(l.settingsEthiopianCalendar),
              subtitle: Text(l.settingsEthiopianCalendarBody),
              value: s.ethiopianCalendar,
              onChanged: (v) => s.ethiopianCalendar = v,
            ),

            _Section(l.settingsGestures),
            _ChoiceTile<SwipeRightAction>(
              title: l.settingsSwipeRight,
              value: s.swipeRight,
              options: {
                SwipeRightAction.complete: l.settingsSwipeComplete,
                SwipeRightAction.edit: l.settingsSwipeEdit,
              },
              onChanged: (v) => s.swipeRight = v,
            ),
            SwitchListTile(
              title: Text(l.settingsAutoComplete),
              value: s.autoCompleteChecklist,
              onChanged: (v) => s.autoCompleteChecklist = v,
            ),
            SwitchListTile(
              title: Text(l.settingsSinkChecked),
              value: s.sinkCheckedItems,
              onChanged: (v) => s.sinkCheckedItems = v,
            ),

            _Section(l.settingsMoney),
            ListTile(
              title: Text(l.settingsCurrency),
              trailing: Text(s.defaultCurrency, style: AppTheme.mono(size: 13, color: context.ink2)),
              onTap: () async {
                final ctrl = TextEditingController(text: s.defaultCurrency);
                final v = await showDialog<String>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l.settingsCurrency),
                    content: TextField(
                      controller: ctrl,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.commonCancel)),
                      TextButton(onPressed: () => Navigator.pop(ctx, ctrl.text), child: Text(l.commonSave)),
                    ],
                  ),
                );
                if (v != null && v.trim().isNotEmpty) s.defaultCurrency = v.trim().toUpperCase();
              },
            ),
            SwitchListTile(
              title: Text(l.settingsPrivacy),
              subtitle: Text(l.settingsPrivacyBody),
              value: s.privacyMode,
              onChanged: (v) => s.privacyMode = v,
            ),

            if (NotificationService.supported) ...[
              _Section(l.settingsReminders),
              SwitchListTile(
                title: Text(l.settingsRemindersEnabled),
                subtitle: Text(l.settingsRemindersBody),
                value: s.remindersEnabled,
                onChanged: _toggleReminders,
              ),
              SwitchListTile(
                title: Text(l.settingsWeeklyDigest),
                subtitle: Text(l.settingsWeeklyDigestBody),
                value: s.weeklyDigest,
                onChanged: s.remindersEnabled ? _toggleDigest : null,
              ),
            ],

            if (NotificationService.supported) ...[
              _Section(l.settingsSpending),
              SwitchListTile(
                title: Text(l.settingsSpendingReminder),
                subtitle: Text(l.settingsSpendingReminderBody),
                value: s.spendingReminder,
                onChanged: (v) async {
                  if (v) await NotificationService.instance.requestPermission();
                  s.spendingReminder = v;
                },
              ),
              if (s.spendingReminder)
                ListTile(
                  title: Text(l.settingsSpendingReminderTime),
                  trailing: Text(
                    TimeOfDay(hour: s.spendingReminderMinutes ~/ 60, minute: s.spendingReminderMinutes % 60)
                        .format(context),
                    style: AppTheme.body(size: 14, color: context.ink2),
                  ),
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                          hour: s.spendingReminderMinutes ~/ 60, minute: s.spendingReminderMinutes % 60),
                    );
                    if (picked != null) s.spendingReminderMinutes = picked.hour * 60 + picked.minute;
                  },
                ),
            ],

            if (AppLock.platformSupported) ...[
              _Section(l.settingsSecurity),
              SwitchListTile(
                title: Text(l.settingsAppLock),
                subtitle: Text(_lockAvailable == false ? l.settingsAppLockUnavailable : l.settingsAppLockBody),
                value: s.appLock,
                onChanged: _lockAvailable == null ? null : _toggleLock,
              ),
              if (s.appLock)
                _ChoiceTile<int>(
                  title: l.settingsLockAfter,
                  value: s.lockAfterMinutes,
                  options: {
                    0: l.settingsLockImmediately,
                    1: l.settingsLockMinutes(1),
                    5: l.settingsLockMinutes(5),
                    15: l.settingsLockMinutes(15),
                  },
                  onChanged: (v) => s.lockAfterMinutes = v,
                ),
            ],

            if (WidgetService.supported) ...[
              _Section(l.settingsWidget),
              _ChoiceTile<String?>(
                title: l.settingsWidgetSource,
                value: categories.any((c) => c.id == s.widgetSource) || s.widgetSource == 'today'
                    ? s.widgetSource
                    : null,
                options: {
                  null: l.settingsWidgetFirst,
                  'today': l.settingsWidgetToday,
                  for (final c in categories) c.id: c.emoji == null ? c.name : '${c.emoji} ${c.name}',
                },
                onChanged: (v) => s.widgetSource = v,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(l.settingsWidgetHint, style: AppTheme.body(size: 12.5, color: context.ink3)),
              ),
            ],

            _Section(l.settingsBackup),
            ListTile(
              leading: const Icon(Icons.upload_file_outlined),
              title: Text(l.settingsExport),
              subtitle: Text(l.settingsExportBody),
              onTap: _export,
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: Text(l.settingsImport),
              subtitle: Text(l.settingsImportBody),
              onTap: _import,
            ),
            SwitchListTile(
              secondary: const Icon(Icons.schedule_outlined),
              title: Text(l.settingsAutoBackup),
              subtitle: Text(s.lastAutoBackup == null
                  ? l.settingsAutoBackupBody
                  : '${l.settingsAutoBackupBody}\n${l.settingsAutoBackupLast(fmtDate(context, s.lastAutoBackup!, withYear: true))}'),
              value: s.autoBackup,
              onChanged: (v) => s.autoBackup = v,
            ),
            if (s.autoBackup)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(onPressed: _backupNow, child: Text(l.settingsBackupNow)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
      child: Text(label, style: AppTheme.eyebrow(context.ink3)),
    );
  }
}

/// A list tile that opens a small picker dialog.
class _ChoiceTile<T> extends StatelessWidget {
  const _ChoiceTile({
    required this.title,
    required this.value,
    required this.options,
    required this.onChanged,
  });
  final String title;
  final T value;
  final Map<T, String> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 160),
        child: Text(
          options[value] ?? '',
          overflow: TextOverflow.ellipsis,
          style: AppTheme.body(size: 14, color: context.ink2),
        ),
      ),
      onTap: () async {
        final picked = await showDialog<(T,)>(
          context: context,
          builder: (ctx) => SimpleDialog(
            title: Text(title),
            children: [
              for (final e in options.entries)
                ListTile(
                  title: Text(e.value),
                  trailing: e.key == value ? Icon(Icons.check, color: ctx.primary) : null,
                  onTap: () => Navigator.pop(ctx, (e.key,)),
                ),
            ],
          ),
        );
        if (picked != null) onChanged(picked.$1);
      },
    );
  }
}

String _presetName(AppLocalizations l, String id) => switch (id) {
      'ocean' => l.themeOcean,
      'forest' => l.themeForest,
      'sunset' => l.themeSunset,
      'lavender' => l.themeLavender,
      'graphite' => l.themeGraphite,
      _ => l.themeHorizon,
    };

/// A tiny preview of a theme: its background, a card and the accent.
class _PresetCard extends StatelessWidget {
  const _PresetCard({
    required this.preset,
    required this.name,
    required this.selected,
    required this.onTap,
  });
  final ThemePreset preset;
  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.dark ? preset.dark : preset.light;
    final r = preset.radius;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Semantics(
        selected: selected,
        button: true,
        label: name,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 96,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: p.bg,
              borderRadius: BorderRadius.circular(r * 0.8),
              border: Border.all(
                color: selected ? p.primary : p.hairlineStrong,
                width: selected ? 2.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(r * 0.45),
                      boxShadow: preset.cards == CardStyle.elevated
                          ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6)]
                          : null,
                      border: preset.cards == CardStyle.outlined ? Border.all(color: p.hairline) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: p.primary, borderRadius: BorderRadius.circular(3)),
                          ),
                          const SizedBox(width: 4),
                          Expanded(child: Container(height: 4, color: p.ink.withValues(alpha: 0.7))),
                        ]),
                        const SizedBox(height: 5),
                        Container(height: 3, width: 40, color: p.ink3.withValues(alpha: 0.6)),
                        const SizedBox(height: 3),
                        Container(height: 3, width: 28, color: p.ink3.withValues(alpha: 0.6)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.body(size: 12, color: p.ink, weight: FontWeight.w600),
                      ),
                    ),
                    if (selected) Icon(Icons.check_circle, size: 14, color: p.primary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
