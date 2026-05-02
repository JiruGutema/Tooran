import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

/// Persists desktop window geometry across launches.
///
/// On Linux / Windows / macOS, the saved size, position, and maximized state
/// are restored before the first frame so the user lands in the same window
/// they left. Resize / move / maximize events save back to SharedPreferences,
/// debounced so a drag doesn't write on every pixel.
///
/// On mobile platforms this is a no-op — `window_manager` isn't supported and
/// the OS owns the window anyway.
class WindowService with WindowListener {
  WindowService._();
  static final WindowService instance = WindowService._();

  static const _kWidth = 'window.width';
  static const _kHeight = 'window.height';
  static const _kX = 'window.x';
  static const _kY = 'window.y';
  static const _kMaximized = 'window.maximized';

  // First-launch defaults — match the design canvas's desktop artboard so the
  // sidebar + main + (eventually) detail pane all have room to breathe.
  static const Size _defaultSize = Size(1200, 800);
  static const Size _minSize = Size(640, 520);

  static bool get _isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  Timer? _saveDebounce;

  /// Read saved geometry and apply it before the window is shown. Call this
  /// after `windowManager.ensureInitialized()` and before `runApp`.
  Future<void> restoreOnStartup() async {
    if (!_isDesktop) return;

    final prefs = await SharedPreferences.getInstance();
    final w = prefs.getDouble(_kWidth) ?? _defaultSize.width;
    final h = prefs.getDouble(_kHeight) ?? _defaultSize.height;
    final x = prefs.getDouble(_kX);
    final y = prefs.getDouble(_kY);
    final maximized = prefs.getBool(_kMaximized) ?? false;

    final options = WindowOptions(
      size: Size(w, h),
      minimumSize: _minSize,
      center: x == null || y == null,
      titleBarStyle: TitleBarStyle.normal,
      skipTaskbar: false,
      title: 'Tooran',
    );

    await windowManager.waitUntilReadyToShow(options, () async {
      if (x != null && y != null) {
        await windowManager.setPosition(Offset(x, y));
      }
      if (maximized) {
        await windowManager.maximize();
      }
      await windowManager.show();
      await windowManager.focus();
    });
  }

  /// Subscribe to window events so future moves/resizes get saved.
  void attachListeners() {
    if (!_isDesktop) return;
    windowManager.addListener(this);
  }

  void dispose() {
    if (!_isDesktop) return;
    windowManager.removeListener(this);
    _saveDebounce?.cancel();
  }

  // Debounce writes — drag/resize fires many events per second.
  void _scheduleSave() {
    _saveDebounce?.cancel();
    _saveDebounce = Timer(const Duration(milliseconds: 400), _save);
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isMax = await windowManager.isMaximized();
      await prefs.setBool(_kMaximized, isMax);
      // Only persist size/position when not maximized — otherwise we'd save
      // the screen-filling geometry and lose the user's preferred restored
      // size.
      if (!isMax) {
        final size = await windowManager.getSize();
        final pos = await windowManager.getPosition();
        await prefs.setDouble(_kWidth, size.width);
        await prefs.setDouble(_kHeight, size.height);
        await prefs.setDouble(_kX, pos.dx);
        await prefs.setDouble(_kY, pos.dy);
      }
    } catch (_) {
      // Best-effort persistence — ignore transient errors (e.g. window
      // already closed when the timer fires).
    }
  }

  @override
  void onWindowResized() => _scheduleSave();

  @override
  void onWindowMoved() => _scheduleSave();

  @override
  void onWindowMaximize() => _scheduleSave();

  @override
  void onWindowUnmaximize() => _scheduleSave();

  @override
  void onWindowClose() {
    // Cancel the debounce and write synchronously so a quick close doesn't
    // drop the last move.
    _saveDebounce?.cancel();
    _save();
  }
}
