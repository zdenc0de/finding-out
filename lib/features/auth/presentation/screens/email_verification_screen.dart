// lib/features/auth/presentation/screens/email_verification_screen.dart
// Pantalla de verificación de email

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router_config.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String? email;

  const EmailVerificationScreen({super.key, this.email});

  @override
  ConsumerState<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends ConsumerState<EmailVerificationScreen> {
  bool _canResend = true;
  int _resendCooldown = 0;

  String get _email {
    // Priorizar el email pasado como parámetro, luego el del estado
    return widget.email ??
           ref.read(authNotifierProvider).pendingEmail ??
           '';
  }

  Future<void> _handleResendEmail() async {
    if (!_canResend || _email.isEmpty) return;

    await ref.read(authNotifierProvider.notifier).resendVerificationEmail(_email);

    // Iniciar cooldown de 60 segundos
    setState(() {
      _canResend = false;
      _resendCooldown = 60;
    });

    _startCooldownTimer();
  }

  void _startCooldownTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCooldown > 0) {
        setState(() => _resendCooldown--);
        if (_resendCooldown > 0) {
          _startCooldownTimer();
        } else {
          setState(() => _canResend = true);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.status == AuthStatus.loading;

    // Escuchar cambios de estado
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.pendingVerification && next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
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
      } else if (next.status == AuthStatus.authenticated) {
        // Si el usuario se autenticó (verificó su email), ir a home
        context.go(AppRoutes.home);
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
        ),
        title: const Text('Verificar email'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icono
                Icon(
                  Icons.mark_email_unread,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 24),
                // Título
                Text(
                  'Verifica tu email',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Descripción
                Text(
                  'Te enviamos un email de confirmación a:',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Email
                Text(
                  _email.isNotEmpty ? _email : 'tu correo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Instrucciones
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildInstructionRow(
                        context,
                        Icons.inbox,
                        'Revisa tu bandeja de entrada',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionRow(
                        context,
                        Icons.touch_app,
                        'Haz clic en el enlace de verificación',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionRow(
                        context,
                        Icons.login,
                        'Vuelve aquí e inicia sesión',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Botón reenviar email
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: (_canResend && !isLoading && _email.isNotEmpty)
                        ? _handleResendEmail
                        : null,
                    icon: isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(
                      _canResend
                          ? 'Reenviar email'
                          : 'Reenviar en $_resendCooldown s',
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón ir a login
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => context.go(AppRoutes.login),
                    child: const Text('Ir a iniciar sesión'),
                  ),
                ),
                const SizedBox(height: 24),
                // Nota sobre spam
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Si no lo encuentras, revisa tu carpeta de spam',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
