// lib/features/events/presentation/widgets/address_search_field.dart
// Campo de búsqueda de dirección con geocoding

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';

/// Resultado de la búsqueda de dirección.
class AddressResult {
  final String formattedAddress;
  final double latitude;
  final double longitude;

  const AddressResult({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
}

/// Campo de búsqueda de dirección que convierte texto a coordenadas.
class AddressSearchField extends StatefulWidget {
  /// Callback cuando se encuentra una dirección válida.
  final ValueChanged<AddressResult?> onAddressFound;

  /// Dirección inicial (opcional).
  final String? initialAddress;

  const AddressSearchField({
    super.key,
    required this.onAddressFound,
    this.initialAddress,
  });

  @override
  State<AddressSearchField> createState() => _AddressSearchFieldState();
}

class _AddressSearchFieldState extends State<AddressSearchField> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  AddressResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _searchAddress() async {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      setState(() {
        _error = 'Ingresa una dirección';
        _result = null;
      });
      widget.onAddressFound(null);
      return;
    }

    setState(() {
      _isSearching = true;
      _error = null;
    });

    try {
      final locations = await locationFromAddress(query);

      if (locations.isEmpty) {
        setState(() {
          _error = 'No se encontró la dirección';
          _result = null;
          _isSearching = false;
        });
        widget.onAddressFound(null);
        return;
      }

      final location = locations.first;

      // Obtener dirección formateada desde las coordenadas
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      String formattedAddress = query;
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final parts = <String>[];
        if (place.street != null && place.street!.isNotEmpty) {
          parts.add(place.street!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          parts.add(place.locality!);
        }
        if (place.administrativeArea != null &&
            place.administrativeArea!.isNotEmpty) {
          parts.add(place.administrativeArea!);
        }
        if (parts.isNotEmpty) {
          formattedAddress = parts.join(', ');
        }
      }

      final result = AddressResult(
        formattedAddress: formattedAddress,
        latitude: location.latitude,
        longitude: location.longitude,
      );

      setState(() {
        _result = result;
        _isSearching = false;
      });

      widget.onAddressFound(result);
    } catch (e) {
      setState(() {
        _error = 'Error al buscar la dirección';
        _result = null;
        _isSearching = false;
      });
      widget.onAddressFound(null);
    }
  }

  void _clearResult() {
    setState(() {
      _controller.clear();
      _result = null;
      _error = null;
    });
    widget.onAddressFound(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de texto con botón de búsqueda
        TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            labelText: 'Dirección',
            hintText: 'Ej: Paseo de la Reforma 222, CDMX',
            prefixIcon: Icon(PhosphorIcons.mapPin()),
            suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: Icon(PhosphorIcons.magnifyingGlass()),
                    onPressed: _searchAddress,
                    tooltip: 'Buscar dirección',
                  ),
            errorText: _error,
          ),
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (_) => _searchAddress(),
        ),

        // Resultado de la búsqueda
        if (_result != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.success.withAlpha(75)),
            ),
            child: Row(
              children: [
                Icon(
                  PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _result!.formattedAddress,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Lat: ${_result!.latitude.toStringAsFixed(6)}, '
                        'Lng: ${_result!.longitude.toStringAsFixed(6)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(PhosphorIcons.x()),
                  onPressed: _clearResult,
                  tooltip: 'Limpiar',
                  iconSize: 18,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
