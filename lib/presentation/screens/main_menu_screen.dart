/// ============================================
/// MAIN MENU SCREEN
/// ============================================
/// Tela principal com menu lateral e 8 apps
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flowproj/presentation/providers/auth/auth_provider.dart';
import 'package:flowproj/core/theme/app_theme.dart';
import 'package:flowproj/presentation/widgets/main_menu/side_menu.dart';
import 'package:flowproj/presentation/widgets/main_menu/top_bar.dart';

class MainMenuScreen extends StatefulWidget {
  final Widget child;

  const MainMenuScreen({
    super.key,
    required this.child,
  });

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _menuItems = [
    {'index': 0, 'icon': Icons.dashboard, 'label': 'Dashboard', 'route': '/home/dashboard'},
    {'index': 1, 'icon': Icons.people, 'label': 'Usuários', 'route': '/home/usuarios'},
    {'index': 2, 'icon': Icons.folder, 'label': 'Projetos', 'route': '/home/projetos'},
    {'index': 3, 'icon': Icons.checklist, 'label': 'Tarefas', 'route': '/home/tarefas'},
    {'index': 4, 'icon': Icons.local_shipping, 'label': 'Operacional', 'route': '/home/operacional'},
    {'index': 5, 'icon': Icons.account_balance, 'label': 'Contabilidade', 'route': '/home/contabilidade'},
    {'index': 6, 'icon': Icons.attach_money, 'label': 'Financeiro', 'route': '/home/financeiro'},
    {'index': 7, 'icon': Icons.folder_open, 'label': 'Documentos', 'route': '/home/documentos'},
    {'index': 8, 'icon': Icons.psychology, 'label': 'IA', 'route': '/home/ia'},
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.currentUser?.displayName ?? 'Usuário';
    final userEmail = authProvider.currentUser?.email ?? '';

    return Scaffold(
      body: Row(
        children: [
          // Menu Lateral
          SideMenu(
            selectedIndex: _selectedIndex,
            menuItems: _menuItems,
            onItemSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
              final route = _menuItems[index]['route'];
              context.go(route);
            },
          ),

          // Conteúdo Principal
          Expanded(
            child: Column(
              children: [
                // Barra Superior
                TopBar(
                  userName: userName,
                  userEmail: userEmail,
                  onLogout: () async {
                    await authProvider.logout();
                    if (context.mounted) {
                      context.go('/login');
                    }
                  },
                ),

                // ✅ Área de Conteúdo
                Expanded(
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}