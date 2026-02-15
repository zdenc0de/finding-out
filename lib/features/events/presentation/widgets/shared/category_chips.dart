// lib/features/events/presentation/widgets/category_chips.dart
// Chips de categorías para filtrar eventos en el mapa

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../providers/events_provider.dart';
import '../../providers/featured_events_provider.dart';

/// Lista horizontal de chips para filtrar eventos por categoría.
///
/// Permite seleccionar una categoría para filtrar los marcadores del mapa.
/// Un chip "Todos" permite mostrar todas las categorías.
class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsState = ref.watch(eventsNotifierProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    if (eventsState.status != EventsStatus.loaded) {
      return const SizedBox.shrink();
    }

    final categories = eventsState.sortedCategories;

    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length + 1, // +1 para el chip "Todos"
        itemBuilder: (context, index) {
          if (index == 0) {
            // Chip "Todos"
            return _CategoryChip(
              label: 'Todos',
              color: AppColors.primary,
              isSelected: selectedCategory == null,
              onTap: () {
                ref.read(selectedCategoryProvider.notifier).state = null;
              },
            );
          }

          final category = categories[index - 1];
          final isSelected = selectedCategory?.id == category.id;

          return _CategoryChip(
            label: category.name,
            color: _parseColor(category.color),
            isSelected: isSelected,
            onTap: () {
              if (isSelected) {
                // Deseleccionar = mostrar todos
                ref.read(selectedCategoryProvider.notifier).state = null;
              } else {
                ref.read(selectedCategoryProvider.notifier).state = category;
              }
            },
          );
        },
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}

/// Chip individual de categoría.
class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color : AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? color : AppColors.outline,
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withAlpha(60),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.shadow.withAlpha(20),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isSelected) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
