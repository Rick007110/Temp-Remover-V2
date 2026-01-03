import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import '../models/app_models.dart';

class StorageAnalyticsService {
  static Future<List<StorageInfo>> getDiskInfo() async {
    List<StorageInfo> drives = [];
    
    try {
      final drivesMask = GetLogicalDrives();
      
      for (int i = 0; i < 26; i++) {
        if ((drivesMask & (1 << i)) != 0) {
          final driveLetter = String.fromCharCode(65 + i);
          final drivePath = '$driveLetter:\\';
          
          final pathPtr = drivePath.toNativeUtf16();
          final freeBytes = calloc<Uint64>();
          final totalBytes = calloc<Uint64>();
          final totalFreeBytes = calloc<Uint64>();
          
          try {
            final result = GetDiskFreeSpaceEx(
              pathPtr,
              freeBytes,
              totalBytes,
              totalFreeBytes,
            );
            
            if (result != 0) {
              final total = totalBytes.value;
              final free = freeBytes.value;
              final used = total - free;
              
              if (total > 0) {
                drives.add(StorageInfo(
                  driveLetter: driveLetter,
                  driveType: 'Local Disk',
                  totalSpace: total,
                  freeSpace: free,
                  usedSpace: used,
                ));
              }
            }
          } finally {
            calloc.free(pathPtr);
            calloc.free(freeBytes);
            calloc.free(totalBytes);
            calloc.free(totalFreeBytes);
          }
        }
      }
    } catch (e) {
      print('Error getting disk info: $e');
    }
    
    return drives;
  }

  static String formatBytes(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes.isInfinite || bytes.isNaN) return "0 B";
    
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    final i = (bytes.bitLength - 1) ~/ 10;
    if (i >= suffixes.length) {
      return '${(bytes / (1 << ((suffixes.length - 1) * 10))).toStringAsFixed(2)} ${suffixes[suffixes.length - 1]}';
    }
    
    final divisor = 1 << (i * 10);
    final result = bytes / divisor;
    
    return '${result.toStringAsFixed(2)} ${suffixes[i]}';
  }
}
