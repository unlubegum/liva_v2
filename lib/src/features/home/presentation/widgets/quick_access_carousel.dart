import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Quick access carousel with minimal icon bubbles
/// Horizontal scrollable list for fast module access
class QuickAccessCarousel extends StatelessWidget {
  final Function(String)? onModuleTap;

  const QuickAccessCarousel({
    super.key,
    this.onModuleTap,
  });

  static const _modules = [
    _QuickAccessItem(
      id: 'family',
      icon: Icons.family_restroom_rounded,
      label: 'Aile',
      color: AppColors.familyAccent,
    ),
    _QuickAccessItem(
      id: 'home',
      icon: Icons.home_rounded,
      label: 'Ev',
      color: AppColors.homeAccent,
    ),
    _QuickAccessItem(
      id: 'car',
      icon: Icons.directions_car_rounded,
      label: 'Araba',
      color: AppColors.carAccent,
    ),
    _QuickAccessItem(
      id: 'pets',
      icon: Icons.pets_rounded,
      label: 'Evcil Hayvan',
      color: AppColors.petsAccent,
    ),
    _QuickAccessItem(
      id: 'travel',
      icon: Icons.flight_rounded,
      label: 'Seyahat',
      color: AppColors.travelAccent,
    ),
    _QuickAccessItem(
      id: 'podcast',
      icon: Icons.podcasts_rounded,
      label: 'Podcast',
      color: AppColors.podcastAccent,
    ),
    _QuickAccessItem(
      id: 'budget',
      icon: Icons.account_balance_wallet_rounded,
      label: 'Bütçe',
      color: AppColors.budgetAccent,
    ),
    _QuickAccessItem(
      id: 'fitness',
      icon: Icons.fitness_center_rounded,
      label: 'Fitness',
      color: AppColors.fitnessAccent,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            'Hızlı Erişim',
            style: AppTextStyles.headlineSmall,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _modules.length,
            itemBuilder: (context, index) {
              final module = _modules[index];
              return _QuickAccessBubble(
                item: module,
                onTap: () => onModuleTap?.call(module.id),
              ).animate(delay: Duration(milliseconds: 50 * index))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.2, end: 0);
            },
          ),
        ),
      ],
    );
  }
}

/// Individual quick access bubble
class _QuickAccessBubble extends StatelessWidget {
  final _QuickAccessItem item;
  final VoidCallback? onTap;

  const _QuickAccessBubble({
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: item.color.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                item.icon,
                color: item.color,
                size: 26,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              style: AppTextStyles.bubbleLabel,
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for quick access items
class _QuickAccessItem {
  final String id;
  final IconData icon;
  final String label;
  final Color color;

  const _QuickAccessItem({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
  });
}
