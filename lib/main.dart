// lib/main.dart
// Punto de entrada de la aplicación Finding Out

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/router_config.dart';
import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';

void main() async {
  // Aseguramos que los bindings de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  // Cargamos las variables de entorno
  await dotenv.load(fileName: '.env');

  // Inicializamos Supabase antes de correr la app
  await SupabaseConfig.initialize();

  // Ejecutamos la app envuelta en ProviderScope para Riverpod
  runApp(const ProviderScope(child: MyApp()));
}

/// Widget raíz de la aplicación
///
/// Usa [ConsumerWidget] para acceder al [routerProvider] de GoRouter.
/// El router maneja toda la navegación y protección de rutas.
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtenemos la instancia de GoRouter del provider
    final router = ref.watch(routerProvider);

    // ─────────────────────────────────────────────────────────────────
    // MaterialApp.router: Versión de MaterialApp para usar con GoRouter
    //
    // Diferencias con MaterialApp normal:
    // - No usa 'home:' ni 'routes:'
    // - Usa 'routerConfig:' para delegar toda la navegación a GoRouter
    // ─────────────────────────────────────────────────────────────────
    return MaterialApp.router(
      // Configuración básica
      title: 'Finding Out',
      debugShowCheckedModeBanner: false,

      // Tema centralizado desde AppTheme
      theme: AppTheme.light,

      // GoRouter maneja toda la navegación
      routerConfig: router,
    );
  }
}
