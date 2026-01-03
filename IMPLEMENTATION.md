# Temp Remover Application

A Flutter Windows application that allows users to:
- Scan temporary files folder
- Delete temp files content
- Empty the Windows Recycle Bin

## Features

### 1. Temp Files Management
- **Scan Temp Folders**: Scans multiple Windows temp directories including:
  - `%TEMP%` - Main Windows temp directory
  - `%LOCALAPPDATA%\Temp` - User's local temp directory
  - `%LOCALAPPDATA%\Microsoft\Windows\INetCache` - Browser cache
- **View File Information**: Displays number of files and total size
- **Delete All**: Safely delete all scanned temp files with confirmation dialog
- **Progress Tracking**: Shows deletion progress and results

### 2. Recycle Bin Management
- **Check Status**: View number of items and total size in recycle bin
- **Empty Safely**: Remove all items from recycle bin with confirmation
- **Automatic Refresh**: Updates recycle bin info after emptying

## Technical Details

### Dependencies
- **flutter**: Core Flutter framework
- **win32**: Windows API integration for recycle bin operations
- **flutter_svg**: SVG support for icons

### Services

#### TempCleanerService
- `getTempDirectories()`: Returns list of system temp directories
- `scanTempFiles()`: Scans all temp directories recursively
- `calculateTotalSize()`: Calculates total size of files
- `formatBytes()`: Formats bytes to human-readable format (B, KB, MB, GB)
- `deleteFile()`: Safely deletes a single file
- `deleteMultipleFiles()`: Deletes multiple files
- `deleteAllTempFiles()`: Deletes all scanned temp files

#### RecycleBinService
- `emptyRecycleBin()`: Empties the Windows Recycle Bin
- `getRecycleBinInfo()`: Retrieves recycle bin file count and total size
- Uses Windows Shell API (SHEmptyRecycleBin, SHQueryRecycleBin)

## Building & Running

### Prerequisites
- Flutter SDK (>=3.10.4)
- Windows 10/11
- Visual Studio with C++ development tools (for Windows build)

### Build Commands
```bash
# Get dependencies
flutter pub get

# Run in debug mode
flutter run -d windows

# Build release version
flutter build windows --release
```

### Running the Application
1. Click "Scan" to find temp files
2. Review the files to be deleted
3. Click "Delete All Temp Files" to remove them
4. Use "Empty Recycle Bin" to clear the recycle bin

## Safety Features
- **Confirmation Dialogs**: All destructive operations require user confirmation
- **Error Handling**: Graceful error handling with user-friendly messages
- **Progress Indication**: Shows loading states during scanning and deletion
- **File Limit Display**: Shows only first 100 files in the list to prevent UI lag

## UI Components
- **AppBar**: Application title and header
- **Recycle Bin Card**: Shows recycle bin status and empty button
- **Temp Files Card**: Shows scan results and delete button
- **File List**: Displays preview of files to be deleted (up to 100)
- **Dialogs**: Confirmation dialogs for all dangerous operations

## Notes
- Application requires administrator privileges for full functionality
- Some system files may not be deletable due to file locks
- Failed deletions are tracked and reported to the user
