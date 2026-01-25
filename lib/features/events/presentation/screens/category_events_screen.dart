// lib/features/events/presentation/screens/category_events_screen.dart
// Pantalla que muestra todos los eventos de una categoría

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';

/// Pantalla que muestra todos los eventos de una categoría específica.
///
/// Accesible desde el botón "Ver todos" en cada sección de categoría
/// del home. Muestra una lista vertical completa de todos los eventos.
class CategoryEventsScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryEventsScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsNotifierProvider);

    // Buscar la categoría y sus eventos
    Category? category;
    List<Event> events = [];

    for (final entry in eventsState.eventsByCategory.entries) {
      if (entry.key.id == categoryId) {
        category = entry.key;
        events = entry.value;
        break;
      }
    }

    // Si no se encuentra la categoría, mostrar error
    if (category == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(PhosphorIcons.arrowLeft()),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                PhosphorIcons.warning(PhosphorIconsStyle.duotone),
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Categoría no encontrada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Volver'),
              ),
            ],
          ),
        ),
      );
    }

    final categoryColor = _parseColor(category.color);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryColor.withAlpha(26),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                _getIconData(category.icon),
                color: categoryColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(category.name),
          ],
        ),
        centerTitle: true,
      ),
      body: events.isEmpty
          ? _buildEmptyState(context, category)
          : RefreshIndicator(
              onRefresh: () async {
                await ref.read(eventsNotifierProvider.notifier).refresh();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index < events.length - 1 ? 16 : 0,
                    ),
                    child: _EventListTile(
                      event: event,
                      categoryColor: categoryColor,
                      onTap: () => context.push('/events/${event.id}'),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, Category category) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.calendarX(PhosphorIconsStyle.duotone),
              size: 80,
              color: AppColors.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay eventos en ${category.name}',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde para descubrir nuevos eventos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
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

/// Tile de evento para listado vertical.
///
/// Versión más horizontal del EventCard, optimizada para
/// mostrar en una lista vertical con más información visible.
class _EventListTile extends StatelessWidget {
  final Event event;
  final Color categoryColor;
  final VoidCallback? onTap;

  const _EventListTile({
    required this.event,
    required this.categoryColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen del evento
            _buildImage(),

            // Contenido
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Fecha
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendar(),
                          size: 16,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            DateFormatter.formatRelativeDate(event.startDate),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                        ),
                      ],
                    ),

                    // Ubicación (si existe)
                    if (event.address != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.mapPin(),
                            size: 16,
                            color: categoryColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.address!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // Descripción breve (si existe)
                    if (event.description != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    const imageSize = 120.0;

    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      return SizedBox(
        width: imageSize,
        height: imageSize,
        child: CachedNetworkImage(
          imageUrl: event.imageUrl!,
          fit: BoxFit.cover,
          memCacheWidth: (imageSize * 2).toInt(),
          memCacheHeight: (imageSize * 2).toInt(),
          placeholder: (context, url) => _buildPlaceholder(isLoading: true),
          errorWidget: (context, url, error) => _buildPlaceholder(),
        ),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    return Container(
      width: 120,
      height: 120,
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
