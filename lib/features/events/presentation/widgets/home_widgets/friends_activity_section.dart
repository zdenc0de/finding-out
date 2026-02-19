// lib/features/events/presentation/widgets/home_widgets/friends_activity_section.dart
// Sección de actividad social — "Tus amigos van a..."

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../providers/events_provider.dart';

/// Tarjeta de prueba social que muestra actividad real de amigos.
class FriendsActivitySection extends ConsumerWidget {
  const FriendsActivitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(friendsActivityProvider);

    return activityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (activities) {
        if (activities.isEmpty) return const SizedBox.shrink();

        // Tomamos la actividad más próxima
        final activity = activities.first;
        final friends = activity.friends;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              // Pila de avatares (máximo 3)
              SizedBox(
                width: _calculateStackWidth(friends.length),
                height: 36,
                child: Stack(
                  children: List.generate(
                    friends.length > 3 ? 3 : friends.length,
                    (index) => _buildAvatar(
                      friends[index].avatarUrl,
                      index * 16.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Texto descriptivo
              Expanded(
                child: RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onBackground,
                        ),
                    children: [
                      TextSpan(
                        text: friends.first.displayName ?? 'Un amigo',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: friends.length == 1
                            ? ' va a '
                            : ' y ${friends.length - 1} amigos van a ',
                      ),
                      TextSpan(
                        text: activity.event.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Botón "Ver"
              TextButton(
                onPressed: () => context.push('/events/${activity.event.id}'),
                child: const Text('Ver'),
              ),
            ],
          ),
        );
      },
    );
  }

  double _calculateStackWidth(int count) {
    if (count == 0) return 0;
    if (count == 1) return 36;
    if (count == 2) return 52;
    return 68; // Para 3 o más
  }

  /// Construye un avatar circular posicionado en la pila.
  Widget _buildAvatar(String? url, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surfaceVariant, width: 2),
        ),
        child: ClipOval(
          child: url != null
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.outlineVariant),
                  errorWidget: (context, url, error) => _buildPlaceholder(),
                )
              : _buildPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.outlineVariant,
      child: const Icon(Icons.person, size: 18, color: AppColors.onSurfaceVariant),
    );
  }
}
