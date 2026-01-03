import 'package:flutter/material.dart';
import '../services/advanced_tools_service.dart';
import '../models/app_models.dart';
import '../theme/windows11_theme.dart';
import 'dart:io';

class AdvancedToolsPage extends StatefulWidget {
  const AdvancedToolsPage({super.key});

  @override
  State<AdvancedToolsPage> createState() => _AdvancedToolsPageState();
}

class _AdvancedToolsPageState extends State<AdvancedToolsPage> with SingleTickerProviderStateMixin {

  late TabController _tabController;
  
  List<LargeFile>? _largeFiles;
  List<DuplicateFileGroup>? _duplicateGroups;
  List<String>? _emptyFolders;
  List<StartupProgram>? _startupPrograms;
  
  bool _isScanning = false;
  String? _statusMessage;
  
  double _minFileSizeMB = 100.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _loadTabData(_tabController.index);
      }
    });
    _loadTabData(0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTabData(int index) async {
    switch (index) {
      case 0:
        await _scanLargeFiles();
        break;
      case 1:
        await _scanDuplicates();
        break;
      case 2:
        await _scanEmptyFolders();
        break;
      case 3:
        await _loadStartupPrograms();
        break;
    }
  }

  Future<void> _scanLargeFiles() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for large files...';
    });

    try {
      final files = await AdvancedToolsService.findLargeFiles(
        rootPath: 'C:\\',
        minSizeBytes: (_minFileSizeMB * 1024 * 1024).toInt(),
      );
      
      setState(() {
        _largeFiles = files;
        _isScanning = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _scanDuplicates() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for duplicate files...';
    });

    try {
      final duplicates = await AdvancedToolsService.findDuplicateFiles(
        rootPath: 'C:\\Users',
      );
      
      setState(() {
        _duplicateGroups = duplicates;
        _isScanning = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _scanEmptyFolders() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning for empty folders...';
    });

    try {
      final folders = await AdvancedToolsService.findEmptyFolders('C:\\Users');
      
      setState(() {
        _emptyFolders = folders.map((dir) => dir.path).toList();
        _isScanning = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _loadStartupPrograms() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Loading startup programs...';
    });

    try {
      final programs = await AdvancedToolsService.getStartupPrograms();
      
      setState(() {
        _startupPrograms = programs;
        _isScanning = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error: $e';
      });
    }
  }

  Future<void> _deleteFile(String path) async {
    try {
      await File(path).delete();
      _showSnackBar('File deleted');
      _loadTabData(_tabController.index);
    } catch (e) {
      _showSnackBar('Error deleting file: $e');
    }
  }

  Future<void> _deleteFolder(String path) async {
    try {
      await Directory(path).delete(recursive: true);
      _showSnackBar('Folder deleted');
      _loadTabData(_tabController.index);
    } catch (e) {
      _showSnackBar('Error deleting folder: $e');
    }
  }

  Future<void> _toggleStartupProgram(StartupProgram program) async {
    try {
      final success = await AdvancedToolsService.disableStartupProgram(program);
      if (success) {
        _showSnackBar('${program.name} disabled');
        await _loadStartupPrograms();
      } else {
        _showSnackBar('Failed to disable ${program.name}. Try running as administrator.');
      }
    } catch (e) {
      _showSnackBar('Error: $e');
    }
  }

  Future<void> _openFolder(String folderPath) async {
    try {
      await Process.run('explorer', [folderPath]);
    } catch (e) {
      _showSnackBar('Error opening folder: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Windows11Colors.darkBackground : Windows11Colors.lightBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Advanced Tools',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Advanced system optimization and analysis tools',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Large Files'),
              Tab(text: 'Duplicates'),
              Tab(text: 'Empty Folders'),
              Tab(text: 'Startup Programs'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLargeFilesTab(),
                _buildDuplicatesTab(),
                _buildEmptyFoldersTab(),
                _buildStartupProgramsTab(),
              ],
            ),
          ),
          if (_statusMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  if (_isScanning) ...[
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    _statusMessage!,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLargeFilesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Text('Minimum size: ${_minFileSizeMB.toInt()} MB'),
              Expanded(
                child: Slider(
                  value: _minFileSizeMB,
                  min: 10,
                  max: 1000,
                  divisions: 99,
                  onChanged: (value) {
                    setState(() {
                      _minFileSizeMB = value;
                    });
                  },
                  onChangeEnd: (value) => _scanLargeFiles(),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanLargeFiles,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isScanning
              ? const Center(child: CircularProgressIndicator())
              : _largeFiles == null || _largeFiles!.isEmpty
                  ? const Center(child: Text('No large files found'))
                  : ListView.builder(
                      itemCount: _largeFiles!.length,
                      itemBuilder: (context, index) {
                        final file = _largeFiles![index];
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(file.name),
                          subtitle: Text('${file.path}\n${_formatBytes(file.size)}'),
                          isThreeLine: true,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteFile(file.path),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildDuplicatesTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanDuplicates,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isScanning
              ? const Center(child: CircularProgressIndicator())
              : _duplicateGroups == null || _duplicateGroups!.isEmpty
                  ? const Center(child: Text('No duplicates found'))
                  : ListView.builder(
                      itemCount: _duplicateGroups!.length,
                      itemBuilder: (context, index) {
                        final group = _duplicateGroups![index];
                        return ExpansionTile(
                          title: Text('${group.files.length} duplicates'),
                          subtitle: Text(_formatBytes(group.totalSize)),
                          children: group.files.map((file) {
                            return ListTile(
                              leading: const Icon(Icons.content_copy),
                              title: Text(file.split('\\').last),
                              subtitle: Text(file),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteFile(file),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildEmptyFoldersTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanEmptyFolders,
                icon: const Icon(Icons.refresh),
                label: const Text('Scan'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isScanning
              ? const Center(child: CircularProgressIndicator())
              : _emptyFolders == null || _emptyFolders!.isEmpty
                  ? const Center(child: Text('No empty folders found'))
                  : ListView.builder(
                      itemCount: _emptyFolders!.length,
                      itemBuilder: (context, index) {
                        final folder = _emptyFolders![index];
                        return ListTile(
                          leading: const Icon(Icons.folder_open),
                          title: Text(folder.split('\\').last),
                          subtitle: Text(folder),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.launch),
                                tooltip: 'Open folder',
                                onPressed: () => _openFolder(folder),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Delete folder',
                                onPressed: () => _deleteFolder(folder),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildStartupProgramsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _loadStartupPrograms,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _isScanning
              ? const Center(child: CircularProgressIndicator())
              : _startupPrograms == null || _startupPrograms!.isEmpty
                  ? const Center(child: Text('No startup programs found'))
                  : ListView.builder(
                      itemCount: _startupPrograms!.length,
                      itemBuilder: (context, index) {
                        final program = _startupPrograms![index];
                        return SwitchListTile(
                          secondary: const Icon(Icons.power_settings_new),
                          title: Text(program.name),
                          subtitle: Text(program.path),
                          value: program.isEnabled,
                          onChanged: (value) => _toggleStartupProgram(program),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
