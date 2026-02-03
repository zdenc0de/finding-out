// lib/features/location_search/data/models/google_places_model.dart
// Modelo para respuestas de Google Places API

import '../../domain/entities/place_suggestion.dart';

/// Modelo para una sugerencia de Google Places Autocomplete.
class GooglePlacesAutocompleteModel {
  final String placeId;
  final String description;
  final String mainText;
  final String? secondaryText;
  final List<String> types;

  const GooglePlacesAutocompleteModel({
    required this.placeId,
    required this.description,
    required this.mainText,
    this.secondaryText,
    this.types = const [],
  });

  /// Crea una instancia desde JSON de Google Places Autocomplete.
  factory GooglePlacesAutocompleteModel.fromJson(Map<String, dynamic> json) {
    final structuredFormatting =
        json['structured_formatting'] as Map<String, dynamic>? ?? {};

    return GooglePlacesAutocompleteModel(
      placeId: json['place_id'] as String? ?? '',
      description: json['description'] as String? ?? '',
      mainText: structuredFormatting['main_text'] as String? ?? '',
      secondaryText: structuredFormatting['secondary_text'] as String?,
      types: (json['types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convierte a entidad PlaceSuggestion.
  /// Nota: Se necesitan las coordenadas del Place Details.
  PlaceSuggestion toEntity({
    required double latitude,
    required double longitude,
    String? street,
    String? houseNumber,
    String? city,
    String? state,
    String? country,
  }) {
    return PlaceSuggestion(
      id: placeId,
      displayName: mainText,
      street: street,
      houseNumber: houseNumber,
      city: city ?? secondaryText,
      state: state,
      country: country,
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Modelo para detalles de un lugar de Google Places.
class GooglePlaceDetailsModel {
  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<AddressComponent> addressComponents;

  const GooglePlaceDetailsModel({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.addressComponents = const [],
  });

  /// Crea una instancia desde JSON de Google Place Details.
  factory GooglePlaceDetailsModel.fromJson(Map<String, dynamic> json) {
    final result = json['result'] as Map<String, dynamic>? ?? json;
    final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};

    return GooglePlaceDetailsModel(
      placeId: result['place_id'] as String? ?? '',
      formattedAddress: result['formatted_address'] as String? ?? '',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['lng'] as num?)?.toDouble() ?? 0.0,
      addressComponents: (result['address_components'] as List<dynamic>?)
              ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Obtiene el componente de dirección por tipo.
  String? getComponent(String type) {
    try {
      return addressComponents
          .firstWhere((c) => c.types.contains(type))
          .longName;
    } catch (_) {
      return null;
    }
  }

  /// Convierte a entidad PlaceSuggestion.
  PlaceSuggestion toEntity() {
    return PlaceSuggestion(
      id: placeId,
      displayName: formattedAddress,
      street: getComponent('route'),
      houseNumber: getComponent('street_number'),
      city: getComponent('locality') ?? getComponent('administrative_area_level_2'),
      state: getComponent('administrative_area_level_1'),
      country: getComponent('country'),
      latitude: latitude,
      longitude: longitude,
    );
  }
}

/// Componente de dirección de Google Places.
class AddressComponent {
  final String longName;
  final String shortName;
  final List<String> types;

  const AddressComponent({
    required this.longName,
    required this.shortName,
    required this.types,
  });

  factory AddressComponent.fromJson(Map<String, dynamic> json) {
    return AddressComponent(
      longName: json['long_name'] as String? ?? '',
      shortName: json['short_name'] as String? ?? '',
      types: (json['types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

/// Modelo para respuesta de Geocoding (reverse).
class GoogleGeocodingModel {
  final String placeId;
  final String formattedAddress;
  final double latitude;
  final double longitude;
  final List<AddressComponent> addressComponents;

  const GoogleGeocodingModel({
    required this.placeId,
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
    this.addressComponents = const [],
  });

  /// Crea una instancia desde JSON de Geocoding.
  factory GoogleGeocodingModel.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] as Map<String, dynamic>? ?? {};
    final location = geometry['location'] as Map<String, dynamic>? ?? {};

    return GoogleGeocodingModel(
      placeId: json['place_id'] as String? ?? '',
      formattedAddress: json['formatted_address'] as String? ?? '',
      latitude: (location['lat'] as num?)?.toDouble() ?? 0.0,
      longitude: (location['lng'] as num?)?.toDouble() ?? 0.0,
      addressComponents: (json['address_components'] as List<dynamic>?)
              ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Obtiene el componente de dirección por tipo.
  String? getComponent(String type) {
    try {
      return addressComponents
          .firstWhere((c) => c.types.contains(type))
          .longName;
    } catch (_) {
      return null;
    }
  }

  /// Convierte a entidad PlaceSuggestion.
  PlaceSuggestion toEntity() {
    return PlaceSuggestion(
      id: placeId,
      displayName: formattedAddress,
      street: getComponent('route'),
      houseNumber: getComponent('street_number'),
      city: getComponent('locality') ?? getComponent('administrative_area_level_2'),
      state: getComponent('administrative_area_level_1'),
      country: getComponent('country'),
      latitude: latitude,
      longitude: longitude,
    );
  }
}
