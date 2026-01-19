import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/pet_repository.dart';
import '../domain/pet_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// ANA EKRAN
// ═══════════════════════════════════════════════════════════════════════════

class PetsScreen extends ConsumerWidget {
  const PetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider);
    final selectedPet = ref.watch(selectedPetProvider);

    if (pets.isEmpty) return const _EmptyPetsView();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 140, pinned: true,
            backgroundColor: selectedPet?.accentColor ?? AppColors.petsAccent,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: Colors.white), onPressed: () => Navigator.pop(context)),
            title: Text('Pati Dostlarım', style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [selectedPet?.accentColor ?? AppColors.petsAccent, (selectedPet?.accentColor ?? AppColors.petsAccent).withOpacity(0.7)],
                  ),
                ),
              ),
            ),
          ),

          // Pet Avatars Bar (Fixed Overflow: Increased Height)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 120, // Increased from 100 to 120 to prevent overflow
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: pets.length + 1,
                itemBuilder: (_, i) {
                  if (i == pets.length) {
                    return _AddPetButton(onTap: () => context.push('/pet-add'));
                  }
                  final pet = pets[i];
                  final isSelected = pet.id == selectedPet?.id;
                  return _PetAvatar(pet: pet, isSelected: isSelected, onTap: () => ref.read(selectedPetIdProvider.notifier).state = pet.id);
                },
              ),
            ),
          ),

          // Selected Pet Dashboard
          if (selectedPet != null) ...[
            // Identity Card
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(16), child: _IdentityCard(pet: selectedPet))),
            
            // Action Grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid.count(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.3,
                children: [
                  _ActionCard(
                    icon: Icons.vaccines_rounded, title: 'Aşı Takvimi',
                    subtitle: selectedPet.nextVaccination != null ? '${selectedPet.nextVaccination!.name} (${selectedPet.nextVaccination!.statusText})' : 'Tamamlandı',
                    color: selectedPet.hasOverdueVaccine ? AppColors.error : AppColors.success,
                    onTap: () {},
                  ),
                  _ActionCard(
                    icon: Icons.pest_control_rounded, title: 'Parazit Takibi',
                    subtitle: selectedPet.nextParasiteDrop != null ? '${selectedPet.nextParasiteDrop!.daysUntilNext} gün kaldı' : 'Planlanmadı',
                    color: selectedPet.hasOverdueParasiteDrop ? AppColors.error : AppColors.primary,
                    onTap: () {},
                  ),
                ],
              ),
            ),

            // AI Trainer (Only for dogs)
            if (selectedPet.type == PetType.dog)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _AITrainerCard(pet: selectedPet, onTap: () => context.push('/pet-trainer')),
                ),
              ),

             // AI Food Analysis Button (Previously in Grid, moved here for better layout or kept in grid? Kept AITrainer, maybe add food analysis as a card)
             SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: _ActionRowCard(
                    icon: Icons.camera_alt_rounded,
                    title: 'AI Mama Analizi',
                    subtitle: 'Mamayı tara, içeriğini öğren',
                    color: AppColors.primary,
                    onTap: () => context.push('/pet-food'),
                  ),
                ),
              ),

            // Parasite Drops Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Parazit Koruması', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.info.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text('Damlalar', style: TextStyle(color: AppColors.info, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _ParasiteDropTile(drop: selectedPet.parasiteDrops[i], petId: selectedPet.id, ref: ref),
                ),
                childCount: selectedPet.parasiteDrops.length,
              ),
            ),

            // Vaccinations List
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Aşı Geçmişi', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: _VaccineTile(vaccine: selectedPet.vaccinations[i], petId: selectedPet.id, ref: ref),
                ),
                childCount: selectedPet.vaccinations.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _PetAvatar extends StatelessWidget {
  final Pet pet; final bool isSelected; final VoidCallback onTap;
  const _PetAvatar({required this.pet, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 80, // Slightly wider for better text fit
      margin: const EdgeInsets.only(right: 12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: pet.accentColor.withOpacity(isSelected ? 1 : 0.3),
            shape: BoxShape.circle,
            border: Border.all(color: isSelected ? pet.accentColor : Colors.transparent, width: 3),
            boxShadow: isSelected ? [BoxShadow(color: pet.accentColor.withOpacity(0.4), blurRadius: 8)] : null,
          ),
          child: Center(child: Text(pet.emoji, style: const TextStyle(fontSize: 30))),
        ),
        const SizedBox(height: 8),
        Text(pet.name, style: TextStyle(fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? AppColors.textPrimary : AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
      ]),
    ),
  ).animate(target: isSelected ? 1 : 0).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
}

class _AddPetButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPetButton({required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 80,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, shape: BoxShape.circle, border: Border.all(color: AppColors.textTertiary.withOpacity(0.3), width: 2, strokeAlign: BorderSide.strokeAlignInside)),
          child: Icon(Icons.add_rounded, color: AppColors.textSecondary, size: 28),
        ),
        const SizedBox(height: 8),
        Text('Ekle', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _IdentityCard extends StatelessWidget {
  final Pet pet;
  const _IdentityCard({required this.pet});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: [pet.accentColor, pet.accentColor.withOpacity(0.7)]),
      borderRadius: BorderRadius.circular(24),
      boxShadow: [BoxShadow(color: pet.accentColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 64, height: 64,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: Center(child: Text(pet.emoji, style: const TextStyle(fontSize: 36))),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(pet.name, style: AppTextStyles.headlineMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(pet.breed, style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.8))),
        ])),
      ]),
      const SizedBox(height: 16),
      Row(children: [
        _InfoChip(Icons.cake_rounded, pet.ageText),
        const SizedBox(width: 12),
        _InfoChip(Icons.monitor_weight_rounded, '${pet.weight} kg'),
      ]),
      if (pet.allergies.isNotEmpty) ...[
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 8, children: pet.allergies.map((a) => _AllergyChip(a)).toList()),
      ],
    ]),
  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0);
}

class _InfoChip extends StatelessWidget {
  final IconData icon; final String text;
  const _InfoChip(this.icon, this.text);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 16, color: Colors.white),
      const SizedBox(width: 6),
      Text(text, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
    ]),
  );
}

class _AllergyChip extends StatelessWidget {
  final String allergy;
  const _AllergyChip(this.allergy);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: AppColors.error.withOpacity(0.9), borderRadius: BorderRadius.circular(12)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.warning_rounded, size: 14, color: Colors.white),
      const SizedBox(width: 4),
      Text(allergy, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _ActionRowCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap;
  const _ActionRowCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
          Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ])),
        Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
      ]),
    ),
  );
}

class _ActionCard extends StatelessWidget {
  final IconData icon; final String title, subtitle; final Color color; final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: color.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: color, size: 24),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w600)),
          Text(subtitle, style: AppTextStyles.cardSubtitle.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
        ]),
      ]),
    ),
  );
}

class _AITrainerCard extends StatelessWidget {
  final Pet pet; final VoidCallback onTap;
  const _AITrainerCard({required this.pet, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryLight]),
        borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 32),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('AI Köpek Eğitmeni', style: AppTextStyles.cardTitle.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('${pet.name} havlıyor mu? Eğitmene sor.', style: AppTextStyles.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
        ])),
        Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.7), size: 28),
      ]),
    ),
  ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
}

class _VaccineTile extends StatelessWidget {
  final Vaccination vaccine; final String petId; final WidgetRef ref;
  const _VaccineTile({required this.vaccine, required this.petId, required this.ref});

  @override
  Widget build(BuildContext context) {
    final color = vaccine.isDone ? AppColors.success : (vaccine.isOverdue ? AppColors.error : AppColors.warning);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Icon(vaccine.isDone ? Icons.check_circle_rounded : Icons.vaccines_rounded, color: color, size: 24),
        ),
        title: Text(vaccine.name, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold, decoration: vaccine.isDone ? TextDecoration.lineThrough : null, color: vaccine.isDone ? AppColors.textTertiary : AppColors.textPrimary)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (vaccine.brand != null)
            Text(vaccine.brand!, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(vaccine.statusText, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
        ]),
        trailing: Transform.scale(
          scale: 1.2,
          child: Checkbox(
            value: vaccine.isDone,
            activeColor: AppColors.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            onChanged: (_) => ref.read(petsProvider.notifier).toggleVaccination(petId, vaccine.id),
          ),
        ),
      ),
    );
  }
}

class _ParasiteDropTile extends StatelessWidget {
  final ParasiteDrop drop; final String petId; final WidgetRef ref;
  const _ParasiteDropTile({required this.drop, required this.petId, required this.ref});

  @override
  Widget build(BuildContext context) {
    final color = drop.isOverdue ? AppColors.error : AppColors.info;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.water_drop_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(drop.name, style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.bold)),
              Text(drop.brand, style: TextStyle(fontSize: 13, color: AppColors.textPrimary)),
            ])),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.textTertiary.withOpacity(0.2))),
              child: Text(drop.durationText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Text(drop.statusText, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold))),
            SizedBox(
              height: 36,
              child: ElevatedButton(
                onPressed: () => ref.read(petsProvider.notifier).toggleParasiteDrop(petId, drop.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: drop.isOverdue ? AppColors.error : AppColors.surfaceVariant,
                  foregroundColor: drop.isOverdue ? Colors.white : AppColors.textPrimary,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(drop.isOverdue ? 'Yenile' : 'Uygulandı'),
              ),
            ),
          ]),
        ]),
      ),
    );
  }
}

class _EmptyPetsView extends StatelessWidget {
  const _EmptyPetsView();

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, leading: IconButton(icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context))),
    body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('🐾', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      Text('Henüz evcil hayvan eklenmedi', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: () => context.push('/pet-add'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Evcil Hayvan Ekle'),
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.petsAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
      ),
    ])),
  );
}
