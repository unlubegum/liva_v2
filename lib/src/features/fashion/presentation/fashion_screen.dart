import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

// ═══════════════════════════════════════════════════════════════════════════
// MODA EKRANI
// ═══════════════════════════════════════════════════════════════════════════

class FashionScreen extends StatelessWidget {
  const FashionScreen({super.key});

  static const _accentColor = Color(0xFFFF6B9D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180, pinned: true,
            backgroundColor: _accentColor,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Moda & Stil', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [_accentColor, _accentColor.withOpacity(0.7), const Color(0xFFFF8FB1)],
                  ),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                  child: _TodayOutfitCard(),
                )),
              ),
            ),
          ),

          // Quick Actions
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.4,
              children: [
                _ActionCard(icon: Icons.camera_alt_rounded, title: 'Kombin Önerisi', subtitle: 'AI ile kombini incele', color: _accentColor, onTap: () {}),
                _ActionCard(icon: Icons.collections_rounded, title: 'Gardırobum', subtitle: '48 parça', color: const Color(0xFF9B59B6), onTap: () {}),
                _ActionCard(icon: Icons.shopping_bag_rounded, title: 'İstek Listesi', subtitle: '12 ürün', color: const Color(0xFFFBBF24), onTap: () {}),
                _ActionCard(icon: Icons.trending_up_rounded, title: 'Trendler', subtitle: '2024 İlkbahar', color: const Color(0xFF3498DB), onTap: () {}),
              ],
            ),
          ),

          // Outfit Inspiration
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Text('İlham Al', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _outfitStyles.length,
                itemBuilder: (_, i) => _StyleCard(style: _outfitStyles[i]).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().slideX(begin: 0.1, end: 0),
              ),
            ),
          ),

          // Season Capsule
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 12), child: Text('Sezon Kapsülü', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _CapsuleCard())),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// Dummy data
final _outfitStyles = [
  ('Casual', '☕️', const Color(0xFFD4A574)),
  ('Business', '💼', const Color(0xFF2C3E50)),
  ('Sporty', '🏃', const Color(0xFF27AE60)),
  ('Evening', '✨', const Color(0xFF8E44AD)),
  ('Weekend', '🌿', const Color(0xFF1ABC9C)),
];

class _TodayOutfitCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3))),
    child: Row(children: [
      Container(
        width: 56, height: 56,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(14)),
        child: const Center(child: Text('👗', style: TextStyle(fontSize: 28))),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bugün Ne Giysem?', style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Hava 18°C, güneşli ☀️', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ])),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Text('Öner', style: TextStyle(color: FashionScreen._accentColor, fontWeight: FontWeight.w600, fontSize: 12)),
      ),
    ]),
  ).animate().fadeIn(duration: 400.ms);
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 22),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    ),
  );
}

class _StyleCard extends StatelessWidget {
  final (String, String, Color) style;
  const _StyleCard({required this.style});

  @override
  Widget build(BuildContext context) => Container(
    width: 130, margin: const EdgeInsets.only(right: 12),
    decoration: BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [style.$3, style.$3.withOpacity(0.7)]),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text(style.$2, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 10),
      Text(style.$1, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
    ]),
  );
}

class _CapsuleCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('🌸', style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 10),
        Text('İlkbahar Kapsülü', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: FashionScreen._accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text('33 parça', style: TextStyle(color: FashionScreen._accentColor, fontWeight: FontWeight.w600, fontSize: 11)),
        ),
      ]),
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _CapsuleItem('👕', '12'),
        _CapsuleItem('👖', '8'),
        _CapsuleItem('👗', '6'),
        _CapsuleItem('👟', '4'),
        _CapsuleItem('👜', '3'),
      ]),
    ]),
  );
}

class _CapsuleItem extends StatelessWidget {
  final String emoji, count;
  const _CapsuleItem(this.emoji, this.count);

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(emoji, style: const TextStyle(fontSize: 28)),
    const SizedBox(height: 4),
    Text(count, style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontSize: 12)),
  ]);
}
