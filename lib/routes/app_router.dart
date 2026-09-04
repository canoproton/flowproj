/// ============================================
/// CONFIGURAÇÃO DE ROTAS - ATUALIZADA
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main_menu_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/usuarios/usuarios_list_screen.dart';
import '../presentation/screens/usuarios/usuarios_form_screen.dart';
import '../presentation/screens/usuarios/usuarios_detail_screen.dart';
import '../presentation/providers/auth/auth_provider.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (isAuthenticated && isLoginRoute) {
        return '/home';
      }

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      return null;
    },
    routes: [
      // Login (pública)
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Home com ShellRoute
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
              // Dashboard
              GoRoute(
                path: 'dashboard',
                name: 'dashboard',
                builder: (context, state) => const DashboardScreen(),
              ),
              // Usuários
              GoRoute(
                path: 'usuarios',
                name: 'usuarios',
                builder: (context, state) => const UsuariosListScreen(),
                routes: [
                  GoRoute(
                    path: 'form',
                    name: 'usuarios_form',
                    builder: (context, state) {
                      final usuario = state.extra as ProfileModel?;
                      return UsuariosFormScreen(usuario: usuario);
                    },
                  ),
                  GoRoute(
                    path: 'detalhes/:id',
                    name: 'usuarios_detalhes',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return UsuariosDetailScreen(id: id);
                    },
                  ),
                ],
              ),
              // Outros módulos (placeholders)
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