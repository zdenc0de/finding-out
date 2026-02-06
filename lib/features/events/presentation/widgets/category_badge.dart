// lib/features/events/presentation/widgets/category_badge.dart
// Badge visual para mostrar la categoría del evento

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/events_provider.dart';

/// Widget que muestra un badge colorido con la categoría del evento.
class CategoryBadge extends ConsumerWidget {
  final String categoryId;

  const CategoryBadge({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(categoryId));

    return categoryAsync.when(
      loading: () => Container(
        height: 32,
        width: 80,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (category) {
        if (category == null) return const SizedBox.shrink();

        final color = _parseColor(category.color);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withAlpha(80), width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category.icon),
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                category.name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }

  PhosphorIconData _getCategoryIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'music-notes':
      case 'music':
        return PhosphorIcons.musicNotes(PhosphorIconsStyle.fill);
      case 'paint-brush':
      case 'art':
        return PhosphorIcons.paintBrush(PhosphorIconsStyle.fill);
      case 'soccer-ball':
      case 'sports':
        return PhosphorIcons.soccerBall(PhosphorIconsStyle.fill);
      case 'fork-knife':
      case 'food':
        return PhosphorIcons.forkKnife(PhosphorIconsStyle.fill);
      case 'graduation-cap':
      case 'education':
        return PhosphorIcons.graduationCap(PhosphorIconsStyle.fill);
      case 'briefcase':
      case 'business':
        return PhosphorIcons.briefcase(PhosphorIconsStyle.fill);
      case 'tree':
      case 'nature':
        return PhosphorIcons.tree(PhosphorIconsStyle.fill);
      case 'heart':
      case 'wellness':
        return PhosphorIcons.heart(PhosphorIconsStyle.fill);
      case 'users':
      case 'social':
        return PhosphorIcons.users(PhosphorIconsStyle.fill);
      case 'game-controller':
      case 'gaming':
        return PhosphorIcons.gameController(PhosphorIconsStyle.fill);
      case 'ticket':
      case 'entertainment':
        return PhosphorIcons.ticket(PhosphorIconsStyle.fill);
      case 'champagne':
      case 'party':
      case 'nightlife':
        return PhosphorIcons.champagne(PhosphorIconsStyle.fill);
      default:
        return PhosphorIcons.tag(PhosphorIconsStyle.fill);
    }
  }
}
