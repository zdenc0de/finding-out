// lib/core/theme/app_theme.dart
// Tema principal de la aplicación Finding Out

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Tema centralizado de la aplicación
///
/// Uso en main.dart:
/// ```dart
/// MaterialApp.router(
///   theme: AppTheme.light,
///   // darkTheme: AppTheme.dark, // Para futuro
/// )
/// ```
abstract class AppTheme {
  // ═══════════════════════════════════════════════════════════════════════════
  // TEMA CLARO (Light Theme)
  // ═══════════════════════════════════════════════════════════════════════════
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,

      // ─────────────────────────────────────────────────────────────────────
      // COLOR SCHEME
      // Define todos los colores semánticos que Material 3 usa automáticamente
      // ─────────────────────────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        // Colores primarios
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,

        // Colores secundarios
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.onSecondary,

        // Colores terciarios
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryLight,
        onTertiaryContainer: AppColors.tertiaryDark,

        // Colores de superficie
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
      // SCAFFOLD
      // ─────────────────────────────────────────────────────────────────────
      scaffoldBackgroundColor: AppColors.background,

      // ─────────────────────────────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        iconTheme: IconThemeData(color: AppColors.onPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.onPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // ELEVATED BUTTON (Botones principales)
      // ─────────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // FILLED BUTTON (Botones de acción secundaria)
      // ─────────────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          disabledForegroundColor: AppColors.onDisabled,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // OUTLINED BUTTON
      // ─────────────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // TEXT BUTTON (Links y acciones terciarias)
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
          foregroundColor: AppColors.primary,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────
      // FLOATING ACTION BUTTON
      // ─────────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.tertiary,
        foregroundColor: AppColors.onTertiary,
        elevation: 4,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // INPUT DECORATION (TextFormField, TextField)
      // ─────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

        // Bordes
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
          borderSide:
              const BorderSide(color: AppColors.inputBorderFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorderError),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.inputBorderError, width: 2),
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
      // CARD
      // ─────────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
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
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          color: AppColors.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 16,
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
        linearTrackColor: AppColors.secondary,
        circularTrackColor: AppColors.secondary,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // CHIP
      // ─────────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        selectedColor: AppColors.primaryLight,
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
        elevation: 8,
      ),

      // ─────────────────────────────────────────────────────────────────────
      // NAVIGATION BAR (Material 3)
      // ─────────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.surface,
        indicatorColor: AppColors.primaryLight,
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
            );
          }
          return const TextStyle(color: AppColors.onSurfaceVariant);
        }),
      ),
    );
  }
}
