// lib/core/theme/app_colors.dart
// Paleta de colores de la aplicación Finding Out

import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la aplicación
///
/// Colores principales:
/// - YInMn Blue (#2E4C8C) - Primario
/// - Old Lace (#FFF3E1) - Secundario/Superficies
/// - Red (#FA2D1A) - Acento/Terciario
///
/// Uso:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Hola', style: TextStyle(color: AppColors.onPrimary))
/// ```
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PRINCIPALES
  // ═══════════════════════════════════════════════════════════════════════════

  /// YInMn Blue - Color primario
  /// Uso: Botones principales, AppBar, links, elementos de acción
  static const Color primary = Color(0xFF2E4C8C);

  /// Variantes del primario
  static const Color primaryLight = Color(0xFF5A75B0);
  static const Color primaryDark = Color(0xFF1E3366);
  static const Color primaryContainer = Color(0xFFD4DFEF);
  static const Color onPrimaryContainer = Color(0xFF1E3366);

  /// Old Lace - Color secundario
  /// Uso: Fondos, superficies, cards, contenedores
  static const Color secondary = Color(0xFFFFF3E1);

  /// Variantes del secundario
  static const Color secondaryLight = Color(0xFFFFFAF5);
  static const Color secondaryDark = Color(0xFFE8D9C5);
  static const Color secondaryContainer = Color(0xFFFFF8EE);
  static const Color onSecondaryContainer = Color(0xFF4A3D2D);

  /// Red - Color terciario/acento
  /// Uso: Badges, notificaciones, elementos destacados, CTAs secundarios
  static const Color tertiary = Color(0xFFFA2D1A);

  /// Variantes del terciario
  static const Color tertiaryLight = Color(0xFFFF6B5A);
  static const Color tertiaryDark = Color(0xFFC41F10);
  static const Color tertiaryContainer = Color(0xFFFFDAD6);
  static const Color onTertiaryContainer = Color(0xFF410003);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE SUPERFICIE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fondo principal de la aplicación (Old Lace claro)
  static const Color background = Color(0xFFFFFAF5);

  /// Superficie de cards y contenedores elevados
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie con énfasis (cards destacadas)
  static const Color surfaceVariant = Color(0xFFFFF3E1);

  /// Superficie con mayor contraste
  static const Color surfaceContainerHighest = Color(0xFFEFE6D8);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE TEXTO (on*)
  // Estos colores se usan SOBRE los colores principales
  // ═══════════════════════════════════════════════════════════════════════════

  /// Texto sobre color primario (botones azules)
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Texto sobre color secundario (fondos claros)
  static const Color onSecondary = Color(0xFF2A2318);

  /// Texto sobre color terciario (elementos rojos)
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Texto sobre fondo
  static const Color onBackground = Color(0xFF1E1B16);

  /// Texto sobre superficie
  static const Color onSurface = Color(0xFF1E1B16);

  /// Texto secundario/subtítulos
  static const Color onSurfaceVariant = Color(0xFF4D4639);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES SEMÁNTICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Error - Rojo para mensajes de error (usando el rojo de la paleta)
  static const Color error = Color(0xFFFA2D1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410003);

  /// Éxito - Verde para confirmaciones
  static const Color success = Color(0xFF2E7D32);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Advertencia - Amarillo/ámbar para alertas
  static const Color warning = Color(0xFFE65100);
  static const Color onWarning = Color(0xFFFFFFFF);

  /// Información - Azul (usando el primario)
  static const Color info = Color(0xFF2E4C8C);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE UI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bordes y divisores
  static const Color outline = Color(0xFFD4C9B9);
  static const Color outlineVariant = Color(0xFFCABFA9);

  /// Sombras
  static const Color shadow = Color(0x1A000000);

  /// Overlay para modales y diálogos
  static const Color scrim = Color(0x52000000);

  /// Elementos deshabilitados
  static const Color disabled = Color(0xFFBDB4A5);
  static const Color onDisabled = Color(0xFF9E9589);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PARA INPUTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Borde de input en estado normal
  static const Color inputBorder = Color(0xFFCABFA9);

  /// Borde de input cuando está enfocado
  static const Color inputBorderFocused = primary;

  /// Borde de input con error
  static const Color inputBorderError = error;

  /// Fondo de input
  static const Color inputFill = Color(0xFFFFFAF5);
}
