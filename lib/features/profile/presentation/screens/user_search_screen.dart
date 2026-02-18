// lib/features/profile/presentation/screens/user_search_screen.dart
// Pantalla de búsqueda de usuarios

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/utils/string_utils.dart';
import '../../domain/entities/public_profile.dart';
import '../providers/profile_provider.dart';

/// Provider para el texto de búsqueda con debounce.
final _searchQueryProvider = StateProvider<String>((ref) => '');

class UserSearchScreen extends ConsumerStatefulWidget {
  const UserSearchScreen({super.key});

  @override
  ConsumerState<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends ConsumerState<UserSearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Rebuild UI para actualizar el suffixIcon
    setState(() {});

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(_searchQueryProvider.notifier).state = query.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(_searchQueryProvider);
    final searchResults = ref.watch(searchProfilesProvider(searchQuery));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar usuarios'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ─────────────────────────────────────────────────────────────
          // SEARCH BAR
          // ─────────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre...',
                prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(PhosphorIcons.x()),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(_searchQueryProvider.notifier).state = '';
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),
          ),

          // ─────────────────────────────────────────────────────────────
          // RESULTS
          // ─────────────────────────────────────────────────────────────
          Expanded(
            child: searchQuery.isEmpty
                ? _buildEmptyState(context)
                : searchResults.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, __) => _buildErrorState(context, error),
                    data: (profiles) => profiles.isEmpty
                        ? _buildNoResultsState(context)
                        : _buildResultsList(context, profiles),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            PhosphorIcons.users(PhosphorIconsStyle.duotone),
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'Busca usuarios por su nombre',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning(PhosphorIconsStyle.duotone),
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error al buscar usuarios',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
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
            'No se encontraron usuarios',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<PublicProfile> profiles) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: profiles.length,
      itemBuilder: (context, index) {
        final profile = profiles[index];
        return _UserListTile(profile: profile);
      },
    );
  }
}

class _UserListTile extends StatelessWidget {
  final PublicProfile profile;

  const _UserListTile({required this.profile});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => context.push('/users/${profile.id}'),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          backgroundImage:
              profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
          child: profile.avatarUrl == null
              ? Text(
                  StringUtils.getInitials(profile.displayName),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                )
              : null,
        ),
        title: Text(
          profile.displayName?.isNotEmpty == true
              ? profile.displayName!
              : 'Usuario',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        trailing: Icon(
          PhosphorIcons.caretRight(),
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
