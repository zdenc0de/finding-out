// lib/features/events/presentation/screens/event_detail_screen.dart
// Pantalla de detalle de evento

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/events_provider.dart';

/// Pantalla de detalle de un evento.
///
/// Muestra toda la información del evento seleccionado.
class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Detalle del evento'),
      ),
      body: eventAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
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
                  'Error al cargar el evento',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
        data: (event) {
          if (event == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIcons.calendarX(PhosphorIconsStyle.duotone),
                    size: 64,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Evento no encontrado',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen del evento
                if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                  SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Image.network(
                      event.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildImagePlaceholder(),
                    ),
                  )
                else
                  _buildImagePlaceholder(),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Fecha
                      _buildInfoRow(
                        context,
                        icon: PhosphorIcons.calendar(),
                        label: 'Fecha',
                        value: DateFormatter.formatLongDate(event.startDate),
                      ),
                      const SizedBox(height: 8),

                      // Hora
                      _buildInfoRow(
                        context,
                        icon: PhosphorIcons.clock(),
                        label: 'Hora',
                        value: DateFormatter.formatTime(event.startDate),
                      ),

                      // Ubicación
                      if (event.address != null) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          context,
                          icon: PhosphorIcons.mapPin(),
                          label: 'Ubicación',
                          value: event.address!,
                        ),
                      ],

                      // Descripción
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Descripción',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],

                      // Organizador
                      if (event.createdBy != null) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Organizador',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        _CreatorCard(creatorId: event.createdBy!),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppColors.surfaceVariant,
      child: Center(
        child: Icon(
          PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
          size: 64,
          color: AppColors.onSurfaceVariant.withAlpha(128),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required PhosphorIconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Widget que muestra la tarjeta del creador/organizador del evento.
class _CreatorCard extends ConsumerWidget {
  final String creatorId;

  const _CreatorCard({required this.creatorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creatorAsync = ref.watch(publicProfileByIdProvider(creatorId));

    return creatorAsync.when(
      loading: () => const SizedBox(
        height: 56,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (creator) {
        if (creator == null) return const SizedBox.shrink();

        return Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => context.push('/users/$creatorId'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: creator.avatarUrl != null
                        ? NetworkImage(creator.avatarUrl!)
                        : null,
                    child: creator.avatarUrl == null
                        ? Text(
                            StringUtils.getInitials(creator.displayName),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      creator.displayName?.isNotEmpty == true
                          ? creator.displayName!
                          : 'Usuario',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                  Icon(
                    PhosphorIcons.caretRight(),
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
