// lib/features/events/presentation/widgets/category_section.dart
// Widget de sección de categoría con listado horizontal de eventos

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/entities/event.dart';
import 'event_card.dart';

/// Sección de categoría con header y listado horizontal de eventos.
///
/// Muestra el icono y nombre de la categoría, botón "Ver todos",
/// y un ListView horizontal de EventCards.
class CategorySection extends StatelessWidget {
  final Category category;
  final List<Event> events;
  final VoidCallback? onSeeAllTap;
  final void Function(Event event)? onEventTap;

  /// Altura del listado horizontal.
  static const double listHeight = 220.0;

  const CategorySection({
    super.key,
    required this.category,
    required this.events,
    this.onSeeAllTap,
    this.onEventTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de la categoría
        _buildHeader(context),
        const SizedBox(height: 12),

        // Listado horizontal de eventos
        if (events.isEmpty)
          _buildEmptyState(context)
        else
          _buildEventsList(),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final categoryColor = _parseColor(category.color);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Icono de la categoría
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: categoryColor.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconData(category.icon),
              color: categoryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Nombre de la categoría
          Expanded(
            child: Text(
              category.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Botón "Ver todos"
          if (events.isNotEmpty)
            TextButton(
              onPressed: onSeeAllTap,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Ver todos',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    PhosphorIcons.caretRight(),
                    size: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEventsList() {
    return SizedBox(
      height: listHeight,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: events.length,
        cacheExtent: 500, // Pre-renderiza ~2-3 tarjetas extra
        physics: const BouncingScrollPhysics(
          decelerationRate: ScrollDecelerationRate.fast,
        ),
        itemBuilder: (context, index) {
          final event = events[index];
          return Padding(
            padding: EdgeInsets.only(
              right: index < events.length - 1 ? 12 : 0,
            ),
            child: EventCard(
              event: event,
              onTap: onEventTap != null ? () => onEventTap!(event) : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'No hay eventos en esta categoría',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      ),
    );
  }

  /// Convierte un color hex string a Color.
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  /// Obtiene el IconData a partir del nombre del icono.
  PhosphorIconData _getIconData(String iconName) {
    final iconMap = {
      'music_note': PhosphorIcons.musicNotes(),
      'sports_soccer': PhosphorIcons.soccerBall(),
      'storefront': PhosphorIcons.storefront(),
      'computer': PhosphorIcons.laptop(),
      'palette': PhosphorIcons.palette(),
      'local_activity': PhosphorIcons.ticket(),
      'restaurant': PhosphorIcons.forkKnife(),
      'movie': PhosphorIcons.filmSlate(),
      'school': PhosphorIcons.graduationCap(),
      'fitness_center': PhosphorIcons.barbell(),
    };

    return iconMap[iconName] ?? PhosphorIcons.calendarBlank();
  }
}
