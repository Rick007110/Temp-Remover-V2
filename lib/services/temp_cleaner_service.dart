import 'dart:io';
import '../models/app_models.dart';

class FileInfo {
  final String path;
  final int size;
  final DateTime modified;
  final bool isDirectory;

  FileInfo({
    required this.path,
    required this.size,
    required this.modified,
    required this.isDirectory,
  });
}

class TempCleanerService {
  // Get the app's executable directory to exclude it from deletion
  static String? _getAppDirectory() {
    try {
      final exePath = Platform.resolvedExecutable;
      final exeDir = Directory(exePath).parent.path;
      return exeDir;
    } catch (e) {
      print('Error getting app directory: $e');
      return null;
    }
  }

  // Check if a path should be excluded from deletion
  static bool _shouldExcludePath(String path) {
    final appDir = _getAppDirectory();
    if (appDir != null && path.startsWith(appDir)) {
      return true;
    }
    
    // Exclude Flutter-specific paths
    final excludePatterns = [
      'flutter_tools',
      'dart-sdk',
      'flutter_windows',
      'temp_remover_revamped', // Our app name
    ];
    
    for (var pattern in excludePatterns) {
      if (path.toLowerCase().contains(pattern.toLowerCase())) {
        return true;
      }
    }
    
    return false;
  }

  // Get system temp directories
  static Future<List<Directory>> getTempDirectories() async {
    List<Directory> tempDirs = [];
    
    // Windows temp directories
    final tempPath = Platform.environment['TEMP'] ?? 'C:\\Windows\\Temp';
    final localTempPath = Platform.environment['LOCALAPPDATA'] ?? '';
    
    // Add TEMP directory
    final tempDir = Directory(tempPath);
    if (await tempDir.exists()) {
      tempDirs.add(tempDir);
    }
    
    // Add AppData\Local\Temp directory
    if (localTempPath.isNotEmpty) {
      final localTempDir = Directory('$localTempPath\\Temp');
      if (await localTempDir.exists()) {
        tempDirs.add(localTempDir);
      }
    }
    
    // Add Temporary Internet Files (Browser Cache)
    if (localTempPath.isNotEmpty) {
      final internetTempDir = Directory('$localTempPath\\Microsoft\\Windows\\INetCache');
      if (await internetTempDir.exists()) {
        tempDirs.add(internetTempDir);
      }
    }
    
    return tempDirs;
  }

  // Scan temp folders and get file information
  static Future<List<FileInfo>> scanTempFiles() async {
    List<FileInfo> files = [];
    final tempDirs = await getTempDirectories();
    
    for (var dir in tempDirs) {
      try {
        await _scanDirectory(dir, files);
      } catch (e) {
        print('Error scanning directory ${dir.path}: $e');
      }
    }
    
    return files;
  }

  // Recursively scan directory for files and folders
  static Future<void> _scanDirectory(Directory dir, List<FileInfo> files) async {
    try {
      final entries = await dir.list(recursive: false, followLinks: false).toList();
      
      for (var entry in entries) {
        try {
          // Skip excluded paths
          if (_shouldExcludePath(entry.path)) {
            continue;
          }
          
          if (entry is File) {
            final stat = await entry.stat();
            files.add(FileInfo(
              path: entry.path,
              size: stat.size,
              modified: stat.modified,
              isDirectory: false,
            ));
          } else if (entry is Directory) {
            // Calculate directory size by scanning its contents
            final dirSize = await _calculateDirectorySize(entry);
            files.add(FileInfo(
              path: entry.path,
              size: dirSize,
              modified: (await entry.stat()).modified,
              isDirectory: true,
            ));
            // Continue scanning subdirectories
            await _scanDirectory(entry, files);
          }
        } catch (e) {
          print('Error processing entry ${entry.path}: $e');
        }
      }
    } catch (e) {
      print('Error listing directory ${dir.path}: $e');
    }
  }

  // Calculate total size of a directory
  static Future<int> _calculateDirectorySize(Directory dir) async {
    int totalSize = 0;
    try {
      final entries = await dir.list(recursive: true, followLinks: false).toList();
      for (var entry in entries) {
        try {
          if (entry is File) {
            final stat = await entry.stat();
            totalSize += stat.size;
          }
        } catch (e) {
          // Ignore files we can't access
        }
      }
    } catch (e) {
      // Ignore directories we can't access
    }
    return totalSize;
  }

  // Calculate total size of files in bytes
  static int calculateTotalSize(List<FileInfo> files) {
    return files.fold(0, (sum, file) => sum + file.size);
  }

  // Format bytes to human readable size
  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes.isInfinite || bytes.isNaN) return "0 B";
    
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (bytes.bitLength - 1) ~/ 10; // More accurate calculation
    if (i >= suffixes.length) {
      return '${(bytes / (1 << ((suffixes.length - 1) * 10))).toStringAsFixed(2)} ${suffixes[suffixes.length - 1]}';
    }
    
    final divisor = 1 << (i * 10);
    final result = bytes / divisor;
    
    return '${result.toStringAsFixed(2)} ${suffixes[i]}';
  }

  // Delete a single file or directory
  static Future<bool> deleteFileOrDirectory(String path) async {
    try {
      final entity = FileSystemEntity.typeSync(path);
      
      if (_shouldExcludePath(path)) {
        print('Skipping excluded path: $path');
        return false;
      }
      
      if (entity == FileSystemEntityType.file) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
          return true;
        }
      } else if (entity == FileSystemEntityType.directory) {
        final dir = Directory(path);
        if (await dir.exists()) {
          await dir.delete(recursive: true);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Error deleting $path: $e');
      return false;
    }
  }

  // Delete multiple files
  static Future<int> deleteMultipleFiles(List<String> filePaths) async {
    int deletedCount = 0;
    
    for (var filePath in filePaths) {
      try {
        if (await deleteFileOrDirectory(filePath)) {
          deletedCount++;
        }
      } catch (e) {
        print('Error deleting $filePath: $e');
      }
    }
    
    return deletedCount;
  }

  // Delete all temp files and folders
  static Future<Map<String, dynamic>> deleteAllTempFiles() async {
    final tempDirs = await getTempDirectories();
    int deleted = 0;
    int failed = 0;
    int totalSize = 0;
    
    // Get all items to delete (but don't recurse into subdirectories)
    Set<String> itemsToDelete = {};
    
    for (var tempDir in tempDirs) {
      try {
        final entries = await tempDir.list(recursive: false, followLinks: false).toList();
        for (var entry in entries) {
          if (!_shouldExcludePath(entry.path)) {
            itemsToDelete.add(entry.path);
            // Calculate size
            try {
              if (entry is File) {
                final stat = await entry.stat();
                totalSize += stat.size;
              } else if (entry is Directory) {
                totalSize += await _calculateDirectorySize(entry);
              }
            } catch (e) {
              // Ignore size calculation errors
            }
          }
        }
      } catch (e) {
        print('Error processing temp directory ${tempDir.path}: $e');
      }
    }
    
    // Delete all items
    for (var path in itemsToDelete) {
      try {
        if (await deleteFileOrDirectory(path)) {
          deleted++;
        } else {
          failed++;
        }
      } catch (e) {
        failed++;
        print('Error deleting $path: $e');
      }
    }
    
    return {
      'totalFiles': itemsToDelete.length,
      'deletedFiles': deleted,
      'failedFiles': failed,
      'totalSize': totalSize,
      'formattedSize': formatBytes(totalSize),
    };
  }

  // Scan custom folders with filters
  static Future<List<FileInfo>> scanCustomFolders({
    required List<String> folderPaths,
    CleaningFilters? filters,
  }) async {
    List<FileInfo> files = [];
    
    for (var folderPath in folderPaths) {
      final dir = Directory(folderPath);
      if (await dir.exists()) {
        try {
          await _scanDirectoryWithFilters(dir, files, filters);
        } catch (e) {
          print('Error scanning directory $folderPath: $e');
        }
      }
    }
    
    return files;
  }

  // Scan directory with filters applied
  static Future<void> _scanDirectoryWithFilters(
    Directory dir,
    List<FileInfo> files,
    CleaningFilters? filters,
  ) async {
    try {
      final entries = await dir.list(recursive: false, followLinks: false).toList();
      
      for (var entry in entries) {
        try {
          if (_shouldExcludePath(entry.path)) {
            continue;
          }
          
          final stat = await entry.stat();
          
          // Apply filters
          if (filters != null && !filters.matchesFilter(entry, stat)) {
            continue;
          }
          
          if (entry is File) {
            files.add(FileInfo(
              path: entry.path,
              size: stat.size,
              modified: stat.modified,
              isDirectory: false,
            ));
          } else if (entry is Directory) {
            final dirSize = await _calculateDirectorySize(entry);
            files.add(FileInfo(
              path: entry.path,
              size: dirSize,
              modified: stat.modified,
              isDirectory: true,
            ));
            await _scanDirectoryWithFilters(entry, files, filters);
          }
        } catch (e) {
          print('Error processing entry ${entry.path}: $e');
        }
      }
    } catch (e) {
      print('Error listing directory ${dir.path}: $e');
    }
  }

  // Delete with filters
  static Future<Map<String, dynamic>> deleteWithFilters({
    required List<String> folderPaths,
    CleaningFilters? filters,
  }) async {
    final files = await scanCustomFolders(
      folderPaths: folderPaths,
      filters: filters,
    );
    
    int deleted = 0;
    int failed = 0;
    int totalSize = calculateTotalSize(files);
    
    for (var file in files) {
      try {
        if (await deleteFileOrDirectory(file.path)) {
          deleted++;
        } else {
          failed++;
        }
      } catch (e) {
        failed++;
        print('Error deleting ${file.path}: $e');
      }
    }
    
    return {
      'totalFiles': files.length,
      'deletedFiles': deleted,
      'failedFiles': failed,
      'totalSize': totalSize,
      'formattedSize': formatBytes(totalSize),
    };
  }
}
