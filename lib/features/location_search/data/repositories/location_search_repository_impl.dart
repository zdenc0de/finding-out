// lib/features/location_search/data/repositories/location_search_repository_impl.dart
// Implementación del repositorio de búsqueda de ubicaciones

import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/location_search_repository.dart';
import '../datasources/photon_datasource.dart';

/// Implementación del repositorio de búsqueda de ubicaciones usando Photon API.
class LocationSearchRepositoryImpl implements LocationSearchRepository {
  final PhotonDatasource _datasource;

  LocationSearchRepositoryImpl(this._datasource);

  @override
  Future<List<PlaceSuggestion>> searchPlaces({
    required String query,
    int limit = 5,
    double? lat,
    double? lon,
  }) async {
    final results = await _datasource.searchPlaces(
      query: query,
      limit: limit,
      lat: lat,
      lon: lon,
    );

    return results.map((model) => model.toEntity()).toList();
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
