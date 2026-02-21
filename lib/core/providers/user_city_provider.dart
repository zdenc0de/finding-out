// lib/core/providers/user_city_provider.dart
// Provider que obtiene el nombre de la ciudad del usuario
// mediante reverse geocoding de su posición actual.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/location_search/presentation/providers/location_search_provider.dart';
import '../services/location/location_state.dart';
import 'location_provider.dart';

/// Provider que retorna el nombre de la ciudad actual del usuario.
///
/// Escucha la posición del [locationNotifierProvider] y realiza
/// reverse geocoding para obtener el nombre de la ciudad.
/// Retorna `null` mientras carga o si no se pudo determinar.
final userCityProvider = FutureProvider<String?>((ref) async {
  final locationState = ref.watch(locationNotifierProvider);

  // Si no hay posición disponible, retornar null
  if (locationState.status != LocationStatus.success ||
      locationState.position == null) {
    return null;
  }

  final lat = locationState.position!.latitude;
  final lng = locationState.position!.longitude;

  try {
    final repository = ref.watch(locationSearchRepositoryProvider);
    final place = await repository.reverseGeocode(
      latitude: lat,
      longitude: lng,
    );

    if (place != null) {
      // Preferir el campo city, luego state, luego displayName
      return place.city ?? place.state ?? place.displayName;
    }
  } catch (_) {
    // Si falla el reverse geocode, no es crítico
  }

  return null;
});
