// lib/features/profile/presentation/providers/profile_provider.dart
// Provider de Riverpod para gestión de perfil

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/public_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Estadísticas del usuario.
class UserStats {
  final int eventsCreated;
  final int eventsAttended;
  final int favoritePlaces;

  const UserStats({
    this.eventsCreated = 0,
    this.eventsAttended = 0,
    this.favoritePlaces = 0,
  });
}

/// Provider de estadísticas del usuario.
///
/// Obtiene el conteo de eventos creados por el usuario actual.
/// Se invalida automáticamente cuando cambia el estado de eventos.
final userStatsProvider = FutureProvider<UserStats>((ref) async {
  // Escuchar cambios en eventos y asistencia para refrescar stats
  ref.watch(eventsNotifierProvider);
  ref.watch(myUpcomingEventsProvider);

  final authState = ref.watch(authNotifierProvider);
  final user = authState.user;

  if (user == null) {
    return const UserStats();
  }

  final repository = ref.read(eventRepositoryProvider);

  try {
    final results = await Future.wait([
      repository.getUserEventsCount(user.id),
      repository.getUserAttendedEventsCount(user.id),
    ]);

    return UserStats(
      eventsCreated: results[0],
      eventsAttended: results[1],
      favoritePlaces: 0,
    );
  } catch (e) {
    return const UserStats();
  }
});

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS PARA PERFILES PÚBLICOS
// ─────────────────────────────────────────────────────────────────────────────

/// Provider del repositorio de perfiles.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(SupabaseConfig.client);
});

/// Provider para obtener el perfil público de un usuario por ID.
///
/// Uso: `ref.watch(publicProfileByIdProvider(userId))`
final publicProfileByIdProvider =
    FutureProvider.family<PublicProfile?, String>((ref, userId) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.getProfileById(userId);
});

/// Provider para buscar perfiles por nombre.
///
/// Uso: `ref.watch(searchProfilesProvider(query))`
final searchProfilesProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, query) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.searchProfiles(query);
});

/// Provider de estadísticas de un usuario por ID.
///
/// Similar a [userStatsProvider] pero para otros usuarios.
final userStatsByIdProvider =
    FutureProvider.family<UserStats, String>((ref, userId) async {
  final eventRepository = ref.read(eventRepositoryProvider);

  try {
    final results = await Future.wait([
      eventRepository.getUserEventsCount(userId),
      eventRepository.getUserAttendedEventsCount(userId),
    ]);

    return UserStats(
      eventsCreated: results[0],
      eventsAttended: results[1],
      favoritePlaces: 0,
    );
  } catch (e) {
    return const UserStats();
  }
});
