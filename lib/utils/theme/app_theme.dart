import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0B4A8B),
      onPrimary: Colors.white,
      secondary: Color(0xFFD32F2F),
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
    ),

    textTheme: TextTheme(
      titleLarge: GoogleFonts.urbanist(
        fontSize: 22,
        fontWeight: FontWeight.w700,
      ),

      titleMedium: GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),

      titleSmall: GoogleFonts.urbanist(
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),

      bodyMedium: GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),

      bodySmall: GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w400,
          color: Color(0xff5D5D5D)
      ),
    ),
    scaffoldBackgroundColor: Color(0xFFF2F4F7),

  );
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF0B4A8B),
      onPrimary: Colors.white,

      secondary: Color(0xFFD32F2F),
      onSecondary: Colors.white,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,

      error: Colors.red,
      onError: Colors.black,
    ),

      textTheme: TextTheme(
        titleLarge: GoogleFonts.urbanist(
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),

        titleMedium: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),

        titleSmall: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: GoogleFonts.urbanist(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),

        bodyMedium: GoogleFonts.urbanist(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        bodySmall: GoogleFonts.urbanist(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),),
  );
}
