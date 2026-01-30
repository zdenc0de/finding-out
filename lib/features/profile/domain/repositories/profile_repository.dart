// lib/features/profile/domain/repositories/profile_repository.dart
// Contrato/interfaz del repositorio de perfil

import '../entities/public_profile.dart';

/// Contrato para operaciones de perfil de usuario.
abstract class ProfileRepository {
  /// Obtiene el perfil público de un usuario por su ID.
  ///
  /// Retorna `null` si el usuario no existe.
  Future<PublicProfile?> getProfileById(String userId);

  /// Busca perfiles por nombre de usuario.
  ///
  /// Retorna una lista vacía si no hay coincidencias.
  Future<List<PublicProfile>> searchProfiles(String query);
}
