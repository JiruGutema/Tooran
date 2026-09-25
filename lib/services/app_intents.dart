import 'package:flutter/foundation.dart' show ChangeNotifier;

/// Something outside the home screen asked for: open a task (reminder or
/// widget tap), add a task (widget "+"), handle shared text, open People.
sealed class AppIntent {
  const AppIntent();
}

class OpenTaskIntent extends AppIntent {
  final String categoryId;
  final String taskId;
  const OpenTaskIntent(this.categoryId, this.taskId);
}

class AddTaskIntent extends AppIntent {
  /// Category to add to; null means the widget's category (or the first).
  final String? categoryId;
  const AddTaskIntent([this.categoryId]);
}

class SharedTextIntent extends AppIntent {
  final String text;
  const SharedTextIntent(this.text);
}

class OpenPeopleIntent extends AppIntent {
  const OpenPeopleIntent();
}

/// Queue of intents; the visible home layout consumes them.
class AppIntents extends ChangeNotifier {
  final List<AppIntent> _pending = [];

  void add(AppIntent intent) {
    _pending.add(intent);
    notifyListeners();
  }

  /// Parses `task:<cat>:<task>` / `people` payloads from notifications.
  void addNotificationPayload(String payload) {
    if (payload == 'people') {
      add(const OpenPeopleIntent());
      return;
    }
    if (payload.startsWith('spending:')) {
      add(AddTaskIntent(payload.substring('spending:'.length)));
      return;
    }
    final parts = payload.split(':');
    if (parts.length == 3 && parts[0] == 'task') add(OpenTaskIntent(parts[1], parts[2]));
  }

  /// Parses home-widget launch links: tooran://task?cat=…&task=…, tooran://add.
  void addWidgetUri(Uri? uri) {
    if (uri == null || uri.scheme != 'tooran') return;
    switch (uri.host) {
      case 'task':
        final c = uri.queryParameters['cat'];
        final t = uri.queryParameters['task'];
        if (c != null && t != null) add(OpenTaskIntent(c, t));
      case 'add':
        add(const AddTaskIntent());
    }
  }

  AppIntent? take() => _pending.isEmpty ? null : _pending.removeAt(0);
}
