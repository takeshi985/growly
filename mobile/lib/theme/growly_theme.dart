import 'package:flutter/material.dart';

abstract final class GrowlyTheme {
  static const cream = Color(0xFFFFFCF5);
  static const green = Color(0xFF57A936);
  static const darkGreen = Color(0xFF2F7135);
  static const softGreen = Color(0xFFE6F6D9);
  static const softYellow = Color(0xFFFFF0C8);
  static const softPurple = Color(0xFFF0E5FF);

  static ThemeData build() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: green,
      brightness: Brightness.light,
      primary: green,
      surface: cream,
    ),
    scaffoldBackgroundColor: cream,
    cardTheme: CardThemeData(
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: Colors.black.withValues(alpha: .08),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(24)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
  );
}
