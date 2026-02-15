// lib/features/events/presentation/widgets/home_widgets/quick_filter_bar.dart
// Barra de filtros rápidos con chips horizontales.

import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Barra de filtros rápidos con chips seleccionables.
///
/// Muestra opciones como "Hoy", "Este fin", "Gratis", etc.
/// El estado de selección es local; conectar a un provider
/// para filtrar eventos reales.
class QuickFilterBar extends StatefulWidget {
  const QuickFilterBar({super.key});

  @override
  State<QuickFilterBar> createState() => _QuickFilterBarState();
}

class _QuickFilterBarState extends State<QuickFilterBar> {
  int _selectedIndex = 0;

  /// Lista de filtros disponibles.
  final List<String> _filters = [
    'Hoy',
    'Este fin',
    'Gratis',
    'Cerca de mí',
    'Amigos van',
    'Música',
    'Comida',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedIndex == index;
          return ChoiceChip(
            label: Text(_filters[index]),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedColor: AppColors.primary,
            backgroundColor: Colors.transparent,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? Colors.transparent : AppColors.outline,
              ),
            ),
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        },
      ),
    );
  }
}
