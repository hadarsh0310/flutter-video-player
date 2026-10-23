import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF101010),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD6A85F),
      brightness: Brightness.dark,
      surface: const Color(0xFF191919),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101010),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}