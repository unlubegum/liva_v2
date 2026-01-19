import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/pregnancy_repository.dart';
import '../domain/pregnancy_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class PregnancyScreen extends ConsumerWidget {
  const PregnancyScreen({super.key});

  static const _accentColor = Color(0xFFE879F9);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(pregnancyStatusProvider);
    final weekInfo = ref.watch(currentWeekInfoProvider);
    final appointments = ref.watch(upcomingAppointmentsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 260, pinned: true,
            backgroundColor: _accentColor,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Hamilelik Takibi', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [_accentColor, _accentColor.withOpacity(0.8), const Color(0xFFF0ABFC)],
                  ),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                  child: _WeekProgressCard(status: status, weekInfo: weekInfo),
                )),
              ),
            ),
          ),

          // Baby Size Card
          if (weekInfo != null)
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: _BabySizeCard(weekInfo: weekInfo))),

          // Stats Row
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverToBoxAdapter(child: Row(children: [
              Expanded(child: _StatCard(icon: Icons.calendar_today_rounded, label: 'Kalan', value: '${status.weeksUntilDue} hafta', color: _accentColor)),
              const SizedBox(width: 12),
              Expanded(child: _StatCard(icon: Icons.child_care_rounded, label: 'Trimester', value: status.trimesterLabel, color: AppColors.primary)),
            ])),
          ),

          // Upcoming Appointments
          SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Yaklaşan Randevular', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: _AppointmentTile(appointment: appointments[i])),
              childCount: appointments.length,
            ),
          ),

          // Tips
          if (weekInfo != null && weekInfo.tips.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Bu Hafta Öneriler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _TipCard(tip: weekInfo.tips[i], index: i),
                ),
                childCount: weekInfo.tips.length,
              ),
            ),
          ],

          // Symptoms
          if (weekInfo != null && weekInfo.symptoms.isNotEmpty) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.fromLTRB(16, 20, 16, 8), child: Text('Olası Belirtiler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)))),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(spacing: 8, runSpacing: 8, children: weekInfo.symptoms.map((s) => _SymptomChip(symptom: s)).toList()),
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _WeekProgressCard extends StatelessWidget {
  final PregnancyStatus status; final PregnancyWeek? weekInfo;
  const _WeekProgressCard({required this.status, this.weekInfo});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withOpacity(0.3))),
    child: Row(children: [
      SizedBox(
        width: 80, height: 80,
        child: Stack(alignment: Alignment.center, children: [
          CircularProgressIndicator(value: status.progress.clamp(0, 1), strokeWidth: 8, backgroundColor: Colors.white.withOpacity(0.2), valueColor: const AlwaysStoppedAnimation(Colors.white)),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('${status.currentWeek}', style: AppTextStyles.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28)),
            Text('hafta', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11)),
          ]),
        ]),
      ),
      const SizedBox(width: 20),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('${status.currentWeek}. Hafta, ${status.currentDay}. Gün', style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        if (weekInfo != null) Text('Bebek: ${weekInfo!.babySize} boyutunda', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13)),
        const SizedBox(height: 8),
        Text('Tahmini doğum: ${status.daysUntilDue} gün sonra', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ])),
    ]),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
}

class _BabySizeCard extends StatelessWidget {
  final PregnancyWeek weekInfo;
  const _BabySizeCard({required this.weekInfo});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: PregnancyScreen._accentColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 6))]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: PregnancyScreen._accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('👶', style: TextStyle(fontSize: 28))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bebek Gelişimi', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
          Text('${weekInfo.babyWeight.toStringAsFixed(0)}g • ${weekInfo.babyLength.toStringAsFixed(1)}cm', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])),
      ]),
      const SizedBox(height: 14),
      Text(weekInfo.babyDevelopment, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, height: 1.5)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20)),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]),
  );
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentTile({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: appointment.typeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(appointment.typeIcon, color: appointment.typeColor, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(appointment.typeLabel, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text('${appointment.date.day} ${months[appointment.date.month - 1]} • ${appointment.doctor}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          if (appointment.note != null) Text(appointment.note!, style: TextStyle(fontSize: 11, color: appointment.typeColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ])),
        Text('${appointment.date.difference(DateTime.now()).inDays} gün', style: TextStyle(fontSize: 12, color: appointment.typeColor, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _TipCard extends StatelessWidget {
  final String tip; final int index;
  const _TipCard({required this.tip, required this.index});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Container(
        width: 32, height: 32,
        decoration: BoxDecoration(color: PregnancyScreen._accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
        child: Center(child: Text('${index + 1}', style: TextStyle(color: PregnancyScreen._accentColor, fontWeight: FontWeight.bold))),
      ),
      const SizedBox(width: 12),
      Expanded(child: Text(tip, style: AppTextStyles.bodyMedium)),
    ]),
  );
}

class _SymptomChip extends StatelessWidget {
  final String symptom;
  const _SymptomChip({required this.symptom});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
    child: Text(symptom, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
  );
}
