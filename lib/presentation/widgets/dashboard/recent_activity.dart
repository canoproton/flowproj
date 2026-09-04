/// ============================================
/// RECENT ACTIVITY
/// ============================================
/// Lista de atividades recentes no dashboard
/// ============================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class RecentActivity extends StatelessWidget {
  const RecentActivity({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Atividades Recentes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Ver todas'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildActivity(
                icon: Icons.folder,
                color: AppTheme.primaryColor,
                title: 'Projeto "Sistema Flow" criado',
                time: 'Há 2 horas',
              ),
              const Divider(height: 1),
              _buildActivity(
                icon: Icons.check_circle,
                color: AppTheme.successColor,
                title: 'Tarefa "Configurar ambiente" concluída',
                time: 'Há 4 horas',
              ),
              const Divider(height: 1),
              _buildActivity(
                icon: Icons.people,
                color: AppTheme.warningColor,
                title: 'João Silva entrou na equipe',
                time: 'Há 1 dia',
              ),
              const Divider(height: 1),
              _buildActivity(
                icon: Icons.description,
                color: AppTheme.infoColor,
                title: 'Documento "Contrato" atualizado',
                time: 'Há 2 dias',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivity({
    required IconData icon,
    required Color color,
    required String title,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}