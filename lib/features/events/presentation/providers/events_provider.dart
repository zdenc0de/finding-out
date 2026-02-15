// lib/features/events/presentation/providers/events_provider.dart
// Provider de Riverpod para gestión de eventos

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../profile/domain/entities/public_profile.dart';
import '../../data/repositories/event_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_attendance.dart';
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

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE ASISTENCIA
// ═══════════════════════════════════════════════════════════════════════════

/// Estado de asistencia para un evento.
class AttendanceState {
  final AttendanceStatus? status;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceState({
    this.status,
    this.isLoading = false,
    this.errorMessage,
  });

  AttendanceState copyWith({
    AttendanceStatus? status,
    bool? isLoading,
    String? errorMessage,
    bool clearStatus = false,
  }) {
    return AttendanceState(
      status: clearStatus ? null : (status ?? this.status),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// Notifier para gestionar la asistencia a un evento.
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final EventRepository _repository;
  final String _eventId;
  final Ref _ref;

  AttendanceNotifier(this._repository, this._eventId, this._ref)
      : super(const AttendanceState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    state = state.copyWith(isLoading: true);
    try {
      final status = await _repository.getMyAttendance(_eventId);
      state = AttendanceState(status: status);
    } catch (e) {
      state = const AttendanceState();
    }
  }

  Future<void> markGoing() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.markAttendance(_eventId, AttendanceStatus.going);
      state = const AttendanceState(status: AttendanceStatus.going);
      _invalidateRelatedProviders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al marcar asistencia',
      );
    }
  }

  Future<void> markInterested() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.markAttendance(_eventId, AttendanceStatus.interested);
      state = const AttendanceState(status: AttendanceStatus.interested);
      _invalidateRelatedProviders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al marcar interés',
      );
    }
  }

  Future<void> cancelAttendance() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await _repository.cancelAttendance(_eventId);
      state = const AttendanceState();
      _invalidateRelatedProviders();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al cancelar asistencia',
      );
    }
  }

  void _invalidateRelatedProviders() {
    _ref.invalidate(friendsAttendingProvider(_eventId));
    _ref.invalidate(attendeeCountProvider(_eventId));
    _ref.invalidate(attendeeStatsProvider(_eventId));
    _ref.invalidate(myUpcomingEventsProvider);
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider family para el estado de asistencia de cada evento.
final attendanceNotifierProvider =
    StateNotifierProvider.family<AttendanceNotifier, AttendanceState, String>(
        (ref, eventId) {
  final repository = ref.watch(eventRepositoryProvider);
  return AttendanceNotifier(repository, eventId, ref);
});

/// Provider para obtener los amigos que van a un evento.
final friendsAttendingProvider =
    FutureProvider.family<List<PublicProfile>, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getFriendsAttending(eventId);
});

/// Provider para obtener el conteo de asistentes a un evento.
final attendeeCountProvider =
    FutureProvider.family<int, String>((ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getAttendeeCount(eventId);
});

/// Provider para obtener estadísticas de asistentes (going e interested).
final attendeeStatsProvider =
    FutureProvider.family<({int going, int interested}), String>(
        (ref, eventId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getAttendeeStats(eventId);
});

/// Provider para obtener una categoría por su ID.
final categoryByIdProvider =
    FutureProvider.family<Category?, String>((ref, categoryId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getCategoryById(categoryId);
});

/// Provider para obtener los próximos eventos a los que el usuario va.
final myUpcomingEventsProvider = FutureProvider<List<Event>>((ref) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getMyUpcomingEvents();
});

/// Provider para obtener los eventos creados por un usuario.
final eventsByCreatorProvider =
    FutureProvider.family<List<Event>, String>((ref, userId) async {
  final repository = ref.watch(eventRepositoryProvider);
  return repository.getEventsByCreator(userId);
});
