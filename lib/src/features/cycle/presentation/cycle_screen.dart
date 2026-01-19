import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/cycle_repository.dart';
import '../domain/cycle_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class CycleScreen extends ConsumerWidget {
  const CycleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycle = ref.watch(currentCycleProvider);
    final stats = ref.watch(cycleStatsProvider);
    final todayLog = ref.watch(todayLogProvider);

    final phase = cycle.currentPhase;

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLogSheet(context, ref, todayLog),
        backgroundColor: phase.color,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 280, pinned: true,
            backgroundColor: phase.color,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Döngü Takibi', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [phase.color, phase.color.withOpacity(0.8), phase.color.withOpacity(0.6)],
                  ),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                  child: _CycleRing(cycle: cycle, phase: phase),
                )),
              ),
            ),
          ),

          // Stats Cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid.count(
              crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
              children: [
                _StatCard(
                  icon: Icons.calendar_today_rounded,
                  label: 'Sonraki Adet',
                  value: '${stats.daysUntilPeriod} gün',
                  color: CyclePhase.menstruation.color,
                ),
                _StatCard(
                  icon: Icons.favorite_rounded,
                  label: 'Yumurtlama',
                  value: stats.isInFertileWindow ? 'Bugün!' : 'Geçti',
                  color: CyclePhase.ovulation.color,
                ),
                _StatCard(
                  icon: Icons.loop_rounded,
                  label: 'Döngü Uzunluğu',
                  value: '${stats.averageCycleLength} gün',
                  color: AppColors.primary,
                ),
                _StatCard(
                  icon: Icons.water_drop_rounded,
                  label: 'Adet Süresi',
                  value: '${stats.averagePeriodLength} gün',
                  color: CyclePhase.menstruation.color,
                ),
              ],
            ),
          ),

          // Phase Info
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _PhaseCard(phase: phase))),

          // Today's Log
          if (todayLog != null) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Bugünün Kaydı', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _TodayLogCard(log: todayLog))),
          ],

          // Symptoms Quick Add
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Semptom Ekle', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: SymptomType.values.length,
                itemBuilder: (_, i) {
                  final symptom = SymptomType.values[i];
                  final isSelected = todayLog?.symptoms.contains(symptom) ?? false;
                  return _SymptomChip(symptom: symptom, isSelected: isSelected, onTap: () {});
                },
              ),
            ),
          ),

          // Mood Tracker
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Ruh Hali', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 10, runSpacing: 10,
                children: Mood.values.map((m) => _MoodChip(mood: m, isSelected: todayLog?.mood == m)).toList(),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref, DailyLog? existing) {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textTertiary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('Günlük Kayıt', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(children: [
            Expanded(child: _LogOptionCard(icon: Icons.water_drop_rounded, label: 'Adet Günü', isSelected: existing?.isFlowDay ?? false, color: CyclePhase.menstruation.color, onTap: () => ref.read(dailyLogsProvider.notifier).toggleFlowDay(DateTime.now()))),
            const SizedBox(width: 12),
            Expanded(child: _LogOptionCard(icon: Icons.thermostat_rounded, label: 'Sıcaklık', isSelected: existing?.temperature != null, color: AppColors.primary, onTap: () {})),
          ]),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.cycleAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: Text('Kaydet', style: AppTextStyles.buttonLarge),
            ),
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _CycleRing extends StatelessWidget {
  final Cycle cycle; final CyclePhase phase;
  const _CycleRing({required this.cycle, required this.phase});

  @override
  Widget build(BuildContext context) => Center(
    child: SizedBox(
      width: 160, height: 160,
      child: Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 160, height: 160,
          child: CircularProgressIndicator(
            value: cycle.progress.clamp(0, 1),
            strokeWidth: 12, backgroundColor: Colors.white.withOpacity(0.2),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            strokeCap: StrokeCap.round,
          ),
        ),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(phase.icon, color: Colors.white, size: 32),
          const SizedBox(height: 6),
          Text('Gün ${cycle.currentDay}', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(phase.label, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
        ]),
      ]),
    ),
  ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1));
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 20),
      ),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]),
  );
}

class _PhaseCard extends StatelessWidget {
  final CyclePhase phase;
  const _PhaseCard({required this.phase});

  String get _phaseDescription => switch (phase) {
    CyclePhase.menstruation => 'Adet döneminde dinlenmeye özen gösterin. Bol sıvı tüketin ve demirden zengin besinler yiyin.',
    CyclePhase.follicular => 'Enerji seviyeniz artıyor! Yeni projelere başlamak için ideal bir dönem.',
    CyclePhase.ovulation => 'En doğurgan dönemdesiniz. Sosyalleşmek ve iletişim için mükemmel bir zaman.',
    CyclePhase.luteal => 'Vücudunuz dinlenmeye hazırlanıyor. Stres yönetimi ve öz bakıma odaklanın.',
  };

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: phase.color.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: phase.color.withOpacity(0.3))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: phase.color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: Icon(phase.icon, color: phase.color, size: 24),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(phase.label, style: AppTextStyles.cardTitle.copyWith(color: phase.color, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(_phaseDescription, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.4)),
      ])),
    ]),
  );
}

class _TodayLogCard extends StatelessWidget {
  final DailyLog log;
  const _TodayLogCard({required this.log});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      if (log.mood != null) ...[
        Text(log.mood!.emoji, style: const TextStyle(fontSize: 36)),
        const SizedBox(width: 14),
      ],
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (log.mood != null) Text(log.mood!.label, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
        if (log.symptoms.isNotEmpty) ...[
          const SizedBox(height: 6),
          Wrap(spacing: 6, children: log.symptoms.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(8)),
            child: Text(s.label, style: const TextStyle(fontSize: 11)),
          )).toList()),
        ],
      ])),
      if (log.isFlowDay) Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: CyclePhase.menstruation.color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(Icons.water_drop_rounded, color: CyclePhase.menstruation.color, size: 20),
      ),
    ]),
  );
}

class _SymptomChip extends StatelessWidget {
  final SymptomType symptom; final bool isSelected; final VoidCallback onTap;
  const _SymptomChip({required this.symptom, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 72, margin: const EdgeInsets.only(right: 10),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 52, height: 52,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.cycleAccent : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isSelected ? AppColors.cycleAccent : AppColors.textTertiary.withOpacity(0.2)),
          ),
          child: Icon(symptom.icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 24),
        ),
        const SizedBox(height: 6),
        Text(symptom.label, style: TextStyle(fontSize: 10, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  );
}

class _MoodChip extends StatelessWidget {
  final Mood mood; final bool isSelected;
  const _MoodChip({required this.mood, this.isSelected = false});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.cycleAccent : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: isSelected ? AppColors.cycleAccent : AppColors.textTertiary.withOpacity(0.2)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(mood.emoji, style: const TextStyle(fontSize: 18)),
      const SizedBox(width: 6),
      Text(mood.label, style: TextStyle(fontSize: 13, color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
    ]),
  );
}

class _LogOptionCard extends StatelessWidget {
  final IconData icon; final String label; final bool isSelected; final Color color; final VoidCallback onTap;
  const _LogOptionCard({required this.icon, required this.label, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.15) : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? color : AppColors.textTertiary.withOpacity(0.2), width: isSelected ? 2 : 1),
      ),
      child: Row(children: [
        Icon(icon, color: isSelected ? color : AppColors.textSecondary, size: 24),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal, color: isSelected ? color : AppColors.textPrimary)),
      ]),
    ),
  );
}
