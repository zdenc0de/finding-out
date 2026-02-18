// lib/core/widgets/floating_navbar.dart
// Fixed Instagram-style bottom navbar - 5 items

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../theme/app_colors.dart';

/// Fixed Instagram-style bottom navbar.
///
/// Positioned at the bottom of the screen, occupying the full width,
/// with support for safe area on devices with notches or navigation bars.
///
/// Items:
/// - 0: Events (list)
/// - 1: Map
/// - 2: Create event (+)
/// - 3: Profile
/// - 4: Search users
class FloatingNavbar extends StatelessWidget {
  const FloatingNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  /// Index of the currently selected tab
  final int currentIndex;

  /// Callback when a tab is selected
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
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
          // Events
          _NavbarItem(
            icon: PhosphorIcons.house(PhosphorIconsStyle.regular),
            activeIcon: PhosphorIcons.house(PhosphorIconsStyle.fill),
            label: 'Events',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          // Map
          _NavbarItem(
            icon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.regular),
            activeIcon: PhosphorIcons.mapTrifold(PhosphorIconsStyle.fill),
            label: 'Map',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          // Create event (+) - Special button
          _CreateButton(
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          // Profile
          _NavbarItem(
            icon: PhosphorIcons.user(PhosphorIconsStyle.regular),
            activeIcon: PhosphorIcons.user(PhosphorIconsStyle.fill),
            label: 'Profile',
            isSelected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          // Search users
          _NavbarItem(
            icon: PhosphorIcons.users(PhosphorIconsStyle.regular),
            activeIcon: PhosphorIcons.users(PhosphorIconsStyle.fill),
            label: 'Search',
            isSelected: currentIndex == 4,
            onTap: () => onTap(4),
          ),
        ],
      ),
    );
  }
}

/// Special button for creating an event (+)
/// Always has a primary background to stand out as the main CTA.
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
              'Create',
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

/// Individual item for the Instagram-style navbar
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
