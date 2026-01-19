import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Calendar Screen - Global takvim görünümü (Placeholder)
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    final months = [
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.background,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
              title: Text(
                'Takvim',
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.travelAccent.withOpacity(0.08),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Current Month Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${months[now.month - 1]} ${now.year}',
                    style: AppTextStyles.headlineSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ),

          // Weekday Headers
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: weekdays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Calendar Grid (Simple placeholder)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: 35,
                  itemBuilder: (context, index) {
                    // Simple calendar logic
                    final firstDay = DateTime(now.year, now.month, 1).weekday;
                    final dayNumber = index - firstDay + 2;
                    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
                    final isValid = dayNumber > 0 && dayNumber <= daysInMonth;
                    final isToday = dayNumber == now.day && isValid;

                    return Container(
                      decoration: BoxDecoration(
                        color: isToday
                            ? AppColors.primary
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          isValid ? dayNumber.toString() : '',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: isToday
                                ? Colors.white
                                : AppColors.textPrimary,
                            fontWeight: isToday
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          ),

          // Upcoming Events Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Yaklaşan Etkinlikler',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ).animate().fadeIn(delay: 300.ms),
          ),

          // Placeholder events
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
              child: Column(
                children: [
                  _EventCard(
                    title: 'Veteriner Randevusu',
                    time: 'Yarın, 14:00',
                    color: AppColors.petsAccent,
                    icon: Icons.pets_rounded,
                  ),
                  const SizedBox(height: 12),
                  _EventCard(
                    title: 'Netflix Abonelik',
                    time: '3 gün sonra',
                    color: AppColors.budgetAccent,
                    icon: Icons.subscriptions_rounded,
                  ),
                  const SizedBox(height: 12),
                  _EventCard(
                    title: 'Araba Servisi',
                    time: 'Gelecek hafta',
                    color: AppColors.carAccent,
                    icon: Icons.build_rounded,
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

/// Event card widget
class _EventCard extends StatelessWidget {
  final String title;
  final String time;
  final Color color;
  final IconData icon;

  const _EventCard({
    required this.title,
    required this.time,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(
            color: color,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    );
  }
}
