# Temp Remover Revamped

A modern, feature-rich Windows system cleaning and optimization application built with Flutter. This is a revamped version of the original Python "Temp Remover" application, remade in Flutter to demonstrate advanced Flutter development techniques.

## Overview

Temp Remover Revamped is a professional-grade system utility that helps users clean up unnecessary files, optimize storage, and maintain their Windows system's performance. With an intuitive Windows 11-style interface, it provides comprehensive tools for managing temporary files, browser data, system cleanup, and storage analysis.

## Features

### 🗑️ Core Cleaning Features

- **Temp Files Management**
  - Scan Windows temporary directories (Temp, LocalAppData\Temp, INetCache)
  - Delete both files and folders recursively
  - Automatic app self-protection (prevents breaking itself during cleanup)
  - Real-time progress tracking

- **Recycle Bin Management**
  - View recycle bin contents and total size
  - Empty recycle bin with confirmation dialog
  - Auto-refreshing status display (updates every 5 seconds)
  - Safe deletion using Windows Shell API

### 🌐 Browser Data Cleaning

- Clean cache from multiple browsers (Chrome, Edge, Firefox, Brave)
- Remove temporary browser files and cached data
- Optimized scanning for browser installation directories

### 🖥️ Windows System Cleanup

- **Windows Update Cache** - Remove old Windows Update files
- **Prefetch Cleaner** - Clear Windows prefetch folder
- **Thumbnail Cache** - Delete Windows thumbnail cache
- **Recent Files List** - Clear Windows recent files/folders
- **DNS Cache Flush** - Flush DNS cache for better network performance
- **Event Logs Cleaner** - Clear old Windows event logs

### 🔧 Advanced Tools

#### Large Files Finder
- Discover files consuming the most disk space
- Depth-limited scanning to prevent excessive memory usage
- Memory-efficient processing
- Skip system directories automatically

#### Duplicate Files Detector
- Find identical files using hash comparison
- Group duplicates by hash for easy management
- File size limits to prevent memory overflow
- Safe detection with depth limiting

#### Empty Folders Remover
- Scan for empty directories across drives
- Open folders in Windows Explorer to verify contents
- Delete confirmed empty folders
- Recursive scanning with depth limits

#### Startup Programs Manager
- View all startup programs
- Disable startup programs to improve boot time
- Administrator privileges required for modifications
- Real-time status updates

### 📊 Storage Analytics

- **Drive Information Dashboard**
  - View all connected drives
  - Display total, used, and free space
  - Visual pie charts showing usage breakdown
  - Color-coded usage indicators (green/orange/red)
  - Progress bars with percentage usage

### 📈 Cleaning History

- Track all cleaning operations performed
- View date, time, and space recovered
- Historical reference for future cleanups
- Export cleaning reports

### ⚙️ Customization

#### Custom Folder Scanning
- Add custom directories to scan and clean
- Remove custom folders from the list
- Scan specific folders instead of system defaults

#### Advanced Filtering
- **Age-Based Filtering** - Delete files older than specified days
- **Extension Filtering** - Delete specific file types (.tmp, .log, .bak, etc.)
- **Size Filtering** - Target files within specific size ranges
- Selective deletion with checkbox options

### 🎨 Theme Customization

- **Three Theme Modes**
  - Light Mode - Clean, bright interface
  - Dark Mode - Eye-friendly dark interface
  - System Setting - Automatically matches Windows 11 system theme
- Windows 11 design language and colors
- Seamless theme switching

## Technical Highlights

### Architecture
- **Service-Based Architecture** - Modular, reusable services for each feature
- **Provider Pattern** - State management with the provider package
- **Responsive UI** - Sidebar navigation with separate pages for each feature
- **Static Methods** - Efficient service calls throughout the application

### Performance Optimizations
- **Memory-Efficient Scanning** - Depth limiting and manual recursion to prevent excessive RAM usage
- **Fast Directory Traversal** - Skips system directories automatically
- **Result Limiting** - Stops scanning after finding sufficient results
- **Size Filtering** - Prevents large files from consuming memory during duplicate detection

### Safety Features
- **App Self-Protection** - Automatically excludes application files from deletion
- **Confirmation Dialogs** - User confirmation before major operations
- **Recycle Bin Usage** - Safe deletion through Windows Shell API where possible
- **Administrator Detection** - Prompts for admin rights when needed
- **System Restore Integration** - Option to create restore points before cleanup

## Navigation Structure

The application features an intuitive Windows 11-style sidebar with 8 main sections:

1. 🧹 **Temp Files** - Clean temporary files with custom folders and filters
2. 🗑️ **Recycle Bin** - Manage recycle bin contents
3. 🌐 **Browser Cleaning** - Clean browser cache and temporary files
4. 🖥️ **System Cleanup** - Windows system file cleanup
5. 🔧 **Advanced Tools** - Large files, duplicates, empty folders, startup programs
6. 📊 **Storage Analytics** - Disk space visualization and analysis
7. 📈 **History** - View cleaning operation history
8. ⚙️ **Settings** - Theme selection and application information

## System Requirements

- **OS**: Windows 10 or later (Windows 11 recommended)
- **Architecture**: x64
- **RAM**: 512 MB minimum
- **Disk Space**: 100 MB for installation
- **Administrator Rights**: Required for some features (registry modifications, system file access)

## Building the Application

### Prerequisites
- Flutter SDK installed and on PATH
- Visual Studio Build Tools or Visual Studio 2019+
- Windows 10/11 SDK

### Build Instructions

**Debug Build:**
```bash
flutter run -d windows
```

**Release Build:**
```bash
flutter build windows --release
```

The release executable will be located at:
```
build\windows\runner\Release\temp_remover_revamped.exe
```

## Dependencies

- **flutter**: Flutter framework
- **fl_chart**: Beautiful charts and graphs
- **provider**: State management
- **win32**: Windows API integration
- **flutter_svg**: SVG image support

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── pages/                             # UI pages for each feature
│   ├── temp_files_page.dart
│   ├── recycle_bin_page.dart
│   ├── browser_cleaning_page.dart
│   ├── system_cleanup_page.dart
│   ├── advanced_tools_page.dart
│   ├── storage_analytics_page.dart
│   ├── history_page.dart
│   └── settings_page.dart
├── services/                          # Business logic services
│   ├── temp_cleaner_service.dart
│   ├── recycle_bin_service.dart
│   ├── browser_cache_service.dart
│   ├── windows_cleanup_service.dart
│   ├── advanced_tools_service.dart
│   ├── storage_analytics_service.dart
│   └── cleaning_history_manager.dart
├── models/                            # Data models
│   └── app_models.dart
├── theme/                             # Theme configuration
│   └── windows11_theme.dart
└── widgets/                           # Reusable widgets
    └── app_navigation_rail.dart
```

## Usage Tips

### For Best Results:
1. Run the application as Administrator for full functionality
2. Close other applications before running large scans
3. Create a system restore point before running aggressive cleanup
4. Review the file list before deletion in Temp Files section
5. Use custom folder filtering for selective cleanup

### Memory Usage:
- The application uses optimized memory-efficient scanning
- Large file scans should use ~100-500 MB RAM
- Empty folder scanning with depth limits prevents excessive memory usage

## About This Project

This is a revamped version of the original Python application "Temp Remover", remade in Flutter to demonstrate modern Flutter development techniques including:
- Complex UI design with Windows 11 styling
- Windows API integration
- State management patterns
- Service-based architecture
- Performance optimization strategies
- Cross-platform considerations

## License

This project is personal and for educational purposes.

## Contributing

This is a personal project. Feedback and suggestions are welcome!

---

**Version**: 1.0.0  
**Last Updated**: January 2026  
**Built with**: Flutter & Dart
