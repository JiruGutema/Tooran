import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' show CupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

import 'l10n/gen/app_localizations.dart';
import 'models/category.dart';
import 'pages/about_page.dart';
import 'pages/contact_page.dart';
import 'pages/help_page.dart';
import 'pages/history_page.dart';
import 'pages/responsive_home.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'providers/categories_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'services/app_intents.dart';
import 'services/backup_service.dart';
import 'services/notification_service.dart';
import 'services/share_intent_service.dart';
import 'services/widget_service.dart';
import 'services/window_service.dart';
import 'theme/app_theme.dart';
import 'utils/money.dart';
import 'widgets/common.dart';
import 'widgets/lock_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Restore the last desktop window geometry before runApp so the user lands
  // in the same window they left, instead of the runner's hardcoded 400x600.
  if (!kIsWeb && (Platform.isLinux || Platform.isWindows || Platform.isMacOS)) {
    await windowManager.ensureInitialized();
    await WindowService.instance.restoreOnStartup();
    WindowService.instance.attachListeners();
  }

  final intents = AppIntents();
  final settings = SettingsProvider();
  final categories = CategoriesProvider();

  // Reminder taps, widget links and shared text all become intents that the
  // home screen handles once it's up.
  NotificationService.instance.onOpen = intents.addNotificationPayload;
  ShareIntentService.instance.onShared = (text) => intents.add(SharedTextIntent(text));
  ShareIntentService.instance.init();
  if (WidgetService.supported) {
    HomeWidget.widgetClicked.listen(intents.addWidgetUri);
  }

  runApp(TaskManagerApp(intents: intents, settings: settings, categories: categories));

  await settings.load();
  unawaited(categories.load());
  unawaited(_startServices(intents));
}

Future<void> _startServices(AppIntents intents) async {
  try {
    await NotificationService.instance.init();
    final payload = NotificationService.instance.takeLaunchPayload();
    if (payload != null) intents.addNotificationPayload(payload);
  } catch (e) {
    debugPrint('Notifications unavailable: $e');
  }
  try {
    await WidgetService.registerCallbacks();
    if (WidgetService.supported) {
      intents.addWidgetUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
    }
  } catch (e) {
    debugPrint('Home widget unavailable: $e');
  }
  final shared = await ShareIntentService.instance.takeInitialText();
  if (shared != null && shared.trim().isNotEmpty) intents.add(SharedTextIntent(shared));
}

class TaskManagerApp extends StatefulWidget {
  const TaskManagerApp({
    super.key,
    required this.intents,
    required this.settings,
    required this.categories,
  });

  final AppIntents intents;
  final SettingsProvider settings;
  final CategoriesProvider categories;

  @override
  State<TaskManagerApp> createState() => _TaskManagerAppState();
}

class _TaskManagerAppState extends State<TaskManagerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.categories.onDataChanged = _syncExternal;
    widget.settings.addListener(_onSettingsChanged);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The home-screen widget may have changed data while we were away.
      widget.categories.reloadIfChangedExternally();
      _maybeAutoBackup();
    }
  }

  // Settings that affect reminders/widget re-run the sync; cheap and
  // debounced by the provider for data changes.
  String? _lastSettingsKey;
  void _onSettingsChanged() {
    final s = widget.settings;
    final key = '${s.remindersEnabled}|${s.weeklyDigest}|${s.widgetSource}|${s.locale}|${s.ethiopianCalendar}'
        '|${s.spendingReminder}|${s.spendingReminderMinutes}';
    if (key == _lastSettingsKey) return;
    _lastSettingsKey = key;
    if (!widget.categories.isLoading) _syncExternal(widget.categories.categories);
    _maybeAutoBackup();
  }

  bool _backupRunning = false;
  Future<void> _maybeAutoBackup() async {
    final s = widget.settings;
    if (!s.loaded || !s.autoBackup || _backupRunning || kIsWeb) return;
    _backupRunning = true;
    try {
      final when = await BackupService().autoBackupIfDue(s.lastAutoBackup);
      if (when != null) s.lastAutoBackup = when;
    } catch (e) {
      debugPrint('Auto backup failed: $e');
    } finally {
      _backupRunning = false;
    }
  }

  AppLocalizations _l10nForBackground() {
    final chosen = widget.settings.locale;
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    for (final candidate in [chosen, device]) {
      if (candidate == null) continue;
      if (AppLocalizations.supportedLocales.any((l) => l.languageCode == candidate.languageCode)) {
        return lookupAppLocalizations(Locale(candidate.languageCode));
      }
    }
    return lookupAppLocalizations(const Locale('en'));
  }

  Future<void> _syncExternal(List<Category> categories) async {
    final s = widget.settings;
    if (!s.loaded) return;
    final l = _l10nForBackground();
    try {
      await NotificationService.instance.sync(
        categories,
        remindersEnabled: s.remindersEnabled,
        weeklyDigest: s.weeklyDigest,
        spendingReminder: s.spendingReminder,
        spendingReminderMinutes: s.spendingReminderMinutes,
        texts: NotificationTexts(
          spendingTitle: l.notifSpendingTitle,
          spendingBody: l.notifSpendingBody,
          channelName: l.notifChannelName,
          channelDescription: l.notifChannelDescription,
          dueBody: l.notifDueBody,
          ledgerDueBody: l.notifLedgerDueBody,
          digestTitle: l.notifDigestTitle,
          digestBody: l.notifDigestBody,
          formatMoney: (minor, cur) => formatMoney(minor, cur, showPlus: true),
        ),
      );
    } catch (e) {
      debugPrint('Reminder sync failed: $e');
    }
    await WidgetService.update(
      categories,
      source: s.widgetSource,
      texts: WidgetTexts(
        todayTitle: l.todayTitle,
        emptyMessage: l.widgetEmpty,
        noCategoriesMessage: l.widgetNoCategories,
        leftCount: l.widgetLeft,
        netLabel: l.ledgerNetLabel,
        dueLabel: (info, task) => dueKindLabel(l, info),
        formatMoney: (minor, cur) => formatMoney(minor, cur),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()..loadThemePreference()),
        ChangeNotifierProvider.value(value: widget.settings),
        ChangeNotifierProvider.value(value: widget.categories),
        ChangeNotifierProvider.value(value: widget.intents),
      ],
      child: Consumer2<ThemeProvider, SettingsProvider>(
        builder: (context, themeProvider, settings, child) {
          AppTheme.apply(
            presetId: settings.themePreset,
            corners: settings.corners,
            cardStyle: settings.cardStyle,
          );
          return MaterialApp(
            title: 'Tooran',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            locale: settings.locale,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              _EnglishFallbackMaterial(),
              _EnglishFallbackCupertino(),
            ],
            builder: (context, child) => _ErrorListener(child: LockGate(child: child!)),
            initialRoute: '/',
            routes: {
              '/': (context) => const ResponsiveHome(),
              '/history': (context) => const HistoryPage(),
              '/help': (context) => HelpPage(),
              '/contact': (context) => ContactPage(),
              '/about': (context) => AboutPage(),
              '/search': (context) => const SearchPage(),
              '/today': (context) => const TodayPage(),
              '/people': (context) => const PeoplePage(),
              '/settings': (context) => const SettingsPage(),
            },
          );
        },
      ),
    );
  }
}

/// Shows a snackbar when saving fails anywhere in the app.
class _ErrorListener extends StatefulWidget {
  const _ErrorListener({required this.child});
  final Widget child;

  @override
  State<_ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<_ErrorListener> {
  ValueNotifier<String?>? _errors;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final errors = context.read<CategoriesProvider>().errors;
    if (errors != _errors) {
      _errors?.removeListener(_show);
      _errors = errors..addListener(_show);
    }
  }

  @override
  void dispose() {
    _errors?.removeListener(_show);
    super.dispose();
  }

  void _show() {
    if (_errors?.value == null) return;
    _errors!.value = null;
    showToast(context, context.l10n.errorSave);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Flutter ships no Material/Cupertino strings for Afaan Oromoo; use
/// English for the few built-in labels (date picker, tooltips) there.
class _EnglishFallbackMaterial extends LocalizationsDelegate<MaterialLocalizations> {
  const _EnglishFallbackMaterial();

  @override
  bool isSupported(Locale locale) => !GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) =>
      GlobalMaterialLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<MaterialLocalizations> old) => false;
}

class _EnglishFallbackCupertino extends LocalizationsDelegate<CupertinoLocalizations> {
  const _EnglishFallbackCupertino();

  @override
  bool isSupported(Locale locale) => !GlobalCupertinoLocalizations.delegate.isSupported(locale);

  @override
  Future<CupertinoLocalizations> load(Locale locale) =>
      GlobalCupertinoLocalizations.delegate.load(const Locale('en'));

  @override
  bool shouldReload(covariant LocalizationsDelegate<CupertinoLocalizations> old) => false;
}
