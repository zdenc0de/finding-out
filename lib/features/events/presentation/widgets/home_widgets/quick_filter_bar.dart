// lib/features/events/presentation/widgets/home_widgets/quick_filter_bar.dart
// Barra de filtros rápidos con chips horizontales.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../providers/event_filters_provider.dart';

/// Barra de filtros rápidos con chips seleccionables.
///
/// Muestra opciones como "Hoy", "Este fin", "Gratis", etc.
/// Usa [selectedEventFilterProvider] para sincronizar el filtro seleccionado.
class QuickFilterBar extends ConsumerWidget {
  const QuickFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(selectedEventFilterProvider);

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: EventFilter.values.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = EventFilter.values[index];
          final isSelected = selectedFilter == filter;

          return ChoiceChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(selectedEventFilterProvider.notifier).state = filter;
              }
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
