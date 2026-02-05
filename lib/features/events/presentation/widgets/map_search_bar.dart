// lib/features/events/presentation/widgets/map_search_bar.dart
// Barra de búsqueda estilo Google Maps para el mapa de eventos

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/featured_events_provider.dart';

/// Barra de búsqueda flotante estilo Google Maps.
///
/// Permite buscar eventos por título o descripción.
/// Incluye botón de menú para filtros adicionales.
class MapSearchBar extends ConsumerStatefulWidget {
  /// Callback cuando se presiona el botón de menú/filtros.
  final VoidCallback? onFilterTap;

  const MapSearchBar({
    super.key,
    this.onFilterTap,
  });

  @override
  ConsumerState<MapSearchBar> createState() => _MapSearchBarState();
}

class _MapSearchBarState extends ConsumerState<MapSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withAlpha(40),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Ícono de búsqueda
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Icon(
              Icons.search,
              color: AppColors.onSurfaceVariant,
              size: 24,
            ),
          ),

          // Campo de texto
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: (value) {
                ref.read(searchQueryProvider.notifier).state = value;
              },
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurface,
                  ),
              decoration: InputDecoration(
                hintText: 'Buscar eventos...',
                hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant.withAlpha(180),
                    ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // Botón de limpiar (solo visible si hay texto)
          if (_controller.text.isNotEmpty)
            IconButton(
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
              icon: Icon(
                PhosphorIcons.x(),
                color: AppColors.onSurfaceVariant,
                size: 20,
              ),
            ),

          // Divider vertical
          Container(
            height: 28,
            width: 1,
            color: AppColors.outline,
            margin: const EdgeInsets.symmetric(horizontal: 4),
          ),

          // Botón de filtros
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onFilterTap,
              borderRadius: const BorderRadius.horizontal(
                right: Radius.circular(28),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Icon(
                  PhosphorIcons.sliders(),
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
