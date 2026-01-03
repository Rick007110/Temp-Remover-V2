import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/storage_analytics_service.dart';
import '../models/app_models.dart';
import '../theme/windows11_theme.dart';

class StorageAnalyticsPage extends StatefulWidget {
  const StorageAnalyticsPage({super.key});

  @override
  State<StorageAnalyticsPage> createState() => _StorageAnalyticsPageState();
}

class _StorageAnalyticsPageState extends State<StorageAnalyticsPage> {
  
  List<StorageInfo>? _drives;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDriveInfo();
  }

  Future<void> _loadDriveInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final drives = await StorageAnalyticsService.getDiskInfo();
      
      setState(() {
        _drives = drives;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  double _getUsagePercentage(StorageInfo drive) {
    if (drive.totalSpace == 0) return 0;
    return ((drive.totalSpace - drive.freeSpace) / drive.totalSpace) * 100;
  }

  Color _getUsageColor(double percentage) {
    if (percentage < 60) return Colors.green;
    if (percentage < 80) return Colors.orange;
    return Colors.red;
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Storage Analytics',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'View disk space usage across all drives',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _loadDriveInfo,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _drives == null || _drives!.isEmpty
                      ? const Center(child: Text('No drives found'))
                      : ListView.builder(
                          itemCount: _drives!.length,
                          itemBuilder: (context, index) {
                            final drive = _drives![index];
                            final usagePercentage = _getUsagePercentage(drive);
                            final usageColor = _getUsageColor(usagePercentage);
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Row(
                                  children: [
                                    // Pie Chart
                                    SizedBox(
                                      width: 150,
                                      height: 150,
                                      child: PieChart(
                                        PieChartData(
                                          sectionsSpace: 2,
                                          centerSpaceRadius: 40,
                                          sections: [
                                            PieChartSectionData(
                                              value: (drive.totalSpace - drive.freeSpace).toDouble(),
                                              color: usageColor,
                                              title: '${usagePercentage.toStringAsFixed(1)}%',
                                              titleStyle: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              radius: 50,
                                            ),
                                            PieChartSectionData(
                                              value: drive.freeSpace.toDouble(),
                                              color: Colors.grey.withOpacity(0.3),
                                              title: '',
                                              radius: 50,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 32),
                                    
                                    // Drive Info
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.storage,
                                                size: 32,
                                                color: usageColor,
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Drive ${drive.driveLetter}',
                                                style: theme.textTheme.headlineSmall?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          _buildInfoRow('Type', drive.driveType, theme),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            'Total Space',
                                            _formatBytes(drive.totalSpace),
                                            theme,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            'Used Space',
                                            _formatBytes(drive.totalSpace - drive.freeSpace),
                                            theme,
                                          ),
                                          const SizedBox(height: 8),
                                          _buildInfoRow(
                                            'Free Space',
                                            _formatBytes(drive.freeSpace),
                                            theme,
                                          ),
                                          const SizedBox(height: 16),
                                          
                                          // Progress Bar
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Usage',
                                                style: theme.textTheme.bodySmall,
                                              ),
                                              const SizedBox(height: 4),
                                              LinearProgressIndicator(
                                                value: usagePercentage / 100,
                                                backgroundColor: Colors.grey.withOpacity(0.3),
                                                valueColor: AlwaysStoppedAnimation<Color>(usageColor),
                                                minHeight: 8,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
