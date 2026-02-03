// lib/features/events/presentation/screens/events_map_screen.dart
// Pantalla del mapa de eventos con Google Maps

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/services/location/location_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_helper.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';
import '../widgets/event_bottom_sheet.dart';
import '../widgets/map_controls.dart';

/// Pantalla del mapa que muestra los eventos como marcadores.
class EventsMapScreen extends ConsumerStatefulWidget {
  const EventsMapScreen({super.key});

  @override
  ConsumerState<EventsMapScreen> createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends ConsumerState<EventsMapScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  double _currentRotation = 0;
  double _currentZoom = LocationHelper.defaultZoom;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final eventsState = ref.read(eventsNotifierProvider);
      if (eventsState.status == EventsStatus.initial) {
        ref.read(eventsNotifierProvider.notifier).loadEventsGroupedByCategory();
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        _showLocationError(next);
      } else if (next.status == LocationStatus.success && next.position != null) {
        _animateToPosition(LocationHelper.toGoogleLatLng(next.position!));
      }
    });

    final eventMarkers = _buildEventMarkers(eventsState);
    final userMarker = _buildUserLocationMarker(locationState);

    final allMarkers = <Marker>{
      ...eventMarkers,
      if (userMarker != null) userMarker,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Eventos'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.arrowsClockwise()),
            tooltip: 'Actualizar',
            onPressed: () {
              ref.read(eventsNotifierProvider.notifier).refresh();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LocationHelper.defaultPositionGoogle,
              zoom: LocationHelper.defaultZoom,
            ),
            markers: allMarkers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapControllerCompleter.complete(controller);
              _mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              setState(() {
                _currentRotation = position.bearing * 3.14159 / 180;
                _currentZoom = position.zoom;
              });
            },
          ),

          if (eventsState.status == EventsStatus.loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          if (eventsState.status == EventsStatus.loaded && eventMarkers.isEmpty)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(PhosphorIconsStyle.fill),
                        color: AppColors.info,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No hay eventos con ubicación disponible',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          Positioned(
            right: 16,
            bottom: 120,
            child: MapControls(
              mapRotation: _currentRotation,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onCompassTap: _resetRotation,
              onMyLocationTap: _goToMyLocation,
              isLoadingLocation: locationState.isLoading,
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildEventMarkers(EventsState eventsState) {
    final Set<Marker> markers = {};

    for (final entry in eventsState.eventsByCategory.entries) {
      final category = entry.key;
      final events = entry.value;
      final hue = _colorHexToHue(category.color);

      for (final event in events) {
        if (LocationHelper.isValidCoordinate(event.locationLat, event.locationLng)) {
          markers.add(
            Marker(
              markerId: MarkerId(event.id),
              position: LatLng(event.locationLat!, event.locationLng!),
              icon: BitmapDescriptor.defaultMarkerWithHue(hue),
              onTap: () => _showEventBottomSheet(event, category.color),
            ),
          );
        }
      }
    }

    return markers;
  }

  double _colorHexToHue(String hex) {
    try {
      final colorValue = int.parse(hex.replaceFirst('#', '0xFF'));
      final color = Color(colorValue);

      // Usar los nuevos accessors que ya retornan valores 0.0-1.0
      final r = color.r;
      final g = color.g;
      final b = color.b;

      final max = [r, g, b].reduce((a, b) => a > b ? a : b);
      final min = [r, g, b].reduce((a, b) => a < b ? a : b);

      double hue = 0;

      if (max != min) {
        final d = max - min;
        if (max == r) {
          hue = ((g - b) / d + (g < b ? 6 : 0)) * 60;
        } else if (max == g) {
          hue = ((b - r) / d + 2) * 60;
        } else {
          hue = ((r - g) / d + 4) * 60;
        }
      }

      return hue;
    } catch (e) {
      return BitmapDescriptor.hueRed;
    }
  }

  Marker? _buildUserLocationMarker(LocationState locationState) {
    if (!locationState.hasLocation || locationState.position == null) {
      return null;
    }

    return Marker(
      markerId: const MarkerId('user_location'),
      position: LocationHelper.toGoogleLatLng(locationState.position!),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      anchor: const Offset(0.5, 0.5),
    );
  }

  void _showEventBottomSheet(Event event, String categoryColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => EventBottomSheet(
        event: event,
        categoryColor: categoryColor,
      ),
    );
  }

  Future<void> _zoomIn() async {
    if (_mapController == null) return;
    final newZoom = (_currentZoom + 1).clamp(3.0, 18.0);
    await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
  }

  Future<void> _zoomOut() async {
    if (_mapController == null) return;
    final newZoom = (_currentZoom - 1).clamp(3.0, 18.0);
    await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
  }

  Future<void> _resetRotation() async {
    if (_mapController == null) return;
    final center = await _getCurrentCenter();
    await _mapController!.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: center, zoom: _currentZoom, bearing: 0),
    ));
  }

  Future<LatLng> _getCurrentCenter() async {
    if (_mapController == null) return LocationHelper.defaultPositionGoogle;
    final visibleRegion = await _mapController!.getVisibleRegion();
    return LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
  }

  Future<void> _goToMyLocation() async {
    if (!mounted) return;

    final locationState = ref.read(locationNotifierProvider);

    if (locationState.hasLocation && locationState.position != null) {
      _animateToPosition(LocationHelper.toGoogleLatLng(locationState.position!));
      return;
    }

    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
  }

  Future<void> _animateToPosition(LatLng position) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: LocationHelper.userLocationZoom),
      ),
    );
  }

  void _showLocationError(LocationState locationState) {
    if (!mounted) return;

    final String message = locationState.errorMessage ?? 'Error de ubicación';
    String? actionLabel;
    VoidCallback? onAction;

    if (locationState.status == LocationStatus.serviceDisabled) {
      actionLabel = 'Configuración';
      onAction = () {
        ref.read(locationNotifierProvider.notifier).openLocationSettings();
      };
    } else if (locationState.status == LocationStatus.permissionPermanentlyDenied) {
      actionLabel = 'Configuración';
      onAction = () {
        ref.read(locationNotifierProvider.notifier).openAppSettings();
      };
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(label: actionLabel, onPressed: onAction)
            : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
