// lib/core/utils/distance_calculator.dart
// Utilidad para calcular distancia entre coordenadas usando fórmula Haversine

import 'dart:math';

/// Calculadora de distancia geográfica usando la fórmula Haversine.
///
/// La fórmula Haversine calcula la distancia del arco más corto entre
/// dos puntos en una esfera (la Tierra), dado sus latitudes y longitudes.
class DistanceCalculator {
  /// Radio de la Tierra en kilómetros
  static const double _earthRadiusKm = 6371.0;

  /// Calcula la distancia en kilómetros entre dos coordenadas geográficas.
  ///
  /// [lat1], [lng1]: Coordenadas del primer punto
  /// [lat2], [lng2]: Coordenadas del segundo punto
  ///
  /// Retorna la distancia en kilómetros.
  static double calculateDistance({
    required double lat1,
    required double lng1,
    required double lat2,
    required double lng2,
  }) {
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);

    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLng / 2) * sin(dLng / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return _earthRadiusKm * c;
  }

  /// Verifica si un punto está dentro de un radio dado desde otro punto.
  ///
  /// [centerLat], [centerLng]: Centro del círculo
  /// [pointLat], [pointLng]: Punto a verificar
  /// [radiusKm]: Radio en kilómetros
  static bool isWithinRadius({
    required double centerLat,
    required double centerLng,
    required double pointLat,
    required double pointLng,
    required double radiusKm,
  }) {
    final distance = calculateDistance(
      lat1: centerLat,
      lng1: centerLng,
      lat2: pointLat,
      lng2: pointLng,
    );
    return distance <= radiusKm;
  }

  /// Convierte grados a radianes.
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}
