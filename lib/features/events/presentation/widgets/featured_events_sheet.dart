// lib/features/events/presentation/widgets/featured_events_sheet.dart
// Panel inferior con eventos destacados y botón Top 10

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/featured_event.dart';
import '../providers/featured_events_provider.dart';
import '../screens/top10_events_screen.dart';

/// Panel inferior con carrusel de eventos destacados.
///
/// Muestra los 5 eventos más relevantes basados en fecha y asistentes.
/// Incluye botón "Top 10" para ver la lista completa.
class FeaturedEventsSheet extends ConsumerWidget {
  /// Callback cuando se selecciona un evento (para centrar el mapa).
  final void Function(FeaturedEvent event)? onEventTap;

  const FeaturedEventsSheet({
    super.key,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredState = ref.watch(featuredEventsNotifierProvider);

    if (featuredState.isLoading) {
      return _buildContainer(
        context,
        child: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (featuredState.events.isEmpty) {
      return _buildContainer(
        context,
        showHeader: false,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                PhosphorIcons.mapPinLine(),
                color: AppColors.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'No hay eventos destacados en tu zona',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final topFive = featuredState.topFive;

    return _buildContainer(
      context,
      showHeader: true,
      onTop10Tap: () => _showTop10(context),
      child: SizedBox(
        height: 140,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: topFive.length,
          itemBuilder: (context, index) {
            final featured = topFive[index];
            return _FeaturedEventCard(
              featured: featured,
              onTap: () => onEventTap?.call(featured),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContainer(
    BuildContext context, {
    required Widget child,
    bool showHeader = true,
    VoidCallback? onTop10Tap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(50),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header con título y botón Top 10
          if (showHeader)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 12),
              child: Row(
                children: [
                  Icon(
                    PhosphorIcons.fire(PhosphorIconsStyle.fill),
                    color: AppColors.tertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Eventos destacados',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  TextButton(
                    onPressed: onTop10Tap,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Top 10',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          PhosphorIcons.arrowRight(),
                          color: AppColors.primary,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          child,

          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  void _showTop10(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const Top10EventsScreen(),
      ),
    );
  }
}

/// Tarjeta compacta de evento destacado para el carrusel.
class _FeaturedEventCard extends StatelessWidget {
  final FeaturedEvent featured;
  final VoidCallback? onTap;

  const _FeaturedEventCard({
    required this.featured,
    this.onTap,
  });

  Color get _categoryColor {
    try {
      return Color(
          int.parse(featured.category.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = featured.event;

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outline.withAlpha(128),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen y badge de categoría
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 70,
                        width: double.infinity,
                        child:
                            event.imageUrl != null && event.imageUrl!.isNotEmpty
                                ? Image.network(
                                    event.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _buildImagePlaceholder(),
                                  )
                                : _buildImagePlaceholder(),
                      ),
                      // Badge de categoría
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _categoryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            featured.category.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Información
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Título
                        Text(
                          event.title,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        // Fecha y asistentes
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.calendar(),
                              size: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                DateFormatter.formatShortDate(event.startDate),
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
                            Icon(
                              PhosphorIcons.users(),
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${featured.attendeeCount}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.surfaceContainerHighest,
      child: Center(
        child: Icon(
          PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
          size: 28,
          color: AppColors.onSurfaceVariant.withAlpha(128),
        ),
      ),
    );
  }
}
