// lib/features/events/presentation/providers/featured_events_provider.dart
// Provider para eventos destacados con ranking por fecha y asistentes

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/services/location/location_state.dart';
import '../../../../core/utils/distance_calculator.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/featured_event.dart';
import 'events_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE CONFIGURACIÓN
// ═══════════════════════════════════════════════════════════════════════════

/// Radio de búsqueda en kilómetros (5-15km).
/// El usuario puede ajustar esto con un slider.
final searchRadiusProvider = StateProvider<double>((ref) => 5.0);

/// Categoría seleccionada para filtrar (null = todas).
final selectedCategoryProvider = StateProvider<Category?>((ref) => null);

/// Texto de búsqueda para filtrar eventos.
final searchQueryProvider = StateProvider<String>((ref) => '');

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE EVENTOS DESTACADOS
// ═══════════════════════════════════════════════════════════════════════════

/// Estado de los eventos destacados.
class FeaturedEventsState {
  final List<FeaturedEvent> events;
  final bool isLoading;
  final String? errorMessage;

  const FeaturedEventsState({
    this.events = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  FeaturedEventsState copyWith({
    List<FeaturedEvent>? events,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeaturedEventsState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  /// Retorna los primeros 5 eventos para el carrusel.
  List<FeaturedEvent> get topFive => events.take(5).toList();

  /// Retorna los 10 eventos para la vista expandida.
  List<FeaturedEvent> get topTen => events.take(10).toList();
}

/// Notifier para gestionar eventos destacados.
class FeaturedEventsNotifier extends StateNotifier<FeaturedEventsState> {
  final Ref _ref;

  FeaturedEventsNotifier(this._ref) : super(const FeaturedEventsState()) {
    _init();
  }

  void _init() {
    // Escuchar cambios en ubicación, eventos, radio y categoría
    _ref.listen(locationNotifierProvider, (_, __) => _recalculate());
    _ref.listen(eventsNotifierProvider, (_, __) => _recalculate());
    _ref.listen(searchRadiusProvider, (_, __) => _recalculate());
    _ref.listen(selectedCategoryProvider, (_, __) => _recalculate());

    // Calcular inicialmente
    _recalculate();
  }

  /// Recalcula los eventos destacados basándose en el estado actual.
  Future<void> _recalculate() async {
    final locationState = _ref.read(locationNotifierProvider);
    final eventsState = _ref.read(eventsNotifierProvider);
    final radius = _ref.read(searchRadiusProvider);
    final selectedCategory = _ref.read(selectedCategoryProvider);
    final searchQuery = _ref.read(searchQueryProvider).toLowerCase().trim();

    // Si no hay ubicación o eventos, no hay nada que calcular
    if (!locationState.hasLocation ||
        locationState.position == null ||
        eventsState.status != EventsStatus.loaded) {
      state = state.copyWith(events: [], isLoading: false);
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final userLat = locationState.position!.latitude;
      final userLng = locationState.position!.longitude;
      final now = DateTime.now();

      final List<FeaturedEvent> featuredEvents = [];

      // Iterar sobre todos los eventos agrupados por categoría
      for (final entry in eventsState.eventsByCategory.entries) {
        final category = entry.key;
        final events = entry.value;

        // Filtrar por categoría seleccionada
        if (selectedCategory != null && category.id != selectedCategory.id) {
          continue;
        }

        for (final event in events) {
          // Filtrar eventos pasados
          if (event.startDate.isBefore(now)) continue;

          // Filtrar por búsqueda
          if (searchQuery.isNotEmpty) {
            final matchesTitle =
                event.title.toLowerCase().contains(searchQuery);
            final matchesDescription =
                event.description?.toLowerCase().contains(searchQuery) ?? false;
            if (!matchesTitle && !matchesDescription) continue;
          }

          // Verificar que tenga coordenadas válidas
          if (event.locationLat == null || event.locationLng == null) continue;

          // Calcular distancia
          final distance = DistanceCalculator.calculateDistance(
            lat1: userLat,
            lng1: userLng,
            lat2: event.locationLat!,
            lng2: event.locationLng!,
          );

          // Filtrar por radio
          if (distance > radius) continue;

          // Obtener conteo de asistentes
          final attendeeCount = await _ref.read(
            attendeeCountProvider(event.id).future,
          );

          featuredEvents.add(FeaturedEvent(
            event: event,
            category: category,
            attendeeCount: attendeeCount,
            distanceKm: distance,
            score: 0, // Se calculará después
          ));
        }
      }

      // Calcular scores (necesitamos el máximo de asistentes)
      final maxAttendees = featuredEvents.isEmpty
          ? 0
          : featuredEvents.map((e) => e.attendeeCount).reduce(
                (a, b) => a > b ? a : b,
              );

      final scoredEvents = featuredEvents.map((fe) {
        final score = FeaturedEvent.calculateScore(
          eventDate: fe.event.startDate,
          attendeeCount: fe.attendeeCount,
          maxAttendees: maxAttendees,
          now: now,
        );
        return FeaturedEvent(
          event: fe.event,
          category: fe.category,
          attendeeCount: fe.attendeeCount,
          distanceKm: fe.distanceKm,
          score: score,
        );
      }).toList();

      // Ordenar por score descendente
      scoredEvents.sort((a, b) => b.score.compareTo(a.score));

      state = FeaturedEventsState(events: scoredEvents);
    } catch (e) {
      state = FeaturedEventsState(
        errorMessage: 'Error al calcular eventos destacados',
      );
    }
  }

  /// Fuerza un recálculo de los eventos destacados.
  Future<void> refresh() async {
    await _recalculate();
  }
}

/// Provider del notifier de eventos destacados.
final featuredEventsNotifierProvider =
    StateNotifierProvider<FeaturedEventsNotifier, FeaturedEventsState>((ref) {
  return FeaturedEventsNotifier(ref);
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DE EVENTOS FILTRADOS PARA EL MAPA
// ═══════════════════════════════════════════════════════════════════════════

/// Provider que retorna los eventos filtrados por categoría y búsqueda.
/// Usado para actualizar los marcadores del mapa.
final filteredEventsProvider = Provider<Map<Category, List<Event>>>((ref) {
  final eventsState = ref.watch(eventsNotifierProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (eventsState.status != EventsStatus.loaded) {
    return {};
  }

  final Map<Category, List<Event>> filtered = {};

  for (final entry in eventsState.eventsByCategory.entries) {
    final category = entry.key;
    final events = entry.value;

    // Filtrar por categoría
    if (selectedCategory != null && category.id != selectedCategory.id) {
      continue;
    }

    // Filtrar por búsqueda
    final filteredEvents = searchQuery.isEmpty
        ? events
        : events.where((event) {
            final matchesTitle =
                event.title.toLowerCase().contains(searchQuery);
            final matchesDescription =
                event.description?.toLowerCase().contains(searchQuery) ?? false;
            return matchesTitle || matchesDescription;
          }).toList();

    if (filteredEvents.isNotEmpty) {
      filtered[category] = filteredEvents;
    }
  }

  return filtered;
});
