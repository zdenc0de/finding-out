// lib/features/profile/presentation/screens/profile_screen.dart
// Pantalla de perfil del usuario

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final statsAsync = ref.watch(userStatsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // ─────────────────────────────────────────────────────────────
              // HEADER: Avatar y datos principales
              // ─────────────────────────────────────────────────────────────
              CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                backgroundImage: user?.avatarUrl != null
                    ? NetworkImage(user!.avatarUrl!)
                    : null,
                child: user?.avatarUrl == null
                    ? Text(
                        _getInitials(user?.displayName ?? user?.email ?? '?'),
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 16),
              Text(
                StringUtils.sanitizeForDisplay(user?.displayName, maxLength: 30).isNotEmpty
                    ? StringUtils.sanitizeForDisplay(user?.displayName, maxLength: 30)
                    : 'Usuario',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                StringUtils.sanitizeForDisplay(user?.email, maxLength: 50),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),

              const SizedBox(height: 16),

              // ─────────────────────────────────────────────────────────────
              // BOTÓN: Editar perfil
              // ─────────────────────────────────────────────────────────────
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.editProfile),
                icon: Icon(PhosphorIcons.pencilSimple()),
                label: const Text('Editar perfil'),
              ),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // INFO: Información de la cuenta
              // ─────────────────────────────────────────────────────────────
              _buildSectionTitle(context, 'Cuenta'),
              const SizedBox(height: 12),
              _buildInfoCard(
                context,
                children: [
                  _buildInfoRow(
                    context,
                    icon: PhosphorIcons.calendar(),
                    label: 'Miembro desde',
                    value: _formatDate(user?.createdAt),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ─────────────────────────────────────────────────────────────
              // STATS: Estadísticas
              // ─────────────────────────────────────────────────────────────
              _buildSectionTitle(context, 'Estadísticas'),
              const SizedBox(height: 12),
              statsAsync.when(
                data: (stats) => _buildInfoCard(
                  context,
                  children: [
                    _buildStatRow(context, 'Eventos asistidos', '${stats.eventsAttended}'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Eventos creados', '${stats.eventsCreated}'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Lugares favoritos', '${stats.favoritePlaces}'),
                  ],
                ),
                loading: () => _buildInfoCard(
                  context,
                  children: [
                    _buildStatRow(context, 'Eventos asistidos', '-'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Eventos creados', '-'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Lugares favoritos', '-'),
                  ],
                ),
                error: (_, __) => _buildInfoCard(
                  context,
                  children: [
                    _buildStatRow(context, 'Eventos asistidos', '0'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Eventos creados', '0'),
                    const Divider(height: 1),
                    _buildStatRow(context, 'Lugares favoritos', '0'),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─────────────────────────────────────────────────────────────
              // ACTIONS: Cerrar sesión
              // ─────────────────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: Icon(PhosphorIcons.signOut()),
                  label: const Text('Cerrar sesión'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required PhosphorIconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String? name) => StringUtils.getInitials(name);

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

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
            },
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
    );
  }
}
