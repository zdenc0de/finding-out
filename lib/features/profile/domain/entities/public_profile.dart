// lib/features/profile/domain/entities/public_profile.dart
// Entidad de dominio para perfil público de usuario

/// Representa el perfil público de un usuario.
///
/// A diferencia de [AppUser], esta entidad solo contiene
/// información pública visible para otros usuarios.
class PublicProfile {
  final String id;
  final String? displayName;
  final String? avatarUrl;
  final DateTime createdAt;

  const PublicProfile({
    required this.id,
    this.displayName,
    this.avatarUrl,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PublicProfile && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'PublicProfile(id: $id, displayName: $displayName)';
  }
}
