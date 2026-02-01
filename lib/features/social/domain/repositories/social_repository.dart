// lib/features/social/domain/repositories/social_repository.dart
// Interface abstracta del repositorio de funciones sociales

import '../../../profile/domain/entities/public_profile.dart';
import '../entities/follow_stats.dart';

abstract class SocialRepository {
  /// Sigue a un usuario
  Future<void> followUser(String userId);

  /// Deja de seguir a un usuario
  Future<void> unfollowUser(String userId);

  /// Verifica si el usuario actual sigue a otro usuario
  Future<bool> isFollowing(String userId);

  /// Obtiene las estadísticas de seguidores de un usuario
  Future<FollowStats> getFollowStats(String userId);

  /// Obtiene la lista de seguidores de un usuario
  Future<List<PublicProfile>> getFollowers(String userId);

  /// Obtiene la lista de usuarios que sigue un usuario
  Future<List<PublicProfile>> getFollowing(String userId);

  /// Obtiene los IDs de usuarios que sigue el usuario actual
  Future<List<String>> getFollowingIds();
}
