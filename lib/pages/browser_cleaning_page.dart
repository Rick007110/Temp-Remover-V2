import 'package:flutter/material.dart';
import '../services/browser_cache_service.dart';
import '../services/cleaning_history_manager.dart';
import '../models/app_models.dart';
import '../theme/windows11_theme.dart';

class BrowserCleaningPage extends StatefulWidget {
  const BrowserCleaningPage({super.key});

  @override
  State<BrowserCleaningPage> createState() => _BrowserCleaningPageState();
}

class _BrowserCleaningPageState extends State<BrowserCleaningPage> {
  
  Map<String, int>? _cacheInfo;
  Map<String, int>? _historyInfo;
  Map<String, int>? _cookiesInfo;
  
  final Map<String, bool> _selectedBrowsers = {
    'Chrome': true,
    'Edge': true,
    'Firefox': true,
    'Brave': true,
  };
  
  bool _isScanning = false;
  bool _isCleaning = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _scanBrowserData();
  }

  Future<void> _scanBrowserData() async {
    setState(() {
      _isScanning = true;
      _statusMessage = 'Scanning browser data...';
    });

    try {
      final selectedBrowsers = _selectedBrowsers.entries
          .where((e) => e.value)
          .map((e) => e.key)
          .toList();

      final caches = await BrowserCacheService.scanBrowserCaches(selectedBrowsers);
      final history = await BrowserCacheService.scanBrowserHistory(selectedBrowsers);
      final cookies = await BrowserCacheService.scanBrowserCookies(selectedBrowsers);

      setState(() {
        _cacheInfo = caches;
        _historyInfo = history;
        _cookiesInfo = cookies;
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

  Future<void> _clearCaches() async {
    final selectedBrowsers = _selectedBrowsers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedBrowsers.isEmpty) {
      _showSnackBar('Please select at least one browser');
      return;
    }

    setState(() {
      _isCleaning = true;
      _statusMessage = 'Clearing browser caches...';
    });

    try {
      final result = await BrowserCacheService.clearBrowserCaches(selectedBrowsers);
      final totalBytes = result.values.fold<int>(0, (sum, bytes) => sum + bytes);
      // Add to history
      await CleaningHistoryManager.addHistoryEntry(
        CleaningHistory(
          timestamp: DateTime.now(),
          operation: 'Browser Cache Cleanup',
          filesDeleted: 0, // File count not tracked for browser cleanup
          bytesDeleted: totalBytes,
        ),
      );
      
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar('Cleared ${_formatBytes(totalBytes)} of cache data');
      await _scanBrowserData();
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error clearing caches: $e');
    }
  }

  Future<void> _clearHistory() async {
    final selectedBrowsers = _selectedBrowsers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedBrowsers.isEmpty) {
      _showSnackBar('Please select at least one browser');
      return;
    }

    setState(() {
      _isCleaning = true;
      _statusMessage = 'Clearing browser history...';
    });

    try {
      final result = await BrowserCacheService.clearBrowserHistory(selectedBrowsers);
      final totalBytes = result.values.fold<int>(0, (sum, bytes) => sum + bytes);
      
      // Add to history
      await CleaningHistoryManager.addHistoryEntry(
        CleaningHistory(
          timestamp: DateTime.now(),
          operation: 'Browser History Cleanup',
          filesDeleted: 0,
          bytesDeleted: totalBytes,
        ),
      );
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar('Cleared ${_formatBytes(totalBytes)} of history');
      await _scanBrowserData();
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error clearing history: $e');
    }
  }

  Future<void> _clearCookies() async {
    final selectedBrowsers = _selectedBrowsers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (selectedBrowsers.isEmpty) {
      _showSnackBar('Please select at least one browser');
      return;
    }

    setState(() {
      _isCleaning = true;
      _statusMessage = 'Clearing browser cookies...';
    });

    try {
      final result = await BrowserCacheService.clearBrowserCookies(selectedBrowsers);
      final totalBytes = result.values.fold<int>(0, (sum, bytes) => sum + bytes);
      
      // Add to history
      await CleaningHistoryManager.addHistoryEntry(
        CleaningHistory(
          timestamp: DateTime.now(),
          operation: 'Browser Cookies Cleanup',
          filesDeleted: 0,
          bytesDeleted: totalBytes,
        ),
      );
      
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });

      _showSnackBar('Cleared ${_formatBytes(totalBytes)} of cookies');
      await _scanBrowserData();
    } catch (e) {
      setState(() {
        _isCleaning = false;
        _statusMessage = null;
      });
      _showSnackBar('Error clearing cookies: $e');
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

  int _getTotalBytes(Map<String, int>? data) {
    if (data == null) return 0;
    return data.values.fold(0, (sum, bytes) => sum + bytes);
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
              'Browser Cleaning',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Clean browser caches, history, and cookies to free up space and protect privacy',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            
            // Browser Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Browsers',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: _selectedBrowsers.keys.map((browser) {
                        return FilterChip(
                          label: Text(browser),
                          selected: _selectedBrowsers[browser]!,
                          onSelected: (selected) {
                            setState(() {
                              _selectedBrowsers[browser] = selected;
                            });
                            _scanBrowserData();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Statistics Cards
            Expanded(
              child: _isScanning
                  ? const Center(child: CircularProgressIndicator())
                  : GridView.count(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.5,
                      children: [
                        _buildDataCard(
                          'Cache Files',
                          _getTotalBytes(_cacheInfo),
                          Icons.cached,
                          Colors.blue,
                          _clearCaches,
                        ),
                        _buildDataCard(
                          'History Items',
                          _getTotalBytes(_historyInfo),
                          Icons.history,
                          Colors.orange,
                          _clearHistory,
                        ),
                        _buildDataCard(
                          'Cookies',
                          _getTotalBytes(_cookiesInfo),
                          Icons.cookie,
                          Colors.green,
                          _clearCookies,
                        ),
                      ],
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

  Widget _buildDataCard(
    String title,
    int bytes,
    IconData icon,
    Color color,
    VoidCallback onClear,
  ) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 32),
                const Spacer(),
                Text(
                  _formatBytes(bytes),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              title,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCleaning ? null : onClear,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Clear'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
