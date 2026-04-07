import 'package:flutter/material.dart';

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
      // Setting Poppins as the default font family for the application UI.
      // This font is bundled in assets/fonts/ to ensure instant loading.
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color.fromARGB(255, 10, 80, 137),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        // Using explicit TextStyle with bundled fontFamily for immediate rendering.
        titleTextStyle: const TextStyle(
          fontFamily: 'Poppins',
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
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: isDark ? Colors.grey.shade400 : const Color(0xFF757575),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Poppins',
          color: isDark ? Colors.grey.shade600 : const Color(0xFFBDBDBD),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2196F3),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16, 
            fontWeight: FontWeight.w600,
          ),
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
          elevation: isDark ? 0 : 2,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),

      textTheme: TextTheme(
        // headlineMedium used for large banners or major section headers.
        headlineMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.bold,
          color: isDark ? const Color(0xFF64B5F6) : const Color(0xFF2196F3),
        ),
        // titleMedium used for section tile headers (e.g., ExpansionTile titles).
        titleMedium: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : const Color(0xFF212121),
        ),
        // bodyMedium used for most standard text fields and descriptors.
        // Using Roboto for body text for better readability.
        bodyMedium: TextStyle(
          fontFamily: 'Roboto',
          color: isDark ? Colors.grey.shade300 : const Color(0xFF212121),
          fontSize: 15,
        ),
        // bodySmall used for subtitles or less prominent info.
        bodySmall: TextStyle(
          fontFamily: 'Roboto',
          color: isDark ? Colors.grey.shade400 : const Color(0xFF757575),
          fontSize: 13,
        ),
      ),
    );
  }
}
