// lib/features/auth/presentation/screens/forgot_password_screen.dart
// Pantalla de recuperación de contraseña

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authNotifierProvider.notifier).resetPassword(
            _emailController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // Escuchar cambios de estado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.passwordResetSent) {
        if (mounted) setState(() => _emailSent = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage ?? 'Email enviado'),
            backgroundColor: AppColors.success,
          ),
        );
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
          onPressed: () => context.go(AppRoutes.login),
        ),
        title: const Text('Recuperar contraseña'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _emailSent ? _buildSuccessContent() : _buildFormContent(isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Icono
          Icon(
            PhosphorIcons.lockKey(PhosphorIconsStyle.duotone),
            size: 80,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          // Título
          Text(
            '¿Olvidaste tu contraseña?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Descripción
          Text(
            'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(PhosphorIcons.envelope()),
            ),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 24),
          // Botón de enviar
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleResetPassword,
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    )
                  : const Text('Enviar enlace'),
            ),
          ),
          const SizedBox(height: 16),
          // Link a login
          TextButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Volver a iniciar sesión'),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Icono de éxito
        Icon(
          PhosphorIcons.envelopeSimpleOpen(PhosphorIconsStyle.duotone),
          size: 80,
          color: AppColors.success,
        ),
        const SizedBox(height: 24),
        // Título
        Text(
          '¡Email enviado!',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        // Descripción
        Text(
          'Revisa tu bandeja de entrada en ${_emailController.text.trim()} y sigue las instrucciones para restablecer tu contraseña.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        // Botón volver a login
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Volver a iniciar sesión'),
          ),
        ),
        const SizedBox(height: 16),
        // Botón reenviar
        TextButton(
          onPressed: () {
            setState(() => _emailSent = false);
          },
          child: const Text('¿No recibiste el email? Intentar de nuevo'),
        ),
      ],
    );
  }
}
