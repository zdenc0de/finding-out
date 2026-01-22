// lib/features/events/data/models/event_model.dart
// Modelo de datos para eventos (serialización/deserialización)

import '../../domain/entities/event.dart';

/// Modelo de datos para eventos con serialización JSON.
///
/// Se usa para convertir datos de Supabase a entidades de dominio.
class EventModel {
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

  const EventModel({
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

  /// Crea un EventModel desde un mapa JSON (Supabase).
  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String,
      imageUrl: json['image_url'] as String?,
      locationLat: (json['location_lat'] as num?)?.toDouble(),
      locationLng: (json['location_lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el modelo a JSON para enviar a Supabase.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'image_url': imageUrl,
      'location_lat': locationLat,
      'location_lng': locationLng,
      'address': address,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Convierte el modelo a una entidad de dominio.
  Event toEntity() {
    return Event(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      imageUrl: imageUrl,
      locationLat: locationLat,
      locationLng: locationLng,
      address: address,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy,
      createdAt: createdAt,
    );
  }
}
