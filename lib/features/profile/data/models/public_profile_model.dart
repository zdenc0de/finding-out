// lib/features/profile/data/models/public_profile_model.dart
// Modelo de datos para perfil público (serialización/deserialización)

import '../../domain/entities/public_profile.dart';

/// Modelo de datos para perfiles públicos con serialización JSON.
///
/// Se usa para convertir datos de la tabla `profiles` de Supabase
/// a entidades de dominio.
class PublicProfileModel {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  const PublicProfileModel({
    required this.id,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  /// Crea un PublicProfileModel desde un mapa JSON (Supabase).
  factory PublicProfileModel.fromJson(Map<String, dynamic> json) {
    return PublicProfileModel(
      id: json['id'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convierte el modelo a una entidad de dominio.
  PublicProfile toEntity() {
    return PublicProfile(
      id: id,
      displayName: displayName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
    );
  }
}
