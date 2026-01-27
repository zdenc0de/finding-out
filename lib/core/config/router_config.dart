// lib/core/config/router_config.dart
// Configuración de rutas con GoRouter integrado con Riverpod

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/email_verification_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/events/presentation/screens/category_events_screen.dart';
import '../../features/events/presentation/screens/create_event_screen.dart';
import '../../features/events/presentation/screens/event_detail_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../widgets/main_shell.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';

/// Nombres de las rutas para evitar errores de tipeo
abstract class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyEmail = '/verify-email';
  static const String resetPassword = '/reset-password';
  static const String home = '/home';
  static const String createEvent = '/events/create';
  static const String eventDetail = '/events/:id';
  static const String categoryEvents = '/events/category/:categoryId';
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
}

/// Provider de GoRouter que escucha cambios de autenticación
///
/// Usa [authNotifierProvider] para determinar si el usuario está autenticado
/// y redirige automáticamente según el estado.
final routerProvider = Provider<GoRouter>((ref) {
  // Escuchamos el estado de autenticación
  final authState = ref.watch(authNotifierProvider);

  return GoRouter(
    // Ruta inicial: empezamos en splash mientras verificamos auth
    initialLocation: AppRoutes.splash,

    // debugLogDiagnostics: true, // Descomentar para debug

    // Lista de rutas de la aplicación
    routes: [
      // ─────────────────────────────────────────────────────────────────
      // RUTA: / (splash)
      // Pantalla de carga inicial mientras se verifica autenticación
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /login
      // Pantalla de inicio de sesión
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /register
      // Pantalla de registro de nuevo usuario
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /forgot-password
      // Pantalla de recuperación de contraseña
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /verify-email
      // Pantalla de verificación de email
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.verifyEmail,
        name: 'verifyEmail',
        builder: (context, state) {
          // Obtener email de los query params o del estado
          final email = state.uri.queryParameters['email'];
          return EmailVerificationScreen(email: email);
        },
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /reset-password
      // Pantalla para establecer nueva contraseña (después del deep link)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.resetPassword,
        name: 'resetPassword',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /home
      // Shell principal con navbar (requiere autenticación)
      // Contiene: EventsHomeScreen y EventsMapScreen
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const MainShell(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /events/category/:categoryId
      // Listado de todos los eventos de una categoría (requiere autenticación)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.categoryEvents,
        name: 'categoryEvents',
        builder: (context, state) {
          final categoryId = state.pathParameters['categoryId']!;
          return CategoryEventsScreen(categoryId: categoryId);
        },
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /events/create
      // Pantalla para crear un nuevo evento (requiere autenticación)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.createEvent,
        name: 'createEvent',
        builder: (context, state) => const CreateEventScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /events/:id
      // Detalle de un evento (requiere autenticación)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: '/events/:id',
        name: 'eventDetail',
        builder: (context, state) {
          final eventId = state.pathParameters['id']!;
          return EventDetailScreen(eventId: eventId);
        },
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /profile
      // Pantalla de perfil del usuario (requiere autenticación)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),

      // ─────────────────────────────────────────────────────────────────
      // RUTA: /profile/edit
      // Pantalla de edición de perfil (requiere autenticación)
      // ─────────────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],

    // ═══════════════════════════════════════════════════════════════════
    // REDIRECT: Lógica de protección de rutas
    //
    // Esta función se ejecuta ANTES de cada navegación y decide:
    // - Si el usuario puede acceder a la ruta solicitada
    // - Si debe ser redirigido a otra ruta
    // ═══════════════════════════════════════════════════════════════════
    redirect: (context, state) {
      // Obtenemos el estado actual de autenticación
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.loading ||
          authState.status == AuthStatus.initial;
      final isPasswordRecovery = authState.status == AuthStatus.passwordRecoveryMode;

      // Ruta que el usuario está intentando visitar
      final currentLocation = state.matchedLocation;

      // Rutas que NO requieren autenticación
      final isAuthRoute = currentLocation == AppRoutes.login ||
          currentLocation == AppRoutes.register ||
          currentLocation == AppRoutes.forgotPassword ||
          currentLocation == AppRoutes.verifyEmail ||
          currentLocation == AppRoutes.resetPassword;
      final isSplash = currentLocation == AppRoutes.splash;
      final isResetPassword = currentLocation == AppRoutes.resetPassword;

      // ─────────────────────────────────────────────────────────────────
      // CASO 0: Modo de recuperación de contraseña (deep link)
      // Redirigir a /reset-password
      // ─────────────────────────────────────────────────────────────────
      if (isPasswordRecovery && !isResetPassword) {
        return AppRoutes.resetPassword;
      }

      // ─────────────────────────────────────────────────────────────────
      // CASO 1: Estado de carga inicial
      // Mostrar splash mientras se verifica la sesión
      // ─────────────────────────────────────────────────────────────────
      if (isLoading) {
        return isSplash ? null : AppRoutes.splash;
      }

      // ─────────────────────────────────────────────────────────────────
      // CASO 1.5: Ya terminó la carga, salir del splash
      // ─────────────────────────────────────────────────────────────────
      if (isSplash) {
        return isAuthenticated ? AppRoutes.home : AppRoutes.login;
      }

      // ─────────────────────────────────────────────────────────────────
      // CASO 2: Usuario NO autenticado intenta acceder a ruta protegida
      // Redirigir a /login
      // ─────────────────────────────────────────────────────────────────
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // ─────────────────────────────────────────────────────────────────
      // CASO 3: Usuario autenticado intenta acceder a /login o /register
      // Redirigir a /home (excepto si está en reset-password)
      // ─────────────────────────────────────────────────────────────────
      if (isAuthenticated && isAuthRoute && !isResetPassword) {
        return AppRoutes.home;
      }

      // ─────────────────────────────────────────────────────────────────
      // CASO 4: Sin redirect necesario
      // El usuario puede acceder a la ruta solicitada
      // ─────────────────────────────────────────────────────────────────
      return null;
    },

    // ═══════════════════════════════════════════════════════════════════
    // ERROR PAGE: Página de error 404
    // ═══════════════════════════════════════════════════════════════════
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              PhosphorIcons.warning(PhosphorIconsStyle.duotone),
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Página no encontrada',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.matchedLocation,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),
  );
});
