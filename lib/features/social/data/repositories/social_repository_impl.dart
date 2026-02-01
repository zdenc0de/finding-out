// lib/features/social/data/repositories/social_repository_impl.dart
// Implementación del repositorio social usando Supabase

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../profile/data/models/public_profile_model.dart';
import '../../../profile/domain/entities/public_profile.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/repositories/social_repository.dart';
import '../models/follow_relation_model.dart';

class SocialRepositoryImpl implements SocialRepository {
  final SupabaseClient _client;

  SocialRepositoryImpl(this._client);

  String? get _currentUserId => _client.auth.currentUser?.id;

  @override
  Future<void> followUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }
    if (currentUserId == userId) {
      throw Exception('No puedes seguirte a ti mismo');
    }

    await _client.from('followers').insert(
      FollowRelationModel.toJsonForCreate(
        followerId: currentUserId,
        followingId: userId,
      ),
    );
  }

  @override
  Future<void> unfollowUser(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) {
      throw Exception('Usuario no autenticado');
    }

    await _client
        .from('followers')
        .delete()
        .eq('follower_id', currentUserId)
        .eq('following_id', userId);
  }

  @override
  Future<bool> isFollowing(String userId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return false;

    try {
      final response = await _client
          .from('followers')
          .select('id')
          .eq('follower_id', currentUserId)
          .eq('following_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<FollowStats> getFollowStats(String userId) async {
    try {
      // Contar seguidores (cuántos siguen a este usuario)
      final followersResponse = await _client
          .from('followers')
          .select()
          .eq('following_id', userId);
      final followersCount = (followersResponse as List<dynamic>).length;

      // Contar siguiendo (a cuántos sigue este usuario)
      final followingResponse = await _client
          .from('followers')
          .select()
          .eq('follower_id', userId);
      final followingCount = (followingResponse as List<dynamic>).length;

      return FollowStats(
        followersCount: followersCount,
        followingCount: followingCount,
      );
    } catch (e) {
      return const FollowStats();
    }
  }

  @override
  Future<List<PublicProfile>> getFollowers(String userId) async {
    try {
      // Obtener IDs de seguidores
      final response = await _client
          .from('followers')
          .select('follower_id')
          .eq('following_id', userId);

      final followerIds = (response as List<dynamic>)
          .map((item) => item['follower_id'] as String)
          .toList();

      if (followerIds.isEmpty) return [];

      // Obtener perfiles de los seguidores
      final profilesResponse = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .inFilter('id', followerIds);

      return (profilesResponse as List<dynamic>)
          .map((json) => PublicProfileModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<PublicProfile>> getFollowing(String userId) async {
    try {
      // Obtener IDs de usuarios que sigue
      final response = await _client
          .from('followers')
          .select('following_id')
          .eq('follower_id', userId);

      final followingIds = (response as List<dynamic>)
          .map((item) => item['following_id'] as String)
          .toList();

      if (followingIds.isEmpty) return [];

      // Obtener perfiles de los seguidos
      final profilesResponse = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .inFilter('id', followingIds);

      return (profilesResponse as List<dynamic>)
          .map((json) => PublicProfileModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<String>> getFollowingIds() async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) return [];

    try {
      final response = await _client
          .from('followers')
          .select('following_id')
          .eq('follower_id', currentUserId);

      return (response as List<dynamic>)
          .map((item) => item['following_id'] as String)
          .toList();
    } catch (e) {
      return [];
    }
  }
}
