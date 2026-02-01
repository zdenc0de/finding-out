// lib/features/auth/presentation/screens/forgot_password_screen.dart
// Pantalla de recuperación de contraseña - Estilo Santorini

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

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

    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.passwordResetSent) {
        if (mounted) setState(() => _emailSent = true);
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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _emailSent
                ? _buildSuccessContent()
                : _buildFormContent(isLoading),
          ),
        ),
      ),
    );
  }

  Widget _buildFormContent(bool isLoading) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // Botón de retroceso
          IconButton(
            onPressed: () => context.go(AppRoutes.login),
            icon: Icon(PhosphorIcons.arrowLeft()),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.surfaceVariant,
              padding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 32),

          // Título grande estilo Santorini
          Text(
            'Recuperar\ncontraseña',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppColors.primary,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
          ),
          const SizedBox(height: 12),

          // Subtítulo
          Text(
            'Te enviaremos un enlace para restablecer tu contraseña',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 48),

          // Campo de email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'tu@email.com',
              prefixIcon: Icon(PhosphorIcons.envelope()),
            ),
            validator: Validators.validateEmail,
          ),
          const SizedBox(height: 32),

          // Botón de enviar
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleResetPassword,
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Enviar enlace'),
            ),
          ),
          const SizedBox(height: 24),

          // Link a login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Recordaste tu contraseña?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
              TextButton(
                onPressed: () => context.go(AppRoutes.login),
                child: const Text('Inicia sesión'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        // Botón de retroceso
        IconButton(
          onPressed: () => context.go(AppRoutes.login),
          icon: Icon(PhosphorIcons.arrowLeft()),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceVariant,
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 32),

        // Icono de éxito
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.success.withAlpha(25),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            PhosphorIcons.envelopeSimpleOpen(PhosphorIconsStyle.duotone),
            size: 48,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 32),

        // Título
        Text(
          'Revisa tu\nemail',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.primary,
                height: 1.1,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 12),

        // Descripción
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
            children: [
              const TextSpan(text: 'Enviamos un enlace a '),
              TextSpan(
                text: _emailController.text.trim(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Revisa tu bandeja de entrada o la carpeta de spam.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 48),

        // Botón volver a login
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            child: const Text('Volver a iniciar sesión'),
          ),
        ),
        const SizedBox(height: 16),

        // Botón reenviar
        SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: () {
              setState(() => _emailSent = false);
            },
            child: const Text('Intentar de nuevo'),
          ),
        ),
      ],
    );
  }
}
