import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/travel_repository.dart';
import '../domain/travel_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRIP DETAIL SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class TripDetailScreen extends ConsumerStatefulWidget {
  final String tripId;
  const TripDetailScreen({super.key, required this.tripId});

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tripsAsync = ref.watch(tripsStreamProvider);
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

    return tripsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Hata: $e'))),
      data: (trips) {
        final trip = trips.firstWhere(
          (t) => t.id == widget.tripId,
          orElse: () => throw Exception('Trip bulunamadı'),
        );

        return Scaffold(
          backgroundColor: AppColors.background,
          body: NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 240, pinned: true,
                backgroundColor: trip.accentColor,
                leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter, end: Alignment.bottomCenter,
                          colors: [trip.accentColor.withValues(alpha: 0.9), trip.accentColor],
                        ),
                      ),
                    ),
                    Positioned(right: -30, bottom: -30, child: Opacity(opacity: 0.15, child: Text(trip.emoji, style: const TextStyle(fontSize: 180)))),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text(trip.emoji, style: const TextStyle(fontSize: 40)),
                          const SizedBox(height: 8),
                          Text(trip.destination, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('${trip.startDate.day} ${months[trip.startDate.month - 1]} - ${trip.endDate.day} ${months[trip.endDate.month - 1]} ${trip.endDate.year}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8))),
                        ]),
                      ),
                    ),
                  ]),
                ),
                bottom: TabBar(
                  controller: _tabController, indicatorColor: Colors.white, indicatorWeight: 3,
                  labelColor: Colors.white, unselectedLabelColor: Colors.white70,
                  tabs: const [Tab(text: 'Genel Bakış'), Tab(text: 'Akıllı Valiz')],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _OverviewTab(trip: trip),
                _PackingTab(trip: trip, ref: ref),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ═══════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  final Trip trip;
  const _OverviewTab({required this.trip});

  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(16), children: [
    // Duration Card
    _InfoCard(icon: Icons.date_range_rounded, title: 'Süre', value: '${trip.duration} gün', color: AppColors.primary),
    const SizedBox(height: 12),

    // Status Card
    _InfoCard(
      icon: trip.isUpcoming ? Icons.flight_takeoff_rounded : Icons.check_circle_rounded,
      title: 'Durum',
      value: trip.isUpcoming ? '${trip.daysUntil} gün sonra' : 'Tamamlandı',
      color: trip.isUpcoming ? AppColors.warning : AppColors.success,
    ),
    const SizedBox(height: 20),

    // Notes
    if (trip.notes != null && trip.notes!.isNotEmpty) ...[
      Text('Notlar', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
        child: Text(trip.notes!, style: AppTextStyles.bodyMedium.copyWith(height: 1.6)),
      ),
      const SizedBox(height: 20),
    ],

    // Map Placeholder
    Text('Harita', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 12),
    Container(
      height: 180,
      decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
      child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.map_rounded, size: 48, color: AppColors.textTertiary),
        const SizedBox(height: 8),
        Text('Harita yakında eklenecek', style: TextStyle(color: AppColors.textTertiary)),
      ])),
    ),
  ]);
}

class _InfoCard extends StatelessWidget {
  final IconData icon; final String title, value; final Color color;
  const _InfoCard({required this.icon, required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 24),
      ),
      const SizedBox(width: 14),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
      ]),
    ]),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// PACKING TAB
// ═══════════════════════════════════════════════════════════════════════════

class _PackingTab extends StatelessWidget {
  final Trip trip; final WidgetRef ref;
  const _PackingTab({required this.trip, required this.ref});

  @override
  Widget build(BuildContext context) {
    final repo = ref.read(travelRepositoryProvider);
    
    // Kategorilere göre grupla
    final grouped = <PackingCategory, List<PackingItem>>{};
    for (final item in trip.packingList) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

    return ListView(padding: const EdgeInsets.all(16), children: [
      // Progress Card
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [trip.accentColor, trip.accentColor.withValues(alpha: 0.8)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          Row(children: [
            const Text('🧳', style: TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Hazırlık Durumu', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12)),
              Text('%${(trip.packProgress * 100).toInt()} Tamamlandı', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            ])),
          ]),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(value: trip.packProgress, minHeight: 10, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: const AlwaysStoppedAnimation(Colors.white)),
          ),
          const SizedBox(height: 6),
          Text('${trip.packedCount} / ${trip.packingList.length} eşya hazır', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
        ]),
      ).animate().fadeIn(duration: 300.ms),

      const SizedBox(height: 16),

      // Magic Wand Button
      GestureDetector(
        onTap: () async {
          await repo.generateAIPackingList(trip.id, trip.destination);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('✨ AI önerileri eklendi!'),
              backgroundColor: trip.accentColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ));
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          ),
          child: Row(children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Sihirli Değnek', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
              Text('Öneri Listesi Oluştur', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ])),
            Icon(Icons.chevron_right_rounded, color: AppColors.primary),
          ]),
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 300.ms),

      const SizedBox(height: 24),

      // Packing List by Category
      if (grouped.isEmpty)
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(children: [
              const Text('📦', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Henüz eşya eklenmedi', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Sihirli Değnek ile başla!', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
            ]),
          ),
        )
      else
        ...grouped.entries.map((entry) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(entry.value.first.categoryIcon, size: 18, color: entry.value.first.categoryColor),
            const SizedBox(width: 8),
            Text(entry.value.first.categoryLabel, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          ...entry.value.map((item) => _PackingItemTile(item: item, tripId: trip.id, repo: repo)),
          const SizedBox(height: 16),
        ])),
    ]);
  }
}

class _PackingItemTile extends StatelessWidget {
  final PackingItem item; final String tripId; final TravelRepository repo;
  const _PackingItemTile({required this.item, required this.tripId, required this.repo});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => repo.togglePackingItem(item.id),
    child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: item.isPacked ? AppColors.success.withValues(alpha: 0.1) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: item.isPacked ? AppColors.success.withValues(alpha: 0.3) : AppColors.textTertiary.withValues(alpha: 0.15)),
      ),
      child: Row(children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24, height: 24,
          decoration: BoxDecoration(
            color: item.isPacked ? AppColors.success : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: item.isPacked ? AppColors.success : AppColors.textTertiary, width: 2),
          ),
          child: item.isPacked ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(
          item.name,
          style: TextStyle(
            decoration: item.isPacked ? TextDecoration.lineThrough : null,
            color: item.isPacked ? AppColors.textTertiary : AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        )),
        if (item.isAutoGenerated)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
            child: Text('AI', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
      ]),
    ),
  );
}
