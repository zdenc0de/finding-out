// lib/core/theme/app_theme.dart
// Tema principal de la aplicación Finding Out
// Estilo: Santorini - Minimalista, elegante, mediterráneo

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema centralizado de la aplicación
///
/// Estilo visual inspirado en Santorini:
/// - Tipografía: Georgia para títulos grandes, sistema para cuerpo
/// - Colores: Azul vibrante sobre blanco limpio
/// - Espaciado: Generoso, minimalista
/// - Bordes: Suaves, redondeados
///
/// Uso en main.dart:
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.light,
/// )
/// ```
abstract class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // TEMA CLARO (Light Theme) - Estilo Santorini
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      // ─────────────────────────────────────────────────────────────────────
      // COLOR SCHEME - Santorini Blue
      // ─────────────────────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        // Colores primarios - Azul vibrante
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,

        // Colores secundarios - Gris elegante
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,

        // Colores terciarios - Coral
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,

        // Colores de superficie - Blancos limpios
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        surfaceContainerHighest: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.onSurfaceVariant,

        // Error
        error: AppColors.error,
        onError: AppColors.onError,

        // Otros
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        shadow: AppColors.shadow,
        scrim: AppColors.scrim,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // TIPOGRAFÍA - Georgia para títulos, sistema para cuerpo
      // ─────────────────────────────────────────────────────────────────────
      textTheme: const TextTheme(
        // Display - Georgia, grande y elegante
        displayLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -1.5,
          color: AppColors.onSurface,
        ),
        displayMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 45,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        displaySmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 36,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),

        // Headline - Georgia para impacto
        headlineLarge: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 32,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
          color: AppColors.onSurface,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 28,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),
        headlineSmall: TextStyle(
          fontFamily: 'Georgia',
          fontSize: 24,
          fontWeight: FontWeight.w400,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),

        // Title - Sistema, clean
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.onSurface,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: AppColors.onSurface,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),

        // Body - Sistema, legible
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          height: 1.5,
          color: AppColors.onSurface,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          height: 1.5,
          color: AppColors.onSurface,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          height: 1.4,
          color: AppColors.onSurfaceVariant,
        ),

        // Label
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.onSurface,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // SCAFFOLD - Fondo blanco limpio
      // ─────────────────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ─────────────────────────────────────────────────────────────────────
      // APP BAR - Transparente con texto oscuro para look moderno
      // ─────────────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.onSurface,
        iconTheme: IconThemeData(color: AppColors.onSurface),
        titleTextStyle: TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.5,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // ELEVATED BUTTON - Azul vibrante, bordes suaves
      // ─────────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // FILLED BUTTON
      // ─────────────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // OUTLINED BUTTON - Borde azul, fondo transparente
      // ─────────────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // TEXT BUTTON - Azul, sin fondo
      // ─────────────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // ICON BUTTON
      // ─────────────────────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.onSurface,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON - Azul primario
      // ─────────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // INPUT DECORATION - Minimalista, bordes sutiles
      // ─────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),

        // Bordes suaves
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderError, width: 2),
        ),

        // Colores de texto
        labelStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        hintStyle: const TextStyle(color: AppColors.onSurfaceVariant),
        errorStyle: const TextStyle(color: AppColors.error),

        // Iconos
        prefixIconColor: AppColors.onSurfaceVariant,
        suffixIconColor: AppColors.onSurfaceVariant,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // CARD - Sombra sutil, bordes redondeados
      // ─────────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.outline, width: 1),
        ),
        margin: const EdgeInsets.all(8),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // DIALOG
      // ─────────────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: const TextStyle(
          fontFamily: 'Georgia',
          color: AppColors.onSurface,
          fontSize: 24,
          fontWeight: FontWeight.w400,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 16,
          height: 1.5,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // SNACK BAR
      // ─────────────────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.onSurface,
        contentTextStyle: const TextStyle(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // DIVIDER
      // ─────────────────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.outline,
        thickness: 1,
        space: 1,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // PROGRESS INDICATOR
      // ─────────────────────────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.primaryContainer,
        circularTrackColor: AppColors.primaryContainer,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // CHIP
      // ─────────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryContainer,
        labelStyle: const TextStyle(color: AppColors.onSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // BOTTOM NAVIGATION BAR
      // ─────────────────────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // NAVIGATION BAR (Material 3)
      // ─────────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryContainer,
        elevation: 0,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return const IconThemeData(color: AppColors.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            );
          }
          return const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          );
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // BOTTOM SHEET
      // ─────────────────────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
    );
  }
}
