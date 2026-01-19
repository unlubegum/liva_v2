import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/car_models.dart';

/// Car Repository Provider
final carRepositoryProvider = Provider<CarRepository>((ref) => CarRepository());

class CarRepository {
  List<Vehicle> getVehicles() {
    final now = DateTime.now();
    return [
      Vehicle(
        id: 'car1',
        name: 'Günlük Araba',
        brand: 'Volkswagen',
        model: 'Golf 8',
        year: 2022,
        type: VehicleType.hatchback,
        fuelType: FuelType.gasoline,
        plateNumber: '34 ABC 123',
        currentOdometer: 24500,
        accentColor: const Color(0xFF3498DB),
        fuelLogs: [
          FuelLog(id: '1', date: now.subtract(const Duration(days: 3)), liters: 42, pricePerLiter: 42.50, odometer: 24200),
          FuelLog(id: '2', date: now.subtract(const Duration(days: 12)), liters: 38, pricePerLiter: 41.80, odometer: 23750),
          FuelLog(id: '3', date: now.subtract(const Duration(days: 25)), liters: 45, pricePerLiter: 40.90, odometer: 23200),
        ],
        serviceRecords: [
          ServiceRecord(id: 's1', type: ServiceType.oil, date: now.subtract(const Duration(days: 60)), cost: 1850, odometer: 20000, description: 'Castrol Edge 5W-30 yağ değişimi', nextDueDate: now.add(const Duration(days: 120)), nextDueOdometer: 30000),
          ServiceRecord(id: 's2', type: ServiceType.inspection, date: now.subtract(const Duration(days: 200)), cost: 750, odometer: 15000, description: 'Araç muayenesi', nextDueDate: now.add(const Duration(days: 165))),
          ServiceRecord(id: 's3', type: ServiceType.insurance, date: now.subtract(const Duration(days: 300)), cost: 8500, odometer: 12000, description: 'Kasko yenileme', nextDueDate: now.subtract(const Duration(days: 5))), // Gecikmiş!
        ],
      ),
      Vehicle(
        id: 'car2',
        name: 'Aile Arabası',
        brand: 'Toyota',
        model: 'RAV4 Hybrid',
        year: 2023,
        type: VehicleType.suv,
        fuelType: FuelType.hybrid,
        plateNumber: '06 XYZ 789',
        currentOdometer: 12800,
        accentColor: const Color(0xFF2ECC71),
        fuelLogs: [
          FuelLog(id: '4', date: now.subtract(const Duration(days: 5)), liters: 35, pricePerLiter: 43.20, odometer: 12500),
          FuelLog(id: '5', date: now.subtract(const Duration(days: 20)), liters: 32, pricePerLiter: 42.10, odometer: 11900),
        ],
        serviceRecords: [
          ServiceRecord(id: 's4', type: ServiceType.tire, date: now.subtract(const Duration(days: 30)), cost: 12000, odometer: 12000, description: 'Kış lastiği takımı', nextDueDate: now.add(const Duration(days: 150))),
        ],
      ),
    ];
  }
}

/// Seçili araç provider
final selectedVehicleIdProvider = StateProvider<String>((ref) => 'car1');

/// Tüm araçlar provider
final vehiclesProvider = StateNotifierProvider<VehiclesNotifier, List<Vehicle>>((ref) {
  final repo = ref.watch(carRepositoryProvider);
  return VehiclesNotifier(repo.getVehicles());
});

class VehiclesNotifier extends StateNotifier<List<Vehicle>> {
  VehiclesNotifier(super.initial);

  void addVehicle(Vehicle vehicle) => state = [...state, vehicle];
  
  void removeVehicle(String id) => state = state.where((v) => v.id != id).toList();
  
  void addFuelLog(String vehicleId, FuelLog log) {
    state = state.map((v) {
      if (v.id != vehicleId) return v;
      return v.copyWith(fuelLogs: [...v.fuelLogs, log], currentOdometer: log.odometer);
    }).toList();
  }
  
  void updateOdometer(String vehicleId, double odometer) {
    state = state.map((v) => v.id == vehicleId ? v.copyWith(currentOdometer: odometer) : v).toList();
  }
}

/// Seçili araç provider (derived)
final selectedVehicleProvider = Provider<Vehicle?>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final selectedId = ref.watch(selectedVehicleIdProvider);
  try {
    return vehicles.firstWhere((v) => v.id == selectedId);
  } catch (_) {
    return vehicles.isNotEmpty ? vehicles.first : null;
  }
});

/// Toplam bu ayki yakıt harcaması
final monthlyFuelCostProvider = Provider<double>((ref) {
  final vehicles = ref.watch(vehiclesProvider);
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);
  
  double total = 0;
  for (final v in vehicles) {
    for (final log in v.fuelLogs) {
      if (log.date.isAfter(startOfMonth)) {
        total += log.totalCost;
      }
    }
  }
  return total;
});
