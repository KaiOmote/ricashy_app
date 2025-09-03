
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4C6EF5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF9B5DE5),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFB00020),
    onError: Color(0xFFFFFFFF),
    surface: Color(0xFFF9F9FB),
    onSurface: Color(0xFF2E2E2E),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF4C6EF5),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF9B5DE5),
    onSecondary: Color(0xFFFFFFFF),
    error: Color(0xFFCF6679),
    onError: Color(0xFF000000),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFFFFFFF),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.light().textTheme,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _darkColorScheme,
      textTheme: GoogleFonts.nunitoTextTheme(
        ThemeData.dark().textTheme,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }
}
