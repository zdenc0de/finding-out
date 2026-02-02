// lib/features/location_search/data/models/photon_place_model.dart
// Modelo para parsear respuesta de Photon API

import '../../domain/entities/place_suggestion.dart';

/// Modelo para parsear respuesta de Photon API.
///
/// Estructura de Photon:
/// ```json
/// {
///   "features": [{
///     "geometry": { "coordinates": [lng, lat] },
///     "properties": {
///       "osm_id": 123456,
///       "name": "Lugar",
///       "street": "Calle",
///       "housenumber": "123",
///       "city": "Ciudad",
///       "state": "Estado",
///       "country": "País"
///     }
///   }]
/// }
/// ```
class PhotonPlaceModel {
  final int osmId;
  final String? name;
  final String? street;
  final String? houseNumber;
  final String? city;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;

  const PhotonPlaceModel({
    required this.osmId,
    this.name,
    this.street,
    this.houseNumber,
    this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  factory PhotonPlaceModel.fromJson(Map<String, dynamic> json) {
    final properties = json['properties'] as Map<String, dynamic>? ?? {};
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = geometry['coordinates'] as List<dynamic>? ?? [0.0, 0.0];

    return PhotonPlaceModel(
      osmId: properties['osm_id'] as int? ?? 0,
      name: properties['name'] as String?,
      street: properties['street'] as String?,
      houseNumber: properties['housenumber'] as String?,
      city: properties['city'] as String?,
      state: properties['state'] as String?,
      country: properties['country'] as String?,
      // Photon retorna [longitude, latitude]
      longitude: (coordinates[0] as num?)?.toDouble() ?? 0.0,
      latitude: (coordinates[1] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convierte a entidad de dominio.
  PlaceSuggestion toEntity() {
    // Construir displayName
    final displayParts = <String>[];

    if (name != null && name!.isNotEmpty) {
      displayParts.add(name!);
    }

    if (street != null && street!.isNotEmpty) {
      final streetText = houseNumber != null && houseNumber!.isNotEmpty
          ? '$street $houseNumber'
          : street!;
      // Evitar duplicados
      if (!displayParts.contains(streetText) && name != streetText) {
        displayParts.add(streetText);
      }
    }

    if (city != null && city!.isNotEmpty) {
      displayParts.add(city!);
    }

    if (country != null && country!.isNotEmpty) {
      displayParts.add(country!);
    }

    return PlaceSuggestion(
      id: 'osm_$osmId',
      displayName: displayParts.isEmpty ? 'Ubicación desconocida' : displayParts.join(', '),
      street: street,
      houseNumber: houseNumber,
      city: city,
      state: state,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
