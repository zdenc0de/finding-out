// lib/features/events/domain/entities/event.dart
// Entidad de dominio para eventos

/// Representa un evento en el dominio.
///
/// Los eventos son las unidades principales de contenido de la app,
/// con información de ubicación, fecha y categoría.
class Event {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final String? imageUrl;
  final double? locationLat;
  final double? locationLng;
  final String? address;
  final DateTime startDate;
  final DateTime? endDate;
  final String? createdBy;
  final DateTime createdAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    this.imageUrl,
    this.locationLat,
    this.locationLng,
    this.address,
    required this.startDate,
    this.endDate,
    this.createdBy,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Event && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
