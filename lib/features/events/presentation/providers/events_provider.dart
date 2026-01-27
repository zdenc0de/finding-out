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
  creating,
  created,
  createError,
}

/// Estado de la pantalla de eventos.
class EventsState {
  final EventsStatus status;
  final Map<Category, List<Event>> eventsByCategory;
  final String? errorMessage;
  final String? successMessage;
  final Event? createdEvent;

  const EventsState({
    this.status = EventsStatus.initial,
    this.eventsByCategory = const {},
    this.errorMessage,
    this.successMessage,
    this.createdEvent,
  });

  EventsState copyWith({
    EventsStatus? status,
    Map<Category, List<Event>>? eventsByCategory,
    String? errorMessage,
    String? successMessage,
    Event? createdEvent,
  }) {
    return EventsState(
      status: status ?? this.status,
      eventsByCategory: eventsByCategory ?? this.eventsByCategory,
      errorMessage: errorMessage,
      successMessage: successMessage,
      createdEvent: createdEvent,
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

  /// Crea un nuevo evento.
  Future<void> createEvent({
    required String title,
    String? description,
    required String categoryId,
    String? imageUrl,
    double? locationLat,
    double? locationLng,
    String? address,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    state = state.copyWith(status: EventsStatus.creating);

    try {
      final event = await _repository.createEvent(
        title: title,
        description: description,
        categoryId: categoryId,
        imageUrl: imageUrl,
        locationLat: locationLat,
        locationLng: locationLng,
        address: address,
        startDate: startDate,
        endDate: endDate,
      );

      state = state.copyWith(
        status: EventsStatus.created,
        createdEvent: event,
        successMessage: 'Evento creado exitosamente',
      );

      // Recargar eventos para mostrar el nuevo
      await loadEventsGroupedByCategory();
    } on EventException catch (e) {
      state = state.copyWith(
        status: EventsStatus.createError,
        errorMessage: e.userMessage,
      );
    } catch (e) {
      state = state.copyWith(
        status: EventsStatus.createError,
        errorMessage: 'Error al crear el evento',
      );
    }
  }

  /// Limpia el estado de éxito/error de creación.
  void clearCreateState() {
    state = state.copyWith(
      status: EventsStatus.loaded,
      createdEvent: null,
      successMessage: null,
      errorMessage: null,
    );
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
