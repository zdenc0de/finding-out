// lib/features/events/presentation/screens/top10_events_screen.dart
// Pantalla modal con los 10 eventos más destacados

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/featured_event.dart';
import '../providers/featured_events_provider.dart';

/// Pantalla que muestra los 10 eventos más destacados.
///
/// Se abre desde el botón "Top 10" del panel de eventos destacados.
class Top10EventsScreen extends ConsumerWidget {
  const Top10EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredState = ref.watch(featuredEventsNotifierProvider);
    final topTen = featuredState.topTen;
    final radius = ref.watch(searchRadiusProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.trophy(PhosphorIconsStyle.fill),
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text('Top 10 Eventos'),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Header con info del radio
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: AppColors.primaryContainer,
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Eventos más relevantes en un radio de ${radius.toInt()} km',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de eventos
          Expanded(
            child: topTen.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          PhosphorIcons.mapPinLine(),
                          size: 64,
                          color: AppColors.onSurfaceVariant.withAlpha(128),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No hay eventos destacados',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Intenta aumentar el radio de búsqueda',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: topTen.length,
                    itemBuilder: (context, index) {
                      return _Top10EventCard(
                        featured: topTen[index],
                        rank: index + 1,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Tarjeta de evento para la lista Top 10.
class _Top10EventCard extends StatelessWidget {
  final FeaturedEvent featured;
  final int rank;

  const _Top10EventCard({
    required this.featured,
    required this.rank,
  });

  Color get _categoryColor {
    try {
      return Color(
          int.parse(featured.category.color.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  Color get _rankColor {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700); // Oro
      case 2:
        return const Color(0xFFC0C0C0); // Plata
      case 3:
        return const Color(0xFFCD7F32); // Bronce
      default:
        return AppColors.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = featured.event;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: rank <= 3 ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: rank <= 3
            ? BorderSide(color: _rankColor.withAlpha(128), width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => context.push('/events/${event.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Ranking
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: rank <= 3
                      ? _rankColor.withAlpha(30)
                      : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                  border: rank <= 3
                      ? Border.all(color: _rankColor, width: 2)
                      : null,
                ),
                child: Center(
                  child: rank <= 3
                      ? Icon(
                          PhosphorIcons.trophy(PhosphorIconsStyle.fill),
                          color: _rankColor,
                          size: 20,
                        )
                      : Text(
                          '$rank',
                          style: const TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 60,
                  height: 60,
                  child: event.imageUrl != null && event.imageUrl!.isNotEmpty
                      ? Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildPlaceholder(),
                        )
                      : _buildPlaceholder(),
                ),
              ),
              const SizedBox(width: 12),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Categoría
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _categoryColor.withAlpha(30),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        featured.category.name,
                        style: TextStyle(
                          color: _categoryColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Título
                    Text(
                      event.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // Fecha y distancia
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.calendar(),
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatShortDate(event.startDate),
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          PhosphorIcons.mapPin(),
                          size: 12,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${featured.distanceKm.toStringAsFixed(1)} km',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Asistentes
              Column(
                children: [
                  Icon(
                    PhosphorIcons.users(PhosphorIconsStyle.fill),
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${featured.attendeeCount}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
          size: 24,
          color: AppColors.onSurfaceVariant.withAlpha(128),
        ),
      ),
    );
  }
}
