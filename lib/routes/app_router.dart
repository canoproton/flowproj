import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../presentation/providers/auth/auth_provider.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/main_menu_screen.dart';
import '../presentation/screens/dashboard/dashboard_screen.dart';
import '../presentation/screens/usuarios/usuarios_list_screen.dart';
import '../presentation/screens/usuarios/usuarios_form_screen.dart';
import '../presentation/screens/usuarios/usuarios_detail_screen.dart';
import '../presentation/screens/projetos/projetos_list_screen.dart';
import '../presentation/screens/tarefas/tarefas_list_screen.dart';
import '../presentation/screens/operacional/operacional_list_screen.dart';
import '../presentation/screens/contabilidade/contabilidade_list_screen.dart';
import '../presentation/screens/financeiro/financeiro_list_screen.dart';
import '../presentation/screens/documentos/documentos_list_screen.dart';
import '../presentation/screens/ia/ia_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final authProvider = context.read<AuthProvider>();
      final isLoggedIn = authProvider.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/home/dashboard';  // ✅ CORRETO
      }
      return null;
    },
    routes: [
      // ============================================
      // ROTA DE LOGIN
      // ============================================
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // ============================================
      // ROTA PRINCIPAL COM SHELL (Menu Lateral)
      // ============================================
      ShellRoute(
        builder: (context, state, child) {
          return MainMenuScreen(child: child);
        },
        routes: [
          // Dashboard
          GoRoute(
            name: 'dashboard',
            path: '/home/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),

          // Usuários - Listagem
          GoRoute(
            name: 'usuarios',
            path: '/home/usuarios',
            builder: (context, state) => const UsuariosListScreen(),
            routes: [
              // Usuários - Formulário (Criar/Editar)
              GoRoute(
                name: 'usuarios_form',
                path: 'form',
                builder: (context, state) => const UsuariosFormScreen(),
              ),
              // Usuários - Detalhes
              GoRoute(
                name: 'usuarios_detalhes',
                path: 'detalhes/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return UsuariosDetailScreen(id: id);
                },
              ),
            ],
          ),

          // Projetos
          GoRoute(
            name: 'projetos',
            path: '/home/projetos',
            builder: (context, state) => const ProjetosListScreen(),
          ),

          // Tarefas
          GoRoute(
            name: 'tarefas',
            path: '/home/tarefas',
            builder: (context, state) => const TarefasListScreen(),
          ),

          // Operacional
          GoRoute(
            name: 'operacional',
            path: '/home/operacional',
            builder: (context, state) => const OperacionalListScreen(),
          ),

          // Contabilidade
          GoRoute(
            name: 'contabilidade',
            path: '/home/contabilidade',
            builder: (context, state) => const ContabilidadeListScreen(),
          ),

          // Financeiro
          GoRoute(
            name: 'financeiro',
            path: '/home/financeiro',
            builder: (context, state) => const FinanceiroListScreen(),
          ),

          // Documentos
          GoRoute(
            name: 'documentos',
            path: '/home/documentos',
            builder: (context, state) => const DocumentosListScreen(),
          ),

          // IA
          GoRoute(
            name: 'ia',
            path: '/home/ia',
            builder: (context, state) => const IAScreen(),
          ),
        ],
      ),
    ],
  );
}