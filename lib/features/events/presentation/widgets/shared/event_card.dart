// lib/features/events/presentation/widgets/event_card.dart
// Widget de tarjeta de evento para listado horizontal

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/event.dart';
import '../../providers/events_provider.dart';

/// Tarjeta de evento para el listado horizontal.
///
/// Muestra la imagen, título, fecha y ubicación del evento.
/// Tiene un ancho fijo para scroll horizontal.
class EventCard extends ConsumerWidget {
  final Event event;
  final VoidCallback? onTap;

  /// Ancho fijo de la tarjeta para scroll horizontal.
  static const double cardWidth = 180.0;

  /// Altura de la imagen.
  static const double imageHeight = 100.0;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendeeStatsAsync = ref.watch(attendeeStatsProvider(event.id));
    return RepaintBoundary(
      child: SizedBox(
        width: cardWidth,
        child: Card(
          clipBehavior: Clip.hardEdge, // Más rápido que antiAlias
          elevation: 2,
          shadowColor: AppColors.shadow,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Imagen del evento con badge de asistentes
              _buildImageWithBadge(context, attendeeStatsAsync),

              // Contenido
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Fecha
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormatter.formatRelativeDate(event.startDate),
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.onSurfaceVariant,
                                      ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Ubicación (si existe)
                      if (event.address != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.address!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.onSurfaceVariant,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildImageWithBadge(
      BuildContext context, AsyncValue<({int going, int interested})> attendeeStatsAsync) {
    return Stack(
      children: [
        // Imagen
        if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
          SizedBox(
            height: imageHeight,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: event.imageUrl!,
              fit: BoxFit.cover,
              memCacheWidth: (cardWidth * 2).toInt(),
              memCacheHeight: (imageHeight * 2).toInt(),
              placeholder: (context, url) => _buildPlaceholder(isLoading: true),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            ),
          )
        else
          _buildPlaceholder(),

        // Badge de asistentes e interesados
        attendeeStatsAsync.when(
          data: (stats) {
            final hasStats = stats.going > 0 || stats.interested > 0;
            if (!hasStats) return const SizedBox.shrink();

            return Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(180),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Asistentes (going)
                    if (stats.going > 0) ...[
                      Icon(
                        PhosphorIcons.users(PhosphorIconsStyle.fill),
                        size: 12,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${stats.going}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ],
                    // Separador si hay ambos
                    if (stats.going > 0 && stats.interested > 0)
                      const SizedBox(width: 6),
                    // Interesados
                    if (stats.interested > 0) ...[
                      Icon(
                        PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        size: 12,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${stats.interested}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      height: imageHeight,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
                size: 40,
                color: AppColors.onSurfaceVariant.withAlpha(128),
              ),
      ),
    );
  }
}
