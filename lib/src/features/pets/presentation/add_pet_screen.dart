import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/pet_repository.dart';
import '../domain/pet_models.dart';

/// Evcil Hayvan Ekleme Wizard'ı
class AddPetScreen extends ConsumerStatefulWidget {
  const AddPetScreen({super.key});

  @override
  ConsumerState<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends ConsumerState<AddPetScreen> {
  int _step = 0;
  PetType? _selectedType;
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();

  void _nextStep() {
    if (_step == 0 && _selectedType != null) {
      setState(() => _step = 1);
    } else if (_step == 1 && _nameController.text.isNotEmpty) {
      _createPet();
    }
  }

  void _createPet() {
    final newPet = Pet(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      type: _selectedType!,
      breed: _breedController.text.trim().isEmpty ? (_selectedType == PetType.dog ? 'Melez' : 'Tekir') : _breedController.text.trim(),
      age: double.tryParse(_ageController.text) ?? 1.0,
      weight: 5.0,
      allergies: [],
      accentColor: _selectedType == PetType.dog ? const Color(0xFFFFB347) : const Color(0xFFB19CD9),
    );
    ref.read(petsProvider.notifier).addPet(newPet);
    ref.read(selectedPetIdProvider.notifier).state = newPet.id;
    context.pop();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(
      backgroundColor: Colors.transparent, elevation: 0,
      leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
      title: Text(_step == 0 ? 'Yeni Dost' : 'Bilgiler', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: _step == 0 ? _buildStep1() : _buildStep2(),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed: (_step == 0 && _selectedType == null) || (_step == 1 && _nameController.text.isEmpty) ? null : _nextStep,
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.petsAccent, disabledBackgroundColor: AppColors.surfaceVariant, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
            child: Text(_step == 0 ? 'Devam' : 'Ekle', style: AppTextStyles.buttonLarge),
          ),
        ),
      ),
    ),
  );

  Widget _buildStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text('Kedi mi Köpek mi?', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text('Yeni dostunuzun türünü seçin', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
    const SizedBox(height: 32),
    Row(children: [
      Expanded(child: _TypeCard(type: PetType.dog, isSelected: _selectedType == PetType.dog, onTap: () => setState(() => _selectedType = PetType.dog))),
      const SizedBox(width: 16),
      Expanded(child: _TypeCard(type: PetType.cat, isSelected: _selectedType == PetType.cat, onTap: () => setState(() => _selectedType = PetType.cat))),
    ]),
  ]);

  Widget _buildStep2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      Text(_selectedType == PetType.dog ? '🐕' : '🐈', style: const TextStyle(fontSize: 32)),
      const SizedBox(width: 12),
      Text('${_selectedType == PetType.dog ? 'Köpek' : 'Kedi'} bilgileri', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
    ]),
    const SizedBox(height: 24),
    _buildInput('İsim *', _nameController, Icons.pets_rounded),
    const SizedBox(height: 16),
    _buildInput('Cins (opsiyonel)', _breedController, Icons.category_rounded),
    const SizedBox(height: 16),
    _buildInput('Yaş (yıl)', _ageController, Icons.cake_rounded, isNumber: true),
  ].animate(interval: 100.ms).fadeIn().slideX(begin: 0.1, end: 0));

  Widget _buildInput(String label, TextEditingController ctrl, IconData icon, {bool isNumber = false}) => TextField(
    controller: ctrl, keyboardType: isNumber ? TextInputType.number : null,
    onChanged: (_) => setState(() {}),
    decoration: InputDecoration(
      labelText: label, filled: true, fillColor: AppColors.surface, prefixIcon: Icon(icon, color: AppColors.textSecondary),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: AppColors.petsAccent, width: 2)),
    ),
  );
}

class _TypeCard extends StatelessWidget {
  final PetType type; final bool isSelected; final VoidCallback onTap;
  const _TypeCard({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDog = type == PetType.dog;
    final color = isDog ? const Color(0xFFFFB347) : const Color(0xFFB19CD9);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? color : Colors.transparent, width: 3),
          boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))] : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(isDog ? '🐕' : '🐈', style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 12),
          Text(isDog ? 'Köpek' : 'Kedi', style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold, color: isSelected ? color : AppColors.textPrimary)),
        ]),
      ),
    ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.02, 1.02));
  }
}
