import 'dart:io';
import 'package:path/path.dart' as path;

class BrowserCacheService {
  static String _getAppDataPath() {
    return Platform.environment['LOCALAPPDATA'] ?? '';
  }

  static String _getAppDataRoamingPath() {
    return Platform.environment['APPDATA'] ?? '';
  }

  static Map<String, List<String>> getBrowserCachePaths() {
    final localAppData = _getAppDataPath();
    final appDataRoaming = _getAppDataRoamingPath();

    return {
      'Chrome': [
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'Cache'),
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'Code Cache'),
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'GPUCache'),
      ],
      'Edge': [
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'Cache'),
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'Code Cache'),
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'GPUCache'),
      ],
      'Firefox': [
        path.join(appDataRoaming, 'Mozilla', 'Firefox', 'Profiles'),
      ],
      'Brave': [
        path.join(localAppData, 'BraveSoftware', 'Brave-Browser', 'User Data', 'Default', 'Cache'),
        path.join(localAppData, 'BraveSoftware', 'Brave-Browser', 'User Data', 'Default', 'Code Cache'),
      ],
    };
  }

  static Map<String, List<String>> getBrowserHistoryPaths() {
    final localAppData = _getAppDataPath();
    final appDataRoaming = _getAppDataRoamingPath();

    return {
      'Chrome': [
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'History'),
      ],
      'Edge': [
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'History'),
      ],
      'Firefox': [
        path.join(appDataRoaming, 'Mozilla', 'Firefox', 'Profiles'),
      ],
      'Brave': [
        path.join(localAppData, 'BraveSoftware', 'Brave-Browser', 'User Data', 'Default', 'History'),
      ],
    };
  }

  static Map<String, List<String>> getBrowserCookiePaths() {
    final localAppData = _getAppDataPath();
    final appDataRoaming = _getAppDataRoamingPath();

    return {
      'Chrome': [
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'Cookies'),
        path.join(localAppData, 'Google', 'Chrome', 'User Data', 'Default', 'Network', 'Cookies'),
      ],
      'Edge': [
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'Cookies'),
        path.join(localAppData, 'Microsoft', 'Edge', 'User Data', 'Default', 'Network', 'Cookies'),
      ],
      'Firefox': [
        path.join(appDataRoaming, 'Mozilla', 'Firefox', 'Profiles'),
      ],
      'Brave': [
        path.join(localAppData, 'BraveSoftware', 'Brave-Browser', 'User Data', 'Default', 'Cookies'),
      ],
    };
  }

  static Future<Map<String, int>> scanBrowserCaches() async {
    Map<String, int> results = {};
    final cachePaths = getBrowserCachePaths();

    for (var entry in cachePaths.entries) {
      int totalSize = 0;
      for (var cachePath in entry.value) {
        final dir = Directory(cachePath);
        if (await dir.exists()) {
          totalSize += await _calculateDirectorySize(dir);
        }
      }
      results[entry.key] = totalSize;
    }

    return results;
  }

  static Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {
            // Skip files we can't access
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
    return size;
  }

  static Future<Map<String, int>> clearBrowserCaches(List<String> browsers) async {
    Map<String, int> results = {};
    final cachePaths = getBrowserCachePaths();

    for (var browser in browsers) {
      int deletedSize = 0;
      final paths = cachePaths[browser] ?? [];
      
      for (var cachePath in paths) {
        final dir = Directory(cachePath);
        if (await dir.exists()) {
          deletedSize += await _deleteDirectoryContents(dir);
        }
      }
      results[browser] = deletedSize;
    }

    return results;
  }

  static Future<Map<String, int>> clearBrowserHistory(List<String> browsers) async {
    Map<String, int> results = {};
    final historyPaths = getBrowserHistoryPaths();

    for (var browser in browsers) {
      int deletedSize = 0;
      final paths = historyPaths[browser] ?? [];
      
      for (var historyPath in paths) {
        if (browser == 'Firefox') {
          // Firefox stores history in profile folders
          final profilesDir = Directory(historyPath);
          if (await profilesDir.exists()) {
            await for (var profile in profilesDir.list()) {
              if (profile is Directory) {
                final historyFile = File(path.join(profile.path, 'places.sqlite'));
                if (await historyFile.exists()) {
                  try {
                    deletedSize += await historyFile.length();
                    await historyFile.delete();
                  } catch (e) {}
                }
              }
            }
          }
        } else {
          final file = File(historyPath);
          if (await file.exists()) {
            try {
              deletedSize += await file.length();
              await file.delete();
            } catch (e) {}
          }
        }
      }
      results[browser] = deletedSize;
    }

    return results;
  }

  static Future<Map<String, int>> clearBrowserCookies(List<String> browsers) async {
    Map<String, int> results = {};
    final cookiePaths = getBrowserCookiePaths();

    for (var browser in browsers) {
      int deletedSize = 0;
      final paths = cookiePaths[browser] ?? [];
      
      for (var cookiePath in paths) {
        if (browser == 'Firefox') {
          final profilesDir = Directory(cookiePath);
          if (await profilesDir.exists()) {
            await for (var profile in profilesDir.list()) {
              if (profile is Directory) {
                final cookieFile = File(path.join(profile.path, 'cookies.sqlite'));
                if (await cookieFile.exists()) {
                  try {
                    deletedSize += await cookieFile.length();
                    await cookieFile.delete();
                  } catch (e) {}
                }
              }
            }
          }
        } else {
          final file = File(cookiePath);
          if (await file.exists()) {
            try {
              deletedSize += await file.length();
              await file.delete();
            } catch (e) {}
          }
        }
      }
      results[browser] = deletedSize;
    }

    return results;
  }

  static Future<int> _deleteDirectoryContents(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: false, followLinks: false)) {
        try {
          if (entity is File) {
            size += await entity.length();
            await entity.delete();
          } else if (entity is Directory) {
            size += await _calculateDirectorySize(entity);
            await entity.delete(recursive: true);
          }
        } catch (e) {
          // Skip items we can't delete
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }
    return size;
  }
}
