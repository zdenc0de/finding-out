// lib/features/events/presentation/screens/events_map_screen.dart
// Pantalla del mapa de eventos con Google Maps

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/event.dart';
import '../providers/events_provider.dart';
import '../widgets/event_bottom_sheet.dart';

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
  final Completer<GoogleMapController> _mapController = Completer();

  // Posición inicial del mapa (Ciudad de México por defecto)
  static const LatLng _defaultPosition = LatLng(19.4326, -99.1332);

  // Zoom inicial
  static const double _defaultZoom = 12.0;

  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    // Cargar eventos si no están cargados
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final eventsState = ref.read(eventsNotifierProvider);
      if (eventsState.status == EventsStatus.initial) {
        ref.read(eventsNotifierProvider.notifier).loadEventsGroupedByCategory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final eventsState = ref.watch(eventsNotifierProvider);

    // Escuchar cambios en eventos para actualizar marcadores
    ref.listen<EventsState>(eventsNotifierProvider, (previous, next) {
      if (next.status == EventsStatus.loaded) {
        _updateMarkers(next);
      }
    });

    // Actualizar marcadores si ya hay eventos cargados
    if (eventsState.status == EventsStatus.loaded && _markers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _updateMarkers(eventsState);
      });
    }

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
          // Mapa de Google
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _defaultPosition,
              zoom: _defaultZoom,
            ),
            markers: _markers,
            onMapCreated: (controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: true,
            // Padding inferior para que el botón de ubicación no quede detrás del navbar
            padding: const EdgeInsets.only(bottom: 100),
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
          if (eventsState.status == EventsStatus.loaded && _markers.isEmpty)
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
              child: Icon(
                PhosphorIcons.navigationArrow(PhosphorIconsStyle.fill),
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Actualiza los marcadores del mapa basándose en los eventos.
  void _updateMarkers(EventsState eventsState) {
    final Set<Marker> markers = {};

    // Obtener todos los eventos de todas las categorías
    for (final entry in eventsState.eventsByCategory.entries) {
      final category = entry.key;
      final events = entry.value;

      for (final event in events) {
        // Solo agregar eventos que tengan coordenadas
        if (event.locationLat != null && event.locationLng != null) {
          markers.add(
            Marker(
              markerId: MarkerId(event.id),
              position: LatLng(event.locationLat!, event.locationLng!),
              infoWindow: InfoWindow(
                title: event.title,
                snippet: event.address ?? 'Sin dirección',
              ),
              icon: BitmapDescriptor.defaultMarkerWithHue(
                _getCategoryHue(category.color),
              ),
              onTap: () => _showEventBottomSheet(event, category.color),
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  /// Convierte un color hex a un hue para el marcador.
  double _getCategoryHue(String colorHex) {
    try {
      final color = Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
      final hsvColor = HSVColor.fromColor(color);
      return hsvColor.hue;
    } catch (e) {
      return BitmapDescriptor.hueRed;
    }
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
    // Por ahora, centramos en la posición por defecto
    // TODO: Implementar geolocalización real
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _defaultPosition,
          zoom: _defaultZoom,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
