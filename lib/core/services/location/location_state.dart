// lib/core/services/location/location_state.dart
// Estado de ubicación para el provider

import 'package:latlong2/latlong.dart';

/// Estados posibles del servicio de ubicación
enum LocationStatus {
  /// Estado inicial, no se ha solicitado ubicación
  initial,
  /// Verificando permisos/servicios
  loading,
  /// Ubicación obtenida exitosamente
  success,
  /// Servicio de ubicación deshabilitado (GPS apagado)
  serviceDisabled,
  /// Permiso de ubicación denegado
  permissionDenied,
  /// Permiso de ubicación denegado permanentemente
  permissionPermanentlyDenied,
  /// Error al obtener ubicación
  error,
}

/// Estado inmutable de la ubicación del usuario
class LocationState {
  /// Estado actual del servicio de ubicación
  final LocationStatus status;

  /// Posición actual del usuario (null si no disponible)
  final LatLng? position;

  /// Mensaje de error (si aplica)
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.position,
    this.errorMessage,
  });

  /// Estado inicial
  const LocationState.initial() : this();

  /// Copiador con modificaciones
  LocationState copyWith({
    LocationStatus? status,
    LatLng? position,
    String? errorMessage,
  }) {
    return LocationState(
      status: status ?? this.status,
      position: position ?? this.position,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Verifica si la ubicación está disponible
  bool get hasLocation => position != null;

  /// Verifica si está cargando
  bool get isLoading => status == LocationStatus.loading;

  /// Verifica si hay un error
  bool get hasError =>
      status == LocationStatus.serviceDisabled ||
      status == LocationStatus.permissionDenied ||
      status == LocationStatus.permissionPermanentlyDenied ||
      status == LocationStatus.error;
}
