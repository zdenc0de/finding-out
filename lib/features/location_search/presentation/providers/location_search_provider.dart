// lib/features/location_search/presentation/providers/location_search_provider.dart
// Provider para búsqueda de ubicaciones con debounce

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/google_places_datasource.dart';
import '../../data/repositories/location_search_repository_impl.dart';
import '../../domain/entities/place_suggestion.dart';
import '../../domain/repositories/location_search_repository.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDERS DE DEPENDENCIAS
// ═══════════════════════════════════════════════════════════════════════════

/// Provider del datasource de Google Places.
final googlePlacesDatasourceProvider = Provider<GooglePlacesDatasource>((ref) {
  final datasource = GooglePlacesDatasource();
  ref.onDispose(() => datasource.dispose());
  return datasource;
});

/// Provider del repositorio de búsqueda de ubicaciones.
final locationSearchRepositoryProvider = Provider<LocationSearchRepository>((ref) {
  final datasource = ref.watch(googlePlacesDatasourceProvider);
  return LocationSearchRepositoryImpl(datasource);
});

// ═══════════════════════════════════════════════════════════════════════════
// ESTADO DE BÚSQUEDA
// ═══════════════════════════════════════════════════════════════════════════

/// Estado de la búsqueda de lugares.
class LocationSearchState {
  final String query;
  final List<PlaceSuggestion> suggestions;
  final bool isLoading;
  final String? errorMessage;
  final PlaceSuggestion? selectedPlace;

  const LocationSearchState({
    this.query = '',
    this.suggestions = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedPlace,
  });

  LocationSearchState copyWith({
    String? query,
    List<PlaceSuggestion>? suggestions,
    bool? isLoading,
    String? errorMessage,
    PlaceSuggestion? selectedPlace,
    bool clearSelected = false,
    bool clearError = false,
  }) {
    return LocationSearchState(
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedPlace: clearSelected ? null : (selectedPlace ?? this.selectedPlace),
    );
  }

  bool get hasSuggestions => suggestions.isNotEmpty;
  bool get hasSelection => selectedPlace != null;
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFIER DE BÚSQUEDA
// ═══════════════════════════════════════════════════════════════════════════

/// Notifier para gestionar la búsqueda de lugares con debounce.
class LocationSearchNotifier extends StateNotifier<LocationSearchState> {
  final LocationSearchRepository _repository;
  Timer? _debounceTimer;

  /// Duración del debounce en milisegundos.
  static const int _debounceDuration = 300;

  /// Mínimo de caracteres para iniciar búsqueda.
  static const int _minQueryLength = 3;

  LocationSearchNotifier(this._repository) : super(const LocationSearchState());

  /// Actualiza el query y dispara búsqueda con debounce.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    state = state.copyWith(
      query: query,
      clearError: true,
    );

    if (query.trim().length < _minQueryLength) {
      state = state.copyWith(suggestions: []);
      return;
    }

    state = state.copyWith(isLoading: true);

    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceDuration),
      () => _performSearch(query),
    );
  }

  /// Ejecuta la búsqueda.
  Future<void> _performSearch(String query) async {
    if (!mounted) return;

    try {
      final suggestions = await _repository.searchPlaces(query: query);

      if (!mounted) return;

      // Solo actualizar si el query no cambió
      if (state.query == query) {
        state = state.copyWith(
          suggestions: suggestions,
          isLoading: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Error al buscar direcciones',
        suggestions: [],
      );
    }
  }

  /// Selecciona una sugerencia.
  void selectPlace(PlaceSuggestion place) {
    state = state.copyWith(
      selectedPlace: place,
      query: place.formattedAddress,
      suggestions: [],
    );
  }

  /// Establece una ubicación manualmente (desde el mapa).
  void setManualLocation({
    required double latitude,
    required double longitude,
    required String address,
  }) {
    final place = PlaceSuggestion(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      displayName: address,
      latitude: latitude,
      longitude: longitude,
    );

    state = state.copyWith(
      selectedPlace: place,
      query: address,
      suggestions: [],
    );
  }

  /// Obtiene dirección de coordenadas (para selector de mapa).
  Future<PlaceSuggestion?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    state = state.copyWith(isLoading: true);

    try {
      final place = await _repository.reverseGeocode(
        latitude: latitude,
        longitude: longitude,
      );

      if (place != null) {
        state = state.copyWith(
          selectedPlace: place,
          query: place.formattedAddress,
          isLoading: false,
        );
      } else {
        // Si no hay resultado, crear uno con las coordenadas
        final manualPlace = PlaceSuggestion(
          id: 'coords_${DateTime.now().millisecondsSinceEpoch}',
          displayName: '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}',
          latitude: latitude,
          longitude: longitude,
        );
        state = state.copyWith(
          selectedPlace: manualPlace,
          query: manualPlace.displayName,
          isLoading: false,
        );
        return manualPlace;
      }

      return place;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'No se pudo obtener la dirección',
      );
      return null;
    }
  }

  /// Limpia la selección y el campo.
  void clear() {
    _debounceTimer?.cancel();
    state = const LocationSearchState();
  }

  /// Limpia las sugerencias (al perder foco).
  void clearSuggestions() {
    state = state.copyWith(suggestions: []);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PROVIDER DEL NOTIFIER
// ═══════════════════════════════════════════════════════════════════════════

/// Provider del notifier de búsqueda de ubicaciones.
///
/// Usa autoDispose para limpiar recursos cuando ya no se usa.
final locationSearchNotifierProvider =
    StateNotifierProvider.autoDispose<LocationSearchNotifier, LocationSearchState>(
  (ref) {
    final repository = ref.watch(locationSearchRepositoryProvider);
    return LocationSearchNotifier(repository);
  },
);
