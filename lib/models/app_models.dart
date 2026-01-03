import 'dart:io';

class CleaningHistory {
  final DateTime timestamp;
  final String operation;
  final int filesDeleted;
  final int bytesDeleted;

  CleaningHistory({
    required this.timestamp,
    required this.operation,
    required this.filesDeleted,
    required this.bytesDeleted,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'operation': operation,
        'filesDeleted': filesDeleted,
        'bytesDeleted': bytesDeleted,
      };

  factory CleaningHistory.fromJson(Map<String, dynamic> json) =>
      CleaningHistory(
        timestamp: DateTime.parse(json['timestamp']),
        operation: json['operation'],
        filesDeleted: json['filesDeleted'],
        bytesDeleted: json['bytesDeleted'],
      );
}

class CustomFolder {
  final String path;
  final String name;
  final bool isEnabled;

  CustomFolder({
    required this.path,
    required this.name,
    this.isEnabled = true,
  });

  Map<String, dynamic> toJson() => {
        'path': path,
        'name': name,
        'isEnabled': isEnabled,
      };

  factory CustomFolder.fromJson(Map<String, dynamic> json) => CustomFolder(
        path: json['path'],
        name: json['name'],
        isEnabled: json['isEnabled'] ?? true,
      );
}

class StorageInfo {
  final String driveLetter;
  final String driveType;
  final int totalSpace;
  final int freeSpace;
  final int usedSpace;

  StorageInfo({
    required this.driveLetter,
    required this.driveType,
    required this.totalSpace,
    required this.freeSpace,
    required this.usedSpace,
  });

  double get usedPercentage => totalSpace > 0 ? (usedSpace / totalSpace) * 100 : 0;
}

class LargeFile {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  LargeFile({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });
}

class DuplicateFileGroup {
  final String hash;
  final List<String> files;
  final int fileSize;

  DuplicateFileGroup({
    required this.hash,
    required this.files,
    required this.fileSize,
  });

  int get totalSize => fileSize * files.length;
  int get totalWastedSpace => fileSize * (files.length - 1);
}

class StartupProgram {
  final String name;
  final String path;
  final String location;
  final bool isEnabled;

  StartupProgram({
    required this.name,
    required this.path,
    required this.location,
    required this.isEnabled,
  });
}

class CleaningFilters {
  final int? minAgeDays;
  final List<String>? allowedExtensions;
  final int? minFileSizeBytes;
  final int? maxFileSizeBytes;

  CleaningFilters({
    this.minAgeDays,
    this.allowedExtensions,
    this.minFileSizeBytes,
    this.maxFileSizeBytes,
  });

  bool matchesFilter(FileSystemEntity entity, FileStat stat) {
    // Check age filter
    if (minAgeDays != null) {
      final ageInDays = DateTime.now().difference(stat.modified).inDays;
      if (ageInDays < minAgeDays!) return false;
    }

    // Check size filter
    if (entity is File) {
      if (minFileSizeBytes != null && stat.size < minFileSizeBytes!) return false;
      if (maxFileSizeBytes != null && stat.size > maxFileSizeBytes!) return false;

      // Check extension filter
      if (allowedExtensions != null && allowedExtensions!.isNotEmpty) {
        final ext = entity.path.split('.').last.toLowerCase();
        if (!allowedExtensions!.contains(ext)) return false;
      }
    }

    return true;
  }
}
