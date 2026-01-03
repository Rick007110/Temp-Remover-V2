import 'dart:io';
import 'package:crypto/crypto.dart';
import '../models/app_models.dart';

class AdvancedToolsService {
  // Find large files
  static Future<List<LargeFile>> findLargeFiles({
    required String rootPath,
    required int minSizeBytes,
    int maxResults = 100,
  }) async {
    List<LargeFile> largeFiles = [];
    final dir = Directory(rootPath);

    if (!await dir.exists()) return largeFiles;

    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            final size = await entity.length();
            if (size >= minSizeBytes) {
              final stat = await entity.stat();
              largeFiles.add(LargeFile(
                path: entity.path,                name: entity.path.split('\\').last,                size: size,
                modified: stat.modified,
              ));
            }
          } catch (e) {
            // Skip files we can't access
          }
        }
      }
    } catch (e) {
      // Skip directories we can't access
    }

    // Sort by size descending
    largeFiles.sort((a, b) => b.size.compareTo(a.size));
    
    // Return top results
    return largeFiles.take(maxResults).toList();
  }

  // Find duplicate files
  static Future<List<DuplicateFileGroup>> findDuplicateFiles({
    required String rootPath,
    int minSizeBytes = 1024, // Skip very small files
    int maxSizeBytes = 100 * 1024 * 1024, // Skip files larger than 100MB for hashing
    int maxDepth = 5,
  }) async {
    Map<String, List<String>> hashGroups = {};
    final skipDirs = {
      'windows', 'program files', 'program files (x86)', 'programdata',
      'system volume information', '\$recycle.bin', 'appdata\\local\\packages',
      'node_modules', '.git'
    };
    int filesProcessed = 0;
    const maxFiles = 10000;

    Future<void> scanDirectory(Directory dir, int depth) async {
      if (depth > maxDepth || filesProcessed >= maxFiles) return;
      
      final dirName = dir.path.toLowerCase();
      if (skipDirs.any((skip) => dirName.contains(skip))) return;

      try {
        await for (var entity in dir.list(followLinks: false)) {
          if (filesProcessed >= maxFiles) break;
          
          if (entity is File) {
            try {
              final size = await entity.length();
              if (size >= minSizeBytes && size <= maxSizeBytes) {
                final hash = await _calculateFileHash(entity);
                if (hash.isNotEmpty) {
                  hashGroups.putIfAbsent(hash, () => []).add(entity.path);
                  filesProcessed++;
                }
              }
            } catch (e) {
              // Skip files we can't access
            }
          } else if (entity is Directory) {
            await scanDirectory(entity, depth + 1);
          }
        }
      } catch (e) {
        // Skip directories we can't access
      }
    }

    final dir = Directory(rootPath);
    if (await dir.exists()) {
      await scanDirectory(dir, 0);
    }

    // Filter to only groups with duplicates
    List<DuplicateFileGroup> duplicates = [];
    for (var entry in hashGroups.entries) {
      if (entry.value.length > 1) {
        final firstFile = File(entry.value.first);
        try {
          final size = await firstFile.length();
          duplicates.add(DuplicateFileGroup(
            hash: entry.key,
            files: entry.value,
            fileSize: size,
          ));
        } catch (e) {
          // Skip if file no longer exists
        }
      }
    }

    // Sort by total wasted space
    duplicates.sort((a, b) => b.totalWastedSpace.compareTo(a.totalWastedSpace));
    
    return duplicates;
  }

  static Future<String> _calculateFileHash(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      return '';
    }
  }

  // Find empty folders
  static Future<List<Directory>> findEmptyFolders(String rootPath, {int maxDepth = 5, int maxResults = 1000}) async {
    List<Directory> emptyFolders = [];
    final skipDirs = {
      'windows', 'program files', 'program files (x86)', 'programdata',
      'system volume information', '\$recycle.bin', 'recovery',
      'perflogs', 'windows.old', 'boot', 'efi', 'appdata\\local\\packages',
      'appdata\\local\\microsoft', 'node_modules', '.git'
    };

    Future<void> scanDirectory(Directory dir, int depth) async {
      if (depth > maxDepth || emptyFolders.length >= maxResults) return;
      
      final dirName = dir.path.toLowerCase();
      if (skipDirs.any((skip) => dirName.contains(skip))) return;

      try {
        final entities = <FileSystemEntity>[];
        await for (var entity in dir.list(followLinks: false)) {
          entities.add(entity);
          if (entities.length > 100) break; // Not empty if it has many items
        }

        if (entities.isEmpty) {
          emptyFolders.add(dir);
          return; // Don't recurse into empty folders
        }

        // Recursively scan subdirectories (only if not too many items)
        if (entities.length <= 50) {
          for (var entity in entities) {
            if (entity is Directory && emptyFolders.length < maxResults) {
              await scanDirectory(entity, depth + 1);
            }
          }
        }
      } catch (e) {
        // Skip directories we can't access
      }
    }

    final dir = Directory(rootPath);
    if (await dir.exists()) {
      await scanDirectory(dir, 0);
    }

    return emptyFolders;
  }

  // Delete empty folders
  static Future<int> deleteEmptyFolders(List<Directory> folders) async {
    int deleted = 0;
    for (var folder in folders) {
      try {
        await folder.delete();
        deleted++;
      } catch (e) {
        // Skip folders we can't delete
      }
    }
    return deleted;
  }

  // Get startup programs (Windows Registry)
  static Future<List<StartupProgram>> getStartupPrograms() async {
    List<StartupProgram> programs = [];

    try {
      // Query registry for startup programs
      final runKey = await Process.run('reg', [
        'query',
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run',
        '/v', '*'
      ]);

      if (runKey.exitCode == 0) {
        _parseRegistryOutput(runKey.stdout.toString(), programs, 'HKCU\\Run');
      }

      final runOnceKey = await Process.run('reg', [
        'query',
        'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce',
        '/v', '*'
      ]);

      if (runOnceKey.exitCode == 0) {
        _parseRegistryOutput(runOnceKey.stdout.toString(), programs, 'HKCU\\RunOnce');
      }
    } catch (e) {
      // Skip if registry access fails
    }

    return programs;
  }

  static void _parseRegistryOutput(String output, List<StartupProgram> programs, String location) {
    final lines = output.split('\n');
    for (var line in lines) {
      if (line.trim().isEmpty || line.contains('HKEY_')) continue;
      
      final parts = line.trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final name = parts[0];
        final path = parts.sublist(2).join(' ');
        
        programs.add(StartupProgram(
          name: name,
          path: path,
          location: location,
          isEnabled: true,
        ));
      }
    }
  }

  // Disable startup program
  static Future<bool> disableStartupProgram(StartupProgram program) async {
    try {
      final key = program.location.contains('RunOnce') 
          ? 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\RunOnce'
          : 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run';
      
      final result = await Process.run('reg', [
        'delete',
        key,
        '/v', program.name,
        '/f'
      ]);

      return result.exitCode == 0;
    } catch (e) {
      return false;
    }
  }
}
