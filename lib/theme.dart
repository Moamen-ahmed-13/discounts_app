import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color.fromARGB(226, 255, 255, 255);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color cardBorder = Color(0xFF2A2A2A);

  static const Color primary = Color.fromARGB(255, 255, 53, 53);
  static const Color primaryLight = Color(0xFFFFC107);
  static const Color secondary = Colors.yellow;
  static const Color accent = Color(0xFF00C853);

  static const Color textPrimary = Colors.black;
  static const Color textSecondaryinBlack = Color(0xFF9E9E9E);
  static const Color textSecondaryinWhite = Color.fromARGB(197, 84, 83, 83);
  static const Color divider = Color(0xFF2A2A2A);

  static const Map<String, Color> badgeColors = {
    'حصري': Color(0xFFFFD700),
    'مميز': Color(0xFFFF6B35),
    'جديد': Color(0xFF00C853),
    'عرض خاص': Color(0xFFEF4444),
  };

  static const Map<String, Color> badgeTextColors = {
    'حصري': Color(0xFF000000),
    'مميز': Color(0xFFFFFFFF),
    'جديد': Color(0xFFFFFFFF),
    'عرض خاص': Color(0xFFFFFFFF),
  };

  static ThemeData get theme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Cairo',
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          background: background,
          surface: surface,
        ),
        scaffoldBackgroundColor: background,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF111111),
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: cardBg,
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: cardBorder, width: 1),
          ),
        ),
        useMaterial3: true,
      );
}
