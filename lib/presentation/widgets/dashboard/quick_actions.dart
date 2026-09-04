/// ============================================
/// QUICK ACTIONS
/// ============================================
/// Ações rápidas no dashboard
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ações Rápidas',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildAction(
              context,
              icon: Icons.add_circle_outline,
              label: 'Novo Projeto',
              color: AppTheme.primaryColor,
              onTap: () => context.go('/projetos/novo'),
            ),
            const Spacer(),
            _buildAction(
              context,
              icon: Icons.assignment_add,
              label: 'Nova Tarefa',
              color: AppTheme.warningColor,
              onTap: () => context.go('/tarefas/nova'),
            ),
            const Spacer(),
            _buildAction(
              context,
              icon: Icons.person_add,
              label: 'Convidar',
              color: AppTheme.successColor,
              onTap: () => context.go('/usuarios/convidar'),
            ),
            const Spacer(),
            _buildAction(
              context,
              icon: Icons.file_upload,
              label: 'Documento',
              color: AppTheme.infoColor,
              onTap: () => context.go('/documentos/upload'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAction(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}