/// ============================================
/// LOADING WIDGET
/// ============================================
/// Widget de carregamento com spinner e mensagem
/// ============================================

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../../core/theme/app_theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SpinKitFadingCircle(
            color: AppTheme.primaryColor,
            size: 48,
          ),
          const SizedBox(height: 16),
          if (message != null)
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}