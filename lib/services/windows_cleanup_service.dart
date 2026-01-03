import 'dart:io';
import 'package:path/path.dart' as path;

class WindowsCleanupService {
  static String _getWindowsPath() {
    return Platform.environment['WINDIR'] ?? 'C:\\Windows';
  }

  // Windows Update Cache
  static Future<int> scanWindowsUpdateCache() async {
    final updatePath = path.join(_getWindowsPath(), 'SoftwareDistribution', 'Download');
    final dir = Directory(updatePath);
    
    if (!await dir.exists()) return 0;
    return await _calculateDirectorySize(dir);
  }

  static Future<int> clearWindowsUpdateCache() async {
    final updatePath = path.join(_getWindowsPath(), 'SoftwareDistribution', 'Download');
    final dir = Directory(updatePath);
    
    if (!await dir.exists()) return 0;
    return await _deleteDirectoryContents(dir);
  }

  // Prefetch
  static Future<int> scanPrefetch() async {
    final prefetchPath = path.join(_getWindowsPath(), 'Prefetch');
    final dir = Directory(prefetchPath);
    
    if (!await dir.exists()) return 0;
    return await _calculateDirectorySize(dir);
  }

  static Future<int> clearPrefetch() async {
    final prefetchPath = path.join(_getWindowsPath(), 'Prefetch');
    final dir = Directory(prefetchPath);
    
    if (!await dir.exists()) return 0;
    return await _deleteDirectoryContents(dir);
  }

  // Thumbnail Cache
  static Future<int> scanThumbnailCache() async {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
    if (localAppData.isEmpty) return 0;
    
    final thumbPath = path.join(localAppData, 'Microsoft', 'Windows', 'Explorer');
    final dir = Directory(thumbPath);
    
    if (!await dir.exists()) return 0;
    
    int size = 0;
    await for (var entity in dir.list(recursive: false)) {
      if (entity is File && entity.path.contains('thumbcache')) {
        try {
          size += await entity.length();
        } catch (e) {}
      }
    }
    return size;
  }

  static Future<int> clearThumbnailCache() async {
    final localAppData = Platform.environment['LOCALAPPDATA'] ?? '';
    if (localAppData.isEmpty) return 0;
    
    final thumbPath = path.join(localAppData, 'Microsoft', 'Windows', 'Explorer');
    final dir = Directory(thumbPath);
    
    if (!await dir.exists()) return 0;
    
    int size = 0;
    await for (var entity in dir.list(recursive: false)) {
      if (entity is File && entity.path.contains('thumbcache')) {
        try {
          size += await entity.length();
          await entity.delete();
        } catch (e) {}
      }
    }
    return size;
  }

  // Recent Files
  static Future<int> scanRecentFiles() async {
    final appData = Platform.environment['APPDATA'] ?? '';
    if (appData.isEmpty) return 0;
    
    final recentPath = path.join(appData, 'Microsoft', 'Windows', 'Recent');
    final dir = Directory(recentPath);
    
    if (!await dir.exists()) return 0;
    return await _calculateDirectorySize(dir);
  }

  static Future<int> clearRecentFiles() async {
    final appData = Platform.environment['APPDATA'] ?? '';
    if (appData.isEmpty) return 0;
    
    final recentPath = path.join(appData, 'Microsoft', 'Windows', 'Recent');
    final dir = Directory(recentPath);
    
    if (!await dir.exists()) return 0;
    return await _deleteDirectoryContents(dir);
  }

  // DNS Cache Flush
  static Future<bool> flushDnsCache() async {
    try {
      final result = await Process.run('ipconfig', ['/flushdns']);
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  // Event Logs
  static Future<bool> clearEventLogs() async {
    try {
      // Clear Application, System logs
      final logs = ['Application', 'System'];
      bool success = true;
      for (var log in logs) {
        try {
          final result = await Process.run('wevtutil', ['cl', log]);
          if (result.exitCode != 0) success = false;
        } catch (e) {
          success = false;
        }
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  // Download History (Windows Downloads folder metadata)
  static Future<int> scanDownloadsFolder() async {
    final userProfile = Platform.environment['USERPROFILE'] ?? '';
    if (userProfile.isEmpty) return 0;
    
    final downloadsPath = path.join(userProfile, 'Downloads');
    final dir = Directory(downloadsPath);
    
    if (!await dir.exists()) return 0;
    return await _calculateDirectorySize(dir);
  }

  // System Restore Point Creation
  static Future<bool> createRestorePoint(String description) async {
    try {
      // Create a PowerShell script to create restore point
      final script = '''
Checkpoint-Computer -Description "$description" -RestorePointType "MODIFY_SETTINGS"
''';
      
      final result = await Process.run(
        'powershell',
        ['-Command', script],
      );
      
      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }

  // Helper methods
  static Future<int> _calculateDirectorySize(Directory dir) async {
    int size = 0;
    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            size += await entity.length();
          } catch (e) {}
        }
      }
    } catch (e) {}
    return size;
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
        } catch (e) {}
      }
    } catch (e) {}
    return size;
  }
}
