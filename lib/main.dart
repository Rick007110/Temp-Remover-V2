import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/windows11_theme.dart';
import 'widgets/app_navigation_rail.dart';
import 'pages/temp_files_page.dart';
import 'pages/recycle_bin_page.dart';
import 'pages/browser_cleaning_page.dart';
import 'pages/system_cleanup_page.dart';
import 'pages/advanced_tools_page.dart';
import 'pages/storage_analytics_page.dart';
import 'pages/history_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Temp Remover V2',
          themeMode: themeProvider.themeMode,
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          home: const MyHomePage(title: 'Temp Remover V2'),
        );
      },
    );
  }
}


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  NavigationItem _currentPage = NavigationItem.tempFiles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AppNavigationRail(
            currentPage: _currentPage,
            onNavigate: (page) {
              setState(() => _currentPage = page);
            },
          ),
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage() {
    switch (_currentPage) {
      case NavigationItem.tempFiles:
        return const TempFilesPage();
      case NavigationItem.recycleBin:
        return const RecycleBinPage();
      case NavigationItem.browserCleaning:
        return const BrowserCleaningPage();
      case NavigationItem.systemCleanup:
        return const SystemCleanupPage();
      case NavigationItem.advancedTools:
        return const AdvancedToolsPage();
      case NavigationItem.storage:
        return const StorageAnalyticsPage();
      case NavigationItem.history:
        return const HistoryPage();
      case NavigationItem.settings:
        return const SettingsPage();
    }
  }
}
