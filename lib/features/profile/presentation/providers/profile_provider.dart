// lib/features/profile/presentation/providers/profile_provider.dart
// Provider de Riverpod para gestión de perfil

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';

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
  // Escuchar cambios en eventos para refrescar stats
  ref.watch(eventsNotifierProvider);

  final authState = ref.watch(authNotifierProvider);
  final user = authState.user;

  if (user == null) {
    return const UserStats();
  }

  final repository = ref.read(eventRepositoryProvider);

  try {
    final eventsCreated = await repository.getUserEventsCount(user.id);

    return UserStats(
      eventsCreated: eventsCreated,
      // TODO: Implementar cuando existan estas funcionalidades
      eventsAttended: 0,
      favoritePlaces: 0,
    );
  } catch (e) {
    return const UserStats();
  }
});
