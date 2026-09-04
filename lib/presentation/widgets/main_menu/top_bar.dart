/// ============================================
/// TOP BAR
/// ============================================
/// Barra superior com saudação, avatar,
/// notificações e logout
/// ============================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TopBar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;

  const TopBar({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
  });

  String get initials {
    final names = userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return userName.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Saudação
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo(a), $userName',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                userEmail,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),

          // Ações
          Row(
            children: [
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
                onPressed: () {
                  // TODO: Implementar notificações
                },
                tooltip: 'Notificações',
              ),

              const SizedBox(width: 4),

              // Avatar
              CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withAlpha(26),
                radius: 20,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Logout
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: onLogout,
                tooltip: 'Sair',
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ],
      ),
    );
  }
}