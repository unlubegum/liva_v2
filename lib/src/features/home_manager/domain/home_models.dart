import 'package:flutter/material.dart';

/// Home Manager domain models - Evim modülü

/// Fatura modeli
class Bill {
  final String id;
  final String title;
  final double amount;
  final DateTime dueDate;
  final bool isPaid;
  final IconData categoryIcon;
  final Color categoryColor;

  const Bill({
    required this.id,
    required this.title,
    required this.amount,
    required this.dueDate,
    this.isPaid = false,
    required this.categoryIcon,
    required this.categoryColor,
  });

  /// Fatura gecikmiş mi?
  bool get isOverdue => !isPaid && dueDate.isBefore(DateTime.now());

  /// Kalan gün sayısı
  int get daysRemaining {
    if (isPaid) return 0;
    return dueDate.difference(DateTime.now()).inDays;
  }

  /// Yakın zamanda mı? (3 gün içinde)
  bool get isDueSoon => !isPaid && !isOverdue && daysRemaining <= 3;

  Bill copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? dueDate,
    bool? isPaid,
    IconData? categoryIcon,
    Color? categoryColor,
  }) {
    return Bill(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      dueDate: dueDate ?? this.dueDate,
      isPaid: isPaid ?? this.isPaid,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}

/// Ev eşyası/varlık modeli
class Asset {
  final String id;
  final String name;
  final DateTime purchaseDate;
  final DateTime? warrantyEndDate;
  final String? photoUrl;
  final String category;
  final Color categoryColor;

  const Asset({
    required this.id,
    required this.name,
    required this.purchaseDate,
    this.warrantyEndDate,
    this.photoUrl,
    required this.category,
    required this.categoryColor,
  });

  /// Garanti geçerli mi?
  bool get hasValidWarranty {
    if (warrantyEndDate == null) return false;
    return warrantyEndDate!.isAfter(DateTime.now());
  }

  /// Garanti kalan yüzde (0.0 - 1.0)
  double get warrantyProgress {
    if (warrantyEndDate == null) return 0.0;
    
    final totalDuration = warrantyEndDate!.difference(purchaseDate).inDays;
    if (totalDuration <= 0) return 0.0;
    
    final remaining = warrantyEndDate!.difference(DateTime.now()).inDays;
    if (remaining <= 0) return 0.0;
    
    return (remaining / totalDuration).clamp(0.0, 1.0);
  }

  /// Garanti kalan süre metni
  String get warrantyText {
    if (warrantyEndDate == null) return 'Garanti yok';
    
    final remaining = warrantyEndDate!.difference(DateTime.now()).inDays;
    if (remaining <= 0) return 'Garanti Bitti';
    
    if (remaining > 365) {
      final years = (remaining / 365).floor();
      return '$years yıl kaldı';
    } else if (remaining > 30) {
      final months = (remaining / 30).floor();
      return '$months ay kaldı';
    } else {
      return '$remaining gün kaldı';
    }
  }

  Asset copyWith({
    String? id,
    String? name,
    DateTime? purchaseDate,
    DateTime? warrantyEndDate,
    String? photoUrl,
    String? category,
    Color? categoryColor,
  }) {
    return Asset(
      id: id ?? this.id,
      name: name ?? this.name,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      warrantyEndDate: warrantyEndDate,
      photoUrl: photoUrl ?? this.photoUrl,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}
