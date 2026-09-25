import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqlite3/sqlite3.dart';

import '../models/category.dart';
import '../models/deleted_category.dart';

/// Persists categories in SQLite (one row per category, so a change rewrites
/// only that category) and small settings in SharedPreferences.
///
/// On first launch the legacy SharedPreferences JSON blobs are copied into
/// the database. The blobs are left in place as a safety net.
class DataService {
  static const String _categoriesKey = 'categories';
  static const String _deletedCategoriesKey = 'deletedCategories';
  static const String _settingsKey = 'settings';

  static const int schemaVersion = 2;
  static const String dbFileName = 'tooran.db';

  /// Tests (and the home-screen widget isolate) can point the service at a
  /// specific database file; `':memory:'` gives an isolated in-memory DB.
  static String? dbPathOverride;

  static Database? _db;
  static String? _dbPath;

  /// Closes the shared connection (tests use this to start fresh).
  static void resetForTesting({String? dbPath}) {
    _db?.close();
    _db = null;
    _dbPath = null;
    dbPathOverride = dbPath;
  }

  Future<String> _resolvePath() async {
    if (dbPathOverride != null) return dbPathOverride!;
    final dir = await getApplicationSupportDirectory();
    await dir.create(recursive: true);
    return p.join(dir.path, dbFileName);
  }

  Future<Database> _open() async {
    final path = await _resolvePath();
    if (_db != null && _dbPath == path) return _db!;
    _db?.close();
    final db = sqlite3.open(path);
    if (path != ':memory:') {
      db.execute('PRAGMA journal_mode=WAL');
    }
    db.execute('PRAGMA busy_timeout=3000');
    db.execute('''
      CREATE TABLE IF NOT EXISTS meta (key TEXT PRIMARY KEY, value TEXT)
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS categories (
        id TEXT PRIMARY KEY,
        sort_order INTEGER NOT NULL,
        json TEXT NOT NULL
      )
    ''');
    db.execute('''
      CREATE TABLE IF NOT EXISTS deleted_categories (
        id TEXT PRIMARY KEY,
        deleted_at TEXT NOT NULL,
        json TEXT NOT NULL
      )
    ''');
    _db = db;
    _dbPath = path;
    await _migrateFromPrefs(db);
    return db;
  }

  String? _meta(Database db, String key) {
    final rows = db.select('SELECT value FROM meta WHERE key = ?', [key]);
    return rows.isEmpty ? null : rows.first['value'] as String?;
  }

  void _setMeta(Database db, String key, String value) {
    db.execute(
      'INSERT INTO meta (key, value) VALUES (?, ?) '
      'ON CONFLICT(key) DO UPDATE SET value = excluded.value',
      [key, value],
    );
  }

  Future<void> _migrateFromPrefs(Database db) async {
    if (_meta(db, 'migrated_from_prefs') != null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      // A corrupt legacy blob is skipped (the old app could not read it
      // either); it stays in SharedPreferences untouched.
      List<Category> cats = [];
      List<DeletedCategory> deleted = [];
      try {
        cats = _decodeCategories(prefs.getString(_categoriesKey));
      } catch (e) {
        developer.log('Skipping unreadable legacy categories', name: 'DataService', error: e);
      }
      try {
        deleted = _decodeDeleted(prefs.getString(_deletedCategoriesKey));
      } catch (e) {
        developer.log('Skipping unreadable legacy history', name: 'DataService', error: e);
      }
      _transaction(db, () {
        for (final c in cats) {
          _upsertCategory(db, c);
        }
        for (final d in deleted) {
          _upsertDeleted(db, d);
        }
        _setMeta(db, 'migrated_from_prefs', DateTime.now().toIso8601String());
        _setMeta(db, 'schema_version', '$schemaVersion');
      });
    } catch (e, st) {
      developer.log('Legacy migration failed', name: 'DataService', error: e, stackTrace: st);
      rethrow;
    }
  }

  void _transaction(Database db, void Function() body) {
    db.execute('BEGIN IMMEDIATE');
    try {
      body();
      db.execute('COMMIT');
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  void _upsertCategory(Database db, Category c) {
    db.execute(
      'INSERT INTO categories (id, sort_order, json) VALUES (?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET sort_order = excluded.sort_order, json = excluded.json',
      [c.id, c.sortOrder, jsonEncode(c.toJson())],
    );
  }

  void _upsertDeleted(Database db, DeletedCategory d) {
    db.execute(
      'INSERT INTO deleted_categories (id, deleted_at, json) VALUES (?, ?, ?) '
      'ON CONFLICT(id) DO UPDATE SET deleted_at = excluded.deleted_at, json = excluded.json',
      [d.id, d.deletedAt.toIso8601String(), jsonEncode(d.toJson())],
    );
  }

  static List<Category> _decodeCategories(String? data) {
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list.map((j) => Category.fromJson(Map<String, dynamic>.from(j))).toList();
  }

  static List<DeletedCategory> _decodeDeleted(String? data) {
    if (data == null || data.isEmpty) return [];
    final list = jsonDecode(data) as List;
    return list
        .map((j) => DeletedCategory.fromJson(Map<String, dynamic>.from(j)))
        .toList();
  }

  // ─── Categories ─────────────────────────────────────────────────────

  Future<List<Category>> loadCategories() async {
    try {
      final db = await _open();
      final rows = db.select('SELECT json FROM categories ORDER BY sort_order, rowid');
      return rows
          .map((r) => Category.fromJson(
              Map<String, dynamic>.from(jsonDecode(r['json'] as String))))
          .toList();
    } catch (e) {
      throw DataServiceException('Failed to load categories: $e');
    }
  }

  /// Replaces the whole category table with [categories].
  Future<void> saveCategories(List<Category> categories) async {
    try {
      final db = await _open();
      _transaction(db, () {
        final ids = categories.map((c) => c.id).toSet();
        final existing = db.select('SELECT id FROM categories').map((r) => r['id'] as String);
        for (final id in existing) {
          if (!ids.contains(id)) db.execute('DELETE FROM categories WHERE id = ?', [id]);
        }
        for (final c in categories) {
          _upsertCategory(db, c);
        }
      });
    } catch (e) {
      throw DataServiceException('Failed to save categories: $e');
    }
  }

  /// Writes a single category (insert or update).
  Future<void> saveCategory(Category category) async {
    try {
      final db = await _open();
      _upsertCategory(db, category);
    } catch (e) {
      throw DataServiceException('Failed to save category: $e');
    }
  }

  Future<void> deleteCategoryRow(String id) async {
    final db = await _open();
    db.execute('DELETE FROM categories WHERE id = ?', [id]);
  }

  /// Persists only the sort order of [categories].
  Future<void> saveCategoryOrder(List<Category> categories) async {
    try {
      final db = await _open();
      _transaction(db, () {
        for (final c in categories) {
          _upsertCategory(db, c);
        }
      });
    } catch (e) {
      throw DataServiceException('Failed to save order: $e');
    }
  }

  // ─── Deleted categories ─────────────────────────────────────────────

  Future<List<DeletedCategory>> loadDeletedCategories() async {
    try {
      final db = await _open();
      final rows = db.select('SELECT json FROM deleted_categories ORDER BY deleted_at');
      return rows
          .map((r) => DeletedCategory.fromJson(
              Map<String, dynamic>.from(jsonDecode(r['json'] as String))))
          .toList();
    } catch (e) {
      throw DataServiceException('Failed to load deleted categories: $e');
    }
  }

  Future<void> saveDeletedCategories(List<DeletedCategory> deletedCategories) async {
    try {
      final db = await _open();
      _transaction(db, () {
        db.execute('DELETE FROM deleted_categories');
        for (final d in deletedCategories) {
          _upsertDeleted(db, d);
        }
      });
    } catch (e) {
      throw DataServiceException('Failed to save deleted categories: $e');
    }
  }

  Future<void> addDeletedCategory(DeletedCategory d) async {
    final db = await _open();
    _upsertDeleted(db, d);
  }

  Future<void> removeDeletedCategory(String id) async {
    final db = await _open();
    db.execute('DELETE FROM deleted_categories WHERE id = ?', [id]);
  }

  /// Changes whenever another connection (e.g. the home-screen widget)
  /// writes to the database. Compare values to know when to reload.
  Future<int> externalDataVersion() async {
    final db = await _open();
    return db.select('PRAGMA data_version').first.values.first as int;
  }

  // ─── Settings ───────────────────────────────────────────────────────

  Future<Map<String, dynamic>> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsData = prefs.getString(_settingsKey);

      if (settingsData == null || settingsData.isEmpty) {
        return {};
      }

      return json.decode(settingsData) as Map<String, dynamic>;
    } catch (e) {
      throw DataServiceException('Failed to load settings: $e');
    }
  }

  Future<void> saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsData = json.encode(settings);

      await prefs.setString(_settingsKey, settingsData);
    } catch (e) {
      throw DataServiceException('Failed to save settings: $e');
    }
  }

  // ─── Backup ─────────────────────────────────────────────────────────

  Future<String> exportJson() async {
    final cats = await loadCategories();
    final deleted = await loadDeletedCategories();
    return const JsonEncoder.withIndent('  ').convert({
      'app': 'tooran',
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': cats.map((c) => c.toJson()).toList(),
      'deletedCategories': deleted.map((d) => d.toJson()).toList(),
    });
  }

  /// Parses a backup without applying it. Accepts the export format above
  /// and a bare list of categories (the legacy storage format).
  BackupContents parseBackup(String data) {
    final decoded = jsonDecode(data);
    if (decoded is List) {
      return BackupContents(
        categories: decoded
            .map((j) => Category.fromJson(Map<String, dynamic>.from(j)))
            .toList(),
        deletedCategories: const [],
      );
    }
    if (decoded is Map && decoded['categories'] is List) {
      return BackupContents(
        categories: (decoded['categories'] as List)
            .map((j) => Category.fromJson(Map<String, dynamic>.from(j)))
            .toList(),
        deletedCategories: ((decoded['deletedCategories'] as List?) ?? const [])
            .map((j) => DeletedCategory.fromJson(Map<String, dynamic>.from(j)))
            .toList(),
      );
    }
    throw const FormatException('Not a Tooran backup');
  }

  /// Applies a backup. `replace` wipes current data first; otherwise
  /// categories are merged by id and tasks inside them by id.
  Future<void> importBackup(BackupContents backup, {required bool replace}) async {
    final db = await _open();
    final current = replace ? <Category>[] : await loadCategories();
    final byId = {for (final c in current) c.id: c};
    for (final incoming in backup.categories) {
      final existing = byId[incoming.id];
      if (existing == null) {
        byId[incoming.id] = incoming;
      } else {
        final taskIds = existing.tasks.map((t) => t.id).toSet();
        existing.tasks.addAll(incoming.tasks.where((t) => !taskIds.contains(t.id)));
      }
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    for (var i = 0; i < merged.length; i++) {
      merged[i].sortOrder = i;
    }
    _transaction(db, () {
      db.execute('DELETE FROM categories');
      for (final c in merged) {
        _upsertCategory(db, c);
      }
      if (replace) db.execute('DELETE FROM deleted_categories');
      for (final d in backup.deletedCategories) {
        _upsertDeleted(db, d);
      }
    });
  }

  /// Writes a dated backup file into [dir], keeping the newest [keep] files.
  Future<File> writeBackupFile(Directory dir, {int keep = 4}) async {
    await dir.create(recursive: true);
    final stamp = DateTime.now().toIso8601String().substring(0, 10);
    final file = File(p.join(dir.path, 'tooran-backup-$stamp.json'));
    await file.writeAsString(await exportJson());
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => p.basename(f.path).startsWith('tooran-backup-'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final old in files.skip(keep)) {
      await old.delete();
    }
    return file;
  }

  // ─── Utility ────────────────────────────────────────────────────────

  Future<void> clearAllData() async {
    try {
      final db = await _open();
      db.execute('DELETE FROM categories');
      db.execute('DELETE FROM deleted_categories');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_categoriesKey);
      await prefs.remove(_deletedCategoriesKey);
      await prefs.remove(_settingsKey);
    } catch (e) {
      throw DataServiceException('Failed to clear data: $e');
    }
  }

  Future<bool> hasData() async {
    try {
      final db = await _open();
      final n = db.select('SELECT (SELECT COUNT(*) FROM categories) + '
          '(SELECT COUNT(*) FROM deleted_categories) AS n').first['n'] as int;
      if (n > 0) return true;
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_settingsKey);
    } catch (e) {
      return false;
    }
  }

  Future<List<Category>> loadCategoriesWithRecovery() async {
    try {
      return await loadCategories();
    } catch (e, st) {
      developer.log(
        'loadCategories failed; returning empty list',
        name: 'DataService',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }

  Future<List<DeletedCategory>> loadDeletedCategoriesWithRecovery() async {
    try {
      return await loadDeletedCategories();
    } catch (e, st) {
      developer.log(
        'loadDeletedCategories failed; returning empty list',
        name: 'DataService',
        error: e,
        stackTrace: st,
      );
      return [];
    }
  }
}

class BackupContents {
  final List<Category> categories;
  final List<DeletedCategory> deletedCategories;
  const BackupContents({required this.categories, required this.deletedCategories});

  int get taskCount => categories.fold(0, (n, c) => n + c.tasks.length);
}

class DataServiceException implements Exception {
  final String message;

  DataServiceException(this.message);

  @override
  String toString() => 'DataServiceException: $message';
}
