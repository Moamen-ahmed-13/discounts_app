// import 'package:flutter/material.dart';

// class AppTheme {
//   static const Color background = Color.fromARGB(226, 255, 255, 255);
//   static const Color surface = Color(0xFF1A1A1A);
//   static const Color cardBg = Color(0xFF1E1E1E);
//   static const Color cardBorder = Color(0xFF2A2A2A);

//   static const Color primary = Color.fromARGB(255, 255, 157, 0);
//   static const Color primaryLight = Color(0xFFFFC107);
//   static const Color secondary = Colors.yellow;
//   static const Color accent = Color(0xFF00C853);

//   static const Color textPrimary = Colors.black;
//   static const Color textSecondaryinBlack = Color(0xFF9E9E9E);
//   static const Color textSecondaryinWhite = Color.fromARGB(197, 84, 83, 83);
//   static const Color divider = Color(0xFF2A2A2A);

//   static const Map<String, Color> badgeColors = {
//     'حصري': Color(0xFFFFD700),
//     'مميز': Color(0xFFFF6B35),
//     'جديد': Color(0xFF00C853),
//     'عرض خاص': Color(0xFFEF4444),
//   };

//   static const Map<String, Color> badgeTextColors = {
//     'حصري': Color(0xFF000000),
//     'مميز': Color(0xFFFFFFFF),
//     'جديد': Color(0xFFFFFFFF),
//     'عرض خاص': Color(0xFFFFFFFF),
//   };

//   static ThemeData get theme => ThemeData(
//         brightness: Brightness.dark,
//         fontFamily: 'Cairo',
//         colorScheme: ColorScheme.dark(
//           primary: primary,
//           secondary: secondary,
//           background: background,
//           surface: surface,
//         ),
//         scaffoldBackgroundColor: background,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Color(0xFF111111),
//           foregroundColor: textPrimary,
//           elevation: 0,
//           centerTitle: true,
//         ),
//         cardTheme: CardThemeData(
//           color: cardBg,
//           elevation: 4,
//           shadowColor: Colors.black.withOpacity(0.5),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//             side: const BorderSide(color: cardBorder, width: 1),
//           ),
//         ),
//         useMaterial3: true,
//       );
// }
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color cardBg = Color(0xFF1E1E1E);
  static const Color cardBorder = Color(0xFF2A2A2A);

  static const Color primary = Color.fromARGB(255, 255, 157, 0);
  static const Color primaryLight = Color(0xFFFFC107);
  static const Color secondary = Color(0xFFFFD700);
  static const Color accent = Color(0xFF00C853);

  static const Color textPrimary = Colors.black;
  static const Color textSecondaryinBlack = Color(0xFF9E9E9E);
  static const Color textSecondaryinWhite = Color(0xFF545353);
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

  static TextTheme get _tajawalTextTheme => GoogleFonts.tajawalTextTheme().copyWith(
    bodyLarge: GoogleFonts.tajawal(),
    bodyMedium: GoogleFonts.tajawal(),
    bodySmall: GoogleFonts.tajawal(),
    displayLarge: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
    displayMedium: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.tajawal(fontWeight: FontWeight.w600),
    labelLarge: GoogleFonts.tajawal(fontWeight: FontWeight.bold),
  );

  static ThemeData get theme => ThemeData(
    brightness: Brightness.light,
    textTheme: _tajawalTextTheme,
    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      surface: background,
    ),
    scaffoldBackgroundColor: background,
    appBarTheme: AppBarTheme(
      backgroundColor: background,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.tajawal(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: GoogleFonts.tajawal(color: Colors.grey),
    ),
    useMaterial3: true,
  );

  // Helper للحصول على TextStyle بفونت تجوال
  static TextStyle tajawal({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color color = textPrimary,
    double? height,
    double? letterSpacing,
  }) =>
      GoogleFonts.tajawal(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}