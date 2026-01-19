import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Fitness Module Screen - Placeholder
class FitnessScreen extends StatelessWidget {
  const FitnessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.fitnessAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.fitnessAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fitness',
                style: AppTextStyles.displayMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Track workouts, health metrics, and goals.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.construction_rounded,
                        size: 64,
                        color: AppColors.textTertiary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Coming Soon',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
