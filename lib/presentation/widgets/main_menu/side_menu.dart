/// ============================================
/// SIDE MENU
/// ============================================
/// Menu lateral com 8 aplicações
/// ============================================

import 'package:flutter/material.dart';
import 'package:flowproj/core/theme/app_theme.dart';
import 'package:flowproj/presentation/widgets/main_menu/menu_item.dart';

class SideMenu extends StatelessWidget {
  final int selectedIndex;
  final List<Map<String, dynamic>> menuItems;
  final Function(int) onItemSelected;

  const SideMenu({
    super.key,
    required this.selectedIndex,
    required this.menuItems,
    required this.onItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Header do Menu
          Container(
            padding: const EdgeInsets.all(20),
            color: AppTheme.primaryColor,
            child: Row(
              children: [
                const FlutterLogo(size: 40),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SocialFlow',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'v2.0',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Itens do Menu
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: menuItems.length,
              itemBuilder: (context, index) {
                final item = menuItems[index];
                return MenuItem(
                  icon: item['icon'],
                  label: item['label'],
                  isSelected: selectedIndex == index,
                  onTap: () => onItemSelected(index),
                );
              },
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Text(
              '© SocialFlow 2026',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}