/// ============================================
/// CONFIGURAÇÃO DE ROTAS
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main_menu_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/providers/auth/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // Se está autenticado e tenta ir para login, redireciona para /home
      if (isAuthenticated && isLoginRoute) {
        return '/home';
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

      // Rota Home com ShellRoute (menu lateral fixo)
      ShellRoute(
        builder: (context, state, child) {
          return MainMenuScreen(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const DashboardScreen(),
            routes: [
              GoRoute(
                path: 'dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
              GoRoute(
                path: 'usuarios',
                name: 'usuarios',
                builder: (context, state) => const Center(
                  child: Text('Usuários - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'projetos',
                name: 'projetos',
                builder: (context, state) => const Center(
                  child: Text('Projetos - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'tarefas',
                name: 'tarefas',
                builder: (context, state) => const Center(
                  child: Text('Tarefas - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'operacional',
                name: 'operacional',
                builder: (context, state) => const Center(
                  child: Text('Operacional - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'contabilidade',
                name: 'contabilidade',
                builder: (context, state) => const Center(
                  child: Text('Contabilidade - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'financeiro',
                name: 'financeiro',
                builder: (context, state) => const Center(
                  child: Text('Financeiro - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'documentos',
                name: 'documentos',
                builder: (context, state) => const Center(
                  child: Text('Documentos - Em desenvolvimento'),
                ),
              ),
              GoRoute(
                path: 'ia',
                name: 'ia',
                builder: (context, state) => const Center(
                  child: Text('IA - Em desenvolvimento'),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}