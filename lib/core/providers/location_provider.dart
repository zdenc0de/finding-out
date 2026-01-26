// lib/core/providers/location_provider.dart
// Provider de Riverpod para el servicio de ubicación

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../errors/exceptions.dart';
import '../services/location/location_service.dart';
import '../services/location/location_service_impl.dart';
import '../services/location/location_state.dart';

/// Provider para la instancia del servicio de ubicación
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationServiceImpl();
});

/// Provider para el estado de ubicación
final locationNotifierProvider =
    StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  final service = ref.watch(locationServiceProvider);
  return LocationNotifier(service);
});

/// Notifier para manejar el estado de ubicación
class LocationNotifier extends StateNotifier<LocationState> {
  final LocationService _service;

  LocationNotifier(this._service) : super(const LocationState.initial());

  /// Obtiene la ubicación actual del usuario.
  ///
  /// Solicita permisos si es necesario y actualiza el estado.
  Future<void> getCurrentLocation() async {
    state = state.copyWith(status: LocationStatus.loading);

    try {
      final position = await _service.getCurrentPosition();
      state = LocationState(
        status: LocationStatus.success,
        position: position,
      );
    } on LocationServiceDisabledException catch (e) {
      state = LocationState(
        status: LocationStatus.serviceDisabled,
        errorMessage: e.message,
      );
    } on LocationPermissionDeniedException catch (e) {
      state = LocationState(
        status: LocationStatus.permissionDenied,
        errorMessage: e.message,
      );
    } on LocationPermissionPermanentlyDeniedException catch (e) {
      state = LocationState(
        status: LocationStatus.permissionPermanentlyDenied,
        errorMessage: e.message,
      );
    } on LocationFetchException catch (e) {
      state = LocationState(
        status: LocationStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = const LocationState(
        status: LocationStatus.error,
        errorMessage: 'Error inesperado al obtener ubicación',
      );
    }
  }

  /// Actualiza la posición manualmente (útil para testing)
  void setPosition(LatLng position) {
    state = LocationState(
      status: LocationStatus.success,
      position: position,
    );
  }

  /// Reinicia el estado a inicial
  void reset() {
    state = const LocationState.initial();
  }

  /// Abre la configuración de la app
  Future<void> openAppSettings() async {
    await _service.openAppSettings();
  }

  /// Abre la configuración de ubicación del dispositivo
  Future<void> openLocationSettings() async {
    await _service.openLocationSettings();
  }
}
