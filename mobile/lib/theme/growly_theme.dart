import 'package:flutter/material.dart';

import 'growly_tokens.dart';

abstract final class GrowlyTheme {
  static const cream = GrowlyColors.canvas;
  static const green = GrowlyColors.brand;
  static const darkGreen = GrowlyColors.brandPressed;
  static const softGreen = GrowlyColors.brandSoft;
  static const softYellow = GrowlyColors.rewardSoft;
  static const softPurple = GrowlyColors.imaginationSoft;

  static ThemeData build() => ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      primary: GrowlyColors.brand,
      onPrimary: Colors.white,
      primaryContainer: GrowlyColors.brandSoft,
      onPrimaryContainer: GrowlyColors.ink,
      secondary: GrowlyColors.accent,
      onSecondary: GrowlyColors.ink,
      secondaryContainer: GrowlyColors.accentSoft,
      onSecondaryContainer: GrowlyColors.ink,
      tertiary: GrowlyColors.imagination,
      tertiaryContainer: GrowlyColors.imaginationSoft,
      error: GrowlyColors.danger,
      surface: GrowlyColors.surface,
      onSurface: GrowlyColors.ink,
      outline: GrowlyColors.outline,
    ),
    scaffoldBackgroundColor: cream,
    fontFamily: null,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
      headlineSmall: TextStyle(fontSize: 23, fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      titleMedium: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 1.45,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.4,
      ),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: GrowlyColors.canvas,
      foregroundColor: GrowlyColors.ink,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: GrowlyColors.ink,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      margin: EdgeInsets.zero,
      shadowColor: GrowlyColors.inkMuted,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(GrowlyRadii.lg)),
        side: BorderSide(color: GrowlyColors.outline),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(48, 56),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrowlyRadii.md),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(48, 54),
        side: const BorderSide(color: GrowlyColors.outline, width: 1.5),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GrowlyRadii.md),
        ),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      height: 74,
      backgroundColor: GrowlyColors.surface,
      indicatorColor: GrowlyColors.brandSoft,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
      iconTheme: WidgetStatePropertyAll(IconThemeData(size: 27)),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: GrowlyColors.brand,
      linearTrackColor: GrowlyColors.outline,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: GrowlyColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GrowlyRadii.md),
        borderSide: const BorderSide(color: GrowlyColors.outline),
      ),
    ),
  );
}
