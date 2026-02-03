// lib/features/location_search/data/repositories/location_search_repository_impl.dart
// Implementación del repositorio de búsqueda de ubicaciones usando Google Places

import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/location_search_repository.dart';
import '../datasources/google_places_datasource.dart';

/// Implementación del repositorio de búsqueda de ubicaciones usando Google Places API.
class LocationSearchRepositoryImpl implements LocationSearchRepository {
  final GooglePlacesDatasource _datasource;

  LocationSearchRepositoryImpl(this._datasource);

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    int limit = 5,
    double? lat,
    double? lon,
  }) async {
    // Obtener sugerencias de autocompletado
    final suggestions = await _datasource.searchPlaces(
      query: query,
      lat: lat,
      lng: lon,
    );

    // Para cada sugerencia, obtener los detalles con coordenadas
    final List<PlaceSuggestion> results = [];

    // Limitar a los primeros 'limit' resultados para no hacer muchas llamadas
    final limitedSuggestions = suggestions.take(limit).toList();

    for (final suggestion in limitedSuggestions) {
      final details = await _datasource.getPlaceDetails(
        placeId: suggestion.placeId,
      );

      if (details != null) {
        results.add(details.toEntity());
      }
    }

    return results;
  }

  @override
  Future<PlaceSuggestion?> reverseGeocode({
    required double latitude,
    required double longitude,
  }) async {
    final result = await _datasource.reverseGeocode(
      latitude: latitude,
      longitude: longitude,
    );

    return result?.toEntity();
  }
}
