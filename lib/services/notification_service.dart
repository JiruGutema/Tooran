import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../models/category.dart';
import '../models/task.dart';
import '../utils/spending.dart';

/// Localized text the service needs (it runs without a BuildContext).
class NotificationTexts {
  final String channelName;
  final String channelDescription;
  final String Function(String categoryName) dueBody;
  final String Function(String person, String amount) ledgerDueBody;
  final String digestTitle;
  final String Function(int openCount, String net) digestBody;
  final String Function(int minor, String currency) formatMoney;
  final String spendingTitle;
  final String spendingBody;

  const NotificationTexts({
    required this.spendingTitle,
    required this.spendingBody,
    required this.channelName,
    required this.channelDescription,
    required this.dueBody,
    required this.ledgerDueBody,
    required this.digestTitle,
    required this.digestBody,
    required this.formatMoney,
  });
}

/// Schedules local reminders for due tasks and the weekly ledger digest.
/// Everything is rescheduled from scratch on each [sync] so the pending
/// set always matches the data.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  /// Called with the notification payload (`task:<categoryId>:<taskId>`)
  /// when the user taps a reminder.
  void Function(String payload)? onOpen;
  String? _launchPayload;

  /// Android caps pending alarms per app; stay well below it.
  static const int _maxScheduled = 60;
  static const int _digestId = 1;

  /// Daily spending reminders use ids 10..16 (one per upcoming day).
  static const int _spendingBaseId = 10;
  static const int _spendingDays = 7;
  static const String _channelId = 'reminders';

  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS);

  Future<void> init() async {
    if (!supported || _ready) return;
    tzdata.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Unknown zone name: fall back to UTC offsets from the device clock.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_tooran'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
      macOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (r) {
        final p = r.payload;
        if (p != null) onOpen?.call(p);
      },
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    if (launch?.didNotificationLaunchApp == true) {
      _launchPayload = launch!.notificationResponse?.payload;
    }
    _ready = true;
  }

  /// The payload of the reminder that launched the app, consumed once.
  String? takeLaunchPayload() {
    final p = _launchPayload;
    _launchPayload = null;
    return p;
  }

  /// Asks for permission to post notifications (Android 13+, iOS).
  Future<bool> requestPermission() async {
    if (!supported) return false;
    await init();
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission() ?? false;
      return granted;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, sound: true) ?? false;
  }

  Future<AndroidScheduleMode> _scheduleMode() async {
    if (!Platform.isAndroid) return AndroidScheduleMode.exactAllowWhileIdle;
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final exact = await android?.canScheduleExactNotifications() ?? false;
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  NotificationDetails _details(NotificationTexts texts) => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          texts.channelName,
          channelDescription: texts.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
        macOS: const DarwinNotificationDetails(),
      );

  /// When a task's reminder fires: at its time, or 9:00 for all-day tasks.
  static DateTime reminderTime(Task t) {
    final d = t.dueAt!;
    return t.dueHasTime ? d : DateTime(d.year, d.month, d.day, 9);
  }

  static int idFor(Task t) => (t.id.hashCode & 0x3fffffff) + 100;

  Future<void> sync(
    List<Category> categories, {
    required bool remindersEnabled,
    required bool weeklyDigest,
    required NotificationTexts texts,
    bool spendingReminder = false,
    int spendingReminderMinutes = 18 * 60,
  }) async {
    if (!supported) return;
    await init();
    try {
      await _plugin.cancelAllPendingNotifications();
    } catch (_) {
      await _plugin.cancelAll();
    }
    final mode = await _scheduleMode();
    final details = _details(texts);
    final now = DateTime.now();

    final upcoming = <(Category, Task, DateTime)>[
      for (final c in categories)
        for (final t in c.tasks)
          if (!t.isCompleted && t.dueAt != null && reminderTime(t).isAfter(now))
            (c, t, reminderTime(t))
    ]..sort((a, b) => a.$3.compareTo(b.$3));

    // Due-date reminders have their own switch; the spending reminder and
    // the weekly digest below are independent of it.
    for (final (c, t, at) in remindersEnabled ? upcoming.take(_maxScheduled) : const <(Category, Task, DateTime)>[]) {
      final body = c.isLedger && t.isLedgerEntry
          ? texts.ledgerDueBody(
              t.person ?? t.name, texts.formatMoney(t.remainingMinor, c.currency))
          : texts.dueBody(c.name);
      await _plugin.zonedSchedule(
        id: idFor(t),
        title: t.name,
        body: body,
        scheduledDate: tz.TZDateTime.from(at, tz.local),
        notificationDetails: details,
        androidScheduleMode: mode,
        payload: 'task:${c.id}:${t.id}',
      );
    }

    // "Log today's spending": one reminder per day for the next week at the
    // chosen time, skipping today if something was already logged. Resynced
    // on every change and app start, so it keeps rolling forward.
    final spendingLists = categories.where((c) => c.isSpending).toList();
    if (spendingReminder && spendingLists.isNotEmpty) {
      final loggedToday = loggedOn(spendingLists.map((c) => c.tasks), now);
      final times = spendingReminderTimes(now, spendingReminderMinutes, loggedToday: loggedToday);
      for (var i = 0; i < times.length && i < _spendingDays; i++) {
        await _plugin.zonedSchedule(
          id: _spendingBaseId + i,
          title: texts.spendingTitle,
          body: texts.spendingBody,
          scheduledDate: tz.TZDateTime.from(times[i], tz.local),
          notificationDetails: details,
          androidScheduleMode: mode,
          payload: 'spending:${spendingLists.first.id}',
        );
      }
    }

    if (weeklyDigest) {
      final ledgers = categories.where((c) => c.isLedger).toList();
      final open = ledgers.fold<int>(
          0, (n, c) => n + c.tasks.where((t) => t.isLedgerEntry && !t.isCompleted).length);
      final net = <String, int>{};
      for (final c in ledgers) {
        net[c.currency] = (net[c.currency] ?? 0) + c.signedOutstandingMinor;
      }
      final netText = net.entries
          .map((e) => texts.formatMoney(e.value, e.key))
          .join(' · ');
      // Next Monday 9:00, then weekly.
      var first = DateTime(now.year, now.month, now.day, 9);
      while (first.weekday != DateTime.monday || !first.isAfter(now)) {
        first = first.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        id: _digestId,
        title: texts.digestTitle,
        body: texts.digestBody(open, netText.isEmpty ? '0' : netText),
        scheduledDate: tz.TZDateTime.from(first, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: 'people',
      );
    }
  }
}
