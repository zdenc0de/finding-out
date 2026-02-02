// lib/features/location_search/data/datasources/photon_datasource.dart
// Cliente para Photon API (geocoding basado en OpenStreetMap)

import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/errors/exceptions.dart';
import '../models/photon_place_model.dart';

/// Cliente para Photon API (geocoding gratuito basado en OpenStreetMap).
///
/// Documentación: https://photon.komoot.io/
class PhotonDatasource {
  static const String _baseUrl = 'https://photon.komoot.io';
  static const String _userAgent = 'FindingOut/1.0 (Flutter App)';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _httpClient;

  PhotonDatasource({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  /// Busca lugares por texto.
  ///
  /// [query] - Texto de búsqueda (mínimo 3 caracteres recomendado)
  /// [limit] - Máximo de resultados (default 5)
  /// [lat], [lon] - Coordenadas para sesgo geográfico (prioriza resultados cercanos)
  /// [lang] - Idioma de resultados (default 'es')
  Future<List<PhotonPlaceModel>> searchPlaces({
    required String query,
    int limit = 5,
    double? lat,
    double? lon,
    String lang = 'es',
  }) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.length < 3) return [];

    final queryParams = <String, String>{
      'q': trimmedQuery,
      'limit': limit.toString(),
      'lang': lang,
    };

    // Agregar sesgo geográfico si se proporcionan coordenadas
    if (lat != null && lon != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lon'] = lon.toString();
    }

    final uri = Uri.parse('$_baseUrl/api').replace(queryParameters: queryParams);

    try {
      final response = await _httpClient
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw LocationSearchException(
          'Error en la búsqueda: ${response.statusCode}',
        );
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>? ?? [];

      return features
          .map((f) => PhotonPlaceModel.fromJson(f as Map<String, dynamic>))
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

  /// Reverse geocoding: coordenadas -> dirección.
  ///
  /// [latitude] - Latitud del punto
  /// [longitude] - Longitud del punto
  /// [lang] - Idioma de resultados (default 'es')
  /// Retorna null si no se encuentra dirección.
  Future<PhotonPlaceModel?> reverseGeocode({
    required double latitude,
    required double longitude,
    String lang = 'es',
  }) async {
    final uri = Uri.parse('$_baseUrl/reverse').replace(
      queryParameters: {
        'lat': latitude.toString(),
        'lon': longitude.toString(),
        'lang': lang,
      },
    );

    try {
      final response = await _httpClient
          .get(uri, headers: {'User-Agent': _userAgent})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        return null;
      }

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final features = json['features'] as List<dynamic>? ?? [];

      if (features.isEmpty) return null;

      return PhotonPlaceModel.fromJson(features.first as Map<String, dynamic>);
    } catch (e) {
      // Silenciar errores en reverse geocoding - retornar null
      return null;
    }
  }

  /// Libera recursos del cliente HTTP.
  void dispose() {
    _httpClient.close();
  }
}
