// lib/features/events/presentation/widgets/home_widgets/hero_event_banner.dart
// Banner hero para evento destacado en la pantalla principal.

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/event.dart';

/// Banner inmersivo para el evento destacado.
///
/// Muestra una imagen grande con degradado, título, fecha,
/// ubicación y un botón de acción. Si no hay evento, no
/// renderiza nada.
class HeroEventBanner extends StatelessWidget {
  final Event? event;
  final VoidCallback? onTap;

  const HeroEventBanner({
    super.key,
    this.event,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currentEvent = event;
    if (currentEvent == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 380,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withAlpha(50),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo
            if (currentEvent.imageUrl != null)
              CachedNetworkImage(
                imageUrl: currentEvent.imageUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.surfaceVariant,
                  child: const Icon(Icons.image_not_supported_outlined, size: 48),
                ),
              )
            else
              Container(
                color: AppColors.primaryContainer,
                child: Center(
                  child: Icon(
                    PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                    size: 64,
                    color: AppColors.primary.withAlpha(100),
                  ),
                ),
              ),

            // Degradado superpuesto
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withAlpha(20),
                    Colors.black.withAlpha(150),
                    Colors.black.withAlpha(220),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),

            // Badge de categoría (esquina superior izquierda)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(50), width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      PhosphorIcons.star(PhosphorIconsStyle.fill),
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Destacado',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            // Contenido (parte inferior)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentEvent.title,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          height: 1.1,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Fecha — derivada de event.startDate
                  Row(
                    children: [
                      Icon(
                        PhosphorIcons.calendarBlank(),
                        color: Colors.white.withAlpha(200),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatearFechaEvento(currentEvent.startDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),

                  // Dirección (si existe)
                  if (currentEvent.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(),
                          color: Colors.white.withAlpha(180),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            currentEvent.address!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.white.withAlpha(180),
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Botón de acción
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.tertiary, AppColors.tertiaryDark],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.tertiary.withAlpha(100),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Ver evento',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 10),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formatea la fecha del evento a un texto legible y relativo.
  String _formatearFechaEvento(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) {
      return 'Hoy • ${DateFormat.jm().format(date)}';
    } else if (difference == 1) {
      return 'Mañana • ${DateFormat.jm().format(date)}';
    } else if (difference > 1 && difference <= 7) {
      return DateFormat('EEEE • h:mm a').format(date);
    } else {
      return DateFormat('EEE, MMM d • h:mm a').format(date);
    }
  }
}
