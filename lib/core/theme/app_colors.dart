// lib/core/theme/app_colors.dart
// Paleta de colores de la aplicación Finding Out

import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la aplicación
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

  /// Persian Blue - Color primario
  /// Uso: Botones principales, AppBar, links, elementos de acción
  static const Color primary = Color(0xFF0038BC);

  /// Variantes del primario (generadas automáticamente)
  static const Color primaryLight = Color(0xFF4D6FD4);
  static const Color primaryDark = Color(0xFF002A8F);

  /// Platinum - Color secundario
  /// Uso: Fondos, superficies, cards, contenedores
  static const Color secondary = Color(0xFFEEEEEE);

  /// Variantes del secundario
  static const Color secondaryLight = Color(0xFFFAFAFA);
  static const Color secondaryDark = Color(0xFFE0E0E0);

  /// Carrot - Color terciario/acento
  /// Uso: Badges, notificaciones, elementos destacados, CTAs secundarios
  static const Color tertiary = Color(0xFFEF8F00);

  /// Variantes del terciario
  static const Color tertiaryLight = Color(0xFFFFB74D);
  static const Color tertiaryDark = Color(0xFFC77700);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE SUPERFICIE
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fondo principal de la aplicación
  static const Color background = Color(0xFFFAFAFA);

  /// Superficie de cards y contenedores elevados
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie con énfasis (cards destacadas)
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE TEXTO (on*)
  // Estos colores se usan SOBRE los colores principales
  // ═══════════════════════════════════════════════════════════════════════════

  /// Texto sobre color primario (botones azules)
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Texto sobre color secundario (fondos claros)
  static const Color onSecondary = Color(0xFF1A1A1A);

  /// Texto sobre color terciario (badges naranjas)
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Texto sobre fondo
  static const Color onBackground = Color(0xFF1A1A1A);

  /// Texto sobre superficie
  static const Color onSurface = Color(0xFF1A1A1A);

  /// Texto secundario/subtítulos
  static const Color onSurfaceVariant = Color(0xFF666666);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES SEMÁNTICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Error - Rojo para mensajes de error
  static const Color error = Color(0xFFD32F2F);
  static const Color onError = Color(0xFFFFFFFF);

  /// Éxito - Verde para confirmaciones
  static const Color success = Color(0xFF388E3C);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Advertencia - Amarillo para alertas
  static const Color warning = Color(0xFFFFA000);
  static const Color onWarning = Color(0xFF1A1A1A);

  /// Información - Azul claro para mensajes informativos
  static const Color info = Color(0xFF1976D2);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE UI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bordes y divisores
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFBDBDBD);

  /// Sombras
  static const Color shadow = Color(0x1A000000);

  /// Overlay para modales y diálogos
  static const Color scrim = Color(0x52000000);

  /// Elementos deshabilitados
  static const Color disabled = Color(0xFFBDBDBD);
  static const Color onDisabled = Color(0xFF9E9E9E);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PARA INPUTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Borde de input en estado normal
  static const Color inputBorder = Color(0xFFBDBDBD);

  /// Borde de input cuando está enfocado
  static const Color inputBorderFocused = primary;

  /// Borde de input con error
  static const Color inputBorderError = error;

  /// Fondo de input
  static const Color inputFill = Color(0xFFFAFAFA);
}
