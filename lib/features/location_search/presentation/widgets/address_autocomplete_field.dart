// lib/features/location_search/presentation/widgets/address_autocomplete_field.dart
// Campo de búsqueda de dirección con autocompletado

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/place_suggestion.dart';
import '../providers/location_search_provider.dart';

/// Resultado de la selección de dirección.
class AddressSelectionResult {
  final String formattedAddress;
  final double latitude;
  final double longitude;

  const AddressSelectionResult({
    required this.formattedAddress,
    required this.latitude,
    required this.longitude,
  });
}

/// Campo de búsqueda de dirección con autocompletado.
class AddressAutocompleteField extends ConsumerStatefulWidget {
  /// Callback cuando se selecciona una dirección.
  final ValueChanged<AddressSelectionResult?> onAddressSelected;

  /// Callback para abrir el selector de mapa.
  final VoidCallback? onMapPickerTap;

  /// Dirección inicial (para edición).
  final String? initialAddress;

  /// Coordenadas iniciales (para edición).
  final double? initialLat;
  final double? initialLng;

  const AddressAutocompleteField({
    super.key,
    required this.onAddressSelected,
    this.onMapPickerTap,
    this.initialAddress,
    this.initialLat,
    this.initialLng,
  });

  @override
  ConsumerState<AddressAutocompleteField> createState() =>
      _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState
    extends ConsumerState<AddressAutocompleteField> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  final _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  bool _isShowingSuggestions = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialAddress != null) {
      _controller.text = widget.initialAddress!;
    }
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _removeOverlay();
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Delay para permitir tap en sugerencias
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted && !_focusNode.hasFocus) {
          _removeOverlay();
          ref.read(locationSearchNotifierProvider.notifier).clearSuggestions();
        }
      });
    }
  }

  void _showOverlay(List<PlaceSuggestion> suggestions) {
    _removeOverlay();

    if (suggestions.isEmpty) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 240),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: suggestions.length,
                itemBuilder: (context, index) {
                  final suggestion = suggestions[index];
                  return _SuggestionTile(
                    suggestion: suggestion,
                    onTap: () => _onSuggestionSelected(suggestion),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _isShowingSuggestions = true;
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _isShowingSuggestions = false;
  }

  void _onSuggestionSelected(PlaceSuggestion suggestion) {
    _removeOverlay();
    _controller.text = suggestion.formattedAddress;
    ref.read(locationSearchNotifierProvider.notifier).selectPlace(suggestion);

    widget.onAddressSelected(AddressSelectionResult(
      formattedAddress: suggestion.formattedAddress,
      latitude: suggestion.latitude,
      longitude: suggestion.longitude,
    ));

    _focusNode.unfocus();
  }

  void _onTextChanged(String value) {
    ref.read(locationSearchNotifierProvider.notifier).onQueryChanged(value);

    // Si el usuario borra el texto, limpiar selección
    if (value.isEmpty) {
      widget.onAddressSelected(null);
    }
  }

  void _clearField() {
    _controller.clear();
    ref.read(locationSearchNotifierProvider.notifier).clear();
    widget.onAddressSelected(null);
    _removeOverlay();
  }

  /// Actualiza el campo desde fuera (por ejemplo, desde el mapa).
  void updateFromMap(AddressSelectionResult result) {
    _controller.text = result.formattedAddress;
    ref.read(locationSearchNotifierProvider.notifier).setManualLocation(
          latitude: result.latitude,
          longitude: result.longitude,
          address: result.formattedAddress,
        );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(locationSearchNotifierProvider);

    // Mostrar/ocultar overlay según sugerencias
    ref.listen<LocationSearchState>(locationSearchNotifierProvider, (prev, next) {
      if (next.hasSuggestions && _focusNode.hasFocus) {
        _showOverlay(next.suggestions);
      } else if (!next.hasSuggestions && _isShowingSuggestions) {
        _removeOverlay();
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Campo de búsqueda
        CompositedTransformTarget(
          link: _layerLink,
          child: TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            decoration: InputDecoration(
              labelText: 'Dirección',
              hintText: 'Busca una dirección...',
              prefixIcon: Icon(PhosphorIcons.mapPin()),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Indicador de carga
                  if (searchState.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  // Botón limpiar
                  else if (_controller.text.isNotEmpty)
                    IconButton(
                      icon: Icon(PhosphorIcons.x()),
                      onPressed: _clearField,
                      tooltip: 'Limpiar',
                    ),
                  // Botón mapa
                  if (widget.onMapPickerTap != null)
                    IconButton(
                      icon: Icon(PhosphorIcons.mapTrifold()),
                      onPressed: widget.onMapPickerTap,
                      tooltip: 'Seleccionar en mapa',
                    ),
                ],
              ),
            ),
            textInputAction: TextInputAction.search,
          ),
        ),

        // Resultado seleccionado
        if (searchState.hasSelection) ...[
          const SizedBox(height: 12),
          _SelectedAddressCard(
            suggestion: searchState.selectedPlace!,
            onClear: _clearField,
          ),
        ],

        // Error
        if (searchState.errorMessage != null) ...[
          const SizedBox(height: 8),
          Text(
            searchState.errorMessage!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

/// Tile de sugerencia en el dropdown.
class _SuggestionTile extends StatelessWidget {
  final PlaceSuggestion suggestion;
  final VoidCallback onTap;

  const _SuggestionTile({
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              PhosphorIcons.mapPin(),
              size: 20,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.displayName,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (suggestion.city != null || suggestion.country != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      [suggestion.city, suggestion.country]
                          .whereType<String>()
                          .join(', '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card que muestra la dirección seleccionada.
class _SelectedAddressCard extends StatelessWidget {
  final PlaceSuggestion suggestion;
  final VoidCallback onClear;

  const _SelectedAddressCard({
    required this.suggestion,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  suggestion.formattedAddress,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lat: ${suggestion.latitude.toStringAsFixed(6)}, '
                  'Lng: ${suggestion.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(PhosphorIcons.x()),
            onPressed: onClear,
            tooltip: 'Limpiar',
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
