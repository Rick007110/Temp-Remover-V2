import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class CleaningHistoryManager {
  static const String _historyKey = 'cleaning_history';
  static const String _customFoldersKey = 'custom_folders';
  static const int _maxHistoryItems = 100;

  // Cleaning History
  static Future<void> addHistoryEntry(CleaningHistory entry) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getHistory();
    
    history.insert(0, entry);
    
    // Keep only last 100 entries
    if (history.length > _maxHistoryItems) {
      history.removeRange(_maxHistoryItems, history.length);
    }
    
    final jsonList = history.map((e) => e.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  static Future<List<CleaningHistory>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_historyKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => CleaningHistory.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
  }

  static Future<Map<String, dynamic>> getHistoryStats() async {
    final history = await getHistory();
    
    if (history.isEmpty) {
      return {
        'totalCleanings': 0,
        'totalItemsDeleted': 0,
        'totalSpaceRecovered': 0,
        'lastCleaning': null,
      };
    }
    
    int totalItems = 0;
    int totalSpace = 0;
    
    for (var entry in history) {
      totalItems += entry.filesDeleted;
      totalSpace += entry.bytesDeleted;
    }
    
    return {
      'totalCleanings': history.length,
      'totalItemsDeleted': totalItems,
      'totalSpaceRecovered': totalSpace,
      'lastCleaning': history.first.timestamp,
    };
  }

  // Custom Folders
  static Future<void> addCustomFolder(CustomFolder folder) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = await getCustomFolders();
    
    // Check if folder already exists
    if (!folders.any((f) => f.path == folder.path)) {
      folders.add(folder);
      final jsonList = folders.map((e) => e.toJson()).toList();
      await prefs.setString(_customFoldersKey, jsonEncode(jsonList));
    }
  }

  static Future<void> removeCustomFolder(String path) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = await getCustomFolders();
    
    folders.removeWhere((f) => f.path == path);
    
    final jsonList = folders.map((e) => e.toJson()).toList();
    await prefs.setString(_customFoldersKey, jsonEncode(jsonList));
  }

  static Future<void> toggleCustomFolder(String path, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    final folders = await getCustomFolders();
    
    final index = folders.indexWhere((f) => f.path == path);
    if (index != -1) {
      folders[index] = CustomFolder(
        path: folders[index].path,
        name: folders[index].name,
        isEnabled: enabled,
      );
      
      final jsonList = folders.map((e) => e.toJson()).toList();
      await prefs.setString(_customFoldersKey, jsonEncode(jsonList));
    }
  }

  static Future<List<CustomFolder>> getCustomFolders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_customFoldersKey);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => CustomFolder.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<CustomFolder>> getEnabledCustomFolders() async {
    final folders = await getCustomFolders();
    return folders.where((f) => f.isEnabled).toList();
  }
}
