import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category.dart';
import '../models/deleted_category.dart';

class DataService {
  static const String _categoriesKey = 'categories';
  static const String _deletedCategoriesKey = 'deletedCategories';
  static const String _settingsKey = 'settings';

  // Categories operations
  Future<List<Category>> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesData = prefs.getString(_categoriesKey);
      
      if (categoriesData == null || categoriesData.isEmpty) {
        return [];
      }

      final List<dynamic> categoriesJson = json.decode(categoriesData);
      return categoriesJson
          .map((categoryJson) => Category.fromJson(categoryJson))
          .toList();
    } catch (e) {
      throw DataServiceException('Failed to load categories: $e');
    }
  }

  Future<void> saveCategories(List<Category> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = categories.map((category) => category.toJson()).toList();
      final categoriesData = json.encode(categoriesJson);
      
      await prefs.setString(_categoriesKey, categoriesData);
    } catch (e) {
      throw DataServiceException('Failed to save categories: $e');
    }
  }

  // Deleted categories operations
  Future<List<DeletedCategory>> loadDeletedCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedData = prefs.getString(_deletedCategoriesKey);
      
      if (deletedData == null || deletedData.isEmpty) {
        return [];
      }

      final List<dynamic> deletedJson = json.decode(deletedData);
      return deletedJson
          .map((deletedJson) => DeletedCategory.fromJson(deletedJson))
          .toList();
    } catch (e) {
      throw DataServiceException('Failed to load deleted categories: $e');
    }
  }

  Future<void> saveDeletedCategories(List<DeletedCategory> deletedCategories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deletedJson = deletedCategories.map((deleted) => deleted.toJson()).toList();
      final deletedData = json.encode(deletedJson);
      
      await prefs.setString(_deletedCategoriesKey, deletedData);
    } catch (e) {
      throw DataServiceException('Failed to save deleted categories: $e');
    }
  }

  // Settings operations
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

  // Utility methods
  Future<void> clearAllData() async {
    try {
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
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_categoriesKey) || 
             prefs.containsKey(_deletedCategoriesKey) ||
             prefs.containsKey(_settingsKey);
    } catch (e) {
      return false;
    }
  }



  // Data recovery methods
  Future<List<Category>> loadCategoriesWithRecovery() async {
    try {
      return await loadCategories();
    } catch (e) {
      // Attempt to recover from backup or return empty list
      return [];
    }
  }

  Future<List<DeletedCategory>> loadDeletedCategoriesWithRecovery() async {
    try {
      return await loadDeletedCategories();
    } catch (e) {
      // Attempt to recover from backup or return empty list
      return [];
    }
  }

  // Backup operations
  Future<void> createBackup() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      final categoriesData = prefs.getString(_categoriesKey);
      final deletedData = prefs.getString(_deletedCategoriesKey);
      final settingsData = prefs.getString(_settingsKey);
      
      if (categoriesData != null) {
        await prefs.setString('${_categoriesKey}_backup_$timestamp', categoriesData);
      }
      if (deletedData != null) {
        await prefs.setString('${_deletedCategoriesKey}_backup_$timestamp', deletedData);
      }
      if (settingsData != null) {
        await prefs.setString('${_settingsKey}_backup_$timestamp', settingsData);
      }
    } catch (e) {
      throw DataServiceException('Failed to create backup: $e');
    }
  }
}

class DataServiceException implements Exception {
  final String message;
  
  DataServiceException(this.message);
  
  @override
  String toString() => 'DataServiceException: $message';
}