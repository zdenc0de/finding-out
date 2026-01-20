// lib/core/utils/string_utils.dart
// Utilidades para manipulación de strings

class StringUtils {
  StringUtils._();

  /// Obtiene las iniciales de un nombre de forma segura
  ///
  /// - Si el nombre está vacío o solo tiene espacios, retorna '?'
  /// - Si tiene dos o más palabras, retorna las iniciales de las primeras dos
  /// - Si tiene una palabra, retorna la primera letra
  static String getInitials(String? name) {
    if (name == null) return '?';

    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';

    // Dividir por espacios y filtrar partes vacías
    final parts = trimmed.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();

    if (parts.isEmpty) return '?';

    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }

    return parts[0][0].toUpperCase();
  }

  /// Sanitiza un string para mostrarlo de forma segura en la UI
  ///
  /// - Limita la longitud máxima
  /// - Elimina caracteres potencialmente problemáticos
  static String sanitizeForDisplay(String? input, {int maxLength = 50}) {
    if (input == null) return '';

    // Eliminar caracteres de control y limitar longitud
    final sanitized = input
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Elimina caracteres de control
        .trim();

    if (sanitized.length <= maxLength) return sanitized;
    return '${sanitized.substring(0, maxLength - 3)}...';
  }
}
