import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/auth_helpers.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CONSTANTS & HELPERS
// ─────────────────────────────────────────────────────────────────────────────

const _cardColor = Color(0xFFFAFAFA);

TextStyle _poppins(double size, {FontWeight weight = FontWeight.normal, Color? color}) =>
    GoogleFonts.poppins(fontSize: size, fontWeight: weight, color: color);

// ─────────────────────────────────────────────────────────────────────────────
// HUB SCREEN
// ─────────────────────────────────────────────────────────────────────────────

class HubScreen extends ConsumerStatefulWidget {
  const HubScreen({super.key});

  @override
  ConsumerState<HubScreen> createState() => _HubScreenState();
}

class _HubScreenState extends ConsumerState<HubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchAndSetFamilyId(ref));
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: h * 0.28),
                const Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: _BentoGrid()),
                const SizedBox(height: 120),
              ],
            ),
          ),
          Positioned(top: 0, left: 0, right: 0, child: _CurvedHeader(height: h * 0.25)),
          const Positioned(bottom: 20, left: 24, right: 24, child: _CrystalDock()),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CURVED HEADER
// ─────────────────────────────────────────────────────────────────────────────

class _CurvedHeader extends StatelessWidget {
  final double height;
  const _CurvedHeader({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.secondary]),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Color(0x30006D77), blurRadius: 20, offset: Offset(0, 8))],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    _Avatar(),
                    const SizedBox(width: 14),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Merhaba, Begüm 👋', style: _poppins(20, weight: FontWeight.w600, color: Colors.white)),
                      Text('Bugün harika görünüyorsun!', style: _poppins(14, color: Colors.white70)),
                    ]),
                  ]),
                  _NotificationBell(),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _HeaderStat(value: '12', label: 'Görev'),
                  _HeaderStat(value: '3', label: 'Hatırlatıcı'),
                  _HeaderStat(value: '€2.4K', label: 'Bütçe'),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1);
  }
}

class _Avatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52, height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white30, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: ClipOval(child: Container(color: Colors.white24, child: const Icon(Icons.person_rounded, color: Colors.white, size: 28))),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46, height: 46,
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
      child: Stack(children: [
        const Center(child: Icon(Icons.notifications_rounded, color: Colors.white, size: 24)),
        Positioned(
          top: 10, right: 10,
          child: Container(
            width: 10, height: 10,
            decoration: BoxDecoration(color: AppColors.warning, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
          ),
        ),
      ]),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  final String value, label;
  const _HeaderStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(value, style: _poppins(22, weight: FontWeight.bold, color: Colors.white)),
    Text(label, style: _poppins(12, color: Colors.white60)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// BENTO GRID
// ─────────────────────────────────────────────────────────────────────────────

class _BentoGrid extends StatelessWidget {
  const _BentoGrid();

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      // Top row
      SizedBox(
        height: 200,
        child: Row(children: [
          Expanded(child: _FamilyStatusCard().animate().fadeIn(delay: 100.ms).scale(begin: const Offset(0.95, 0.95))),
          const SizedBox(width: 12),
          Expanded(child: Column(children: [
            Expanded(child: _StatCard(icon: Icons.task_alt_rounded, color: AppColors.primary, value: '3', label: 'Aktif Görev').animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.95, 0.95))),
            const SizedBox(height: 12),
            Expanded(child: _StatCard(icon: Icons.receipt_long_rounded, color: AppColors.warning, value: '€120', label: 'Ödenecek').animate().fadeIn(delay: 300.ms).scale(begin: const Offset(0.95, 0.95))),
          ])),
        ]),
      ),
      const SizedBox(height: 12),
      // Quick actions
      const _QuickActionsCard().animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
      const SizedBox(height: 16),
      // Modules title
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(padding: const EdgeInsets.only(left: 4, bottom: 12), child: Text('Modüller', style: _poppins(16, weight: FontWeight.w600, color: AppColors.textPrimary))),
      ).animate().fadeIn(delay: 500.ms),
      // Module grid
      const _ModuleGrid(),
    ]);
  }
}

class _BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const _BentoCard({required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: _cardColor,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, spreadRadius: 2, offset: const Offset(0, 4))],
    ),
    child: child,
  );
}

class _FamilyStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) => _BentoCard(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('😊', style: TextStyle(fontSize: 48)),
      const SizedBox(height: 8),
      Text('Aile Durumu', style: _poppins(14, weight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 4),
      Text('Her şey yolunda', style: _poppins(12, weight: FontWeight.w500, color: AppColors.success)),
    ]),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, label;
  const _StatCard({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => _BentoCard(
    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 22),
      ),
      const SizedBox(width: 12),
      Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(value, style: _poppins(24, weight: FontWeight.bold, color: AppColors.textPrimary)),
        Text(label, style: _poppins(11, color: AppColors.textSecondary)),
      ]),
    ]),
  );
}

class _QuickActionsCard extends StatelessWidget {
  const _QuickActionsCard();

  @override
  Widget build(BuildContext context) => _BentoCard(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Hızlı İşlemler', style: _poppins(14, weight: FontWeight.w600, color: AppColors.textPrimary)),
      const SizedBox(height: 14),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [
        _QuickAction(key: Key('add_task'), icon: Icons.add_task_rounded, label: 'Görev', color: AppColors.primary),
        _QuickAction(key: Key('add_bill'), icon: Icons.receipt_outlined, label: 'Fatura', color: AppColors.warning),
        _QuickAction(key: Key('add_announce'), icon: Icons.campaign_rounded, label: 'Duyuru', color: AppColors.info),
        _QuickAction(key: Key('add_event'), icon: Icons.event_rounded, label: 'Etkinlik', color: AppColors.cycleAccent),
      ]),
    ]),
  );
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction({super.key, required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(children: [
    Container(
      width: 50, height: 50,
      decoration: BoxDecoration(color: color.withOpacity(0.12), shape: BoxShape.circle),
      child: Icon(icon, color: color, size: 24),
    ),
    const SizedBox(height: 6),
    Text(label, style: _poppins(10, weight: FontWeight.w500, color: AppColors.textSecondary)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// MODULE GRID
// ─────────────────────────────────────────────────────────────────────────────

const _modules = [
  (Icons.family_restroom_rounded, 'Aile', '/family', Color(0xFFFFB084)),
  (Icons.home_rounded, 'Ev', '/home-module', Color(0xFF7DD3C0)),
  (Icons.directions_car_rounded, 'Araç', '/car', Color(0xFF5BA4E6)),
  (Icons.pets_rounded, 'Evcil', '/pets', Color(0xFFFFD166)),
  (Icons.flight_rounded, 'Seyahat', '/travel', Color(0xFF9B8BF4)),
  (Icons.account_balance_wallet_rounded, 'Bütçe', '/budget', Color(0xFF4ADE80)),
];

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid();

  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
    itemCount: _modules.length,
    itemBuilder: (ctx, i) {
      final (icon, label, route, color) = _modules[i];
      return GestureDetector(
        onTap: () => ctx.push(route),
        child: Container(
          decoration: BoxDecoration(
            color: _cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(label, style: _poppins(12, weight: FontWeight.w500, color: AppColors.textPrimary)),
          ]),
        ),
      ).animate(delay: Duration(milliseconds: 600 + i * 50)).fadeIn().scale(begin: const Offset(0.9, 0.9));
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// CRYSTAL DOCK
// ─────────────────────────────────────────────────────────────────────────────

class _CrystalDock extends StatelessWidget {
  const _CrystalDock();

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    alignment: Alignment.center,
    children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8))],
              border: Border.all(color: Colors.white.withOpacity(0.5)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _DockItem(Icons.home_rounded, 'Ana Sayfa', true, () => context.go('/home')),
              _DockItem(Icons.calendar_month_rounded, 'Takvim', false, () => context.go('/calendar')),
              const SizedBox(width: 60),
              _DockItem(Icons.grid_view_rounded, 'Modüller', false, () => context.go('/hub')),
              _DockItem(Icons.settings_rounded, 'Ayarlar', false, () => context.go('/settings')),
            ]),
          ),
        ),
      ),
      Positioned(
        top: -16,
        child: GestureDetector(
          key: const Key('fab_add'),
          onTap: () {},
          child: Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppColors.primary, AppColors.secondary]),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 16, offset: const Offset(0, 6))],
            ),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
          ),
        ),
      ),
    ],
  ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3);
}

class _DockItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _DockItem(this.icon, this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: selected ? 26 : 22, color: selected ? AppColors.primary : AppColors.textTertiary),
      const SizedBox(height: 4),
      Text(label, style: _poppins(10, weight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppColors.primary : AppColors.textTertiary)),
    ]),
  );
}
