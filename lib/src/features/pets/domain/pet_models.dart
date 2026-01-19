import 'package:flutter/material.dart';

/// Pet türleri
enum PetType { cat, dog }

/// Parazit damla süresi
enum ParasiteDropDuration { oneMonth, threeMonths }

/// Aşı modeli  
class Vaccination {
  final String id;
  final String name;
  final String? brand; // Örn: Nobivac, Eurican, Vanguard
  final DateTime date;
  final bool isDone;

  const Vaccination({
    required this.id,
    required this.name,
    this.brand,
    required this.date,
    this.isDone = false,
  });

  Vaccination copyWith({String? id, String? name, String? brand, DateTime? date, bool? isDone}) => Vaccination(
    id: id ?? this.id, name: name ?? this.name, brand: brand ?? this.brand,
    date: date ?? this.date, isDone: isDone ?? this.isDone,
  );

  bool get isUpcoming => !isDone && date.isAfter(DateTime.now());
  bool get isOverdue => !isDone && date.isBefore(DateTime.now());
  
  String get statusText {
    if (isDone) return 'Yapıldı';
    if (isOverdue) return 'Gecikti';
    final days = date.difference(DateTime.now()).inDays;
    if (days <= 7) return '$days gün kaldı';
    return '${(days / 30).floor()} ay sonra';
  }
}

/// Parazit damlası modeli
class ParasiteDrop {
  final String id;
  final String name;
  final String brand; // Örn: Bravecto, Nexgard, Frontline
  final ParasiteDropDuration duration;
  final DateTime appliedDate;
  final bool isApplied;

  const ParasiteDrop({
    required this.id,
    required this.name,
    required this.brand,
    required this.duration,
    required this.appliedDate,
    this.isApplied = false,
  });

  ParasiteDrop copyWith({bool? isApplied, DateTime? appliedDate}) => ParasiteDrop(
    id: id, name: name, brand: brand, duration: duration,
    appliedDate: appliedDate ?? this.appliedDate, isApplied: isApplied ?? this.isApplied,
  );

  String get durationText => duration == ParasiteDropDuration.oneMonth ? '1 Aylık' : '3 Aylık';
  
  DateTime get nextDueDate => duration == ParasiteDropDuration.oneMonth
    ? appliedDate.add(const Duration(days: 30))
    : appliedDate.add(const Duration(days: 90));
  
  bool get isUpcoming => !isApplied && nextDueDate.isAfter(DateTime.now());
  bool get isOverdue => isApplied && DateTime.now().isAfter(nextDueDate);
  
  int get daysUntilNext => nextDueDate.difference(DateTime.now()).inDays;

  String get statusText {
    if (!isApplied) return 'Uygulanmadı';
    if (isOverdue) return 'Yenilenmeli!';
    if (daysUntilNext <= 7) return '$daysUntilNext gün kaldı';
    return '$daysUntilNext gün sonra yenile';
  }
}

/// Pet modeli
class Pet {
  final String id;
  final String name;
  final PetType type;
  final String breed;
  final double age;
  final double weight;
  final String? photoUrl;
  final List<String> allergies;
  final List<Vaccination> vaccinations;
  final List<ParasiteDrop> parasiteDrops;
  final Color accentColor;

  const Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.age,
    required this.weight,
    this.photoUrl,
    this.allergies = const [],
    this.vaccinations = const [],
    this.parasiteDrops = const [],
    required this.accentColor,
  });

  String get emoji => type == PetType.dog ? '🐕' : '🐈';

  String get ageText {
    if (age < 1) return '${(age * 12).round()} aylık';
    return '${age.toStringAsFixed(1)} yaş';
  }

  Vaccination? get nextVaccination {
    final upcoming = vaccinations.where((v) => !v.isDone).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return upcoming.isNotEmpty ? upcoming.first : null;
  }

  ParasiteDrop? get nextParasiteDrop {
    final active = parasiteDrops.where((p) => p.isApplied).toList()
      ..sort((a, b) => a.nextDueDate.compareTo(b.nextDueDate));
    return active.isNotEmpty ? active.first : null;
  }

  bool get hasOverdueVaccine => vaccinations.any((v) => v.isOverdue);
  bool get hasOverdueParasiteDrop => parasiteDrops.any((p) => p.isOverdue);

  Pet copyWith({
    String? id, String? name, PetType? type, String? breed,
    double? age, double? weight, String? photoUrl,
    List<String>? allergies, List<Vaccination>? vaccinations,
    List<ParasiteDrop>? parasiteDrops, Color? accentColor,
  }) => Pet(
    id: id ?? this.id, name: name ?? this.name, type: type ?? this.type,
    breed: breed ?? this.breed, age: age ?? this.age, weight: weight ?? this.weight,
    photoUrl: photoUrl ?? this.photoUrl, allergies: allergies ?? this.allergies,
    vaccinations: vaccinations ?? this.vaccinations,
    parasiteDrops: parasiteDrops ?? this.parasiteDrops,
    accentColor: accentColor ?? this.accentColor,
  );
}
