import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standardized loading widget
class AppLoading extends StatelessWidget {
  final String? message;
  final Color? color;
  
  const AppLoading({super.key, this.message, this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppColors.primary,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Inline loading indicator
class AppLoadingInline extends StatelessWidget {
  final double size;
  final Color? color;
  
  const AppLoadingInline({super.key, this.size = 24, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color ?? AppColors.primary,
        strokeWidth: 2,
      ),
    );
  }
}
