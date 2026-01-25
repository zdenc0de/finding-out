// lib/core/services/location/location_service.dart
// Interfaz del servicio de ubicación

import 'package:latlong2/latlong.dart';

/// Interfaz abstracta para el servicio de ubicación.
///
/// Define los métodos necesarios para manejar la geolocalización
/// del usuario siguiendo Clean Architecture.
abstract class LocationService {
  /// Verifica si el servicio de ubicación está habilitado (GPS).
  Future<bool> isLocationServiceEnabled();

  /// Verifica si la app tiene permiso de ubicación.
  Future<bool> hasLocationPermission();

  /// Solicita permiso de ubicación al usuario.
  ///
  /// Retorna `true` si el permiso fue concedido.
  Future<bool> requestLocationPermission();

  /// Obtiene la posición actual del usuario.
  ///
  /// Lanza [LocationServiceDisabledException] si el GPS está apagado.
  /// Lanza [LocationPermissionDeniedException] si no hay permiso.
  /// Lanza [LocationFetchException] si hay error al obtener ubicación.
  Future<LatLng> getCurrentPosition();

  /// Abre la configuración de la app para habilitar permisos.
  Future<bool> openAppSettings();

  /// Abre la configuración de ubicación del dispositivo.
  Future<bool> openLocationSettings();
}
