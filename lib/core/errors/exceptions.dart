// lib/core/errors/exceptions.dart
// Excepciones personalizadas de la aplicación

/// Excepción base de la aplicación
abstract class AppException implements Exception {
  final String message;
  final String? debugInfo;

  const AppException(this.message, [this.debugInfo]);

  /// Mensaje seguro para mostrar al usuario (sin información sensible)
  String get userMessage => message;

  @override
  String toString() => message;
}

/// Excepciones relacionadas con autenticación
class AuthException extends AppException {
  const AuthException(super.message, [super.debugInfo]);
}

/// Credenciales inválidas (email o contraseña incorrectos)
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException([String? debugInfo])
      : super('Email o contraseña incorrectos', debugInfo);
}

/// Email no verificado
class EmailNotVerifiedException extends AuthException {
  const EmailNotVerifiedException([String? debugInfo])
      : super('Debes confirmar tu email antes de iniciar sesión', debugInfo);
}

/// Email ya registrado
class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException([String? debugInfo])
      : super('Este email ya está registrado', debugInfo);
}

/// Contraseña muy débil
class WeakPasswordException extends AuthException {
  const WeakPasswordException([String? debugInfo])
      : super('La contraseña debe tener al menos 6 caracteres', debugInfo);
}

/// Email con formato inválido
class InvalidEmailException extends AuthException {
  const InvalidEmailException([String? debugInfo])
      : super('El formato del email no es válido', debugInfo);
}

/// Límite de intentos excedido
class RateLimitException extends AuthException {
  const RateLimitException([String? debugInfo])
      : super('Demasiados intentos. Intenta más tarde', debugInfo);
}

/// Verificación de email requerida (registro exitoso)
class EmailVerificationRequiredException extends AuthException {
  const EmailVerificationRequiredException([String? debugInfo])
      : super('Se requiere verificación de email', debugInfo);
}

/// Excepción de red/conexión
class NetworkException extends AppException {
  const NetworkException([String? debugInfo])
      : super('Error de conexión. Verifica tu internet', debugInfo);
}

/// Error desconocido
class UnknownException extends AppException {
  const UnknownException([String? debugInfo])
      : super('Ha ocurrido un error inesperado', debugInfo);
}
