// lib/features/events/presentation/widgets/shared/search_event_tile.dart
// Widget de resultado de búsqueda de eventos (estilo lista vertical)

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/date_formatter.dart';
import '../../../domain/entities/event.dart';

/// Tile de resultado de búsqueda para un evento.
///
/// A diferencia del [EventCard] (horizontal), este widget está diseñado
/// para mostrarse en una lista vertical de resultados de búsqueda.
class SearchEventTile extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;

  const SearchEventTile({
    super.key,
    required this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Imagen thumbnail
            _buildThumbnail(),
            const SizedBox(width: 14),

            // Información del evento
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Fecha
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                        size: 13,
                        color: AppColors.primary,
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

                  // Dirección (si existe)
                  if (event.address != null && event.address!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          size: 13,
                          color: AppColors.primary,
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

            // Flecha de navegación
            Icon(
              PhosphorIcons.caretRight(),
              size: 18,
              color: AppColors.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el thumbnail circular de la imagen del evento.
  Widget _buildThumbnail() {
    const double size = 56;

    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: CachedNetworkImage(
            imageUrl: event.imageUrl!,
            fit: BoxFit.cover,
            memCacheWidth: (size * 2).toInt(),
            memCacheHeight: (size * 2).toInt(),
            placeholder: (_, __) => _buildPlaceholder(size),
            errorWidget: (_, __, ___) => _buildPlaceholder(size),
          ),
        ),
      );
    }

    return _buildPlaceholder(size);
  }

  /// Placeholder cuando no hay imagen disponible.
  Widget _buildPlaceholder(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
        size: 24,
        color: AppColors.onSurfaceVariant.withAlpha(128),
      ),
    );
  }
}
