// lib/core/utils/validators.dart
// Validadores para formularios y datos

/// Utilidades de validación para formularios
class Validators {
  Validators._();

  /// Regex para validación de email según RFC 5322 (simplificado)
  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Valida un email
  /// Retorna null si es válido, o un mensaje de error si no lo es
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu email';
    }
    final trimmed = value.trim();
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  /// Valida una contraseña para login (requisitos mínimos)
  static String? validateLoginPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  /// Valida una contraseña para registro (requisitos más estrictos)
  static String? validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa una contraseña';
    }
    if (value.length < 8) {
      return 'Mínimo 8 caracteres';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Debe incluir al menos una mayúscula';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Debe incluir al menos una minúscula';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Debe incluir al menos un número';
    }
    return null;
  }

  /// Valida que las contraseñas coincidan
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  /// Valida que un nombre no esté vacío
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre';
    }
    return null;
  }
}
