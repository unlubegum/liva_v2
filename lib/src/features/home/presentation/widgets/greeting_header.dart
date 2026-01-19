import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Greeting header widget with time-based greeting
/// Displays "Good Morning/Afternoon/Evening" with date
class GreetingHeader extends StatelessWidget {
  final String userName;

  const GreetingHeader({
    super.key,
    this.userName = 'there',
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Günaydın';
    } else if (hour < 17) {
      return 'İyi Günler';
    } else {
      return 'İyi Akşamlar';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'];
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    
    return '${now.day} ${months[now.month - 1]}, ${weekdays[now.weekday - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary.withOpacity(0.08),
            AppColors.background,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getFormattedDate(),
            style: AppTextStyles.greetingSubtitle,
          ),
          const SizedBox(height: 4),
          Text(
            '${_getGreeting()}, $userName',
            style: AppTextStyles.greeting,
          ),
          const SizedBox(height: 20),
          // Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bugün 3 Görev',
                        style: AppTextStyles.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Harika gidiyorsun! Böyle devam et.',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
