// lib/features/events/presentation/widgets/home_widgets/friends_activity_section.dart
// Sección de actividad social — "Tus amigos van a..."

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';

/// Tarjeta de prueba social que muestra actividad de amigos.
///
/// Actualmente usa datos de ejemplo. Conectar a un provider real
/// para mostrar la actividad real de amigos del usuario.
class FriendsActivitySection extends StatelessWidget {
  const FriendsActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Pila de avatares
          SizedBox(
            width: 56,
            height: 40,
            child: Stack(
              children: [
                _buildAvatar('https://i.pravatar.cc/100?img=5', 0),
                _buildAvatar('https://i.pravatar.cc/100?img=8', 20),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Texto con nombre en negritas
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onBackground,
                    ),
                children: const [
                  TextSpan(
                    text: 'María',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: ' y 3 amigos van a un evento...'),
                ],
              ),
            ),
          ),

          // Botón "Ver"
          TextButton(
            onPressed: () {},
            child: const Text('Ver'),
          ),
        ],
      ),
    );
  }

  /// Construye un avatar circular posicionado en la pila.
  Widget _buildAvatar(String url, double left) {
    return Positioned(
      left: left,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.surface, width: 2),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: AppColors.surfaceVariant),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceVariant,
              child: const Icon(Icons.person, size: 18),
            ),
          ),
        ),
      ),
    );
  }
}
