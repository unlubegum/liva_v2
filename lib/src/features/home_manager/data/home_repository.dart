import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/home_models.dart';

/// Home Manager Repository - Dummy Data Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return HomeRepository();
});

class HomeRepository {
  /// Faturalar - Ödeme tarihi bazında sıralı
  List<Bill> getBills() {
    final now = DateTime.now();
    return [
      Bill(
        id: '1',
        title: 'Elektrik',
        amount: 850,
        dueDate: now.add(const Duration(days: 2)),
        isPaid: false,
        categoryIcon: Icons.bolt_rounded,
        categoryColor: const Color(0xFFFFD166),
      ),
      Bill(
        id: '2',
        title: 'Netflix',
        amount: 200,
        dueDate: now.subtract(const Duration(days: 5)),
        isPaid: true,
        categoryIcon: Icons.movie_rounded,
        categoryColor: const Color(0xFFE50914),
      ),
      Bill(
        id: '3',
        title: 'Su',
        amount: 400,
        dueDate: now.subtract(const Duration(days: 3)),
        isPaid: false,
        categoryIcon: Icons.water_drop_rounded,
        categoryColor: const Color(0xFF5BA4E6),
      ),
      Bill(
        id: '4',
        title: 'Doğalgaz',
        amount: 1200,
        dueDate: now.add(const Duration(days: 10)),
        isPaid: false,
        categoryIcon: Icons.local_fire_department_rounded,
        categoryColor: const Color(0xFFF97316),
      ),
      Bill(
        id: '5',
        title: 'İnternet',
        amount: 350,
        dueDate: now.add(const Duration(days: 5)),
        isPaid: false,
        categoryIcon: Icons.wifi_rounded,
        categoryColor: const Color(0xFF9B8BF4),
      ),
      Bill(
        id: '6',
        title: 'Spotify',
        amount: 60,
        dueDate: now.add(const Duration(days: 15)),
        isPaid: true,
        categoryIcon: Icons.headphones_rounded,
        categoryColor: const Color(0xFF1DB954),
      ),
    ];
  }

  /// Ev eşyaları
  List<Asset> getAssets() {
    final now = DateTime.now();
    return [
      Asset(
        id: '1',
        name: 'Çamaşır Makinesi',
        purchaseDate: now.subtract(const Duration(days: 365)),
        warrantyEndDate: now.add(const Duration(days: 730)), // 2 yıl kaldı
        photoUrl: null,
        category: 'Beyaz Eşya',
        categoryColor: const Color(0xFF5BA4E6),
      ),
      Asset(
        id: '2',
        name: 'Dyson Süpürge',
        purchaseDate: now.subtract(const Duration(days: 180)),
        warrantyEndDate: now.add(const Duration(days: 545)), // 1.5 yıl kaldı
        photoUrl: null,
        category: 'Elektrikli Ev Aletleri',
        categoryColor: const Color(0xFF9B8BF4),
      ),
      Asset(
        id: '3',
        name: 'Kahve Makinesi',
        purchaseDate: now.subtract(const Duration(days: 800)),
        warrantyEndDate: now.subtract(const Duration(days: 70)), // Garanti bitti
        photoUrl: null,
        category: 'Mutfak',
        categoryColor: const Color(0xFF8B5A2B),
      ),
    ];
  }

  /// Toplam ödenecek (bu ay için)
  double getTotalPending() {
    return getBills()
        .where((bill) => !bill.isPaid)
        .fold(0.0, (sum, bill) => sum + bill.amount);
  }
}

/// State Providers for mutable data
final billsProvider = StateNotifierProvider<BillsNotifier, List<Bill>>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return BillsNotifier(repo.getBills());
});

class BillsNotifier extends StateNotifier<List<Bill>> {
  BillsNotifier(List<Bill> initial) : super(initial);

  void togglePaid(String billId) {
    state = state.map((bill) {
      if (bill.id == billId) {
        return bill.copyWith(isPaid: !bill.isPaid);
      }
      return bill;
    }).toList();
  }

  void markAsPaid(String billId) {
    state = state.map((bill) {
      if (bill.id == billId) {
        return bill.copyWith(isPaid: true);
      }
      return bill;
    }).toList();
  }

  /// Ödenmemiş faturaların toplam tutarı
  double get totalPending {
    return state
        .where((bill) => !bill.isPaid)
        .fold(0.0, (sum, bill) => sum + bill.amount);
  }
}

final assetsProvider = StateNotifierProvider<AssetsNotifier, List<Asset>>((ref) {
  final repo = ref.watch(homeRepositoryProvider);
  return AssetsNotifier(repo.getAssets());
});

class AssetsNotifier extends StateNotifier<List<Asset>> {
  AssetsNotifier(List<Asset> initial) : super(initial);

  void addAsset(Asset asset) {
    state = [...state, asset];
  }

  void removeAsset(String assetId) {
    state = state.where((a) => a.id != assetId).toList();
  }
}

/// Toplam ödenecek tutar provider
final totalPendingProvider = Provider<double>((ref) {
  final bills = ref.watch(billsProvider);
  return bills
      .where((bill) => !bill.isPaid)
      .fold(0.0, (sum, bill) => sum + bill.amount);
});
