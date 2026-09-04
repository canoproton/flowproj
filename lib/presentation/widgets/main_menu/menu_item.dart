/// ============================================
/// MENU ITEM
/// ============================================
/// Item individual do menu lateral
/// ============================================

import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryColor.withAlpha(26) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border(
                    left: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 4,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                size: 22,
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}