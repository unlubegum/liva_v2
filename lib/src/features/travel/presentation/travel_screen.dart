import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/travel_repository.dart';
import '../domain/travel_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// TRAVEL HOME SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class TravelScreen extends ConsumerWidget {
  const TravelScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final upcomingTrip = ref.watch(upcomingTripProvider);
    final pastTrips = ref.watch(pastTripsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yeni seyahat planlama çok yakında!')));
        },
        backgroundColor: AppColors.travelAccent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: upcomingTrip != null ? 340 : 120,
            pinned: true,
            backgroundColor: AppColors.travelAccent,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Seyahat', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: upcomingTrip != null
                ? _CountdownHeroCard(trip: upcomingTrip)
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [AppColors.travelAccent, AppColors.travelAccent.withOpacity(0.7)],
                      ),
                    ),
                  ),
            ),
          ),

          // Upcoming Packing Progress
          if (upcomingTrip != null && upcomingTrip.packingList.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _PackingProgressCard(trip: upcomingTrip),
              ),
            ),

          // Past Trips
          if (pastTrips.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 12), child: Text('Anılar', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: pastTrips.length,
                  itemBuilder: (_, i) => _PastTripCard(trip: pastTrips[i]).animate(delay: Duration(milliseconds: 100 * i)).fadeIn().slideX(begin: 0.1, end: 0),
                ),
              ),
            ),
          ],

          // Empty State
          if (upcomingTrip == null && pastTrips.isEmpty)
            SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('✈️', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 16),
                Text('Henüz seyahat planlanmadı', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Text('+ butonuna tıklayarak yeni bir seyahat ekle', style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary)),
              ])),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _CountdownHeroCard extends StatelessWidget {
  final Trip trip;
  const _CountdownHeroCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    
    return GestureDetector(
      onTap: () => context.push('/travel-detail', extra: trip.id),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [trip.accentColor.withOpacity(0.9), trip.accentColor, trip.accentColor.withOpacity(0.8)],
          ),
        ),
        child: Stack(children: [
          // Background Pattern
          Positioned.fill(child: Opacity(
            opacity: 0.1,
            child: Center(child: Text(trip.emoji, style: const TextStyle(fontSize: 200))),
          )),
          
          // Dark overlay gradient
          Positioned.fill(child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.3)],
              ),
            ),
          )),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.end, children: [
                // Emoji
                Text(trip.emoji, style: const TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                
                // Countdown
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('${trip.daysUntil}', style: const TextStyle(fontSize: 72, fontWeight: FontWeight.bold, color: Colors.white, height: 1)),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text('GÜN KALDI', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.9), letterSpacing: 2)),
                  ),
                ]),
                
                const SizedBox(height: 8),
                
                // Destination name
                Text(trip.destination, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                
                // Dates
                Text('${trip.startDate.day} ${months[trip.startDate.month - 1]} - ${trip.endDate.day} ${months[trip.endDate.month - 1]} • ${trip.duration} gün', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
              ]),
            ),
          ),
        ]),
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _PackingProgressCard extends StatelessWidget {
  final Trip trip;
  const _PackingProgressCard({required this.trip});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => context.push('/travel-detail', extra: trip.id),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: trip.accentColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: trip.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('🧳', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Akıllı Valiz', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Row(children: [
            Expanded(child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: trip.packProgress, backgroundColor: AppColors.surfaceVariant, valueColor: AlwaysStoppedAnimation(trip.accentColor), minHeight: 8),
            )),
            const SizedBox(width: 12),
            Text('%${(trip.packProgress * 100).toInt()}', style: TextStyle(color: trip.accentColor, fontWeight: FontWeight.bold)),
          ]),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      ]),
    ),
  );
}

class _PastTripCard extends StatelessWidget {
  final Trip trip;
  const _PastTripCard({required this.trip});

  @override
  Widget build(BuildContext context) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    
    return GestureDetector(
      onTap: () => context.push('/travel-detail', extra: trip.id),
      child: Container(
        width: 160, margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [trip.accentColor, trip.accentColor.withOpacity(0.7)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(children: [
          Positioned(right: -20, bottom: -20, child: Opacity(opacity: 0.2, child: Text(trip.emoji, style: const TextStyle(fontSize: 100)))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(trip.emoji, style: const TextStyle(fontSize: 32)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(trip.destination, style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${months[trip.startDate.month - 1]} ${trip.startDate.year}', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
