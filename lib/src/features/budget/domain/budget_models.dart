import 'package:flutter/material.dart';

enum TransactionCategory {
  food(label: 'Yeme & İçme', icon: Icons.fastfood_rounded, color: Color(0xFFFF9F1C)),
  transport(label: 'Ulaşım', icon: Icons.directions_car_rounded, color: Color(0xFF3A86FF)),
  bills(label: 'Faturalar', icon: Icons.receipt_long_rounded, color: Color(0xFFEF476F)),
  entertainment(label: 'Eğlence', icon: Icons.movie_rounded, color: Color(0xFF8338EC)),
  shopping(label: 'Alışveriş', icon: Icons.shopping_bag_rounded, color: Color(0xFFFF006E)),
  health(label: 'Sağlık', icon: Icons.health_and_safety_rounded, color: Color(0xFF2EC4B6)),
  income(label: 'Gelir', icon: Icons.account_balance_wallet_rounded, color: Color(0xFF06D6A0));

  final String label;
  final IconData icon;
  final Color color;
  const TransactionCategory({required this.label, required this.icon, required this.color});
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final TransactionCategory category;
  final bool isExpense;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
  });
}

class BudgetStats {
  final double totalLimit;
  final double totalSpent;
  
  double get remaining => totalLimit - totalSpent;
  double get spentPercentage => (totalSpent / totalLimit).clamp(0.0, 1.0);

  const BudgetStats({required this.totalLimit, required this.totalSpent});
}
