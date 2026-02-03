// lib/features/location_search/presentation/screens/map_location_picker_screen.dart
// Pantalla para seleccionar ubicación en un mapa interactivo (Google Maps)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/providers/location_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/location_helper.dart';
import '../providers/location_search_provider.dart';

/// Resultado del selector de ubicación en mapa.
class MapLocationResult {
  final String address;
  final double latitude;
  final double longitude;

  const MapLocationResult({
    required this.address,
    required this.latitude,
    required this.longitude,
  });
}

/// Pantalla para seleccionar ubicación en un mapa interactivo.
class MapLocationPickerScreen extends ConsumerStatefulWidget {
  /// Ubicación inicial (si se está editando).
  final ll.LatLng? initialLocation;

  /// Dirección inicial.
  final String? initialAddress;

  const MapLocationPickerScreen({
    super.key,
    this.initialLocation,
    this.initialAddress,
  });

  /// Muestra el picker como modal y retorna el resultado.
  static Future<MapLocationResult?> show(
    BuildContext context, {
    ll.LatLng? initialLocation,
    String? initialAddress,
  }) {
    return showModalBottomSheet<MapLocationResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: MapLocationPickerScreen(
            initialLocation: initialLocation,
            initialAddress: initialAddress,
          ),
        ),
      ),
    );
  }

  @override
  ConsumerState<MapLocationPickerScreen> createState() =>
      _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState
    extends ConsumerState<MapLocationPickerScreen> {
  final Completer<GoogleMapController> _mapControllerCompleter = Completer();
  GoogleMapController? _mapController;
  late LatLng _selectedPosition;
  String? _selectedAddress;
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    // Convertir de latlong2 a google_maps si hay ubicación inicial
    if (widget.initialLocation != null) {
      _selectedPosition = LocationHelper.toGoogleLatLng(widget.initialLocation!);
    } else {
      _selectedPosition = LocationHelper.defaultPositionGoogle;
    }
    _selectedAddress = widget.initialAddress;

    // Intentar usar ubicación del usuario si no hay inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialLocation == null) {
        _tryUseUserLocation();
      }
    });
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _tryUseUserLocation() async {
    final locationState = ref.read(locationNotifierProvider);
    if (locationState.hasLocation && locationState.position != null) {
      final googlePosition = LocationHelper.toGoogleLatLng(locationState.position!);
      setState(() {
        _selectedPosition = googlePosition;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: googlePosition, zoom: 15),
        ),
      );
    }
  }

  Future<void> _onMapTap(LatLng point) async {
    setState(() {
      _selectedPosition = point;
      _isLoadingAddress = true;
      _selectedAddress = null;
    });

    // Obtener dirección de las coordenadas
    final place = await ref
        .read(locationSearchNotifierProvider.notifier)
        .getAddressFromCoordinates(point.latitude, point.longitude);

    if (mounted) {
      setState(() {
        _isLoadingAddress = false;
        _selectedAddress = place?.formattedAddress ??
            '${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}';
      });
    }
  }

  void _onMyLocationTap() async {
    await ref.read(locationNotifierProvider.notifier).getCurrentLocation();
    final locationState = ref.read(locationNotifierProvider);

    if (locationState.hasLocation && locationState.position != null) {
      final googlePosition = LocationHelper.toGoogleLatLng(locationState.position!);
      setState(() {
        _selectedPosition = googlePosition;
      });
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: googlePosition, zoom: 16),
        ),
      );
      _onMapTap(googlePosition);
    }
  }

  void _confirmSelection() {
    if (_selectedAddress == null && !_isLoadingAddress) {
      // Generar dirección con coordenadas si no hay
      _selectedAddress =
          '${_selectedPosition.latitude.toStringAsFixed(6)}, '
          '${_selectedPosition.longitude.toStringAsFixed(6)}';
    }

    Navigator.of(context).pop(MapLocationResult(
      address: _selectedAddress ?? '',
      latitude: _selectedPosition.latitude,
      longitude: _selectedPosition.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);

    return Column(
      children: [
        // Handle para arrastrar
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),

        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              IconButton(
                icon: Icon(PhosphorIcons.x()),
                onPressed: () => Navigator.of(context).pop(),
              ),
              Expanded(
                child: Text(
                  'Seleccionar ubicación',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 48), // Balance
            ],
          ),
        ),

        const Divider(),

        // Mapa
        Expanded(
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _selectedPosition,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('selected_location'),
                    position: _selectedPosition,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed,
                    ),
                  ),
                },
                onMapCreated: (GoogleMapController controller) {
                  _mapControllerCompleter.complete(controller);
                  _mapController = controller;
                },
                onTap: _onMapTap,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),

              // Botón mi ubicación
              Positioned(
                right: 16,
                bottom: 16,
                child: FloatingActionButton.small(
                  heroTag: 'my_location_picker',
                  onPressed: locationState.isLoading ? null : _onMyLocationTap,
                  backgroundColor: AppColors.surface,
                  child: locationState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          PhosphorIcons.crosshair(),
                          color: AppColors.primary,
                        ),
                ),
              ),

              // Instrucciones
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withAlpha(240),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.info(PhosphorIconsStyle.fill),
                        color: AppColors.info,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Toca el mapa para seleccionar la ubicación',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Indicador de carga de dirección
              if (_isLoadingAddress)
                Positioned(
                  top: 80,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadow,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Obteniendo dirección...'),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Panel inferior con dirección y botón confirmar
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.outline)),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dirección seleccionada
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIcons.mapPin(PhosphorIconsStyle.fill),
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _isLoadingAddress
                            ? Row(
                                children: [
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Obteniendo dirección...',
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _selectedAddress ?? 'Ubicación seleccionada',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_selectedPosition.latitude.toStringAsFixed(6)}, '
                                    '${_selectedPosition.longitude.toStringAsFixed(6)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Botón confirmar
                FilledButton.icon(
                  onPressed: _isLoadingAddress ? null : _confirmSelection,
                  icon: Icon(PhosphorIcons.check()),
                  label: const Text('Confirmar ubicación'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
