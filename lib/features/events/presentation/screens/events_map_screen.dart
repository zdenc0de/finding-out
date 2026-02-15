// lib/features/events/presentation/screens/events_map_screen.dart
// Pantalla del mapa de eventos con Google Maps - Rediseño estilo Google Maps

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/services/location/location_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_helper.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/featured_event.dart';
import '../providers/events_provider.dart';
import '../providers/featured_events_provider.dart';
import '../widgets/category_chips.dart';
import '../widgets/event_bottom_sheet.dart';
import '../widgets/featured_events_sheet.dart';
import '../widgets/map_controls.dart';
import '../widgets/map_search_bar.dart';
import '../widgets/radius_slider.dart';

/// Pantalla del mapa que muestra los eventos como marcadores.
/// Diseño estilo Google Maps con barra de búsqueda, filtros y eventos destacados.
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
  Timer? _cameraDebounce;

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
    _cameraDebounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEvents = ref.watch(filteredEventsProvider);
    final locationState = ref.watch(locationNotifierProvider);

    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        _showLocationError(next);
      } else if (next.status == LocationStatus.success &&
          next.position != null) {
        _animateToPosition(LocationHelper.toGoogleLatLng(next.position!));
      }
    });

    // Listener para navegación desde detalle de evento
    ref.listen<LatLng?>(mapTargetLocationProvider, (previous, next) {
      if (next != null && _mapController != null) {
        _animateToPosition(next, zoom: 16);
        // Limpiar el provider después de usar
        Future.microtask(() {
          ref.read(mapTargetLocationProvider.notifier).state = null;
        });
      }
    });

    final eventMarkers = _buildEventMarkers(filteredEvents);
    final userLocationCircles = _buildUserLocationCircles(locationState);

    return Scaffold(
      body: Stack(
        children: [
          // Mapa de Google
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LocationHelper.defaultPositionGoogle,
              zoom: LocationHelper.defaultZoom,
            ),
            markers: eventMarkers,
            circles: userLocationCircles,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 120,
              bottom: MediaQuery.of(context).padding.bottom + 260,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapControllerCompleter.complete(controller);
              _mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              _cameraDebounce?.cancel();
              _cameraDebounce = Timer(const Duration(milliseconds: 100), () {
                if (mounted) {
                  setState(() {
                    _currentRotation = position.bearing * 3.14159 / 180;
                    _currentZoom = position.zoom;
                  });
                }
              });
            },
          ),

          // Overlay de carga
          if (ref.watch(eventsNotifierProvider).status == EventsStatus.loading)
            Container(
              color: Colors.black26,
              child: const Center(child: CircularProgressIndicator()),
            ),

          // === NUEVA UI ESTILO GOOGLE MAPS ===

          // Barra de búsqueda superior
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: MapSearchBar(
              onFilterTap: () => showRadiusSliderSheet(context),
            ),
          ),

          // Chips de categorías
          Positioned(
            top: MediaQuery.of(context).padding.top + 72,
            left: 0,
            right: 0,
            child: const CategoryChips(),
          ),

          // Mensaje cuando no hay eventos
          if (filteredEvents.isEmpty &&
              ref.watch(eventsNotifierProvider).status == EventsStatus.loaded)
            Positioned(
              top: MediaQuery.of(context).padding.top + 130,
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
                          'No hay eventos con los filtros seleccionados',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Controles del mapa (derecha)
          Positioned(
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 300,
            child: MapControls(
              mapRotation: _currentRotation,
              onZoomIn: _zoomIn,
              onZoomOut: _zoomOut,
              onCompassTap: _resetRotation,
              onMyLocationTap: _goToMyLocation,
              isLoadingLocation: locationState.isLoading,
            ),
          ),

          // Panel de eventos destacados (inferior - encima del navbar)
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 56, // Navbar height + safe area
            child: FeaturedEventsSheet(
              onEventTap: (FeaturedEvent featured) {
                _animateToEvent(featured.event);
                _showEventBottomSheet(
                  featured.event,
                  featured.category.color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildEventMarkers(Map<dynamic, List<Event>> eventsByCategory) {
    final Set<Marker> markers = {};

    for (final entry in eventsByCategory.entries) {
      final category = entry.key;
      final events = entry.value;
      final hue = _colorHexToHue(category.color);

      for (final event in events) {
        if (LocationHelper.isValidCoordinate(
            event.locationLat, event.locationLng)) {
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

  Set<Circle> _buildUserLocationCircles(LocationState locationState) {
    if (!locationState.hasLocation || locationState.position == null) {
      return {};
    }

    final position = LocationHelper.toGoogleLatLng(locationState.position!);

    return {
      Circle(
        circleId: const CircleId('user_location_outer'),
        center: position,
        radius: 50,
        fillColor: AppColors.primary.withValues(alpha: 0.15),
        strokeColor: AppColors.primary.withValues(alpha: 0.3),
        strokeWidth: 1,
      ),
      Circle(
        circleId: const CircleId('user_location_inner'),
        center: position,
        radius: 12,
        fillColor: AppColors.primary,
        strokeColor: Colors.white,
        strokeWidth: 3,
      ),
    };
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

  Future<void> _animateToEvent(Event event) async {
    if (_mapController == null) return;
    if (event.locationLat == null || event.locationLng == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(event.locationLat!, event.locationLng!),
          zoom: 16,
        ),
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
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) /
          2,
    );
  }

  Future<void> _goToMyLocation() async {
    if (!mounted) return;

    final locationState = ref.read(locationNotifierProvider);

    if (locationState.hasLocation && locationState.position != null) {
      _animateToPosition(
          LocationHelper.toGoogleLatLng(locationState.position!));
      return;
    }

    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
  }

  Future<void> _animateToPosition(LatLng position, {double? zoom}) async {
    if (_mapController == null) return;

    await _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: position, zoom: zoom ?? LocationHelper.userLocationZoom),
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
    } else if (locationState.status ==
        LocationStatus.permissionPermanentlyDenied) {
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
