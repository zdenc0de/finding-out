// lib/features/events/presentation/providers/event_search_provider.dart
// Provider para la búsqueda de eventos con debounce

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/event.dart';
import 'events_provider.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO DE BÚSQUEDA
// ═══════════════════════════════════════════════════════════════════════════

/// Estado de la búsqueda de eventos.
class EventSearchState {
  final String query;
  final List<Event> results;
  final bool isLoading;
  final bool hasSearched;
  final String? errorMessage;

  const EventSearchState({
    this.query = '',
    this.results = const [],
    this.isLoading = false,
    this.hasSearched = false,
    this.errorMessage,
  });

  EventSearchState copyWith({
    String? query,
    List<Event>? results,
    bool? isLoading,
    bool? hasSearched,
    String? errorMessage,
    bool clearError = false,
  }) {
    return EventSearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
      hasSearched: hasSearched ?? this.hasSearched,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STATE NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para gestionar la búsqueda de eventos con debounce.
class EventSearchNotifier extends StateNotifier<EventSearchState> {
  final Ref _ref;
  Timer? _debounceTimer;

  EventSearchNotifier(this._ref) : super(const EventSearchState());

  /// Busca eventos con debounce de 400ms.
  void search(String query) {
    state = state.copyWith(query: query, clearError: true);

    // Cancelar búsqueda anterior
    _debounceTimer?.cancel();

    // Si el query está vacío, limpiar resultados
    if (query.trim().isEmpty) {
      state = state.copyWith(
        results: [],
        isLoading: false,
        hasSearched: false,
      );
      return;
    }

    // Mostrar indicador de carga
    state = state.copyWith(isLoading: true);

    // Debounce de 400ms
    _debounceTimer = Timer(const Duration(milliseconds: 400), () async {
      try {
        final repository = _ref.read(eventRepositoryProvider);
        final results = await repository.searchEvents(query.trim());

        // Verificar que el query no haya cambiado durante la búsqueda
        if (state.query == query) {
          state = state.copyWith(
            results: results,
            isLoading: false,
            hasSearched: true,
          );
        }
      } catch (e) {
        if (state.query == query) {
          state = state.copyWith(
            isLoading: false,
            hasSearched: true,
            errorMessage: 'Error al buscar eventos',
          );
        }
      }
    });
  }

  /// Limpia la búsqueda y reinicia el estado.
  void clear() {
    _debounceTimer?.cancel();
    state = const EventSearchState();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════════

/// Provider para la búsqueda de eventos.
final eventSearchProvider =
    StateNotifierProvider.autoDispose<EventSearchNotifier, EventSearchState>(
  (ref) => EventSearchNotifier(ref),
);
