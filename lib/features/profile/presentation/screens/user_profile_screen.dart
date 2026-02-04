// lib/features/profile/presentation/screens/user_profile_screen.dart
// Pantalla para ver el perfil de otro usuario

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../events/presentation/providers/events_provider.dart';
import '../../../social/presentation/widgets/follow_button.dart';
import '../../domain/entities/public_profile.dart';
import '../providers/profile_provider.dart';

class UserProfileScreen extends ConsumerWidget {
  final String userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileByIdProvider(userId));
    final statsAsync = ref.watch(userStatsByIdProvider(userId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        title: const Text('Perfil de usuario'),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _buildErrorState(context),
        data: (profile) {
          if (profile == null) return _buildNotFoundState(context);
          return _buildProfileContent(context, profile, statsAsync, ref);
        },
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.warning(PhosphorIconsStyle.duotone),
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Error al cargar el perfil',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNotFoundState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.userCircle(PhosphorIconsStyle.duotone),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Usuario no encontrado',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    PublicProfile profile,
    AsyncValue<UserStats> statsAsync,
    WidgetRef ref,
  ) {
    // Verificar si es el perfil del usuario actual
    final authState = ref.watch(authNotifierProvider);
    final isOwnProfile = authState.user?.id == userId;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // ─────────────────────────────────────────────────────────────
            // HEADER: Avatar y nombre
            // ─────────────────────────────────────────────────────────────
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              backgroundImage: profile.avatarUrl != null
                  ? NetworkImage(profile.avatarUrl!)
                  : null,
              child: profile.avatarUrl == null
                  ? Text(
                      StringUtils.getInitials(profile.displayName),
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
              StringUtils.sanitizeForDisplay(profile.displayName, maxLength: 30)
                      .isNotEmpty
                  ? StringUtils.sanitizeForDisplay(profile.displayName,
                      maxLength: 30)
                  : 'Usuario',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),

            // ─────────────────────────────────────────────────────────────
            // BOTÓN SEGUIR (solo si no es el perfil propio)
            // ─────────────────────────────────────────────────────────────
            if (!isOwnProfile) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                child: FollowButton(userId: userId),
              ),
            ],

            // ─────────────────────────────────────────────────────────────
            // ESTADÍSTICAS DE SEGUIDORES
            // ─────────────────────────────────────────────────────────────
            const SizedBox(height: 24),
            FollowStatsRow(userId: userId),

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
                  value: _formatDate(profile.createdAt),
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
                  _buildStatRow(
                      context, 'Eventos creados', '${stats.eventsCreated}'),
                ],
              ),
              loading: () => _buildInfoCard(
                context,
                children: [
                  _buildStatRow(context, 'Eventos creados', '-'),
                ],
              ),
              error: (_, __) => _buildInfoCard(
                context,
                children: [
                  _buildStatRow(context, 'Eventos creados', '0'),
                ],
              ),
            ),

            // ─────────────────────────────────────────────────────────────────────
            // EVENTOS CREADOS
            // ─────────────────────────────────────────────────────────────────────
            const SizedBox(height: 24),
            _buildSectionTitle(context, 'Eventos creados'),
            const SizedBox(height: 12),
            _buildCreatedEventsSection(context, ref),
          ],
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

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _buildCreatedEventsSection(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsByCreatorProvider(userId));

    return eventsAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, __) => _buildInfoCard(
        context,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No se pudieron cargar los eventos',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
      data: (events) {
        if (events.isEmpty) {
          return _buildInfoCard(
            context,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(
                      PhosphorIcons.calendarBlank(),
                      size: 32,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No ha creado eventos',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return _buildInfoCard(
          context,
          children: events.map((event) {
            final isLast = events.last == event;
            return Column(
              children: [
                InkWell(
                  onTap: () => context.push('/events/${event.id}'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withAlpha(25),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${event.startDate.day}',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      height: 1,
                                    ),
                              ),
                              Text(
                                _getShortMonth(event.startDate.month),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormatter.formatTime(event.startDate),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          PhosphorIcons.caretRight(),
                          size: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                ),
                if (!isLast) const Divider(height: 1),
              ],
            );
          }).toList(),
        );
      },
    );
  }

  String _getShortMonth(int month) {
    const months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return months[month - 1];
  }
}
