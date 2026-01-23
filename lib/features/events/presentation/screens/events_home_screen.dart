// lib/features/events/presentation/screens/events_home_screen.dart
// Pantalla principal de eventos con listados horizontales por categoría

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/category_section.dart';

/// Pantalla principal que muestra eventos agrupados por categoría.
///
/// Reemplaza la HomeScreen original y muestra listados horizontales
/// de eventos organizados por categoría (Música, Deportes, etc.).
class EventsHomeScreen extends ConsumerStatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  ConsumerState<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends ConsumerState<EventsHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsNotifierProvider.notifier).loadEventsGroupedByCategory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final eventsState = ref.watch(eventsNotifierProvider);
    final user = authState.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finding Out'),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => context.go(AppRoutes.profile),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                StringUtils.getInitials(user?.displayName ?? user?.email),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            tooltip: 'Cerrar sesión',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: _buildBody(eventsState),
    );
  }

  Widget _buildBody(EventsState eventsState) {
    switch (eventsState.status) {
      case EventsStatus.initial:
      case EventsStatus.loading:
        return const Center(
          child: CircularProgressIndicator(),
        );

      case EventsStatus.error:
        return _buildError(eventsState.errorMessage);

      case EventsStatus.loaded:
        return _buildEventsList(eventsState);
    }
  }

  Widget _buildError(String? errorMessage) {
    return Center(
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
              errorMessage ?? 'Error al cargar los eventos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref
                    .read(eventsNotifierProvider.notifier)
                    .loadEventsGroupedByCategory();
              },
              icon: Icon(PhosphorIcons.arrowClockwise()),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventsList(EventsState eventsState) {
    final categories = eventsState.sortedCategories;

    if (categories.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(eventsNotifierProvider.notifier).refresh();
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(
            decelerationRate: ScrollDecelerationRate.fast,
          ),
        ),
        cacheExtent: 500, // Pre-renderiza contenido extra
        itemCount: categories.length + 1, // +1 para el header
        itemBuilder: (context, index) {
          // Header (índice 0)
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explora tu ciudad',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Descubre eventos cerca de ti',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            );
          }

          // Categorías (índice 1 en adelante)
          final categoryIndex = index - 1;
          final category = categories[categoryIndex];
          final events = eventsState.eventsByCategory[category] ?? [];

          return RepaintBoundary(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: CategorySection(
                category: category,
                events: events,
                onSeeAllTap: () {
                  // TODO: Navegar a listado completo de categoría
                },
                onEventTap: (event) {
                  context.push('/events/${event.id}');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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
              'No hay eventos disponibles',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Vuelve más tarde para descubrir nuevos eventos',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                ref
                    .read(eventsNotifierProvider.notifier)
                    .loadEventsGroupedByCategory();
              },
              icon: Icon(PhosphorIcons.arrowClockwise()),
              label: const Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
