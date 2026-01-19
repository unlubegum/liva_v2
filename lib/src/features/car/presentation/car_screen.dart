import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/car_repository.dart';
import '../domain/car_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class CarScreen extends ConsumerWidget {
  const CarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);
    final selectedVehicle = ref.watch(selectedVehicleProvider);
    final monthlyFuel = ref.watch(monthlyFuelCostProvider);

    if (vehicles.isEmpty) return const _EmptyView();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddFuelSheet(context, ref, selectedVehicle!),
        backgroundColor: selectedVehicle?.accentColor ?? AppColors.carAccent,
        child: const Icon(Icons.local_gas_station_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200, pinned: true,
            backgroundColor: selectedVehicle?.accentColor ?? AppColors.carAccent,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Arabam', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [selectedVehicle?.accentColor ?? AppColors.carAccent, (selectedVehicle?.accentColor ?? AppColors.carAccent).withOpacity(0.7)],
                  ),
                ),
                child: SafeArea(child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 70, 24, 20),
                  child: _MonthlyFuelCard(cost: monthlyFuel),
                )),
              ),
            ),
          ),

          // Vehicle Selector
          SliverToBoxAdapter(
            child: SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: vehicles.length,
                itemBuilder: (_, i) {
                  final v = vehicles[i];
                  return _VehicleChip(vehicle: v, isSelected: v.id == selectedVehicle?.id, onTap: () => ref.read(selectedVehicleIdProvider.notifier).state = v.id);
                },
              ),
            ),
          ),

          // Vehicle Stats
          if (selectedVehicle != null) ...[
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: _VehicleInfoCard(vehicle: selectedVehicle))),

            // Quick Stats Row
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverToBoxAdapter(child: Row(children: [
                Expanded(child: _StatCard(icon: Icons.speed_rounded, label: 'Kilometre', value: '${(selectedVehicle.currentOdometer / 1000).toStringAsFixed(1)}k', color: AppColors.primary)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.local_gas_station_rounded, label: 'Ort. Tüketim', value: '${selectedVehicle.averageConsumption.toStringAsFixed(1)} L', color: AppColors.warning)),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(icon: Icons.payments_rounded, label: 'Toplam Yakıt', value: '₺${(selectedVehicle.totalFuelCost / 1000).toStringAsFixed(1)}k', color: AppColors.success)),
              ])),
            ),

            // Overdue Services Warning
            if (selectedVehicle.overdueServices.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _OverdueWarning(services: selectedVehicle.overdueServices),
                ),
              ),

            // Upcoming Services
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text('Yaklaşan Servisler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final service = selectedVehicle.upcomingServices[i];
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: _ServiceTile(service: service));
                },
                childCount: selectedVehicle.upcomingServices.length,
              ),
            ),

            // Recent Fuel Logs
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text('Son Yakıt Kayıtları', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final log = selectedVehicle.fuelLogs[i];
                  return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: _FuelLogTile(log: log));
                },
                childCount: selectedVehicle.fuelLogs.length.clamp(0, 5),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }

  void _showAddFuelSheet(BuildContext context, WidgetRef ref, Vehicle vehicle) {
    final litersCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final odometerCtrl = TextEditingController(text: vehicle.currentOdometer.toStringAsFixed(0));

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textTertiary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Yakıt Ekle', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildField('Litre', litersCtrl, Icons.local_gas_station_rounded),
            const SizedBox(height: 12),
            _buildField('Litre Fiyatı (₺)', priceCtrl, Icons.attach_money_rounded),
            const SizedBox(height: 12),
            _buildField('Kilometre', odometerCtrl, Icons.speed_rounded),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () {
                  final liters = double.tryParse(litersCtrl.text) ?? 0;
                  final price = double.tryParse(priceCtrl.text) ?? 0;
                  final odometer = double.tryParse(odometerCtrl.text) ?? vehicle.currentOdometer;
                  if (liters > 0 && price > 0) {
                    ref.read(vehiclesProvider.notifier).addFuelLog(vehicle.id, FuelLog(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      date: DateTime.now(), liters: liters, pricePerLiter: price, odometer: odometer,
                    ));
                    Navigator.pop(ctx);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: vehicle.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Kaydet', style: AppTextStyles.buttonLarge),
              ),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon) => TextField(
    controller: ctrl, keyboardType: TextInputType.number,
    decoration: InputDecoration(
      labelText: label, filled: true, fillColor: AppColors.background, prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _MonthlyFuelCard extends StatelessWidget {
  final double cost;
  const _MonthlyFuelCard({required this.cost});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.3))),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.local_gas_station_rounded, color: Colors.white, size: 26),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Bu Ay Yakıt', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8))),
        Text('₺${cost.toStringAsFixed(0)}', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
      ])),
    ]),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
}

class _VehicleChip extends StatelessWidget {
  final Vehicle vehicle; final bool isSelected; final VoidCallback onTap;
  const _VehicleChip({required this.vehicle, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? vehicle.accentColor : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? vehicle.accentColor : AppColors.textTertiary.withOpacity(0.2)),
        boxShadow: isSelected ? [BoxShadow(color: vehicle.accentColor.withOpacity(0.3), blurRadius: 8)] : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(vehicle.emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 8),
        Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
          Text(vehicle.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textPrimary)),
          Text('${vehicle.brand} ${vehicle.model}', style: TextStyle(fontSize: 11, color: isSelected ? Colors.white70 : AppColors.textSecondary)),
        ]),
      ]),
    ),
  );
}

class _VehicleInfoCard extends StatelessWidget {
  final Vehicle vehicle;
  const _VehicleInfoCard({required this.vehicle});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: AppColors.surface, borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: vehicle.accentColor.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 6))],
    ),
    child: Row(children: [
      Container(
        width: 72, height: 72,
        decoration: BoxDecoration(color: vehicle.accentColor.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
        child: Center(child: Text(vehicle.emoji, style: const TextStyle(fontSize: 40))),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(vehicle.name, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('${vehicle.brand} ${vehicle.model} • ${vehicle.year}', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        Row(children: [
          _InfoBadge(Icons.local_gas_station_rounded, vehicle.fuelLabel),
          const SizedBox(width: 8),
          if (vehicle.plateNumber != null) _InfoBadge(Icons.directions_car_rounded, vehicle.plateNumber!),
        ]),
      ])),
    ]),
  ).animate().fadeIn(duration: 300.ms);
}

class _InfoBadge extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoBadge(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 14, color: AppColors.textSecondary),
      const SizedBox(width: 4),
      Text(text, style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, size: 22, color: color),
      const SizedBox(height: 8),
      Text(value, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
      Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
    ]),
  );
}

class _OverdueWarning extends StatelessWidget {
  final List<ServiceRecord> services;
  const _OverdueWarning({required this.services});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withOpacity(0.3))),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
        child: const Icon(Icons.warning_rounded, color: AppColors.error, size: 24),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Geciken Servis!', style: AppTextStyles.cardTitle.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
        Text(services.map((s) => s.typeLabel).join(', '), style: AppTextStyles.bodySmall.copyWith(color: AppColors.error.withOpacity(0.8))),
      ])),
    ]),
  ).animate().shake(delay: 500.ms, duration: 500.ms, hz: 3);
}

class _ServiceTile extends StatelessWidget {
  final ServiceRecord service;
  const _ServiceTile({required this.service});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
    child: Row(children: [
      Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: service.typeColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
        child: Icon(service.typeIcon, color: service.typeColor, size: 22),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(service.typeLabel, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
        Text('${service.daysUntilDue} gün sonra', style: TextStyle(fontSize: 12, color: service.daysUntilDue < 30 ? AppColors.warning : AppColors.textSecondary)),
      ])),
      Text('₺${service.cost.toStringAsFixed(0)}', style: AppTextStyles.cardSubtitle),
    ]),
  );
}

class _FuelLogTile extends StatelessWidget {
  final FuelLog log;
  const _FuelLogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.local_gas_station_rounded, color: AppColors.warning, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${log.liters.toStringAsFixed(1)} L', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text('${log.date.day} ${months[log.date.month - 1]} • ${log.odometer.toStringAsFixed(0)} km', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ])),
        Text('₺${log.totalCost.toStringAsFixed(0)}', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🚗', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      Text('Henüz araç eklenmedi', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
    ])),
  );
}
