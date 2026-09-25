import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'data_service.dart';

/// Export/import of the whole data set as a JSON file, plus the optional
/// weekly automatic backup into the app's documents folder.
class BackupService {
  BackupService({DataService? dataService}) : _data = dataService ?? DataService();

  final DataService _data;

  /// Writes a backup file and opens the share sheet so the user can save it
  /// to Drive, Telegram "Saved Messages", Files, …
  Future<void> exportAndShare({required String subject}) async {
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final file = File(p.join(dir.path, 'tooran-backup-$stamp.json'));
    await file.writeAsString(await _data.exportJson());
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path, mimeType: 'application/json')],
      subject: subject,
    ));
  }

  /// Lets the user pick a backup file; returns its parsed contents, or null
  /// if they cancelled. Throws [FormatException] for files that aren't
  /// Tooran backups.
  Future<BackupContents?> pickBackup() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['json'],
    );
    if (files.isEmpty) return null;
    final bytes = await files.first.readAsBytes();
    return _data.parseBackup(utf8.decode(bytes));
  }

  static Future<Directory> autoBackupDir() async {
    final docs = await getApplicationDocumentsDirectory();
    return Directory(p.join(docs.path, 'backups'));
  }

  /// Writes a backup when the last one is at least a week old. Returns the
  /// time of the backup if one was written.
  Future<DateTime?> autoBackupIfDue(DateTime? last) async {
    final now = DateTime.now();
    if (last != null && now.difference(last) < const Duration(days: 7)) return null;
    await _data.writeBackupFile(await autoBackupDir());
    return now;
  }
}
