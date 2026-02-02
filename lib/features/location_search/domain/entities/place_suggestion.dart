// lib/features/location_search/domain/entities/place_suggestion.dart
// Entidad que representa una sugerencia de lugar

/// Representa una sugerencia de lugar del autocompletado.
class PlaceSuggestion {
  final String id;
  final String displayName;
  final String? street;
  final String? houseNumber;
  final String? city;
  final String? state;
  final String? country;
  final double latitude;
  final double longitude;

  const PlaceSuggestion({
    required this.id,
    required this.displayName,
    this.street,
    this.houseNumber,
    this.city,
    this.state,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Genera una dirección formateada para mostrar.
  String get formattedAddress {
    final parts = <String>[];

    if (street != null && street!.isNotEmpty) {
      final streetPart = houseNumber != null && houseNumber!.isNotEmpty
          ? '$street $houseNumber'
          : street!;
      parts.add(streetPart);
    }

    if (city != null && city!.isNotEmpty) {
      parts.add(city!);
    }

    if (state != null && state!.isNotEmpty) {
      parts.add(state!);
    }

    return parts.isEmpty ? displayName : parts.join(', ');
  }

  @override
  String toString() => 'PlaceSuggestion(id: $id, displayName: $displayName)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlaceSuggestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
