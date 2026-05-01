import 'package:flutter/material.dart';

/// Define los dos temas de la aplicación:
/// - [themeEstandar]: tema verde claro por defecto.
/// - [themeBajaVision]: alto contraste negro/amarillo, fuentes 1.5×, WCAG AA.
class AppThemes {
  AppThemes._();

  // ─────────────────────────────────────────────────────────────
  // Tema estándar (el original de la app)
  // ─────────────────────────────────────────────────────────────
  static ThemeData get themeEstandar {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF4CAF50),
        brightness: Brightness.light,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Tema baja visión
  // Alto contraste: fondo negro, texto blanco, acentos #FFD700
  // Fuente base ×1.5 | Botones ≥56 dp | Bordes 2–3 px | WCAG AA
  // ─────────────────────────────────────────────────────────────
  static ThemeData get themeBajaVision {
    const Color primario   = Color(0xFFFFD700); // amarillo — ratio >11:1 sobre negro
    const Color fondo      = Colors.black;
    const Color superficie = Color(0xFF1A1A1A);
    const Color texto      = Colors.white;
    const Color textoSec   = Color(0xFFCCCCCC);
    const Color borde      = Color(0xFF666666);

    const colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: primario,
      onPrimary: Colors.black,
      primaryContainer: Color(0xFF4A3F00),
      onPrimaryContainer: primario,
      secondary: primario,
      onSecondary: Colors.black,
      secondaryContainer: Color(0xFF4A3F00),
      onSecondaryContainer: primario,
      tertiary: primario,
      onTertiary: Colors.black,
      tertiaryContainer: Color(0xFF4A3F00),
      onTertiaryContainer: primario,
      error: Color(0xFFFF6B6B),
      onError: Colors.black,
      errorContainer: Color(0xFF4A0000),
      onErrorContainer: Color(0xFFFF6B6B),
      surface: superficie,
      onSurface: texto,
      surfaceContainerHighest: Color(0xFF2A2A2A),
      onSurfaceVariant: textoSec,
      outline: primario,
      outlineVariant: borde,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: texto,
      onInverseSurface: Colors.black,
      inversePrimary: Color(0xFF856700),
    );

    // Escala ×1.5 sobre los tamaños estándar de Material 3
    const textTheme = TextTheme(
      displayLarge:   TextStyle(fontSize: 57,   fontWeight: FontWeight.w400, color: texto),
      displayMedium:  TextStyle(fontSize: 45,   fontWeight: FontWeight.w400, color: texto),
      displaySmall:   TextStyle(fontSize: 36,   fontWeight: FontWeight.w400, color: texto),
      headlineLarge:  TextStyle(fontSize: 48,   fontWeight: FontWeight.w600, color: texto),
      headlineMedium: TextStyle(fontSize: 42,   fontWeight: FontWeight.w600, color: texto),
      headlineSmall:  TextStyle(fontSize: 36,   fontWeight: FontWeight.w600, color: texto),
      titleLarge:     TextStyle(fontSize: 33,   fontWeight: FontWeight.w700, color: texto),
      titleMedium:    TextStyle(fontSize: 24,   fontWeight: FontWeight.w600, color: texto),
      titleSmall:     TextStyle(fontSize: 21,   fontWeight: FontWeight.w600, color: texto),
      bodyLarge:      TextStyle(fontSize: 24,   fontWeight: FontWeight.w400, color: texto),
      bodyMedium:     TextStyle(fontSize: 21,   fontWeight: FontWeight.w400, color: texto),
      bodySmall:      TextStyle(fontSize: 18,   fontWeight: FontWeight.w400, color: textoSec),
      labelLarge:     TextStyle(fontSize: 21,   fontWeight: FontWeight.w600, color: texto),
      labelMedium:    TextStyle(fontSize: 18,   fontWeight: FontWeight.w500, color: texto),
      labelSmall:     TextStyle(fontSize: 16,   fontWeight: FontWeight.w500, color: texto),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: fondo,
      textTheme: textTheme,

      // Iconos escalados ×1.4 (24 × 1.4 ≈ 34)
      iconTheme: const IconThemeData(size: 34, color: texto),
      primaryIconTheme: const IconThemeData(size: 34, color: primario),

      // AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: fondo,
        foregroundColor: texto,
        elevation: 0,
        iconTheme: IconThemeData(size: 34, color: texto),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
      ),

      // ElevatedButton — mínimo 56 dp, texto 1.5×
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primario,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 56),
          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: primario, width: 2),
          ),
        ),
      ),

      // OutlinedButton
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primario,
          minimumSize: const Size(double.infinity, 56),
          side: const BorderSide(color: primario, width: 2),
          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // TextButton
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primario,
          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w600),
          minimumSize: const Size(0, 48),
        ),
      ),

      // Card — borde visible y grueso
      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primario, width: 2),
        ),
      ),

      // Inputs — bordes 2–3 px
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        labelStyle: const TextStyle(fontSize: 21, color: primario),
        hintStyle: const TextStyle(fontSize: 21, color: Color(0xFF888888)),
        errorStyle: const TextStyle(fontSize: 18, color: Color(0xFFFF6B6B)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primario, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borde, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primario, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      ),

      // Switch — thumb negro sobre track amarillo
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? Colors.black : Colors.white;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected) ? primario : const Color(0xFF444444);
        }),
      ),

      // ListTile
      listTileTheme: const ListTileThemeData(
        iconColor: primario,
        textColor: texto,
      ),

      // Divider
      dividerTheme: const DividerThemeData(
        color: Color(0xFF444444),
        thickness: 1,
      ),

      // FilterChip / Chip
      chipTheme: ChipThemeData(
        backgroundColor: superficie,
        selectedColor: const Color(0x33FFD700),
        labelStyle: const TextStyle(fontSize: 18, color: texto),
        side: const BorderSide(color: borde, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        checkmarkColor: primario,
      ),

      // SnackBar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: superficie,
        contentTextStyle: const TextStyle(fontSize: 18, color: texto),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: primario, width: 1.5),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // AlertDialog
      dialogTheme: DialogThemeData(
        backgroundColor: superficie,
        titleTextStyle: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: texto,
        ),
        contentTextStyle: const TextStyle(fontSize: 21, color: texto),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: primario, width: 2),
        ),
      ),
    );
  }
}
