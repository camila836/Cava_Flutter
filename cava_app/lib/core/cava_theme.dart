import 'package:flutter/material.dart';

abstract final class CavaColors {
  static const cocoa = Color(0xFF2E1A13);
  static const brown = Color(0xFF553527);
  static const gold = Color(0xFFC5A25D);
  static const cream = Color(0xFFF7F0E6);
  static const paper = Color(0xFFFFFBF5);
  static const muted = Color(0xFF75665D);
  static const line = Color(0xFFE3D5C4);
}

ThemeData cavaTheme() {
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    borderSide: BorderSide(color: CavaColors.line),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: CavaColors.cocoa,
      primary: CavaColors.cocoa,
      secondary: CavaColors.gold,
      surface: CavaColors.paper,
    ),
    scaffoldBackgroundColor: CavaColors.cream,
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontFamily: 'serif', fontSize: 38, height: 1.1, color: CavaColors.cocoa),
      headlineMedium: TextStyle(fontFamily: 'serif', fontSize: 30, color: CavaColors.cocoa),
      titleLarge: TextStyle(fontFamily: 'serif', fontSize: 24, color: CavaColors.cocoa),
      titleMedium: TextStyle(fontWeight: FontWeight.w600, color: CavaColors.cocoa),
      bodyMedium: TextStyle(height: 1.5, color: CavaColors.muted),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: CavaColors.paper,
      foregroundColor: CavaColors.cocoa,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(fontFamily: 'serif', fontSize: 23, letterSpacing: 3, color: CavaColors.cocoa),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: border,
      enabledBorder: border,
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: CavaColors.gold, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: CavaColors.cocoa,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3),
      ),
    ),
    cardTheme: CardThemeData(
      color: CavaColors.paper,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: CavaColors.line),
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: CavaColors.paper,
      indicatorColor: Color(0xFFEAD9B8),
    ),
  );
}

class CavaEyebrow extends StatelessWidget {
  const CavaEyebrow(this.text, {super.key, this.color = CavaColors.gold});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2),
  );
}
