import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/providers/onboarding_provider.dart';
import 'widgets/greeting_header.dart';
import 'widgets/daily_feed_card.dart';

/// Home Screen - Stream-based, focus-centric design
/// Clean, minimalist UI with highlight cards and daily feed
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _QuickActionsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedItems = DummyFeedData.todaysFeed;
    final userName = ref.watch(userNameProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: _buildFAB(context),
      body: CustomScrollView(
        slivers: [
          // Greeting Header
          SliverToBoxAdapter(
            child: GreetingHeader(userName: userName.isNotEmpty ? userName : 'Kullanıcı')
                .animate()
                .fadeIn(duration: 500.ms)
                .slideY(begin: -0.1, end: 0),
          ),

          // Highlight Cards Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: _HighlightCard(
                      title: 'Bugün',
                      value: '${feedItems.length}',
                      subtitle: 'Bildirim Var',
                      icon: Icons.check_circle_outline_rounded,
                      gradient: const [Color(0xFF667eea), Color(0xFF764ba2)],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _HighlightCard(
                      title: 'Bütçe',
                      value: '%20',
                      subtitle: 'Kullanıldı',
                      icon: Icons.account_balance_wallet_outlined,
                      gradient: const [Color(0xFF11998e), Color(0xFF38ef7d)],
                    ),
                  ),
                ],
              ),
            ).animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0),
          ),

          // Section Header - Daily Feed
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Günlük Akış',
                    style: AppTextStyles.headlineSmall,
                  ),
                  TextButton(
                    onPressed: () => _showAllFeed(context, feedItems),
                    child: Text(
                      'Tümünü Gör',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          ),

          // Daily Feed List
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = feedItems[index];
                  return DailyFeedCard(
                    item: item,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${item.module} açılıyor: ${item.title}'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: item.accentColor,
                        ),
                      );
                    },
                  ).animate(delay: Duration(milliseconds: 100 * index))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0);
                },
                childCount: feedItems.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => _showQuickActions(context),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  void _showAllFeed(BuildContext context, List<FeedItem> items) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Tüm Bildirimler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                itemCount: items.length,
                itemBuilder: (context, index) => DailyFeedCard(
                  item: items[index],
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Neumorphic Highlight Card
class _HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _HighlightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          // Neumorphic light shadow
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: 12,
            offset: const Offset(-4, -4),
          ),
          // Neumorphic dark shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Icon
          Positioned(
            right: -8,
            top: -8,
            child: Icon(
              icon,
              size: 64,
              color: gradient[0].withOpacity(0.1),
            ),
          ),
          // Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardMeta.copyWith(
                  color: gradient[0],
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: gradient,
                ).createShader(bounds),
                child: Text(
                  value,
                  style: AppTextStyles.summaryCount.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Quick Actions Bottom Sheet
class _QuickActionsSheet extends StatelessWidget {
  const _QuickActionsSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textTertiary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Hızlı Ekle',
            style: AppTextStyles.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          
          // Quick Action Items
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickActionItem(
                icon: Icons.receipt_long_rounded,
                label: 'Harcama',
                color: AppColors.budgetAccent,
                onTap: () async {
                  Navigator.pop(context);
                  // Open Budget Screen with Add Sheet logic if possible, 
                  // or just navigate to Budget for now.
                  // Ideally: ref.read(budgetNavigationProvider).openAddSheet();
                  // For now, let's navigate to Budget Screen and maybe pass an extra?
                  // Or better, show the Budget Add Sheet directly here?
                  // Let's navigate to Budget Screen for simplicity as the add sheet mock is inside it.
                  GoRouter.of(context).push('/budget'); 
                },
              ),
              _QuickActionItem(
                icon: Icons.check_circle_outline_rounded,
                label: 'Görev',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Görev ekleme açılıyor...')),
                  );
                },
              ),
              _QuickActionItem(
                icon: Icons.water_drop_rounded,
                label: 'Su',
                color: AppColors.travelAccent,
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Su kaydedildi!')),
                  );
                },
              ),
              _QuickActionItem(
                icon: Icons.fitness_center_rounded,
                label: 'Egzersiz',
                color: AppColors.fitnessAccent,
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context).push('/fitness');
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// Quick Action Item Widget
class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.bubbleLabel.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
