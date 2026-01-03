import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}

class Windows11Colors {
  // Windows 11 Primary Colors
  static const Color primaryBlue = Color(0xFF0078D4);
  static const Color accentBlue = Color(0xFF005A9E);
  static const Color lightBlue = Color(0xFFE8F4FB);

  // Windows 11 Light Mode Colors
  static const Color lightBackground = Color(0xFFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F3F3);
  static const Color lightBorder = Color(0xFFE0E0E0);

  // Windows 11 Dark Mode Colors
  static const Color darkBackground = Color(0xFF1F1F1F);
  static const Color darkSurfaceVariant = Color(0xFF2D2D2D);
  static const Color darkBorder = Color(0xFF3F3F3F);
}

ThemeData getLightTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Windows11Colors.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: Windows11Colors.lightBlue,
      onPrimaryContainer: Windows11Colors.accentBlue,
      secondary: Windows11Colors.primaryBlue,
      onSecondary: Colors.white,
      tertiary: Windows11Colors.accentBlue,
      onTertiary: Colors.white,
      surface: Colors.white,
      onSurface: Color(0xFF1F1F1F),
      surfaceVariant: Windows11Colors.lightSurfaceVariant,
      onSurfaceVariant: Color(0xFF49454E),
      outline: Windows11Colors.lightBorder,
      outlineVariant: Windows11Colors.lightBorder,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      errorContainer: Color(0xFFF9DEDC),
      onErrorContainer: Color(0xFF8C0A08),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1F1F1F),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFF1F1F1F)),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Windows11Colors.lightBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Windows11Colors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Windows11Colors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Windows11Colors.lightSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.primaryBlue, width: 2),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Windows11Colors.primaryBlue,
      onPrimary: Colors.white,
      primaryContainer: Color(0xFF004687),
      onPrimaryContainer: Color(0xFFD0E4FF),
      secondary: Windows11Colors.primaryBlue,
      onSecondary: Colors.white,
      tertiary: Color(0xFF80CAFF),
      onTertiary: Color(0xFF003355),
      surface: Windows11Colors.darkBackground,
      onSurface: Color(0xFFE4E4E7),
      surfaceVariant: Windows11Colors.darkSurfaceVariant,
      onSurfaceVariant: Color(0xFFC7C7CC),
      outline: Windows11Colors.darkBorder,
      outlineVariant: Windows11Colors.darkBorder,
      error: Color(0xFFF2B8B5),
      onError: Color(0xFF601410),
      errorContainer: Color(0xFF8C0A08),
      onErrorContainer: Color(0xFFF9DEDC),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Windows11Colors.darkBackground,
      foregroundColor: Color(0xFFE4E4E7),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: Color(0xFFE4E4E7)),
    ),
    cardTheme: CardThemeData(
      color: Windows11Colors.darkSurfaceVariant,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Windows11Colors.darkBorder, width: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Windows11Colors.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Windows11Colors.primaryBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Windows11Colors.darkBackground,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Windows11Colors.primaryBlue, width: 2),
      ),
    ),
  );
}
