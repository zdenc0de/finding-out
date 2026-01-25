// lib/core/utils/location_helper.dart
// Utilidades para manejo de ubicación y geolocalización

import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Utilidades para cálculos y operaciones con ubicaciones
class LocationHelper {
  LocationHelper._();

  /// Posición por defecto (Ciudad de México)
  static const LatLng defaultPosition = LatLng(19.4326, -99.1332);

  /// Zoom por defecto para el mapa
  static const double defaultZoom = 12.0;

  /// Zoom al centrar en ubicación del usuario
  static const double userLocationZoom = 15.0;

  /// Calcula la distancia en kilómetros entre dos puntos.
  ///
  /// Usa la fórmula de Haversine para calcular la distancia
  /// sobre la superficie de la Tierra.
  static double distanceInKm(LatLng from, LatLng to) {
    const double earthRadius = 6371; // Radio de la Tierra en km

    final double lat1 = _toRadians(from.latitude);
    final double lat2 = _toRadians(to.latitude);
    final double dLat = _toRadians(to.latitude - from.latitude);
    final double dLng = _toRadians(to.longitude - from.longitude);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) *
            math.cos(lat2) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  /// Calcula la distancia en metros entre dos puntos.
  static double distanceInMeters(LatLng from, LatLng to) {
    return distanceInKm(from, to) * 1000;
  }

  /// Formatea la distancia para mostrar al usuario.
  ///
  /// Retorna "X km" si la distancia es >= 1 km, "X m" si es menor.
  static String formatDistance(double meters) {
    if (meters >= 1000) {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }

  /// Convierte grados a radianes.
  static double _toRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  /// Verifica si una coordenada es válida.
  static bool isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  /// Crea un LatLng desde coordenadas opcionales.
  ///
  /// Retorna null si las coordenadas son inválidas.
  static LatLng? createLatLng(double? lat, double? lng) {
    if (!isValidCoordinate(lat, lng)) return null;
    return LatLng(lat!, lng!);
  }

  /// Calcula el centro de un conjunto de puntos.
  static LatLng? calculateCenter(List<LatLng> points) {
    if (points.isEmpty) return null;
    if (points.length == 1) return points.first;

    double totalLat = 0;
    double totalLng = 0;

    for (final point in points) {
      totalLat += point.latitude;
      totalLng += point.longitude;
    }

    return LatLng(totalLat / points.length, totalLng / points.length);
  }
}
