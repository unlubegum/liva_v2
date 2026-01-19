import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pet_models.dart';

/// Pet Repository Provider
final petRepositoryProvider = Provider<PetRepository>((ref) => PetRepository());

class PetRepository {
  List<Pet> getPets() {
    final now = DateTime.now();
    return [
      Pet(
        id: 'pasa',
        name: 'Paşa',
        type: PetType.dog,
        breed: 'Golden Retriever',
        age: 2.0,
        weight: 32.5,
        allergies: ['Tahıl'],
        accentColor: const Color(0xFFFFB347),
        vaccinations: [
          Vaccination(id: 'v1', name: 'Kuduz Aşısı', brand: 'Nobivac Rabies', date: now.subtract(const Duration(days: 60)), isDone: true),
          Vaccination(id: 'v2', name: 'Karma Aşı (DHPPi)', brand: 'Eurican DHPPi2', date: now.add(const Duration(days: 14)), isDone: false),
          Vaccination(id: 'v3', name: 'Lyme Aşısı', brand: 'Nobivac Lyme', date: now.add(const Duration(days: 90)), isDone: false),
          Vaccination(id: 'v4', name: 'Köpek Gribü (Kennel Cough)', brand: 'Nobivac KC', date: now.add(const Duration(days: 120)), isDone: false),
          Vaccination(id: 'v5', name: 'Leptospirozis', brand: 'Eurican L', date: now.subtract(const Duration(days: 180)), isDone: true),
        ],
        parasiteDrops: [
          ParasiteDrop(id: 'pd1', name: 'Dış Parazit (Pire+Kene)', brand: 'Bravecto', duration: ParasiteDropDuration.threeMonths, appliedDate: now.subtract(const Duration(days: 60)), isApplied: true),
          ParasiteDrop(id: 'pd2', name: 'İç Parazit (Solucan)', brand: 'Drontal Plus', duration: ParasiteDropDuration.threeMonths, appliedDate: now.subtract(const Duration(days: 45)), isApplied: true),
        ],
      ),
      Pet(
        id: 'mia',
        name: 'Mia',
        type: PetType.cat,
        breed: 'Scottish Fold',
        age: 4.0,
        weight: 4.2,
        allergies: [],
        accentColor: const Color(0xFFB19CD9),
        vaccinations: [
          Vaccination(id: 'v6', name: 'Kuduz Aşısı', brand: 'Nobivac Rabies', date: now.subtract(const Duration(days: 30)), isDone: true),
          Vaccination(id: 'v7', name: 'Kedi Lösemisi (FeLV)', brand: 'Purevax FeLV', date: now.add(const Duration(days: 45)), isDone: false),
          Vaccination(id: 'v8', name: 'Karma Aşı (RCP)', brand: 'Nobivac Tricat Trio', date: now.add(const Duration(days: 60)), isDone: false),
          Vaccination(id: 'v9', name: 'Kedi AIDS (FIV)', brand: 'Fel-O-Vax FIV', date: now.add(const Duration(days: 90)), isDone: false),
        ],
        parasiteDrops: [
          ParasiteDrop(id: 'pd3', name: 'Dış Parazit (Pire+Kene)', brand: 'Frontline Combo', duration: ParasiteDropDuration.oneMonth, appliedDate: now.subtract(const Duration(days: 20)), isApplied: true),
          ParasiteDrop(id: 'pd4', name: 'İç Parazit (Solucan)', brand: 'Milbemax', duration: ParasiteDropDuration.threeMonths, appliedDate: now.subtract(const Duration(days: 30)), isApplied: true),
        ],
      ),
      Pet(
        id: 'baron',
        name: 'Baron',
        type: PetType.dog,
        breed: 'Doberman',
        age: 3.5,
        weight: 38.0,
        allergies: ['Tavuk', 'Süt Ürünleri'],
        accentColor: const Color(0xFF4A4A4A),
        vaccinations: [
          Vaccination(id: 'v10', name: 'Kuduz Aşısı', brand: 'Rabisin', date: now.subtract(const Duration(days: 10)), isDone: false), // Gecikmiş!
          Vaccination(id: 'v11', name: 'Parvovirüs (CPV)', brand: 'Vanguard Plus 5', date: now.add(const Duration(days: 7)), isDone: false),
          Vaccination(id: 'v12', name: 'Karma Aşı (DHPPi)', brand: 'Nobivac DHPPi', date: now.add(const Duration(days: 30)), isDone: false),
          Vaccination(id: 'v13', name: 'Köpek Gribü (Kennel Cough)', brand: 'Bronchi-Shield', date: now.add(const Duration(days: 60)), isDone: false),
        ],
        parasiteDrops: [
          ParasiteDrop(id: 'pd5', name: 'Dış Parazit (Pire+Kene)', brand: 'NexGard Spectra', duration: ParasiteDropDuration.oneMonth, appliedDate: now.subtract(const Duration(days: 35)), isApplied: true), // Gecikmiş!
          ParasiteDrop(id: 'pd6', name: 'İç Parazit (Solucan)', brand: 'Panacur', duration: ParasiteDropDuration.threeMonths, appliedDate: now.subtract(const Duration(days: 100)), isApplied: true),
        ],
      ),
    ];
  }
}

/// Seçili pet provider
final selectedPetIdProvider = StateProvider<String>((ref) => 'pasa');

/// Tüm petler provider
final petsProvider = StateNotifierProvider<PetsNotifier, List<Pet>>((ref) {
  final repo = ref.watch(petRepositoryProvider);
  return PetsNotifier(repo.getPets());
});

class PetsNotifier extends StateNotifier<List<Pet>> {
  PetsNotifier(super.initial);

  void addPet(Pet pet) => state = [...state, pet];
  
  void removePet(String id) => state = state.where((p) => p.id != id).toList();
  
  void toggleVaccination(String petId, String vaccineId) {
    state = state.map((pet) {
      if (pet.id != petId) return pet;
      final updatedVaccines = pet.vaccinations.map((v) {
        if (v.id != vaccineId) return v;
        return v.copyWith(isDone: !v.isDone);
      }).toList();
      return pet.copyWith(vaccinations: updatedVaccines);
    }).toList();
  }

  void toggleParasiteDrop(String petId, String dropId) {
    state = state.map((pet) {
      if (pet.id != petId) return pet;
      final updatedDrops = pet.parasiteDrops.map((d) {
        if (d.id != dropId) return d;
        return d.copyWith(isApplied: !d.isApplied, appliedDate: DateTime.now());
      }).toList();
      return pet.copyWith(parasiteDrops: updatedDrops);
    }).toList();
  }
}

/// Seçili pet provider (derived)
final selectedPetProvider = Provider<Pet?>((ref) {
  final pets = ref.watch(petsProvider);
  final selectedId = ref.watch(selectedPetIdProvider);
  try {
    return pets.firstWhere((p) => p.id == selectedId);
  } catch (_) {
    return pets.isNotEmpty ? pets.first : null;
  }
});
