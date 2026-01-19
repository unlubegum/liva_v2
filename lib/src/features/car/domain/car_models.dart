import 'package:flutter/material.dart';

/// Araç türleri
enum VehicleType { sedan, suv, hatchback, pickup, motorcycle }

/// Yakıt türleri
enum FuelType { gasoline, diesel, electric, hybrid, lpg }

/// Servis türleri
enum ServiceType { oil, tire, brake, filter, inspection, insurance, other }

/// Yakıt kaydı
class FuelLog {
  final String id;
  final DateTime date;
  final double liters;
  final double pricePerLiter;
  final double odometer; // km
  final String? note;

  const FuelLog({
    required this.id,
    required this.date,
    required this.liters,
    required this.pricePerLiter,
    required this.odometer,
    this.note,
  });

  double get totalCost => liters * pricePerLiter;
}

/// Servis kaydı
class ServiceRecord {
  final String id;
  final ServiceType type;
  final DateTime date;
  final double cost;
  final double odometer;
  final String description;
  final DateTime? nextDueDate;
  final double? nextDueOdometer;

  const ServiceRecord({
    required this.id,
    required this.type,
    required this.date,
    required this.cost,
    required this.odometer,
    required this.description,
    this.nextDueDate,
    this.nextDueOdometer,
  });

  String get typeLabel => switch (type) {
    ServiceType.oil => 'Yağ Değişimi',
    ServiceType.tire => 'Lastik',
    ServiceType.brake => 'Fren',
    ServiceType.filter => 'Filtre',
    ServiceType.inspection => 'Muayene',
    ServiceType.insurance => 'Sigorta',
    ServiceType.other => 'Diğer',
  };

  IconData get typeIcon => switch (type) {
    ServiceType.oil => Icons.oil_barrel_rounded,
    ServiceType.tire => Icons.tire_repair_rounded,
    ServiceType.brake => Icons.warning_rounded,
    ServiceType.filter => Icons.filter_alt_rounded,
    ServiceType.inspection => Icons.fact_check_rounded,
    ServiceType.insurance => Icons.shield_rounded,
    ServiceType.other => Icons.build_rounded,
  };

  Color get typeColor => switch (type) {
    ServiceType.oil => const Color(0xFFFFB347),
    ServiceType.tire => const Color(0xFF4A4A4A),
    ServiceType.brake => const Color(0xFFE74C3C),
    ServiceType.filter => const Color(0xFF3498DB),
    ServiceType.inspection => const Color(0xFF2ECC71),
    ServiceType.insurance => const Color(0xFF9B59B6),
    ServiceType.other => const Color(0xFF95A5A6),
  };

  bool get isUpcoming => nextDueDate != null && nextDueDate!.isAfter(DateTime.now());
  bool get isOverdue => nextDueDate != null && nextDueDate!.isBefore(DateTime.now());
  
  int get daysUntilDue => nextDueDate?.difference(DateTime.now()).inDays ?? 0;
}

/// Araç modeli
class Vehicle {
  final String id;
  final String name;
  final String brand;
  final String model;
  final int year;
  final VehicleType type;
  final FuelType fuelType;
  final String? plateNumber;
  final double currentOdometer;
  final Color accentColor;
  final List<FuelLog> fuelLogs;
  final List<ServiceRecord> serviceRecords;

  const Vehicle({
    required this.id,
    required this.name,
    required this.brand,
    required this.model,
    required this.year,
    required this.type,
    required this.fuelType,
    this.plateNumber,
    required this.currentOdometer,
    required this.accentColor,
    this.fuelLogs = const [],
    this.serviceRecords = const [],
  });

  /// Araç emoji
  String get emoji => switch (type) {
    VehicleType.sedan => '🚗',
    VehicleType.suv => '🚙',
    VehicleType.hatchback => '🚗',
    VehicleType.pickup => '🛻',
    VehicleType.motorcycle => '🏍️',
  };

  /// Yakıt türü label
  String get fuelLabel => switch (fuelType) {
    FuelType.gasoline => 'Benzin',
    FuelType.diesel => 'Dizel',
    FuelType.electric => 'Elektrik',
    FuelType.hybrid => 'Hibrit',
    FuelType.lpg => 'LPG',
  };

  /// Toplam yakıt harcaması
  double get totalFuelCost => fuelLogs.fold(0, (sum, log) => sum + log.totalCost);

  /// Ortalama yakıt tüketimi (L/100km)
  double get averageConsumption {
    if (fuelLogs.length < 2) return 0;
    final sorted = List<FuelLog>.from(fuelLogs)..sort((a, b) => a.odometer.compareTo(b.odometer));
    final totalLiters = sorted.skip(1).fold(0.0, (sum, log) => sum + log.liters);
    final totalKm = sorted.last.odometer - sorted.first.odometer;
    if (totalKm <= 0) return 0;
    return (totalLiters / totalKm) * 100;
  }

  /// Yaklaşan servisler
  List<ServiceRecord> get upcomingServices => serviceRecords.where((s) => s.isUpcoming).toList()
    ..sort((a, b) => (a.nextDueDate ?? DateTime.now()).compareTo(b.nextDueDate ?? DateTime.now()));

  /// Geciken servisler
  List<ServiceRecord> get overdueServices => serviceRecords.where((s) => s.isOverdue).toList();

  Vehicle copyWith({
    String? id, String? name, String? brand, String? model, int? year,
    VehicleType? type, FuelType? fuelType, String? plateNumber,
    double? currentOdometer, Color? accentColor,
    List<FuelLog>? fuelLogs, List<ServiceRecord>? serviceRecords,
  }) => Vehicle(
    id: id ?? this.id, name: name ?? this.name, brand: brand ?? this.brand,
    model: model ?? this.model, year: year ?? this.year, type: type ?? this.type,
    fuelType: fuelType ?? this.fuelType, plateNumber: plateNumber ?? this.plateNumber,
    currentOdometer: currentOdometer ?? this.currentOdometer, accentColor: accentColor ?? this.accentColor,
    fuelLogs: fuelLogs ?? this.fuelLogs, serviceRecords: serviceRecords ?? this.serviceRecords,
  );
}
