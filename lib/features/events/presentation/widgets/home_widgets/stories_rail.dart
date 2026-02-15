// lib/features/events/presentation/widgets/home_widgets/stories_rail.dart
// Rail horizontal de stories / eventos en vivo ("Happening Now").

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../core/theme/app_colors.dart';

/// Rail horizontal que muestra stories de eventos en vivo.
///
/// Actualmente usa datos de ejemplo. Conectar a un proveedor
/// real (ej. un Riverpod provider) para mostrar eventos en vivo reales.
class StoriesRail extends StatelessWidget {
  const StoriesRail({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo — reemplazar con datos reales de un provider
    final stories = [
      const _StoryData(name: 'Go Live', isLive: false, imageUrl: null, isAction: true),
      const _StoryData(name: 'Beach Part...', isLive: true, imageUrl: 'https://images.unsplash.com/photo-1544498565-5c128522e84d?w=150'),
      const _StoryData(name: 'Food Fest', isLive: true, imageUrl: 'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=150'),
      const _StoryData(name: 'Gallery', isLive: true, imageUrl: 'https://images.unsplash.com/photo-1460661618165-24d85830b802?w=150'),
      const _StoryData(name: 'Comedy', isLive: true, imageUrl: 'https://images.unsplash.com/photo-1520263115673-611416db79d4?w=150'),
      const _StoryData(name: 'More', isLive: false, imageUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'En vivo ahora',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              final story = stories[index];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Column(
                  children: [
                    _buildAvatar(context, story),
                    const SizedBox(height: 6),
                    Text(
                      story.name,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Construye el avatar circular para cada story.
  Widget _buildAvatar(BuildContext context, _StoryData story) {
    // Caso especial: botón de acción "Go Live"
    if (story.isAction) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.outline, width: 2),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.camera(), size: 24, color: AppColors.primary),
              const Icon(Icons.add, size: 12, color: AppColors.primary),
            ],
          ),
        ),
      );
    }

    // Avatar con borde en degradado si está en vivo
    return Container(
      width: 68,
      height: 68,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: story.isLive
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.tertiary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: story.isLive ? null : Colors.transparent,
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surface,
        ),
        padding: const EdgeInsets.all(2),
        child: ClipOval(
          child: story.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: story.imageUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceVariant,
                    child: Icon(PhosphorIcons.user(), size: 24, color: AppColors.onSurfaceVariant),
                  ),
                )
              : Container(
                  color: AppColors.surfaceVariant,
                  child: Icon(PhosphorIcons.user(), size: 24, color: AppColors.onSurfaceVariant),
                ),
        ),
      ),
    );
  }
}

/// Modelo de datos tipado para cada story.
///
/// Reemplaza el uso de Map<String, dynamic> sin tipado.
class _StoryData {
  final String name;
  final bool isLive;
  final String? imageUrl;
  final bool isAction;

  const _StoryData({
    required this.name,
    required this.isLive,
    this.imageUrl,
    this.isAction = false,
  });
}
