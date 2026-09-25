import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Receives text shared into Tooran from other apps (Android share sheet).
class ShareIntentService {
  ShareIntentService._();
  static final ShareIntentService instance = ShareIntentService._();

  static const MethodChannel _channel = MethodChannel('tooran/share');

  /// Called with text shared while the app is already running.
  void Function(String text)? onShared;

  static bool get supported => !kIsWeb && Platform.isAndroid;

  void init() {
    if (!supported) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'sharedText' && call.arguments is String) {
        onShared?.call(call.arguments as String);
      }
    });
  }

  /// Text that launched the app, returned only once.
  Future<String?> takeInitialText() async {
    if (!supported) return null;
    try {
      return await _channel.invokeMethod<String>('getInitialSharedText');
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
