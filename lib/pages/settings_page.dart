import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/windows11_theme.dart';
import '../services/update_check_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isCheckingForUpdates = false;
  UpdateInfo? _updateInfo;

  Future<void> _checkForUpdates() async {
    setState(() => _isCheckingForUpdates = true);
    try {
      final updateInfo = await UpdateCheckService.checkForUpdates();
      setState(() => _updateInfo = updateInfo);
      
      if (updateInfo.isUpdateAvailable) {
        _showUpdateDialog(updateInfo);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You are using the latest version')),
        );
      }
    } finally {
      setState(() => _isCheckingForUpdates = false);
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Current version: ${updateInfo.currentVersion}'),
              const SizedBox(height: 8),
              Text('Latest version: ${updateInfo.latestVersion}'),
              const SizedBox(height: 16),
              Text(
                'Release Notes:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Text(updateInfo.releaseNotes),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _downloadUpdate(updateInfo.downloadUrl);
            },
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadUpdate(String downloadUrl) async {
    if (downloadUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No download available for Windows')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening GitHub releases page...')),
    );
    await UpdateCheckService.downloadUpdate(downloadUrl);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your application preferences',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          
          // Theme Settings
          Card(
            child: Padding(
             Update Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Updates',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Check for the latest version and download updates from GitHub',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isCheckingForUpdates ? null : _checkForUpdates,
                        icon: _isCheckingForUpdates
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.refresh),
                        label: Text(_isCheckingForUpdates
                            ? 'Checking...'
                            : 'Check for Updates'),
                      ),
                      const SizedBox(width: 16),
                      if (_updateInfo != null && !_updateInfo!.isUpdateAvailable)
                        Text(
                          'Version ${_updateInfo!.currentVersion} is up to date',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      if (_updateInfo != null && _updateInfo!.isUpdateAvailable)
                        Text(
                          'Update available: ${_updateInfo!.latestVersion}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Theme',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ThemeOptionTile(
                    icon: Icons.light_mode,
                    title: 'Light Mode',
                    subtitle: 'Use bright colors for better daytime visibility',
                    value: ThemeMode.light,
                  ),
                  const SizedBox(height: 12),
                  _ThemeOptionTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Use dark colors to reduce eye strain',
                    value: ThemeMode.dark,
                  ),
                  const SizedBox(height: 12),
                  _ThemeOptionTile(
                    icon: Icons.settings_brightness,
                    title: 'System Setting',
                    subtitle: 'Follow your Windows 11 theme preference',
                    value: ThemeMode.system,
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // About Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'This is a revamped version of my Python application "Temp Remover", remade in Flutter to learn about Flutter development.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    label: 'Application',
                    value: 'Temp Remover V2',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Version',
                    value: '1.0.0',
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    label: 'Platform',
                    value: 'Windows 11',
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Features Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _FeatureItem(
                    icon: Icons.folder_open,
                    title: 'Temp Files Cleanup',
                    description: 'Scan and delete temporary files from multiple system directories',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.delete_outline,
                    title: 'Recycle Bin Management',
                    description: 'Permanently empty your recycle bin with one click',
                  ),
                  const SizedBox(height: 12),
                  _FeatureItem(
                    icon: Icons.palette,
                    title: 'Windows 11 Theme',
                    description: 'Modern UI design with light and dark mode support',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final ThemeMode value;

  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isSelected = themeProvider.themeMode == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.read<ThemeProvider>().setThemeMode(value),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.08)
                : Colors.transparent,
            border: isSelected
                ? Border.all(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
