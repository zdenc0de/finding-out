// lib/features/home/presentation/screens/home_screen.dart
// Pantalla principal después del login

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/router_config.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// HomeScreen: Pantalla principal de la aplicación
///
/// Esta pantalla se muestra solo cuando el usuario está autenticado.
/// El redirect de GoRouter se encarga de proteger esta ruta.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos el estado de autenticación para mostrar datos del usuario
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;

    return Scaffold(
      // ─────────────────────────────────────────────────────────────────
      // APP BAR
      // ─────────────────────────────────────────────────────────────────
    
      appBar: AppBar(
        title: const Text('Finding Out'),
        centerTitle: true,
        actions: [
          // Botón de cerrar sesión en el AppBar
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            tooltip: 'Cerrar sesión',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),

      // ─────────────────────────────────────────────────────────────────
      // BODY: Contenido principal
      // ─────────────────────────────────────────────────────────────────
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tarjeta de bienvenida - Navega al perfil al hacer tap
              Card(
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => context.go(AppRoutes.profile),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        // Avatar del usuario - Usa colores del tema
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          backgroundImage: user?.avatarUrl != null
                              ? NetworkImage(user!.avatarUrl!)
                              : null,
                          child: user?.avatarUrl == null
                              ? Text(
                                  _getInitials(user?.displayName ?? user?.email ?? '?'),
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 16),
                        // Saludo
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '¡Hola, ${StringUtils.sanitizeForDisplay(user?.displayName, maxLength: 30).isNotEmpty ? StringUtils.sanitizeForDisplay(user?.displayName, maxLength: 30) : 'Usuario'}!',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              PhosphorIcons.caretRight(),
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Email - Usa color secundario de texto del tema
                        Text(
                          StringUtils.sanitizeForDisplay(user?.email, maxLength: 50),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Título de sección
              Text(
                'Explora tu ciudad',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Placeholder para contenido futuro
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        PhosphorIcons.compassRose(PhosphorIconsStyle.duotone),
                        size: 80,
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Próximamente: Eventos cerca de ti',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Obtiene las iniciales del nombre o email del usuario
  String _getInitials(String? name) => StringUtils.getInitials(name);

  /// Muestra un diálogo de confirmación antes de cerrar sesión
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authNotifierProvider.notifier).signOut();
              // El redirect de GoRouter se encargará de llevarnos a /login
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
