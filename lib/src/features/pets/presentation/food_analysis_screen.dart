import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Mama Analizi Ekranı - Scanner mock
class FoodAnalysisScreen extends StatefulWidget {
  const FoodAnalysisScreen({super.key});

  @override
  State<FoodAnalysisScreen> createState() => _FoodAnalysisScreenState();
}

class _FoodAnalysisScreenState extends State<FoodAnalysisScreen> {
  bool _isScanning = false;
  bool _hasResult = false;

  void _startScan() {
    setState(() { _isScanning = true; _hasResult = false; });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _isScanning = false; _hasResult = true; });
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      leading: IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
      title: Text('Mama Tarayıcı', style: AppTextStyles.headlineSmall.copyWith(color: Colors.white)),
      centerTitle: true,
    ),
    body: Stack(children: [
      // Camera background mock
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.grey[900]!, Colors.grey[800]!, Colors.grey[900]!]),
        ),
      ),

      // Scan Frame
      Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 280, height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: _isScanning ? AppColors.primary : Colors.white.withOpacity(0.5), width: 3),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Stack(children: [
              // Corner decorations
              ...[Alignment.topLeft, Alignment.topRight, Alignment.bottomLeft, Alignment.bottomRight].map((a) => Positioned.fill(child: Align(alignment: a, child: _CornerDecor(isScanning: _isScanning)))),
              // Center icon
              Center(child: Icon(_isScanning ? Icons.autorenew_rounded : Icons.camera_alt_rounded, size: 64, color: Colors.white.withOpacity(0.4)).animate(target: _isScanning ? 1 : 0).rotate(duration: 1000.ms, curve: Curves.linear).then().rotate(duration: 1000.ms)),
              // Scanning line
              if (_isScanning)
                Positioned.fill(
                  child: Container(margin: const EdgeInsets.all(20))
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 1500.ms, color: AppColors.primary.withOpacity(0.3)),
                ),
            ]),
          ),
          const SizedBox(height: 24),
          Text(_isScanning ? 'Taranıyor...' : 'Mama paketini çerçeveye yerleştirin', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
        ]),
      ),

      // Scan Button
      Positioned(
        bottom: 60, left: 0, right: 0,
        child: Center(
          child: GestureDetector(
            onTap: _isScanning ? null : _startScan,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isScanning ? AppColors.textTertiary : AppColors.primary,
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 20)],
              ),
              child: Icon(_isScanning ? Icons.hourglass_top_rounded : Icons.qr_code_scanner_rounded, color: Colors.white, size: 36),
            ).animate(target: _isScanning ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(0.9, 0.9)),
          ),
        ),
      ),

      // Result Bottom Sheet
      if (_hasResult)
        Positioned(
          bottom: 0, left: 0, right: 0,
          child: _ResultSheet(onClose: () => setState(() => _hasResult = false)),
        ),
    ]),
  );
}

class _CornerDecor extends StatelessWidget {
  final bool isScanning;
  const _CornerDecor({required this.isScanning});

  @override
  Widget build(BuildContext context) => Container(
    width: 24, height: 24, margin: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      border: Border(
        top: BorderSide(color: isScanning ? AppColors.primary : Colors.white, width: 3),
        left: BorderSide(color: isScanning ? AppColors.primary : Colors.white, width: 3),
      ),
    ),
  );
}

class _ResultSheet extends StatelessWidget {
  final VoidCallback onClose;
  const _ResultSheet({required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(28))),
    child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Analiz Sonucu', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
        IconButton(icon: Icon(Icons.close_rounded, color: AppColors.textSecondary), onPressed: onClose),
      ]),
      const SizedBox(height: 16),
      // Score
      Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), shape: BoxShape.circle),
          child: Center(child: Text('85%', style: AppTextStyles.headlineMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Uygunluk Oranı', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text('Royal Canin - Golden Retriever', style: AppTextStyles.cardSubtitle),
        ])),
      ]),
      const SizedBox(height: 20),
      // Warnings
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Alerji Riski!', style: AppTextStyles.cardTitle.copyWith(color: AppColors.error, fontWeight: FontWeight.bold)),
            Text('Bu mama tavuk içerir. Evcil hayvanınızın alerjisi var.', style: AppTextStyles.bodySmall.copyWith(color: AppColors.error.withOpacity(0.8))),
          ])),
        ]),
      ),
      const SizedBox(height: 16),
      // Ingredients
      Text('İçerikler', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: ['Tavuk 🚫', 'Pirinç', 'Balık Yağı', 'Vitaminler', 'Mineraller'].map((i) => _IngredientChip(i, i.contains('🚫'))).toList()),
      const SizedBox(height: 24),
    ]),
  ).animate().slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOut);
}

class _IngredientChip extends StatelessWidget {
  final String name; final bool isAllergen;
  const _IngredientChip(this.name, this.isAllergen);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: isAllergen ? AppColors.error.withOpacity(0.15) : AppColors.surfaceVariant, borderRadius: BorderRadius.circular(20)),
    child: Text(name, style: TextStyle(fontSize: 12, color: isAllergen ? AppColors.error : AppColors.textSecondary, fontWeight: isAllergen ? FontWeight.bold : FontWeight.normal)),
  );
}
