import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// Fingerprint / face / device-PIN unlock via the system prompt.
class AppLock {
  AppLock._();
  static final LocalAuthentication _auth = LocalAuthentication();

  /// True while the system prompt is up — its own pause/resume must not
  /// re-lock the app.
  static bool authenticating = false;

  static bool get platformSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isWindows);

  static Future<bool> available() async {
    if (!platformSupported) return false;
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  static Future<bool> authenticate(String reason) async {
    if (!platformSupported) return true;
    authenticating = true;
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } catch (_) {
      return false;
    } finally {
      // Resume events from the prompt arrive just after it closes.
      Future.delayed(const Duration(milliseconds: 800), () => authenticating = false);
    }
  }
}

/// Covers the app with a lock screen when app lock is on: at launch, and
/// after it has been in the background for the configured time.
class LockGate extends StatefulWidget {
  const LockGate({super.key, required this.child});
  final Widget child;

  @override
  State<LockGate> createState() => _LockGateState();
}

class _LockGateState extends State<LockGate> with WidgetsBindingObserver {
  bool _locked = true;
  bool _initialised = false;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final settings = context.watch<SettingsProvider>();
    if (!_initialised && settings.loaded) {
      _initialised = true;
      _locked = settings.appLock;
      if (_locked) WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    }
    if (!settings.appLock && _locked && _initialised) _locked = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final settings = context.read<SettingsProvider>();
    if (!settings.appLock || AppLock.authenticating) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.hidden) {
      _backgroundedAt ??= DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final since = _backgroundedAt;
      _backgroundedAt = null;
      if (since != null &&
          DateTime.now().difference(since) >= Duration(minutes: settings.lockAfterMinutes)) {
        setState(() => _locked = true);
        _unlock();
      }
    }
  }

  Future<void> _unlock() async {
    if (AppLock.authenticating) return;
    final ok = await AppLock.authenticate(context.l10n.lockReason);
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (!settings.loaded) return const SizedBox.shrink();
    return Stack(
      children: [
        // Keep the app mounted underneath so state survives locking.
        Offstage(offstage: _locked && settings.appLock, child: widget.child),
        if (_locked && settings.appLock)
          Positioned.fill(
            child: Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SafeArea(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.lock_outline, size: 40, color: context.ink3),
                      const SizedBox(height: 16),
                      Text(context.l10n.lockTitle, style: AppTheme.display(size: 26, color: context.ink)),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: _unlock,
                        icon: const Icon(Icons.fingerprint),
                        label: Text(context.l10n.lockUnlock),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
