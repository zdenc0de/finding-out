// lib/features/location_search/data/datasources/google_places_datasource.dart
// Cliente para Google Places API

import 'dart:async';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/google_places_model.dart';

/// Cliente para Google Places API.
///
/// Usa:
/// - Places Autocomplete API para sugerencias
/// - Place Details API para obtener coordenadas
/// - Geocoding API para reverse geocoding
class GooglePlacesDatasource {
  static const String _placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place';
  static const String _geocodingBaseUrl =
      'https://maps.googleapis.com/maps/api/geocode';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _httpClient;
  final String _apiKey;

  GooglePlacesDatasource({http.Client? httpClient, String? apiKey})
      : _httpClient = httpClient ?? http.Client(),
        _apiKey = apiKey ?? dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';

  /// Busca lugares por texto con autocompletado.
  ///
  /// [query] - Texto de búsqueda (mínimo 3 caracteres recomendado)
  /// [lat], [lng] - Coordenadas para sesgo geográfico (prioriza resultados cercanos)
  /// [radius] - Radio en metros para el sesgo geográfico (default 50km)
  /// [language] - Idioma de resultados (default 'es')
  Future<List<GooglePlacesAutocompleteModel>> searchPlaces({
    required String query,
    double? lat,
    double? lng,
    int radius = 50000,
    String language = 'es',
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 3) return [];
    if (_apiKey.isEmpty) {
      throw const LocationSearchException('API key no configurada');
    }

    final queryParams = <String, String>{
      'input': trimmedQuery,
      'key': _apiKey,
      'language': language,
      'types': 'geocode|establishment', // Direcciones y establecimientos
    };

    // Agregar sesgo geográfico si se proporcionan coordenadas
    if (lat != null && lng != null) {
      queryParams['location'] = '$lat,$lng';
      queryParams['radius'] = radius.toString();
    }

    final uri = Uri.parse('$_placesBaseUrl/autocomplete/json')
        .replace(queryParameters: queryParams);

    try {
      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw LocationSearchException(
          'Error en la búsqueda: ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;

      if (status == 'ZERO_RESULTS') {
        return [];
      }

      if (status != 'OK') {
        final errorMessage = json['error_message'] as String?;
        throw LocationSearchException(
          errorMessage ?? 'Error en Google Places: $status',
        );
      }

      final predictions = json['predictions'] as List<dynamic>? ?? [];
      return predictions
          .map((p) =>
              GooglePlacesAutocompleteModel.fromJson(p as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw const LocationSearchException('Respuesta inválida del servidor');
    } on TimeoutException {
      throw const LocationSearchException('Tiempo de espera agotado');
    } catch (e) {
      if (e is LocationSearchException) rethrow;
      throw LocationSearchException('Error de conexión: $e');
    }
  }

  /// Obtiene los detalles de un lugar por su Place ID.
  ///
  /// Necesario para obtener las coordenadas de una sugerencia de autocompletado.
  Future<GooglePlaceDetailsModel?> getPlaceDetails({
    required String placeId,
    String language = 'es',
  }) async {
    if (_apiKey.isEmpty) {
      throw const LocationSearchException('API key no configurada');
    }

    final queryParams = {
      'place_id': placeId,
      'key': _apiKey,
      'language': language,
      'fields': 'place_id,formatted_address,geometry,address_components',
    };

    final uri = Uri.parse('$_placesBaseUrl/details/json')
        .replace(queryParameters: queryParams);

    try {
      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;

      if (status != 'OK') {
        return null;
      }

      return GooglePlaceDetailsModel.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// Reverse geocoding: coordenadas -> dirección.
  ///
  /// [latitude] - Latitud del punto
  /// [longitude] - Longitud del punto
  /// [language] - Idioma de resultados (default 'es')
  /// Retorna null si no se encuentra dirección.
  Future<GoogleGeocodingModel?> reverseGeocode({
    required double latitude,
    required double longitude,
    String language = 'es',
  }) async {
    if (_apiKey.isEmpty) {
      return null;
    }

    final queryParams = {
      'latlng': '$latitude,$longitude',
      'key': _apiKey,
      'language': language,
      'result_type': 'street_address|route|locality',
    };

    final uri = Uri.parse('$_geocodingBaseUrl/json')
        .replace(queryParameters: queryParams);

    try {
      final response = await _httpClient.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final status = json['status'] as String?;

      if (status != 'OK') {
        return null;
      }

      final results = json['results'] as List<dynamic>? ?? [];
      if (results.isEmpty) return null;

      return GoogleGeocodingModel.fromJson(
          results.first as Map<String, dynamic>);
    } catch (e) {
      return null;
    }
  }

  /// Libera recursos del cliente HTTP.
  void dispose() {
    _httpClient.close();
  }
}
