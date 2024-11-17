import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ).copyWith(
      surface: const Color(0xFF1E1E1E),
      surfaceContainerHighest: const Color(0xFF3C3C3C),
      onSurface: Colors.white,
      surfaceContainer: const Color(0xFF2C2C2C),
      onSurfaceVariant: Colors.white.withOpacity(0.9),
    ),
    cardTheme: const CardTheme(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: Colors.white),
      titleSmall: TextStyle(color: Colors.white70),
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white70),
      bodySmall: TextStyle(color: Colors.white60),
    ),
  );
} 