import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class RecycleBinService {
  // Empty the recycle bin using Windows API
  static Future<bool> emptyRecycleBin() async {
    try {
      // Use SHELLFLAG_NOCONFIRMATION to skip confirmation dialog
      final result = SHEmptyRecycleBin(
        nullptr, // hwnd - no parent window
        nullptr, // pszRootPath - NULL for all drives
        SHERB_NOCONFIRMATION | SHERB_NOPROGRESSUI, // dwFlags
      );
      
      return result == S_OK;
    } catch (e) {
      print('Error emptying recycle bin: $e');
      return false;
    }
  }

  // Get recycle bin info
  static Future<Map<String, dynamic>> getRecycleBinInfo() async {
    try {
      // Create a SHQUERYRBINFO structure
      final queryRBInfo = calloc<SHQUERYRBINFO>();
      queryRBInfo.ref.cbSize = sizeOf<SHQUERYRBINFO>();
      
      // Query recycle bin information for all drives (NULL = all drives)
      final result = SHQueryRecycleBin(nullptr, queryRBInfo);
      
      if (result == S_OK) {
        final fileCount = queryRBInfo.ref.i64NumItems;
        final totalSize = queryRBInfo.ref.i64Size;
        
        calloc.free(queryRBInfo);
        
        return {
          'success': true,
          'fileCount': fileCount,
          'totalSize': totalSize,
          'formattedSize': _formatBytes(totalSize.toInt()),
        };
      }
      
      calloc.free(queryRBInfo);
      return {
        'success': false,
        'fileCount': 0,
        'totalSize': 0,
        'formattedSize': '0 B',
      };
    } catch (e) {
      print('Error getting recycle bin info: $e');
      return {
        'success': false,
        'fileCount': 0,
        'totalSize': 0,
        'formattedSize': '0 B',
      };
    }
  }

  // Format bytes to human readable format
  static String _formatBytes(int bytes) {
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
}

// Win32 API declarations
const String _shell32 = 'shell32.dll';

// SHQUERYRBINFO structure
final class SHQUERYRBINFO extends Struct {
  @Uint32()
  external int cbSize;
  
  @Int64()
  external int i64Size;
  
  @Int64()
  external int i64NumItems;
}

// SHEmptyRecycleBin constants
const int SHERB_NOCONFIRMATION = 0x00000001;
const int SHERB_NOPROGRESSUI = 0x00000002;

// SHEmptyRecycleBin function
final DynamicLibrary _shell32Lib = DynamicLibrary.open(_shell32);

typedef SHEmptyRecycleBinNative = Int32 Function(
  Pointer<Void> hwnd,
  Pointer<Utf16> pszRootPath,
  Uint32 dwFlags,
);

typedef SHEmptyRecycleBinDart = int Function(
  Pointer<Void> hwnd,
  Pointer<Utf16> pszRootPath,
  int dwFlags,
);

final SHEmptyRecycleBinDart SHEmptyRecycleBin =
    _shell32Lib.lookup<NativeFunction<SHEmptyRecycleBinNative>>('SHEmptyRecycleBinW').asFunction();

// SHQueryRecycleBin function
typedef SHQueryRecycleBinNative = Int32 Function(
  Pointer<Utf16> pszRootPath,
  Pointer<SHQUERYRBINFO> pSHQueryRBInfo,
);

typedef SHQueryRecycleBinDart = int Function(
  Pointer<Utf16> pszRootPath,
  Pointer<SHQUERYRBINFO> pSHQueryRBInfo,
);

final SHQueryRecycleBinDart SHQueryRecycleBin =
    _shell32Lib.lookup<NativeFunction<SHQueryRecycleBinNative>>('SHQueryRecycleBinW').asFunction();
