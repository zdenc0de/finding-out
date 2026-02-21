// lib/features/events/presentation/screens/events_home_screen.dart
// Pantalla principal de eventos con diseño inmersivo
// Diseño basado en: Netflix meets Eventbrite

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/providers/user_city_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/category.dart';
import '../providers/event_filters_provider.dart';
import '../providers/event_search_provider.dart';
import '../providers/events_provider.dart';
import '../widgets/shared/category_section.dart';
import '../widgets/shared/search_event_tile.dart';
import '../widgets/home_widgets/friends_activity_section.dart';
import '../widgets/home_widgets/hero_event_banner.dart';
import '../widgets/home_widgets/quick_filter_bar.dart';
import '../widgets/home_widgets/stories_rail.dart';
import '../widgets/home_widgets/trending_events_section.dart';

/// Pantalla principal renovada con diseño inmersivo.
class EventsHomeScreen extends ConsumerStatefulWidget {
  const EventsHomeScreen({super.key});

  @override
  ConsumerState<EventsHomeScreen> createState() => _EventsHomeScreenState();
}

class _EventsHomeScreenState extends ConsumerState<EventsHomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar eventos y obtener ubicación al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(eventsNotifierProvider.notifier).loadEventsGroupedByCategory();
      ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final filteredEvents = ref.watch(filteredEventsByCategoryProvider);
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final cityAsync = ref.watch(userCityProvider);
    final cityName = cityAsync.valueOrNull ?? 'Ubicación';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsActivityProvider);
          await ref.read(eventsNotifierProvider.notifier).refresh();
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. Encabezado fijo (Ubicación + Búsqueda + Perfil)
            SliverAppBar(
              pinned: true,
              floating: true,
              snap: true,
              backgroundColor: AppColors.background,
              surfaceTintColor: AppColors.background,
              elevation: 0,
              toolbarHeight: 70,
              title: Row(
                children: [
                  // Chip de ubicación
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                          color: AppColors.primary,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cityName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.onSurface,
                              ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          PhosphorIcons.caretDown(),
                          color: AppColors.onSurfaceVariant,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Avatar de perfil
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primaryContainer,
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? Text(
                              user?.displayName?.isNotEmpty == true
                                  ? user!.displayName![0]
                                  : 'U',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: GestureDetector(
                    onTap: () => _showSearchSheet(context),
                    child: Container(
                      height: 48,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIcons.magnifyingGlass(),
                            color: AppColors.onSurfaceVariant,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Buscar eventos, lugares...',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.outlineVariant),
                            ),
                            child: Icon(
                              PhosphorIcons.slidersHorizontal(),
                              color: AppColors.onSurface,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 2. Rail de stories (En vivo ahora)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: StoriesRail(),
              ),
            ),

            // 3. Banner hero de evento destacado
            SliverToBoxAdapter(
              child: _buildHeroSection(eventsState, filteredEvents),
            ),

            // 4. Filtros rápidos
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: QuickFilterBar(),
              ),
            ),

            // 5. Trending cerca de ti
            SliverToBoxAdapter(
              child: _buildTrendingSection(eventsState, filteredEvents),
            ),

            // 6. Actividad de amigos
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: FriendsActivitySection(),
              ),
            ),
            
            // 7. Categorías
            _buildCategoryLists(eventsState, filteredEvents),

            // Pequeño espacio al final para el scroll
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  /// Aplana todos los eventos de todas las categorías en una sola lista.
  List<Event> _getAllEvents(Map<Category, List<Event>> eventsByCategory) {
    return eventsByCategory.values.expand((e) => e).toList();
  }

  /// Calcula una puntuación de relevancia para un evento.
  ///
  /// Criterios:
  /// - Proximidad temporal: eventos más próximos puntúan más
  /// - Tiene imagen: indica mayor esfuerzo/promoción
  /// - Tiene ubicación: evento más completo
  double _eventScore(Event event) {
    double score = 0;
    final now = DateTime.now();
    final hoursUntil = event.startDate.difference(now).inHours;

    // Proximidad temporal (máx 50 pts)
    // Eventos para hoy o mañana puntúan más alto
    if (hoursUntil >= 0 && hoursUntil <= 24) {
      score += 50; // Hoy
    } else if (hoursUntil > 24 && hoursUntil <= 72) {
      score += 35; // Próximos 3 días
    } else if (hoursUntil > 72 && hoursUntil <= 168) {
      score += 20; // Esta semana
    } else if (hoursUntil > 0) {
      score += 5;  // Más adelante
    }
    // Eventos pasados obtienen puntuación 0 de proximidad

    // Tiene imagen (20 pts) — indica mayor esfuerzo/promoción
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      score += 20;
    }

    // Tiene ubicación completa (15 pts) — evento más detallado
    if (event.locationLat != null && event.locationLng != null) {
      score += 10;
    }
    if (event.address != null && event.address!.isNotEmpty) {
      score += 5;
    }

    // Tiene descripción (10 pts) — contenido más completo
    if (event.description != null && event.description!.isNotEmpty) {
      score += 10;
    }

    return score;
  }

  /// Retorna los eventos ordenados por puntuación de relevancia (mayor primero).
  List<Event> _getRankedEvents(Map<Category, List<Event>> eventsByCategory) {
    final allEvents = _getAllEvents(eventsByCategory);
    // Eliminar duplicados por ID (un evento puede estar en múltiples categorías)
    final uniqueEvents = <String, Event>{};
    for (final event in allEvents) {
      uniqueEvents[event.id] = event;
    }
    final events = uniqueEvents.values.toList();
    events.sort((a, b) => _eventScore(b).compareTo(_eventScore(a)));
    return events;
  }

  Widget _buildHeroSection(EventsState state, Map<Category, List<Event>> filteredEvents) {
    if (state.status == EventsStatus.loading) {
      return const SizedBox(
        height: 380,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }

    final rankedEvents = _getRankedEvents(filteredEvents);
    if (rankedEvents.isEmpty) return const SizedBox.shrink();

    // Tomamos los top 3 eventos mejor puntuados para el carrusel
    final featuredEvents = rankedEvents.take(3).toList();

    return HeroEventBanner(
      events: featuredEvents,
      onEventTap: (event) => context.push('/events/${event.id}'),
    );
  }

  Widget _buildTrendingSection(EventsState state, Map<Category, List<Event>> filteredEvents) {
    final rankedEvents = _getRankedEvents(filteredEvents);
    
    // Saltamos los que ya están en el hero (top 3) y tomamos los siguientes 5
    if (rankedEvents.length <= 3) return const SizedBox.shrink();

    final trendingEvents = rankedEvents.skip(3).take(5).toList();

    return TrendingEventsSection(
      events: trendingEvents,
      onEventTap: (Event event) => context.push('/events/${event.id}'),
    );
  }

  Widget _buildCategoryLists(EventsState state, Map<Category, List<Event>> filteredEvents) {
     final categories = filteredEvents.keys.toList();
     categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
     
     if (categories.isEmpty && state.status != EventsStatus.loading) {
       return SliverToBoxAdapter(
         child: Center(
           child: Padding(
             padding: const EdgeInsets.all(32.0),
             child: Text(
               'No se encontraron eventos con este filtro',
               style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                 color: AppColors.onSurfaceVariant,
               ),
             ),
           ),
         ),
       );
     }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final category = categories[index];
          final events = filteredEvents[category] ?? [];
          
          if (events.isEmpty) return const SizedBox.shrink();

          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: CategorySection(
              category: category,
              events: events,
              onSeeAllTap: () => context.push('/events/category/${category.id}'),
              onEventTap: (event) => context.push('/events/${event.id}'),
            ),
          );
        },
        childCount: categories.length,
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _SearchBottomSheet(),
    );
  }
}

/// Bottom sheet con búsqueda de eventos en tiempo real.
class _SearchBottomSheet extends ConsumerStatefulWidget {
  const _SearchBottomSheet();

  @override
  ConsumerState<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends ConsumerState<_SearchBottomSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(eventSearchProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle visual
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Campo de búsqueda
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (value) {
                  ref.read(eventSearchProvider.notifier).search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Buscar eventos, lugares...',
                  prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(PhosphorIcons.x()),
                          onPressed: () {
                            _controller.clear();
                            ref.read(eventSearchProvider.notifier).clear();
                          },
                        )
                      : IconButton(
                          icon: Icon(PhosphorIcons.x()),
                          onPressed: () => Navigator.pop(context),
                        ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Resultados
            Expanded(
              child: _buildSearchContent(searchState, scrollController),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el contenido según el estado de búsqueda.
  Widget _buildSearchContent(
    EventSearchState searchState,
    ScrollController scrollController,
  ) {
    // Estado de carga
    if (searchState.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    // Error
    if (searchState.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.warning(PhosphorIconsStyle.duotone),
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                searchState.errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Sin resultados tras buscar
    if (searchState.hasSearched && searchState.results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone),
                size: 56,
                color: AppColors.outlineVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Sin resultados para "${searchState.query}"',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otro término de búsqueda',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // Hay resultados
    if (searchState.results.isNotEmpty) {
      return ListView.separated(
        controller: scrollController,
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        itemCount: searchState.results.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          indent: 86,
          color: AppColors.outlineVariant.withAlpha(80),
        ),
        itemBuilder: (context, index) {
          final event = searchState.results[index];
          return SearchEventTile(
            event: event,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              Navigator.pop(context);
              GoRouter.of(context).push('/events/${event.id}');
            },
          );
        },
      );
    }

    // Estado inicial (sin búsqueda)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.duotone),
              size: 56,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Busca por nombre, descripción o ubicación',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

