// lib/core/services/location/location_service_impl.dart
// Implementación del servicio de ubicación usando geolocator

import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:latlong2/latlong.dart';

import '../../errors/exceptions.dart';
import 'location_service.dart';

/// Implementación del servicio de ubicación usando el paquete geolocator.
class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<bool> requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  @override
  Future<LatLng> getCurrentPosition() async {
    // Verificar si el servicio está habilitado
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationServiceDisabledException();
    }

    // Verificar permisos
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionPermanentlyDeniedException();
    }

    // Obtener posición
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      throw LocationFetchException(e.toString());
    }
  }

  @override
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  @override
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
