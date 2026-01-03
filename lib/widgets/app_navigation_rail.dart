import 'package:flutter/material.dart';

enum NavigationItem {
  tempFiles,
  recycleBin,
  browserCleaning,
  systemCleanup,
  advancedTools,
  storage,
  history,
  settings,
}

class AppNavigationRail extends StatelessWidget {
  final NavigationItem currentPage;
  final Function(NavigationItem) onNavigate;

  const AppNavigationRail({
    Key? key,
    required this.currentPage,
    required this.onNavigate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Temp Remover V2',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              children: [
                _NavigationTile(
                  icon: Icons.folder_open,
                  label: 'Temp Files',
                  isSelected: currentPage == NavigationItem.tempFiles,
                  onTap: () => onNavigate(NavigationItem.tempFiles),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.delete_outline,
                  label: 'Recycle Bin',
                  isSelected: currentPage == NavigationItem.recycleBin,
                  onTap: () => onNavigate(NavigationItem.recycleBin),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.web,
                  label: 'Browser Cleaning',
                  isSelected: currentPage == NavigationItem.browserCleaning,
                  onTap: () => onNavigate(NavigationItem.browserCleaning),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.cleaning_services,
                  label: 'System Cleanup',
                  isSelected: currentPage == NavigationItem.systemCleanup,
                  onTap: () => onNavigate(NavigationItem.systemCleanup),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.build,
                  label: 'Advanced Tools',
                  isSelected: currentPage == NavigationItem.advancedTools,
                  onTap: () => onNavigate(NavigationItem.advancedTools),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.pie_chart,
                  label: 'Storage Analytics',
                  isSelected: currentPage == NavigationItem.storage,
                  onTap: () => onNavigate(NavigationItem.storage),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.history,
                  label: 'History',
                  isSelected: currentPage == NavigationItem.history,
                  onTap: () => onNavigate(NavigationItem.history),
                ),
                const SizedBox(height: 8),
                _NavigationTile(
                  icon: Icons.settings,
                  label: 'Settings',
                  isSelected: currentPage == NavigationItem.settings,
                  onTap: () => onNavigate(NavigationItem.settings),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'v1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavigationTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavigationTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_NavigationTile> createState() => _NavigationTileState();
}

class _NavigationTileState extends State<_NavigationTile> {
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() {}),
      onExit: (_) => setState(() {}),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          hoverColor: widget.isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Theme.of(context).colorScheme.primary.withOpacity(0.08),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: widget.isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Colors.transparent,
              border: widget.isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  widget.icon,
                  size: 20,
                  color: widget.isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: widget.isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
