// lib/core/theme/app_colors.dart
// Paleta de colores de la aplicación Finding Out
// Inspirado en el estilo Santorini - Minimalista, vibrante, elegante

import 'package:flutter/material.dart';

/// Paleta de colores centralizada de la aplicación
///
/// Estilo: Santorini - Mediterráneo moderno
/// - Azul vibrante (#2B4CFF) - Primario
/// - Blanco limpio - Superficies
/// - Gris suave - Textos secundarios
///
/// Uso:
/// ```dart
/// Container(color: AppColors.primary)
/// Text('Hola', style: TextStyle(color: AppColors.onPrimary))
/// ```
abstract class AppColors {
  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PRINCIPALES - Santorini Blue
  // ═══════════════════════════════════════════════════════════════════════════

  /// Santorini Blue - Color primario vibrante
  /// Uso: Botones principales, links, elementos de acción, acentos
  static const Color primary = Color(0xFF2B4CFF);

  /// Variantes del primario
  static const Color primaryLight = Color(0xFF5A72FF);
  static const Color primaryDark = Color(0xFF1A3AD4);
  static const Color primaryContainer = Color(0xFFE8ECFF);
  static const Color onPrimaryContainer = Color(0xFF1A3AD4);

  /// Color secundario - Gris neutro elegante
  /// Uso: Textos secundarios, bordes sutiles
  static const Color secondary = Color(0xFF6B7280);

  /// Variantes del secundario
  static const Color secondaryLight = Color(0xFF9CA3AF);
  static const Color secondaryDark = Color(0xFF4B5563);
  static const Color secondaryContainer = Color(0xFFF3F4F6);
  static const Color onSecondaryContainer = Color(0xFF374151);

  /// Color terciario/acento - Coral vibrante
  /// Uso: Badges, notificaciones, CTAs destacados
  static const Color tertiary = Color(0xFFFF6B5A);

  /// Variantes del terciario
  static const Color tertiaryLight = Color(0xFFFF9A8F);
  static const Color tertiaryDark = Color(0xFFE54A3A);
  static const Color tertiaryContainer = Color(0xFFFFEBE9);
  static const Color onTertiaryContainer = Color(0xFF7F2318);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE SUPERFICIE - Blancos y grises limpios
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fondo principal - Blanco puro para máxima limpieza
  static const Color background = Color(0xFFFFFFFF);

  /// Superficie de cards y contenedores
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie con sutil diferencia (cards sobre fondo)
  static const Color surfaceVariant = Color(0xFFF9FAFB);

  /// Superficie con mayor contraste
  static const Color surfaceContainerHighest = Color(0xFFF3F4F6);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE TEXTO (on*)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Texto sobre color primario (botones azules)
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Texto sobre color secundario
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Texto sobre color terciario
  static const Color onTertiary = Color(0xFFFFFFFF);

  /// Texto principal - Negro suave
  static const Color onBackground = Color(0xFF1A1A1A);

  /// Texto sobre superficie
  static const Color onSurface = Color(0xFF1A1A1A);

  /// Texto secundario/subtítulos - Gris medio
  static const Color onSurfaceVariant = Color(0xFF6B7280);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES SEMÁNTICOS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Error - Rojo claro
  static const Color error = Color(0xFFDC2626);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFEE2E2);
  static const Color onErrorContainer = Color(0xFF7F1D1D);

  /// Éxito - Verde fresco
  static const Color success = Color(0xFF16A34A);
  static const Color onSuccess = Color(0xFFFFFFFF);

  /// Advertencia - Ámbar cálido
  static const Color warning = Color(0xFFF59E0B);
  static const Color onWarning = Color(0xFFFFFFFF);

  /// Información - Usa el primario
  static const Color info = Color(0xFF2B4CFF);
  static const Color onInfo = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES DE UI
  // ═══════════════════════════════════════════════════════════════════════════

  /// Bordes y divisores - Gris muy sutil
  static const Color outline = Color(0xFFE5E7EB);
  static const Color outlineVariant = Color(0xFFD1D5DB);

  /// Sombras
  static const Color shadow = Color(0x1A000000);

  /// Overlay para modales
  static const Color scrim = Color(0x52000000);

  /// Elementos deshabilitados
  static const Color disabled = Color(0xFFD1D5DB);
  static const Color onDisabled = Color(0xFF9CA3AF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PARA INPUTS
  // ═══════════════════════════════════════════════════════════════════════════

  /// Borde de input en estado normal
  static const Color inputBorder = Color(0xFFE5E7EB);

  /// Borde de input cuando está enfocado
  static const Color inputBorderFocused = primary;

  /// Borde de input con error
  static const Color inputBorderError = error;

  /// Fondo de input - Blanco
  static const Color inputFill = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════════════════════
  // COLORES PARA LOGIN SCREEN
  // ═══════════════════════════════════════════════════════════════════════════

  /// Fondo de inputs en login - Azul muy tenue
  static const Color loginInputFill = Color(0xFFEDF2FF);

  /// Borde de inputs en login - Azul claro sutil
  static const Color loginInputBorder = Color(0xFFC8D6FF);

  /// Gradiente del botón Continue - Inicio
  static const Color loginGradientStart = Color(0xFF2B8FFF);

  /// Gradiente del botón Continue - Fin
  static const Color loginGradientEnd = Color(0xFF1A6FD4);

  /// Fondo del card glassmorphism en login
  static const Color loginCardBackground = Color(0xF2FFFFFF);

  /// Color de fondo cálido del login (crema)
  static const Color loginBackground = Color(0xFFFAF6F1);
}
