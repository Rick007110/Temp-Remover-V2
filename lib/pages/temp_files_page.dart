import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../services/temp_cleaner_service.dart';
import '../services/cleaning_history_manager.dart';
import '../models/app_models.dart';

class TempFilesPage extends StatefulWidget {
  const TempFilesPage({Key? key}) : super(key: key);

  @override
  State<TempFilesPage> createState() => _TempFilesPageState();
}

class _TempFilesPageState extends State<TempFilesPage> {
  List<FileInfo> tempFiles = [];
  List<CustomFolder> customFolders = [];
  bool isScanning = false;
  bool isDeleting = false;
  bool _showFilters = false;
  
  // Filter options
  int _ageFilterDays = 0; // 0 means no filter
  Set<String> _extensionFilter = {};
  final List<String> _commonExtensions = [
    'tmp', 'temp', 'log', 'bak', 'cache', 'old',
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomFolders();
  }

  Future<void> _loadCustomFolders() async {
    final folders = await CleaningHistoryManager.getEnabledCustomFolders();
    setState(() {
      customFolders = folders;
    });
  }

  Future<void> _scanTempFiles() async {
    setState(() {
      isScanning = true;
      tempFiles = [];
    });

    try {
      final files = await TempCleanerService.scanTempFiles();
      setState(() {
        tempFiles = files;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning temp files: $e')),
        );
      }
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<void> _deleteAllTempFiles() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Delete ${tempFiles.length} items (files and folders) totaling ${TempCleanerService.formatBytes(TempCleanerService.calculateTotalSize(tempFiles))}?\n\nNote: Files and folders used by this application will be automatically excluded.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      isDeleting = true;
    });

    try {
      // Create filters
      final filters = CleaningFilters(
        minAgeDays: _ageFilterDays > 0 ? _ageFilterDays : null,
        allowedExtensions: _extensionFilter.isNotEmpty ? _extensionFilter.toList() : null,
      );
      
      // Get temp folder paths and custom folders
      final List<String> folderPaths = [
        Platform.environment['TEMP'] ?? '',
        ...customFolders.where((f) => f.isEnabled).map((f) => f.path),
      ];
      
      final result = await TempCleanerService.deleteWithFilters(
        folderPaths: folderPaths,
        filters: filters,
      );
      
      // Add to history
      await CleaningHistoryManager.addHistoryEntry(
        CleaningHistory(
          timestamp: DateTime.now(),
          operation: 'Temp Files Cleanup',
          filesDeleted: result['deletedFiles'],
          bytesDeleted: result['deletedBytes'],
        ),
      );
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Deletion Complete'),
            content: Text(
              'Deleted: ${result['deletedFiles']} items\n'
              'Failed: ${result['failedFiles']} items\n'
              'Space freed: ${result['formattedSize']}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _scanTempFiles();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting files: $e')),
        );
      }
    } finally {
      setState(() {
        isDeleting = false;
      });
    }
  }

  Future<void> _addCustomFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      final folder = CustomFolder(
        path: selectedDirectory,
        name: selectedDirectory.split('\\').last,
        isEnabled: true,
      );
      
      await CleaningHistoryManager.addCustomFolder(folder);
      await _loadCustomFolders();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custom folder added')),
        );
      }
    }
  }

  Future<void> _toggleCustomFolder(CustomFolder folder) async {
    final updatedFolder = CustomFolder(
      path: folder.path,
      name: folder.name,
      isEnabled: !folder.isEnabled,
    );
    
    await CleaningHistoryManager.addCustomFolder(updatedFolder);
    await _loadCustomFolders();
  }

  Future<void> _removeCustomFolder(CustomFolder folder) async {
    await CleaningHistoryManager.removeCustomFolder(folder.path);
    await _loadCustomFolders();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Custom folder removed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalSize = TempCleanerService.calculateTotalSize(tempFiles);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temporary Files',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan and delete temporary files and folders from your system',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // Temp Files Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Results',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatisticCard(
                        icon: Icons.folder_outlined,
                        label: 'Items Found',
                        value: tempFiles.length.toString(),
                      ),
                      _StatisticCard(
                        icon: Icons.storage,
                        label: 'Total Size',
                        value: TempCleanerService.formatBytes(totalSize),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: isScanning ? null : _scanTempFiles,
                        icon: isScanning
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.search, size: 18),
                        label: Text(isScanning ? 'Scanning...' : 'Scan Temp Files'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(_showFilters ? Icons.filter_alt_off : Icons.filter_alt),
                        label: const Text('Filters'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: _addCustomFolder,
                        icon: const Icon(Icons.create_new_folder),
                        label: const Text('Add Folder'),
                      ),
                      const Spacer(),
                      if (tempFiles.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: isDeleting ? null : _deleteAllTempFiles,
                          icon: isDeleting
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Icon(Icons.delete, size: 18),
                          label: Text(isDeleting ? 'Deleting...' : 'Delete All'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Filters Card
          if (_showFilters) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filters',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Age Filter
                    Row(
                      children: [
                        Text('Delete files older than: $_ageFilterDays days'),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Slider(
                            value: _ageFilterDays.toDouble(),
                            min: 0,
                            max: 365,
                            divisions: 73,
                            label: _ageFilterDays == 0 ? 'No filter' : '$_ageFilterDays days',
                            onChanged: (value) {
                              setState(() {
                                _ageFilterDays = value.toInt();
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Extension Filter
                    Text(
                      'File Extensions (leave empty to delete all):',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _commonExtensions.map((ext) {
                        final isSelected = _extensionFilter.contains(ext);
                        return FilterChip(
                          label: Text('.$ext'),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _extensionFilter.add(ext);
                              } else {
                                _extensionFilter.remove(ext);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
          
          // Custom Folders Card
          if (customFolders.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Custom Folders',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...customFolders.map((folder) {
                      return ListTile(
                        leading: const Icon(Icons.folder),
                        title: Text(folder.name),
                        subtitle: Text(folder.path),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Switch(
                              value: folder.isEnabled,
                              onChanged: (value) => _toggleCustomFolder(folder),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeCustomFolder(folder),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          
          // File List
          if (tempFiles.isNotEmpty) ...[
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Items to be deleted (${tempFiles.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 400),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.builder(
                        itemCount: tempFiles.length > 100 ? 100 : tempFiles.length,
                        itemBuilder: (context, index) {
                          final file = tempFiles[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              file.isDirectory ? Icons.folder : Icons.description_outlined,
                              size: 18,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            title: Text(
                              file.path.split('\\').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: Text(
                              TempCleanerService.formatBytes(file.size),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (tempFiles.length > 100)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Showing 100 of ${tempFiles.length} items',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatisticCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
