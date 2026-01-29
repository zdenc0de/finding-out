// lib/features/profile/presentation/screens/edit_profile_screen.dart
// Pantalla de edición de perfil

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/avatar_picker_field.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String? _avatarUrl;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos actuales del usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserData();
    });
  }

  void _loadUserData() {
    if (!mounted) return;
    final user = ref.read(authNotifierProvider).user;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _avatarUrl = user.avatarUrl;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final user = ref.read(authNotifierProvider).user;
    final nameChanged = _nameController.text.trim() != (user?.displayName ?? '');
    final avatarChanged = _avatarUrl != user?.avatarUrl;
    setState(() => _hasChanges = nameChanged || avatarChanged);
  }

  void _onAvatarUploaded(String? url) {
    setState(() {
      _avatarUrl = url;
    });
    _onFieldChanged();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    await ref.read(authNotifierProvider.notifier).updateProfile(
          displayName: name.isNotEmpty ? name : null,
          avatarUrl: _avatarUrl,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.user;
    final isLoading = authState.status == AuthStatus.loading;

    // Escuchar cambios de estado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.profileUpdated) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? 'Perfil actualizado'),
            backgroundColor: AppColors.success,
          ),
        );
        // Volver al perfil
        context.pop();
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.error,
          ),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.pop(),
        ),
        title: const Text('Editar perfil'),
        actions: [
          // Botón guardar en AppBar
          TextButton(
            onPressed: (_hasChanges && !isLoading) ? _handleSave : null,
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Text(
                    'Guardar',
                    style: TextStyle(
                      color: _hasChanges
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.secondary,
                    ),
                  ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Avatar picker
                AvatarPickerField(
                  initialImageUrl: user?.avatarUrl,
                  userName: _nameController.text.isNotEmpty ? _nameController.text : user?.displayName,
                  userEmail: user?.email,
                  onImageUploaded: _onAvatarUploaded,
                  radius: 50,
                ),
                const SizedBox(height: 32),
                // Campo nombre
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(PhosphorIcons.user()),
                    hintText: 'Tu nombre para mostrar',
                  ),
                  onChanged: (_) => _onFieldChanged(),
                  validator: Validators.validateDisplayName,
                ),
                const SizedBox(height: 24),
                // Email (solo lectura)
                TextFormField(
                  initialValue: user?.email ?? '',
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(PhosphorIcons.envelope()),
                    suffixIcon: Icon(
                      PhosphorIcons.lock(),
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'El email no se puede cambiar desde aquí',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),
                // Botón guardar (alternativo al de AppBar)
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_hasChanges && !isLoading) ? _handleSave : null,
                    child: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          )
                        : const Text('Guardar cambios'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
