/// ============================================
/// DASHBOARD SCREEN
/// ============================================
/// Tela principal após o login com métricas,
/// gráficos e atividades recentes
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';  // ✅ ADICIONADO
import '../../providers/auth/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/dashboard/metric_card.dart';
import '../../widgets/dashboard/recent_activity.dart';
import '../../widgets/dashboard/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.displayName ?? 'Usuário';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bem-vindo(a)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withAlpha(179),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      userName,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Notificações
                IconButton(
                  icon: Stack(
                    children: [
                      const Icon(Icons.notifications_outlined),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: AppTheme.dangerColor,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Center(
                            child: Text(
                              '3',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  onPressed: () {},
                ),
                // Logout
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      GoRouter.of(context).go('/login');  // ✅ CORRIGIDO
                    }
                  },
                  tooltip: 'Sair',
                ),
                const SizedBox(width: 4),
              ],
            ),

            // Conteúdo
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Cards de Métricas
                  Row(
                    children: const [
                      Expanded(
                        child: MetricCard(
                          title: 'Projetos Ativos',
                          value: '12',
                          icon: Icons.folder,
                          color: AppTheme.primaryColor,
                          change: '+2 este mês',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Tarefas Pendentes',
                          value: '28',
                          icon: Icons.checklist,
                          color: AppTheme.warningColor,
                          change: '5 vencidas',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: const [
                      Expanded(
                        child: MetricCard(
                          title: 'Equipe',
                          value: '8',
                          icon: Icons.people,
                          color: AppTheme.successColor,
                          change: '+2 este mês',
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Concluídos',
                          value: '47',
                          icon: Icons.check_circle,
                          color: AppTheme.infoColor,
                          change: 'este mês',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Ações Rápidas
                  const QuickActions(),
                  const SizedBox(height: 24),

                  // Atividades Recentes
                  const RecentActivity(),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}