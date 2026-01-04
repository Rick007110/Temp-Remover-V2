import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;
  final bool isUpdateAvailable;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.isUpdateAvailable,
  });
}

class UpdateCheckService {
  static const String _repoOwner = 'Rick007110';
  static const String _repoName = 'Temp-Remover-V2';
  static const String _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  static const String _currentVersion = '1.0.1';

  static Future<UpdateInfo> checkForUpdates() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl)).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Update check timed out'),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final latestVersion = jsonData['tag_name']?.replaceFirst('v', '') ?? _currentVersion;
        final releaseNotes = jsonData['body'] ?? 'No release notes available';
        final downloadUrl = _getWindowsDownloadUrl(jsonData['assets']);

        return UpdateInfo(
          currentVersion: _currentVersion,
          latestVersion: latestVersion,
          downloadUrl: downloadUrl,
          releaseNotes: releaseNotes,
          isUpdateAvailable: _compareVersions(latestVersion, _currentVersion) > 0,
        );
      } else {
        throw Exception('Failed to fetch release information');
      }
    } catch (e) {
      return UpdateInfo(
        currentVersion: _currentVersion,
        latestVersion: _currentVersion,
        downloadUrl: '',
        releaseNotes: 'Error checking for updates: $e',
        isUpdateAvailable: false,
      );
    }
  }

  static String _getWindowsDownloadUrl(List<dynamic>? assets) {
    if (assets == null || assets.isEmpty) {
      return 'https://github.com/$_repoOwner/$_repoName/releases/latest';
    }

    // Look for Windows executable
    for (var asset in assets) {
      final name = asset['name']?.toLowerCase() ?? '';
      if (name.contains('windows') || name.endsWith('.exe') || name.endsWith('.msi')) {
        return asset['browser_download_url'] ?? '';
      }
    }

    // Fallback to releases page
    return 'https://github.com/$_repoOwner/$_repoName/releases/latest';
  }

  /// Compare two version strings
  /// Returns: positive if v1 > v2, negative if v1 < v2, 0 if equal
  static int _compareVersions(String v1, String v2) {
    final parts1 = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    // Pad with zeros
    final maxLength = parts1.length > parts2.length ? parts1.length : parts2.length;
    while (parts1.length < maxLength) parts1.add(0);
    while (parts2.length < maxLength) parts2.add(0);

    for (int i = 0; i < maxLength; i++) {
      if (parts1[i] != parts2[i]) {
        return parts1[i].compareTo(parts2[i]);
      }
    }
    return 0;
  }

  static Future<bool> downloadUpdate(String downloadUrl) async {
    try {
      final response = await http.get(Uri.parse(downloadUrl)).timeout(
        const Duration(minutes: 5),
        onTimeout: () => throw TimeoutException('Download timed out'),
      );

      if (response.statusCode == 200) {
        final downloadsPath = Platform.environment['USERPROFILE'] ?? '';
        final fileName = downloadUrl.split('/').last;
        final filePath = '$downloadsPath\\Downloads\\$fileName';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        // Open the downloaded file
        await Process.run('explorer', [file.parent.path]);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}
