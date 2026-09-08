import 'package:flutter/material.dart';

abstract final class CavaColors {
  static const cocoa = Color(0xFF2E1A13);
  static const brown = Color(0xFF553527);
  static const gold = Color(0xFFC5A25D);
  static const cream = Color(0xFFF6EEDD);
  static const paper = Color(0xFFFFFBF5);
  static const muted = Color(0xFF75665D);
  static const line = Color(0xFFE3D5C4);

  // Paleta del nuevo diseño (sitio web CAVA)
  static const ink = Color(0xFF241B14); // texto principal casi negro
  static const forest = Color(0xFF1F3D2E); // verde bosque (botones/acentos)
  static const wine = Color(0xFF6E1423); // vino/maroon (botones/acentos)
  static const blush =
      Color(0xFFF3E2DD); // franja rosada clara (sección anchetas)
  static const divider = Color(0xFFD9C7A8);
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
      displaySmall: TextStyle(
          fontFamily: 'serif',
          fontSize: 34,
          height: 1.15,
          color: Colors.white,
          fontWeight: FontWeight.w500),
      headlineMedium:
          TextStyle(fontFamily: 'serif', fontSize: 28, color: CavaColors.ink),
      titleLarge:
          TextStyle(fontFamily: 'serif', fontSize: 22, color: CavaColors.ink),
      titleMedium:
          TextStyle(fontWeight: FontWeight.w600, color: CavaColors.ink),
      bodyMedium: TextStyle(height: 1.5, color: CavaColors.muted),
      labelLarge: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3),
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: CavaColors.cream,
      foregroundColor: CavaColors.ink,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
          fontFamily: 'serif',
          fontSize: 21,
          letterSpacing: 3,
          color: CavaColors.ink),
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
        textStyle:
            const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.3),
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
        style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2),
      );
}

/// Título tipo "Hechos para disfrutar *despacio*" con la última palabra en
/// cursiva y color de acento, como en el sitio web.
class CavaTituloAcento extends StatelessWidget {
  const CavaTituloAcento(this.texto, this.acento,
      {super.key,
      this.color = CavaColors.ink,
      this.acentoColor = CavaColors.wine,
      this.textAlign = TextAlign.start});
  final String texto;
  final String acento;
  final Color color;
  final Color acentoColor;
  final TextAlign textAlign;
  @override
  Widget build(BuildContext context) => RichText(
        textAlign: textAlign,
        text: TextSpan(
          style: TextStyle(
              fontFamily: 'serif', fontSize: 24, color: color, height: 1.25),
          children: [
            TextSpan(text: '$texto '),
            TextSpan(
                text: acento,
                style:
                    TextStyle(fontStyle: FontStyle.italic, color: acentoColor)),
          ],
        ),
      );
}

/// Pequeña línea dorada centrada, usada como separador decorativo.
class CavaLineaDorada extends StatelessWidget {
  const CavaLineaDorada({super.key, this.width = 46});
  final double width;
  @override
  Widget build(BuildContext context) =>
      Container(height: 2, width: width, color: CavaColors.gold);
}
