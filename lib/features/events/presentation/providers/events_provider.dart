// lib/features/events/presentation/providers/events_provider.dart
// Provider de Riverpod para gestión de eventos

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../../domain/repositories/event_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DEL REPOSITORIO
// ═══════════════════════════════════════════════════════════════════════════

/// Provider del repositorio de eventos.
final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepositoryImpl(SupabaseConfig.client);
});

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO DE EVENTOS
// ═══════════════════════════════════════════════════════════════════════════

/// Estados posibles del cargado de eventos.
enum EventsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado de la pantalla de eventos.
class EventsState {
  final EventsStatus status;
  final Map<Category, List<Event>> eventsByCategory;
  final String? errorMessage;

  const EventsState({
    this.status = EventsStatus.initial,
    this.eventsByCategory = const {},
    this.errorMessage,
  });

  EventsState copyWith({
    EventsStatus? status,
    Map<Category, List<Event>>? eventsByCategory,
    String? errorMessage,
  }) {
    return EventsState(
      status: status ?? this.status,
      eventsByCategory: eventsByCategory ?? this.eventsByCategory,
      errorMessage: errorMessage,
    );
  }

  /// Retorna las categorías ordenadas por displayOrder.
  List<Category> get sortedCategories {
    final categories = eventsByCategory.keys.toList();
    categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return categories;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATE NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para gestionar el estado de eventos.
class EventsNotifier extends StateNotifier<EventsState> {
  final EventRepository _repository;

  EventsNotifier(this._repository) : super(const EventsState());

  /// Carga todos los eventos agrupados por categoría.
  Future<void> loadEventsGroupedByCategory() async {
    state = state.copyWith(status: EventsStatus.loading);

    try {
      final eventsByCategory = await _repository.getEventsGroupedByCategory();
      state = EventsState(
        status: EventsStatus.loaded,
        eventsByCategory: eventsByCategory,
      );
    } on EventException catch (e) {
      state = EventsState(
        status: EventsStatus.error,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = const EventsState(
        status: EventsStatus.error,
        errorMessage: 'Error al cargar los eventos',
      );
    }
  }

  /// Recarga los eventos (pull-to-refresh).
  Future<void> refresh() async {
    await loadEventsGroupedByCategory();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DEL NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

/// Provider del notifier de eventos.
final eventsNotifierProvider =
    StateNotifierProvider<EventsNotifier, EventsState>((ref) {
  final repository = ref.watch(eventRepositoryProvider);
  return EventsNotifier(repository);
});

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS AUXILIARES
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para obtener un evento específico por ID.
final eventByIdProvider =
    FutureProvider.family<Event?, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventById(eventId);
});
