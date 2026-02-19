// lib/features/profile/data/repositories/profile_repository_impl.dart
// Implementación del repositorio de perfil

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/public_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../models/public_profile_model.dart';

/// Implementación del repositorio de perfiles usando Supabase.
class ProfileRepositoryImpl implements ProfileRepository {
  final SupabaseClient _client;

  ProfileRepositoryImpl(this._client);

  @override
  Future<PublicProfile?> getProfileById(String userId) async {
    try {
      final response = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .eq('id', userId)
          .maybeSingle();

      if (response == null) return null;
      return PublicProfileModel.fromJson(response).toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<PublicProfile>> searchProfiles(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    try {
      final response = await _client
          .from('profiles')
          .select('id, display_name, avatar_url, created_at')
          .ilike('display_name', '%$trimmedQuery%')
          .order('display_name')
          .limit(20);

      return (response as List<dynamic>)
          .map((json) => PublicProfileModel.fromJson(json as Map<String, dynamic>))
          .map((model) => model.toEntity())
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<PublicProfile> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      throw Exception('No hay usuario autenticado');
    }

    // 1. Actualizar metadata de auth
    final Map<String, dynamic> data = {};
    if (displayName != null) data['display_name'] = displayName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    if (data.isNotEmpty) {
      await _client.auth.updateUser(UserAttributes(data: data));
    }

    // 2. Retornar el perfil actualizado (Supabase trigger suele sincronizar auth.users -> public.profiles)
    final profile = await getProfileById(currentUser.id);
    if (profile == null) {
      throw Exception('Error al recuperar el perfil actualizado');
    }

    return profile;
  }
}
