// lib/features/events/presentation/screens/events_map_screen.dart
// Pantalla del mapa de eventos con flutter_map + OpenStreetMap

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/services/location/location_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_helper.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';
import '../widgets/event_bottom_sheet.dart';
import '../widgets/event_marker.dart';

/// Pantalla del mapa que muestra los eventos como marcadores.
///
/// Los usuarios pueden ver la ubicación de los eventos y tocar
/// los marcadores para ver más información.
class EventsMapScreen extends ConsumerStatefulWidget {
  const EventsMapScreen({super.key});

  @override
  ConsumerState<EventsMapScreen> createState() => _EventsMapScreenState();
}

class _EventsMapScreenState extends ConsumerState<EventsMapScreen> {
  final MapController _mapController = MapController();
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    // Cargar eventos si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final eventsState = ref.read(eventsNotifierProvider);
      if (eventsState.status == EventsStatus.initial) {
        ref.read(eventsNotifierProvider.notifier).loadEventsGroupedByCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final locationState = ref.watch(locationNotifierProvider);

    // Escuchar cambios en el estado de ubicación para mostrar errores
    ref.listen<LocationState>(locationNotifierProvider, (previous, next) {
      if (next.hasError && next.errorMessage != null) {
        _showLocationError(next);
      } else if (next.status == LocationStatus.success && next.position != null) {
        _animateToPosition(next.position!);
      }
    });

    // Construir marcadores de eventos
    final eventMarkers = _buildEventMarkers(eventsState);

    // Construir marcador de ubicación del usuario
    final userMarker = _buildUserLocationMarker(locationState);

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
          // Mapa con OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LocationHelper.defaultPosition,
              initialZoom: LocationHelper.defaultZoom,
              minZoom: 3,
              maxZoom: 18,
              onMapReady: () {
                setState(() => _mapReady = true);
              },
            ),
            children: [
              // Capa de tiles de OpenStreetMap
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.findingout.app',
                maxZoom: 19,
              ),
              // Capa de marcadores de eventos
              MarkerLayer(markers: eventMarkers),
              // Capa de marcador del usuario (si tiene ubicación)
              if (userMarker != null) MarkerLayer(markers: [userMarker]),
            ],
          ),

          // Indicador de carga
          if (eventsState.status == EventsStatus.loading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),

          // Mensaje si no hay eventos con ubicación
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

          // Botón de mi ubicación
          Positioned(
            right: 16,
            bottom: 120,
            child: FloatingActionButton.small(
              heroTag: 'my_location',
              onPressed: _goToMyLocation,
              backgroundColor: AppColors.surface,
              child: locationState.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    )
                  : Icon(
                      PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                      color: AppColors.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye la lista de marcadores de eventos.
  List<Marker> _buildEventMarkers(EventsState eventsState) {
    final List<Marker> markers = [];

    for (final entry in eventsState.eventsByCategory.entries) {
      final category = entry.key;
      final events = entry.value;

      for (final event in events) {
        // Solo agregar eventos que tengan coordenadas válidas
        if (LocationHelper.isValidCoordinate(
            event.locationLat, event.locationLng)) {
          markers.add(
            Marker(
              point: LatLng(event.locationLat!, event.locationLng!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => _showEventBottomSheet(event, category.color),
                child: EventMarkerWidget(colorHex: category.color),
              ),
            ),
          );
        }
      }
    }

    return markers;
  }

  /// Construye el marcador de ubicación del usuario.
  Marker? _buildUserLocationMarker(LocationState locationState) {
    if (!locationState.hasLocation) return null;

    return Marker(
      point: locationState.position!,
      width: 48,
      height: 48,
      child: const UserLocationMarker(),
    );
  }

  /// Muestra el bottom sheet con la información del evento.
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

  /// Navega a la ubicación actual del usuario.
  Future<void> _goToMyLocation() async {
    if (!mounted) return;

    final locationState = ref.read(locationNotifierProvider);

    // Si ya tenemos ubicación, simplemente animar a ella
    if (locationState.hasLocation && locationState.position != null) {
      _animateToPosition(locationState.position!);
      return;
    }

    // Si no tenemos ubicación, solicitarla
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
  }

  /// Anima el mapa a una posición específica.
  void _animateToPosition(LatLng position) {
    if (!_mapReady) return;

    _mapController.move(position, LocationHelper.userLocationZoom);
  }

  /// Muestra un error de ubicación al usuario.
  void _showLocationError(LocationState locationState) {
    if (!mounted) return;

    final String message = locationState.errorMessage ?? 'Error de ubicación';
    String? actionLabel;
    VoidCallback? onAction;

    // Determinar acción según el tipo de error
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
            ? SnackBarAction(
                label: actionLabel,
                onPressed: onAction,
              )
            : null,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}
