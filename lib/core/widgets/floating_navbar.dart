// lib/core/widgets/floating_navbar.dart
// Navbar flotante con diseño elíptico centrado - 4 items

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Navbar flotante con diseño elíptico/pill que flota sobre el contenido.
///
/// Se posiciona en la parte inferior de la pantalla con padding,
/// centrado horizontalmente con forma de cápsula/elipse.
///
/// Items:
/// - 0: Eventos (lista)
/// - 1: Mapa
/// - 2: Crear evento (+)
/// - 3: Perfil
class FloatingNavbar extends StatelessWidget {
  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Índice del tab actualmente seleccionado
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
              // Eventos
              _NavbarItem(
                icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
                activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                label: 'Eventos',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              const SizedBox(width: 4),
              // Mapa
              _NavbarItem(
                icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular),
                activeIcon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
                label: 'Mapa',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              const SizedBox(width: 4),
              // Crear evento (+) - Botón especial
              _CreateButton(
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              const SizedBox(width: 4),
              // Perfil
              _NavbarItem(
                icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
                activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                label: 'Perfil',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Botón especial de crear evento (+)
/// Siempre tiene fondo primario para destacar como CTA principal.
class _CreateButton extends StatelessWidget {
  const _CreateButton({
    required this.isSelected,
    required this.onTap,
  });

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(40),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(80),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          PhosphorIcons.plus(PhosphorIconsStyle.bold),
          color: AppColors.onPrimary,
          size: 24,
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
          horizontal: isSelected ? 16 : 12,
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
              size: 22,
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
