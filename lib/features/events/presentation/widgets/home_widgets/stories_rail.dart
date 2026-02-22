// lib/features/events/presentation/widgets/home_widgets/stories_rail.dart
// Rail horizontal de stories / eventos en vivo ("Happening Now").

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../core/theme/app_colors.dart';

/// Rail horizontal que muestra stories de eventos en vivo.
///
/// Actualmente usa datos de ejemplo con imágenes locales.
/// Conectar a un proveedor real (ej. un Riverpod provider)
/// para mostrar eventos en vivo reales.
class StoriesRail extends StatelessWidget {
  const StoriesRail({super.key});

  @override
  Widget build(BuildContext context) {
    // Datos de ejemplo — reemplazar con datos reales de un provider
    final stories = [
      const _StoryData(name: 'Go Live', isLive: false, assetPath: null, isAction: true),
      const _StoryData(name: 'Beach Party', isLive: true, assetPath: 'assets/images/stories/story_beach_party.png'),
      const _StoryData(name: 'Food Fest', isLive: true, assetPath: 'assets/images/stories/story_food_fest.png'),
      const _StoryData(name: 'Gallery', isLive: true, assetPath: 'assets/images/stories/story_art_gallery.png'),
      const _StoryData(name: 'Comedy', isLive: true, assetPath: 'assets/images/stories/story_comedy_show.png'),
      const _StoryData(name: 'Más', isLive: false, assetPath: 'assets/images/stories/story_more_events.png'),
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
          child: story.assetPath != null
              ? Image.asset(
                  story.assetPath!,
                  fit: BoxFit.cover,
                  width: 60,
                  height: 60,
                  errorBuilder: (context, error, stackTrace) => Container(
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
  final String? assetPath;
  final bool isAction;

  const _StoryData({
    required this.name,
    required this.isLive,
    this.assetPath,
    this.isAction = false,
  });
}

