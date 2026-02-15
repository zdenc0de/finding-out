// lib/features/events/presentation/screens/event_detail_screen.dart
// Pantalla de detalle de evento - Estilo Santorini

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../profile/presentation/providers/profile_provider.dart';
import '../../../../core/widgets/main_shell.dart';
import '../providers/events_provider.dart';
import '../widgets/detail_widgets/attendance_buttons.dart';
import '../widgets/detail_widgets/attendee_stats_section.dart';
import '../widgets/shared/category_badge.dart';
import '../widgets/detail_widgets/friends_attending_section.dart';

/// Pantalla de detalle de un evento.
class EventDetailScreen extends ConsumerWidget {
  final String eventId;

  const EventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventAsync = ref.watch(eventByIdProvider(eventId));

    // Status bar transparente para efecto inmersivo
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: eventAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _buildErrorState(context),
        data: (event) {
          if (event == null) {
            return _buildNotFoundState(context);
          }

          return CustomScrollView(
            slivers: [
              // Hero Image con AppBar transparente
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                stretch: true,
                backgroundColor: AppColors.primary,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withAlpha(80),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withAlpha(80),
                      child: IconButton(
                        icon: Icon(
                          PhosphorIcons.shareFat(PhosphorIconsStyle.fill),
                          color: Colors.white,
                        ),
                        onPressed: () => _shareEvent(
                          context,
                          title: event.title,
                          description: event.description,
                          date: event.startDate,
                          address: event.address,
                        ),
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  stretchModes: const [StretchMode.zoomBackground],
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Imagen
                      if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                        Image.network(
                          event.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      else
                        _buildImagePlaceholder(),

                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withAlpha(150),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Contenido
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        event.title,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                              height: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),

                      // Badge de categoría
                      CategoryBadge(categoryId: event.categoryId),
                      const SizedBox(height: 20),

                      // Estadísticas de asistentes
                      AttendeeStatsSection(eventId: eventId),
                      const SizedBox(height: 20),

                      // Info cards
                      _buildInfoCard(
                        context,
                        icon: PhosphorIcons.calendar(PhosphorIconsStyle.fill),
                        title: 'Fecha',
                        value: DateFormatter.formatLongDate(event.startDate),
                      ),
                      const SizedBox(height: 12),

                      _buildInfoCard(
                        context,
                        icon: PhosphorIcons.clock(PhosphorIconsStyle.fill),
                        title: 'Hora',
                        value: DateFormatter.formatTime(event.startDate),
                      ),

                      if (event.address != null &&
                          event.locationLat != null &&
                          event.locationLng != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          title: 'Ubicación',
                          value: event.address!,
                          onTap: () {
                            // Setear las coordenadas destino
                            ref.read(mapTargetLocationProvider.notifier).state =
                                LatLng(event.locationLat!, event.locationLng!);
                            // Navegar al mapa
                            ref.read(currentTabIndexProvider.notifier).state =
                                1;
                            context.go('/home');
                          },
                        ),
                      ] else if (event.address != null) ...[
                        const SizedBox(height: 12),
                        _buildInfoCard(
                          context,
                          icon: PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          title: 'Ubicación',
                          value: event.address!,
                        ),
                      ],

                      // Botones de asistencia
                      const SizedBox(height: 24),
                      AttendanceButtons(eventId: eventId),

                      // Descripción
                      if (event.description != null &&
                          event.description!.isNotEmpty) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Acerca del evento',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          event.description!,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                        ),
                      ],

                      // Amigos que van
                      FriendsAttendingSection(eventId: eventId),

                      // Organizador
                      if (event.createdBy != null) ...[
                        const SizedBox(height: 32),
                        Text(
                          'Organizador',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        _CreatorCard(creatorId: event.createdBy!),
                      ],

                      // Espacio para el navbar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Comparte el evento usando el sistema de compartir nativo.
  void _shareEvent(
    BuildContext context, {
    required String title,
    String? description,
    required DateTime date,
    String? address,
  }) {
    final buffer = StringBuffer();

    // Título con emoji
    buffer.writeln('🎉 $title');
    buffer.writeln();

    // Fecha y hora
    buffer.writeln('📅 ${DateFormatter.formatLongDate(date)}');
    buffer.writeln('🕐 ${DateFormatter.formatTime(date)}');

    // Ubicación si está disponible
    if (address != null && address.isNotEmpty) {
      buffer.writeln('📍 $address');
    }

    // Descripción truncada
    if (description != null && description.isNotEmpty) {
      buffer.writeln();
      final truncatedDesc = description.length > 150
          ? '${description.substring(0, 150)}...'
          : description;
      buffer.writeln(truncatedDesc);
    }

    buffer.writeln();
    buffer.writeln('¡Descúbrelo en Finding Out! 🌴');

    Share.share(
      buffer.toString(),
      subject: title,
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                PhosphorIcons.warning(PhosphorIconsStyle.duotone),
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Error al cargar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'No pudimos cargar el evento',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(PhosphorIcons.arrowLeft()),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                PhosphorIcons.calendarX(PhosphorIconsStyle.duotone),
                size: 48,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Evento no encontrado',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Este evento ya no está disponible',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(PhosphorIcons.arrowLeft()),
              label: const Text('Volver'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.primary.withAlpha(30),
      child: Center(
        child: Icon(
          PhosphorIcons.calendarBlank(PhosphorIconsStyle.duotone),
          size: 64,
          color: AppColors.primary.withAlpha(100),
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required PhosphorIconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    final content = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withAlpha(100),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.onSurface,
                      ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            Icon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
        ],
      ),
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      );
    }

    return content;
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
      loading: () => Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (creator) {
        if (creator == null) return const SizedBox.shrink();

        return Material(
          color: AppColors.surfaceVariant.withAlpha(100),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () => context.push('/users/$creatorId'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withAlpha(25),
                    backgroundImage: creator.avatarUrl != null
                        ? NetworkImage(creator.avatarUrl!)
                        : null,
                    child: creator.avatarUrl == null
                        ? Text(
                            StringUtils.getInitials(creator.displayName),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          creator.displayName?.isNotEmpty == true
                              ? creator.displayName!
                              : 'Usuario',
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface,
                                  ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ver perfil',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.primary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIcons.caretRight(),
                    color: AppColors.onSurfaceVariant,
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
