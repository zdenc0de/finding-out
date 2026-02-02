// lib/features/location_search/domain/repositories/location_search_repository.dart
// Contrato para búsqueda de ubicaciones

import '../entities/place_suggestion.dart';

/// Contrato para búsqueda de ubicaciones.
abstract class LocationSearchRepository {
  /// Busca sugerencias de lugares basadas en el texto.
  ///
  /// [query] - Texto de búsqueda (mínimo 3 caracteres)
  /// [limit] - Máximo de resultados (default 5)
  /// [lat], [lon] - Coordenadas para sesgo geográfico (opcional)
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    int limit = 5,
    double? lat,
    double? lon,
  });

  /// Obtiene la dirección de unas coordenadas (reverse geocoding).
  ///
  /// [latitude] - Latitud del punto
  /// [longitude] - Longitud del punto
  /// Retorna null si no se encuentra dirección.
  Future<PlaceSuggestion?> reverseGeocode({
    required double latitude,
    required double longitude,
  });
}
