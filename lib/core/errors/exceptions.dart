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

/// Error al enviar email de restablecimiento de contraseña
class PasswordResetException extends AuthException {
  const PasswordResetException([String? debugInfo])
      : super('No se pudo enviar el email de recuperación', debugInfo);
}

/// Error al actualizar perfil
class ProfileUpdateException extends AuthException {
  const ProfileUpdateException([String? debugInfo])
      : super('No se pudo actualizar el perfil', debugInfo);
}

/// Usuario no encontrado
class UserNotFoundException extends AuthException {
  const UserNotFoundException([String? debugInfo])
      : super('No existe una cuenta con este email', debugInfo);
}

/// Excepción de red/conexión
class NetworkException extends AuthException {
  const NetworkException([String? debugInfo])
      : super('Error de conexión. Verifica tu internet', debugInfo);
}

/// Error desconocido
class UnknownException extends AppException {
  const UnknownException([String? debugInfo])
      : super('Ha ocurrido un error inesperado', debugInfo);
}

// ═══════════════════════════════════════════════════════════════════════════
// EXCEPCIONES DE EVENTOS
// ═══════════════════════════════════════════════════════════════════════════

/// Excepción base para errores relacionados con eventos
class EventException extends AppException {
  const EventException(super.message, [super.debugInfo]);
}

/// Error al cargar categorías
class CategoriesLoadException extends EventException {
  const CategoriesLoadException([String? debugInfo])
      : super('No se pudieron cargar las categorías', debugInfo);
}

/// Error al cargar eventos
class EventsLoadException extends EventException {
  const EventsLoadException([String? debugInfo])
      : super('No se pudieron cargar los eventos', debugInfo);
}

/// Evento no encontrado
class EventNotFoundException extends EventException {
  const EventNotFoundException([String? debugInfo])
      : super('El evento no fue encontrado', debugInfo);
}

/// Error al crear un evento
class EventCreateException extends EventException {
  const EventCreateException([String? debugInfo])
      : super('No se pudo crear el evento', debugInfo);
}

// ═══════════════════════════════════════════════════════════════════════════
// EXCEPCIONES DE UBICACIÓN
// ═══════════════════════════════════════════════════════════════════════════

/// Excepción base para errores relacionados con ubicación
class LocationException extends AppException {
  const LocationException(super.message, [super.debugInfo]);
}

/// Servicio de ubicación deshabilitado (GPS apagado)
class LocationServiceDisabledException extends LocationException {
  const LocationServiceDisabledException([String? debugInfo])
      : super('El servicio de ubicación está deshabilitado. Activa el GPS', debugInfo);
}

/// Permiso de ubicación denegado
class LocationPermissionDeniedException extends LocationException {
  const LocationPermissionDeniedException([String? debugInfo])
      : super('Se requiere permiso de ubicación para esta función', debugInfo);
}

/// Permiso de ubicación denegado permanentemente
class LocationPermissionPermanentlyDeniedException extends LocationException {
  const LocationPermissionPermanentlyDeniedException([String? debugInfo])
      : super('Permiso de ubicación denegado. Habilítalo en la configuración de la app', debugInfo);
}

/// Error al obtener la ubicación
class LocationFetchException extends LocationException {
  const LocationFetchException([String? debugInfo])
      : super('No se pudo obtener tu ubicación', debugInfo);
}

// ═══════════════════════════════════════════════════════════════════════════
// EXCEPCIONES DE STORAGE
// ═══════════════════════════════════════════════════════════════════════════

/// Excepción base para errores relacionados con almacenamiento
class StorageException extends AppException {
  const StorageException(super.message, [super.debugInfo]);
}

/// Error al subir imagen
class ImageUploadException extends StorageException {
  const ImageUploadException([String? debugInfo])
      : super('No se pudo subir la imagen', debugInfo);
}

/// Imagen demasiado grande
class ImageTooLargeException extends StorageException {
  const ImageTooLargeException([String? debugInfo])
      : super('La imagen es demasiado grande. Máximo 5MB', debugInfo);
}

/// Formato de imagen inválido
class InvalidImageFormatException extends StorageException {
  const InvalidImageFormatException([String? debugInfo])
      : super('Formato de imagen no válido. Usa JPG, PNG o WebP', debugInfo);
}

// ═══════════════════════════════════════════════════════════════════════════
// EXCEPCIONES DE BÚSQUEDA DE UBICACIÓN
// ═══════════════════════════════════════════════════════════════════════════

/// Excepción para errores de búsqueda de ubicación (Photon API)
class LocationSearchException extends AppException {
  const LocationSearchException([super.message = 'Error al buscar ubicación']);
}
