// lib/core/widgets/floating_navbar.dart
// Navbar flotante con diseño elíptico centrado

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Navbar flotante con diseño elíptico/pill que flota sobre el contenido.
///
/// Se posiciona en la parte inferior de la pantalla con padding,
/// centrado horizontalmente con forma de cápsula/elipse.
class FloatingNavbar extends StatelessWidget {
  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Índice del tab actualmente seleccionado (0 = Home, 1 = Mapa)
  final int currentIndex;

  /// Callback cuando se selecciona un tab
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 24,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.shadow.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavbarItem(
                icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'Eventos',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              const SizedBox(width: 8),
              _NavbarItem(
                icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular),
                activeIcon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                label: 'Mapa',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Item individual del navbar con animación de selección
class _NavbarItem extends StatelessWidget {
  const _NavbarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
