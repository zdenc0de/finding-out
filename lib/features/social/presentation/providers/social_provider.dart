// lib/features/social/presentation/providers/social_provider.dart
// Providers de Riverpod para funcionalidad social (seguir usuarios)

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../profile/domain/entities/public_profile.dart';
import '../../data/repositories/social_repository_impl.dart';
import '../../domain/entities/follow_stats.dart';
import '../../domain/repositories/social_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REPOSITORIO
// ─────────────────────────────────────────────────────────────────────────────

/// Provider del repositorio social.
final socialRepositoryProvider = Provider<SocialRepository>((ref) {
  return SocialRepositoryImpl(SupabaseConfig.client);
});

// ─────────────────────────────────────────────────────────────────────────────
// ESTADO DE FOLLOW
// ─────────────────────────────────────────────────────────────────────────────

/// Estado para el botón de seguir.
class FollowState {
  final bool isFollowing;
  final bool isLoading;
  final String? errorMessage;

  const FollowState({
    this.isFollowing = false,
    this.isLoading = false,
    this.errorMessage,
  });

  FollowState copyWith({
    bool? isFollowing,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FollowState(
      isFollowing: isFollowing ?? this.isFollowing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para gestionar follow/unfollow.
class FollowNotifier extends StateNotifier<FollowState> {
  final SocialRepository _repository;
  final String _userId;
  final Ref _ref;

  FollowNotifier(this._repository, this._userId, this._ref)
      : super(const FollowState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    try {
      final isFollowing = await _repository.isFollowing(_userId);
      state = FollowState(isFollowing: isFollowing);
    } catch (e) {
      state = const FollowState();
    }
  }

  Future<void> toggleFollow() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      if (state.isFollowing) {
        await _repository.unfollowUser(_userId);
        state = const FollowState(isFollowing: false);
      } else {
        await _repository.followUser(_userId);
        state = const FollowState(isFollowing: true);
      }
      // Invalidar stats del usuario para refrescar conteos
      _ref.invalidate(followStatsProvider(_userId));
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al actualizar seguimiento',
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider family para el estado de follow de cada usuario.
final followNotifierProvider =
    StateNotifierProvider.family<FollowNotifier, FollowState, String>(
        (ref, userId) {
  final repository = ref.watch(socialRepositoryProvider);
  return FollowNotifier(repository, userId, ref);
});

// ─────────────────────────────────────────────────────────────────────────────
// PROVIDERS DE LECTURA
// ─────────────────────────────────────────────────────────────────────────────

/// Provider para verificar si se sigue a un usuario.
///
/// Uso: `ref.watch(isFollowingProvider(userId))`
final isFollowingProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.isFollowing(userId);
});

/// Provider para estadísticas de follow de un usuario.
///
/// Uso: `ref.watch(followStatsProvider(userId))`
final followStatsProvider =
    FutureProvider.family<FollowStats, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowStats(userId);
});

/// Provider para lista de seguidores de un usuario.
///
/// Uso: `ref.watch(followersListProvider(userId))`
final followersListProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowers(userId);
});

/// Provider para lista de usuarios que sigue.
///
/// Uso: `ref.watch(followingListProvider(userId))`
final followingListProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, userId) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowing(userId);
});

/// Provider para IDs de usuarios que sigue el usuario actual.
///
/// Útil para verificar rápidamente si "mis amigos" van a un evento.
final followingIdsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(socialRepositoryProvider);
  return repository.getFollowingIds();
});
