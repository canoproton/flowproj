/// ============================================
/// CONFIGURAÇÃO DE ROTAS
/// ============================================
/// Gerencia a navegação do aplicativo usando
/// GoRouter com proteção de rotas
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/providers/auth/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      // Verificar autenticação
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Se está autenticado e tenta ir para login, redireciona para dashboard
      if (isAuthenticated && isLoginRoute) {
        return '/dashboard';
      }

      // Se não está autenticado e tenta ir para qualquer rota protegida
      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Rota de Login (pública)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Rotas Protegidas (requer autenticação)
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: Text('Dashboard - Em desenvolvimento'),
          ),
        ),
      ),
    ],
  );
}