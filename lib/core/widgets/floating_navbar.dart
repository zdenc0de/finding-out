// lib/core/widgets/floating_navbar.dart
// Bottom navbar fijo estilo Instagram - 5 items

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Bottom navbar fijo estilo Instagram.
///
/// Se posiciona en la parte inferior de la pantalla, ocupando todo el ancho,
/// con soporte para safe area en dispositivos con notch o barra de navegación.
///
/// Items:
/// - 0: Eventos (lista)
/// - 1: Mapa
/// - 2: Crear evento (+)
/// - 3: Perfil
/// - 4: Buscar usuarios
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 6,
          bottom: bottomPadding > 0 ? bottomPadding : 8,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.shadow.withAlpha(20),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Eventos
            _NavbarItem(
              icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
              label: 'Eventos',
              isSelected: currentIndex == 0,
              onTap: () => onTap(0),
            ),
            // Mapa
            _NavbarItem(
              icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
              label: 'Mapa',
              isSelected: currentIndex == 1,
              onTap: () => onTap(1),
            ),
            // Crear evento (+) - Botón especial
            _CreateButton(
              isSelected: currentIndex == 2,
              onTap: () => onTap(2),
            ),
            // Perfil
            _NavbarItem(
              icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
              label: 'Perfil',
              isSelected: currentIndex == 3,
              onTap: () => onTap(3),
            ),
            // Buscar usuarios
            _NavbarItem(
              icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
              activeIcon: PhosphorIcons.users(PhosphorIconsStyle.fill),
              label: 'Buscar',
              isSelected: currentIndex == 4,
              onTap: () => onTap(4),
            ),
          ],
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
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
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Crear',
              style: TextStyle(
                color:
                    isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Item individual del navbar estilo Instagram
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
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color:
                  isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color:
                    isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
