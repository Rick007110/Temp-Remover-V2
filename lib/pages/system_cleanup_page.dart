import 'package:flutter/material.dart';
import '../services/windows_cleanup_service.dart';
import '../services/cleaning_history_manager.dart';
import '../models/app_models.dart';
import '../theme/windows11_theme.dart';

class SystemCleanupPage extends StatefulWidget {
  const SystemCleanupPage({super.key});

  @override
  State<SystemCleanupPage> createState() => _SystemCleanupPageState();
}

class _SystemCleanupPageState extends State<SystemCleanupPage> {
  Map<String, int> _scanResults = {};
  bool _isScanning = false;
  bool _isCleaning = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _scanAllAreas();
  }

  Future<void> _scanAllAreas() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning system areas...';
    });

    try {
      final results = <String, int>{};
      
      results['Windows Update Cache'] = await WindowsCleanupService.scanWindowsUpdateCache();
      results['Prefetch Files'] = await WindowsCleanupService.scanPrefetch();
      results['Thumbnail Cache'] = await WindowsCleanupService.scanThumbnailCache();
      results['Recent Files'] = await WindowsCleanupService.scanRecentFiles();

      setState(() {
        _scanResults = results;
        _isScanning = false;
        _statusMessage = null;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _statusMessage = 'Error scanning: $e';
      });
    }
  }

  Future<void> _clearArea(String area) async {
    setState(() {
      _isCleaning = true;
      _statusMessage = 'Clearing $area...';
    });

    try {
      int clearedBytes = 0;
      
      switch (area) {
        case 'Windows Update Cache':
          clearedBytes = await WindowsCleanupService.clearWindowsUpdateCache();
          break;
        case 'Prefetch Files':
          clearedBytes = await WindowsCleanupService.clearPrefetch();
          break;
        case 'Thumbnail Cache':
          clearedBytes = await WindowsCleanupService.clearThumbnailCache();
          break;
        case 'Recent Files':
          clearedBytes = await WindowsCleanupService.clearRecentFiles();
          break;
      }

      // Add to history
      await CleaningHistoryManager.addHistoryEntry(
        CleaningHistory(
          timestamp: DateTime.now(),
          operation: 'System Cleanup - $area',
          filesDeleted: 0, // File count not tracked
          bytesDeleted: clearedBytes,
        ),
      );

      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar('Cleared ${_formatBytes(clearedBytes)} from $area');
      await _scanAllAreas();
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error clearing $area: $e');
    }
  }

  Future<void> _flushDns() async {
    setState(() {
      _isCleaning = true;
      _statusMessage = 'Flushing DNS cache...';
    });

    try {
      final success = await WindowsCleanupService.flushDnsCache();
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar(success 
          ? 'DNS cache flushed successfully' 
          : 'Failed to flush DNS cache');
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error flushing DNS: $e');
    }
  }

  Future<void> _clearEventLogs() async {
    setState(() {
      _isCleaning = true;
      _statusMessage = 'Clearing event logs...';
    });

    try {
      final success = await WindowsCleanupService.clearEventLogs();
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar(success 
          ? 'Event logs cleared successfully' 
          : 'Failed to clear event logs (admin required)');
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error clearing logs: $e');
    }
  }

  Future<void> _createRestorePoint() async {
    setState(() {
      _isCleaning = true;
      _statusMessage = 'Creating system restore point...';
    });

    try {
      final success = await WindowsCleanupService.createRestorePoint('Temp Remover Cleanup');
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar(success 
          ? 'Restore point created successfully' 
          : 'Failed to create restore point');
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error creating restore point: $e');
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
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'System Cleanup',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clean Windows system files and caches to optimize performance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // System Tools
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'System Tools',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isCleaning ? null : _flushDns,
                          icon: const Icon(Icons.dns),
                          label: const Text('Flush DNS'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isCleaning ? null : _clearEventLogs,
                          icon: const Icon(Icons.event_note),
                          label: const Text('Clear Event Logs'),
                        ),
                        ElevatedButton.icon(
                          onPressed: _isCleaning ? null : _createRestorePoint,
                          icon: const Icon(Icons.restore),
                          label: const Text('Create Restore Point'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Cleanup Areas
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: _scanResults.entries.map((entry) {
                        return _buildCleanupCard(
                          entry.key,
                          entry.value,
                          _getIconForArea(entry.key),
                          _getColorForArea(entry.key),
                        );
                      }).toList(),
                    ),
            ),
            
            if (_statusMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Row(
                  children: [
                    if (_isCleaning) ...[
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
      ),
    );
  }

  Widget _buildCleanupCard(String area, int bytes, IconData icon, Color color) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon, color: color, size: 32),
        title: Text(
          area,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(_formatBytes(bytes)),
        trailing: ElevatedButton(
          onPressed: _isCleaning ? null : () => _clearArea(area),
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
          ),
          child: const Text('Clean'),
        ),
      ),
    );
  }

  IconData _getIconForArea(String area) {
    switch (area) {
      case 'Windows Update Cache':
        return Icons.update;
      case 'Prefetch Files':
        return Icons.speed;
      case 'Thumbnail Cache':
        return Icons.image;
      case 'Recent Files':
        return Icons.history;
      case 'Error Reports':
        return Icons.error_outline;
      default:
        return Icons.folder;
    }
  }

  Color _getColorForArea(String area) {
    switch (area) {
      case 'Windows Update Cache':
        return Colors.blue;
      case 'Prefetch Files':
        return Colors.green;
      case 'Thumbnail Cache':
        return Colors.purple;
      case 'Recent Files':
        return Colors.orange;
      case 'Error Reports':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
