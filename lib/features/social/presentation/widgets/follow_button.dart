// lib/features/social/presentation/widgets/follow_button.dart
// Widget reutilizable para seguir/dejar de seguir usuarios

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/social_provider.dart';

/// Botón para seguir/dejar de seguir a un usuario.
///
/// Muestra "Seguir" cuando no se sigue al usuario y
/// "Siguiendo" cuando ya se le sigue.
class FollowButton extends ConsumerWidget {
  final String userId;
  final bool expanded;

  const FollowButton({
    super.key,
    required this.userId,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followState = ref.watch(followNotifierProvider(userId));

    // Mostrar error si existe
    ref.listen(followNotifierProvider(userId), (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(followNotifierProvider(userId).notifier).clearError();
      }
    });

    if (followState.isFollowing) {
      return _buildFollowingButton(context, ref, followState);
    } else {
      return _buildFollowButton(context, ref, followState);
    }
  }

  Widget _buildFollowButton(
    BuildContext context,
    WidgetRef ref,
    FollowState followState,
  ) {
    return FilledButton.icon(
      onPressed: followState.isLoading
          ? null
          : () => ref.read(followNotifierProvider(userId).notifier).toggleFollow(),
      icon: followState.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(PhosphorIcons.userPlus(), size: 18),
      label: const Text('Seguir'),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: expanded ? const Size(double.infinity, 44) : null,
        padding: expanded
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildFollowingButton(
    BuildContext context,
    WidgetRef ref,
    FollowState followState,
  ) {
    return OutlinedButton.icon(
      onPressed: followState.isLoading
          ? null
          : () => ref.read(followNotifierProvider(userId).notifier).toggleFollow(),
      icon: followState.isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : Icon(PhosphorIcons.userCheck(), size: 18),
      label: const Text('Siguiendo'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        minimumSize: expanded ? const Size(double.infinity, 44) : null,
        padding: expanded
            ? const EdgeInsets.symmetric(horizontal: 24, vertical: 12)
            : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}

/// Widget que muestra las estadísticas de seguidores/siguiendo.
class FollowStatsRow extends ConsumerWidget {
  final String userId;

  const FollowStatsRow({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(followStatsProvider(userId));

    return statsAsync.when(
      loading: () => _buildStatsRow(context, '-', '-'),
      error: (_, __) => _buildStatsRow(context, '0', '0'),
      data: (stats) => _buildStatsRow(
        context,
        '${stats.followersCount}',
        '${stats.followingCount}',
      ),
    );
  }

  Widget _buildStatsRow(
    BuildContext context,
    String followers,
    String following,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStatItem(context, followers, 'Seguidores'),
        const SizedBox(width: 32),
        _buildStatItem(context, following, 'Siguiendo'),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
