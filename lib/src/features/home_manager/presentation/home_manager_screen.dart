import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/home_repository.dart';
import '../domain/home_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class HomeManagerScreen extends ConsumerStatefulWidget {
  const HomeManagerScreen({super.key});
  @override
  ConsumerState<HomeManagerScreen> createState() => _HomeManagerScreenState();
}

class _HomeManagerScreenState extends ConsumerState<HomeManagerScreen> with SingleTickerProviderStateMixin {
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

  void _showAddMenu() => _showSheet(
    title: 'Ne Eklemek İstersiniz?',
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      _OptionTile(Icons.receipt_long_rounded, 'Fatura Ekle', 'Yeni fatura kaydı', AppColors.budgetAccent, () {
        Navigator.pop(context);
        _showFormSheet('Yeni Fatura', AppColors.budgetAccent, [
          _buildInput('Fatura adı (örn: Elektrik)', Icons.receipt_outlined),
          _buildInput('Tutar (₺)', Icons.payments_outlined, isNumber: true),
        ]);
      }),
      const SizedBox(height: 12),
      _OptionTile(Icons.inventory_2_rounded, 'Eşya Ekle', 'Garanti takibi için', AppColors.homeAccent, () {
        Navigator.pop(context);
        _showFormSheet('Yeni Eşya', AppColors.homeAccent, [
          _buildInput('Eşya adı (örn: Buzdolabı)', Icons.inventory_2_outlined),
          _buildInput('Kategori (örn: Beyaz Eşya)', Icons.category_outlined),
        ]);
      }),
    ]),
  );

  void _showSheet({required String title, required Widget child}) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _SheetContainer(title: title, child: child),
    );
  }

  void _showFormSheet(String title, Color btnColor, List<Widget> fields) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: _SheetContainer(
          title: title,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            ...fields.map((f) => Padding(padding: const EdgeInsets.only(bottom: 12), child: f)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity, height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(backgroundColor: btnColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Kaydet', style: AppTextStyles.buttonLarge),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildInput(String hint, IconData icon, {bool isNumber = false}) => TextField(
    keyboardType: isNumber ? TextInputType.number : null,
    decoration: InputDecoration(
      hintText: hint, filled: true, fillColor: AppColors.background, prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final totalPending = ref.watch(totalPendingProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu, backgroundColor: AppColors.homeAccent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: 300, pinned: true, backgroundColor: AppColors.homeAccent,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Evim', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.homeAccent, AppColors.homeAccent.withOpacity(0.8), const Color(0xFF4ECDC4)])),
                child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(24, 60, 24, 60), child: _PulseCard(totalPending))),
              ),
            ),
            bottom: TabBar(
              controller: _tabController, indicatorColor: Colors.white, indicatorWeight: 3,
              labelColor: Colors.white, unselectedLabelColor: Colors.white70,
              tabs: const [Tab(text: 'Faturalar'), Tab(text: 'Eşyalar')],
            ),
          ),
        ],
        body: TabBarView(controller: _tabController, children: const [_BillsTab(), _AssetsTab()]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ORTAK WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _SheetContainer extends StatelessWidget {
  final String title;
  final Widget child;
  const _SheetContainer({required this.title, required this.child});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: const BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.textTertiary.withOpacity(0.3), borderRadius: BorderRadius.circular(2))),
      const SizedBox(height: 24),
      Text(title, style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      child,
      const SizedBox(height: 16),
    ]),
  );
}

class _OptionTile extends StatelessWidget {
  final IconData icon; final String title, sub; final Color color; final VoidCallback onTap;
  const _OptionTile(this.icon, this.title, this.sub, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text(sub, style: AppTextStyles.cardSubtitle),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      ]),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  final IconData icon; final String text;
  const _EmptyState(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 64, color: AppColors.textTertiary),
    const SizedBox(height: 16),
    Text(text, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textTertiary)),
  ]));
}

class _Badge extends StatelessWidget {
  final String text; final Color color;
  const _Badge(this.text, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER KARTI
// ═══════════════════════════════════════════════════════════════════════════

class _PulseCard extends StatelessWidget {
  final double total;
  const _PulseCard(this.total);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.3)),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Text('Toplam Ödenecek', style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500)),
        ]),
        const SizedBox(height: 12),
        Text('₺${total.toStringAsFixed(0)}', style: AppTextStyles.displayLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 36)),
        const SizedBox(height: 2),
        Text('Bu ay için bekleyen faturalar', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.7))),
      ]),
    ),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0);
}

// ═══════════════════════════════════════════════════════════════════════════
// FATURALAR TAB
// ═══════════════════════════════════════════════════════════════════════════

class _BillsTab extends ConsumerWidget {
  const _BillsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bills = ref.watch(billsProvider);
    final sorted = List<Bill>.from(bills)..sort((a, b) {
      if (a.isPaid != b.isPaid) return a.isPaid ? 1 : -1;
      return a.dueDate.compareTo(b.dueDate);
    });

    if (sorted.isEmpty) return const _EmptyState(Icons.receipt_long_outlined, 'Henüz fatura yok');

    return ListView.builder(
      padding: const EdgeInsets.all(16), itemCount: sorted.length,
      itemBuilder: (_, i) => _BillCard(sorted[i], () => ref.read(billsProvider.notifier).togglePaid(sorted[i].id))
          .animate(delay: Duration(milliseconds: 50 * i)).fadeIn(duration: 300.ms).slideX(begin: 0.1, end: 0),
    );
  }
}

class _BillCard extends StatelessWidget {
  final Bill bill; final VoidCallback onToggle;
  const _BillCard(this.bill, this.onToggle);

  static const _months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];

  @override
  Widget build(BuildContext context) {
    final paid = bill.isPaid, overdue = bill.isOverdue, soon = bill.isDueSoon;

    return Dismissible(
      key: Key(bill.id),
      direction: paid ? DismissDirection.none : DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: AppColors.budgetAccent, borderRadius: BorderRadius.circular(20)),
        alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 24),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_circle_rounded, color: Colors.white), SizedBox(width: 8), Text('Ödendi', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ),
      confirmDismiss: (_) async { onToggle(); return false; },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: bill.categoryColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(color: bill.categoryColor.withOpacity(paid ? 0.1 : 0.15), borderRadius: BorderRadius.circular(14)),
            child: Icon(paid ? Icons.check_circle_rounded : bill.categoryIcon, color: paid ? AppColors.success : bill.categoryColor, size: 26),
          ),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(bill.title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600, color: paid ? AppColors.textTertiary : AppColors.textPrimary, decoration: paid ? TextDecoration.lineThrough : null))),
              if (paid) const _Badge('Ödendi', AppColors.success)
              else if (overdue) const _Badge('Gecikti', AppColors.error)
              else if (soon) _Badge('${bill.daysRemaining} Gün', AppColors.warning),
            ]),
            const SizedBox(height: 4),
            Text('${bill.dueDate.day} ${_months[bill.dueDate.month - 1]}', style: AppTextStyles.cardSubtitle.copyWith(color: overdue && !paid ? AppColors.error : AppColors.textSecondary)),
          ])),
          Text('₺${bill.amount.toStringAsFixed(0)}', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold, color: paid ? AppColors.textTertiary : AppColors.textPrimary)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// EŞYALAR TAB
// ═══════════════════════════════════════════════════════════════════════════

class _AssetsTab extends ConsumerWidget {
  const _AssetsTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assets = ref.watch(assetsProvider);
    if (assets.isEmpty) return const _EmptyState(Icons.inventory_2_outlined, 'Henüz eşya eklenmedi');

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 0.8),
      itemCount: assets.length,
      itemBuilder: (_, i) => _AssetCard(assets[i]).animate(delay: Duration(milliseconds: 100 * i)).fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}

class _AssetCard extends StatelessWidget {
  final Asset asset;
  const _AssetCard(this.asset);

  IconData get _icon => switch (asset.category.toLowerCase()) {
    'beyaz eşya' => Icons.kitchen_rounded,
    'elektrikli ev aletleri' => Icons.electrical_services_rounded,
    'mutfak' => Icons.coffee_rounded,
    'elektronik' => Icons.devices_rounded,
    _ => Icons.inventory_2_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final valid = asset.hasValidWarranty, progress = asset.warrantyProgress;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: asset.categoryColor.withOpacity(0.15), blurRadius: 15, offset: const Offset(0, 6))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Container(
          width: double.infinity,
          decoration: BoxDecoration(color: asset.categoryColor.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
          child: Center(child: Icon(_icon, size: 48, color: asset.categoryColor)),
        )),
        const SizedBox(height: 12),
        Text(asset.name, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(asset.category, style: AppTextStyles.cardSubtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Garanti', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          Text(asset.warrantyText, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: valid ? AppColors.success : AppColors.textTertiary)),
        ]),
        const SizedBox(height: 6),
        Stack(children: [
          Container(height: 6, decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(3))),
          FractionallySizedBox(widthFactor: progress, child: Container(
            height: 6,
            decoration: BoxDecoration(gradient: LinearGradient(colors: valid ? [AppColors.success, AppColors.homeAccent] : [AppColors.textTertiary, AppColors.textTertiary]), borderRadius: BorderRadius.circular(3)),
          )),
        ]),
      ]),
    );
  }
}
