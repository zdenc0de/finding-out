// lib/features/events/presentation/widgets/featured_events_sheet.dart
// Panel inferior con eventos destacados y botón Top 10

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/providers/location_provider.dart';
import '../../domain/entities/featured_event.dart';
import '../providers/featured_events_provider.dart';
import '../screens/top10_events_screen.dart';

/// Panel inferior con carrusel de eventos destacados.
///
/// Muestra los 5 eventos más relevantes basados en fecha y asistentes.
/// Incluye botón "Top 10" para ver la lista completa.
/// Se puede colapsar/expandir tocando el handle.
class FeaturedEventsSheet extends ConsumerStatefulWidget {
  /// Callback cuando se selecciona un evento (para centrar el mapa).
  final void Function(FeaturedEvent event)? onEventTap;

  const FeaturedEventsSheet({
    super.key,
    this.onEventTap,
  });

  @override
  ConsumerState<FeaturedEventsSheet> createState() =>
      _FeaturedEventsSheetState();
}

class _FeaturedEventsSheetState extends ConsumerState<FeaturedEventsSheet>
    with SingleTickerProviderStateMixin {
  bool _isCollapsed = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleCollapse() {
    setState(() {
      _isCollapsed = !_isCollapsed;
      if (_isCollapsed) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final featuredState = ref.watch(featuredEventsNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

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

    // Si no hay ubicación, mostrar botón para activarla
    if (!locationState.hasLocation) {
      return _buildContainer(
        context,
        showHeader: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  PhosphorIcons.mapPinLine(),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Activa tu ubicación',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      'Para ver eventos destacados cerca de ti',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              FilledButton.tonal(
                onPressed: () {
                  ref
                      .read(locationNotifierProvider.notifier)
                      .getCurrentLocation();
                },
                style: FilledButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Activar'),
              ),
            ],
          ),
        ),
      );
    }

    if (featuredState.events.isEmpty) {
      return _buildContainer(
        context,
        showHeader: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
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
              onTap: () => widget.onEventTap?.call(featured),
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
    bool allowCollapse = true,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(
            color: Color(0x10000000),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle clickable para colapsar/expandir
          GestureDetector(
            onTap: allowCollapse ? _toggleCollapse : null,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          // Contenido animado
          SizeTransition(
            sizeFactor: ReverseAnimation(_heightAnimation),
            axisAlignment: -1,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header con título y botón Top 10
                if (showHeader)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
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
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        TextButton(
                          onPressed: onTop10Tap,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
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

                const SizedBox(height: 12),
              ],
            ),
          ),
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
