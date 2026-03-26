import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme => _createTheme(Brightness.light);
  static ThemeData get darkTheme => _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: const Color(0xFF2196F3), // Professional Blue
      onPrimary: Colors.white,
      secondary: isDark ? const Color(0xFF90CAF9) : const Color(0xFF212121),
      onSecondary: isDark ? const Color(0xFF0D47A1) : Colors.white,
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      surface: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      onSurface: isDark ? Colors.white : const Color(0xFF212121),
      surfaceContainerHighest: isDark ? const Color(0xFF333333) : const Color(0xFFF5F5F5),
      onSurfaceVariant: isDark ? Colors.grey.shade400 : const Color(0xFF757575),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 10, 80, 137),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),

      cardTheme: CardThemeData(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        elevation: isDark ? 0 : 2,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark ? BorderSide(color: Colors.grey.shade800, width: 1) : BorderSide.none,
        ),
      ),

      iconTheme: IconThemeData(
        color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
        size: 24,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? Colors.grey.shade800 : Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2196F3), width: 2),
        ),
        labelStyle: GoogleFonts.poppins(color: isDark ? Colors.grey.shade400 : const Color(0xFF757575)),
        hintStyle: GoogleFonts.poppins(color: isDark ? Colors.grey.shade600 : const Color(0xFFBDBDBD)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          elevation: isDark ? 0 : 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      textTheme: TextTheme(
        headlineMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
        ),
        titleMedium: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF212121),
        ),
        bodyMedium: GoogleFonts.roboto(
          color: isDark ? Colors.grey.shade300 : const Color(0xFF212121),
          fontSize: 15,
        ),
        bodySmall: GoogleFonts.roboto(
          color: isDark ? Colors.grey.shade400 : const Color(0xFF757575),
          fontSize: 13,
        ),
      ),
    );
  }
}
