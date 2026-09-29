import 'package:flutter/material.dart';

import '../services/data_service.dart';
import '../theme/app_theme.dart';

/// What swiping a task row to the right does.
enum SwipeRightAction { complete, edit }

/// App-wide preferences, stored in the same settings map as the theme.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider({DataService? dataService})
      : _data = dataService ?? DataService();

  final DataService _data;
  Map<String, dynamic> _s = {};
  bool _loaded = false;

  bool get loaded => _loaded;

  Future<void> load() async {
    try {
      _s = await _data.loadSettings();
    } catch (_) {
      _s = {};
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _set(String key, Object? value) async {
    if (value == null) {
      _s.remove(key);
    } else {
      _s[key] = value;
    }
    notifyListeners();
    try {
      // Re-read so keys written by ThemeProvider are not lost.
      final current = await _data.loadSettings();
      if (value == null) {
        current.remove(key);
      } else {
        current[key] = value;
      }
      await _data.saveSettings(current);
    } catch (e) {
      debugPrint('Failed to save setting $key: $e');
    }
  }

  // ── Look ────────────────────────────────────────────────────────────
  String get themePreset => presetById(_s['themePreset'] as String?).id;
  set themePreset(String id) => _set('themePreset', id);

  CornerStyle get corners => CornerStyle.values
      .firstWhere((c) => c.name == _s['corners'], orElse: () => CornerStyle.theme);
  set corners(CornerStyle v) => _set('corners', v.name);

  /// null follows the theme's own card style.
  CardStyle? get cardStyle {
    final v = _s['cardStyle'] as String?;
    for (final c in CardStyle.values) {
      if (c.name == v) return c;
    }
    return null;
  }

  set cardStyle(CardStyle? v) => _set('cardStyle', v?.name);

  // ── Text ────────────────────────────────────────────────────────────
  FontChoice get font => _byName(FontChoice.values, _s['font'], FontChoice.inter);
  set font(FontChoice v) => _set('font', v.name);

  TextWeight get textWeight => _byName(TextWeight.values, _s['textWeight'], TextWeight.normal);
  set textWeight(TextWeight v) => _set('textWeight', v.name);

  /// Multiplies the system text size; 1.0 leaves it as is.
  double get textScale => (_s['textScale'] as num?)?.toDouble() ?? 1.0;
  set textScale(double v) => _set('textScale', v);

  LineSpacing get lineSpacing => _byName(LineSpacing.values, _s['lineSpacing'], LineSpacing.normal);
  set lineSpacing(LineSpacing v) => _set('lineSpacing', v.name);

  Density get density => _byName(Density.values, _s['density'], Density.normal);
  set density(Density v) => _set('density', v.name);

  /// Puts every text and layout setting back to its default.
  Future<void> resetText() async {
    const keys = {'font', 'textWeight', 'textScale', 'lineSpacing', 'density'};
    _s.removeWhere((k, _) => keys.contains(k));
    notifyListeners();
    try {
      final current = await _data.loadSettings();
      current.removeWhere((k, _) => keys.contains(k));
      await _data.saveSettings(current);
    } catch (e) {
      debugPrint('Failed to reset text settings: $e');
    }
  }

  // ── Gestures ────────────────────────────────────────────────────────
  SwipeRightAction get swipeRight =>
      _s['swipeRight'] == 'edit' ? SwipeRightAction.edit : SwipeRightAction.complete;
  set swipeRight(SwipeRightAction v) => _set('swipeRight', v.name);

  // ── Language & dates ────────────────────────────────────────────────
  /// null follows the system language.
  Locale? get locale {
    final code = _s['locale'] as String?;
    return code == null ? null : Locale(code);
  }

  set localeCode(String? code) => _set('locale', code);

  bool get ethiopianCalendar => _s['ethiopianCalendar'] == true;
  set ethiopianCalendar(bool v) => _set('ethiopianCalendar', v);

  // ── Lists ───────────────────────────────────────────────────────────
  bool get autoCompleteChecklist => _s['autoCompleteChecklist'] == true;
  set autoCompleteChecklist(bool v) => _set('autoCompleteChecklist', v);

  bool get sinkCheckedItems => _s['sinkCheckedItems'] == true;
  set sinkCheckedItems(bool v) => _set('sinkCheckedItems', v);

  // ── Money ───────────────────────────────────────────────────────────
  String get defaultCurrency => _s['defaultCurrency'] as String? ?? 'ETB';
  set defaultCurrency(String v) => _set('defaultCurrency', v);

  bool get privacyMode => _s['privacyMode'] == true;
  set privacyMode(bool v) => _set('privacyMode', v);

  // ── Reminders ───────────────────────────────────────────────────────
  bool get remindersEnabled => _s['remindersEnabled'] != false;
  set remindersEnabled(bool v) => _set('remindersEnabled', v);

  /// Daily "log today's spending" reminder (only with a Spending list).
  bool get spendingReminder => _s['spendingReminder'] != false;
  set spendingReminder(bool v) => _set('spendingReminder', v);

  /// Minutes after midnight; default 18:00.
  int get spendingReminderMinutes => (_s['spendingReminderMinutes'] as num?)?.toInt() ?? 18 * 60;
  set spendingReminderMinutes(int v) => _set('spendingReminderMinutes', v);

  bool get weeklyDigest => _s['weeklyDigest'] == true;
  set weeklyDigest(bool v) => _set('weeklyDigest', v);

  // ── Security ────────────────────────────────────────────────────────
  bool get appLock => _s['appLock'] == true;
  set appLock(bool v) => _set('appLock', v);

  /// Minutes in the background before the app locks again.
  int get lockAfterMinutes => (_s['lockAfterMinutes'] as num?)?.toInt() ?? 1;
  set lockAfterMinutes(int v) => _set('lockAfterMinutes', v);

  // ── Backup ──────────────────────────────────────────────────────────
  bool get autoBackup => _s['autoBackup'] == true;
  set autoBackup(bool v) => _set('autoBackup', v);

  DateTime? get lastAutoBackup {
    final v = _s['lastAutoBackup'] as String?;
    return v == null ? null : DateTime.tryParse(v);
  }

  set lastAutoBackup(DateTime? v) => _set('lastAutoBackup', v?.toIso8601String());

  // ── Home-screen widget ──────────────────────────────────────────────
  /// 'today', a category id, or null for the first category.
  String? get widgetSource => _s['widgetSource'] as String?;
  set widgetSource(String? v) => _set('widgetSource', v);

  // ── Remembered UI state ─────────────────────────────────────────────
  Set<String> get expandedCategories =>
      ((_s['expanded'] as List?) ?? const []).cast<String>().toSet();
  set expandedCategories(Set<String> ids) => _set('expanded', ids.toList());

  bool get tipsDismissed => _s['tipsDismissed'] == true;
  set tipsDismissed(bool v) => _set('tipsDismissed', v);

  static T _byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
      values.firstWhere((v) => v.name == name, orElse: () => fallback);
}
