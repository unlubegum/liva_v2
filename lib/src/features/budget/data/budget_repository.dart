import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/budget_models.dart';

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) => BudgetRepository());

final transactionsProvider = StateNotifierProvider<TransactionsNotifier, List<Transaction>>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return TransactionsNotifier(repo.getTransactions());
});

final budgetStatsProvider = Provider<BudgetStats>((ref) {
  final transactions = ref.watch(transactionsProvider);
  const limit = 25000.0;
  
  double spent = 0;
  for (var t in transactions) {
    if (t.isExpense) {
      spent += t.amount;
    }
  }

  return BudgetStats(totalLimit: limit, totalSpent: spent);
});

class BudgetRepository {
  List<Transaction> getTransactions() {
    final now = DateTime.now();
    return [
      Transaction(
        id: '1', title: 'Maaş', amount: 45000.0,
        date: DateTime(now.year, now.month, 1), category: TransactionCategory.income, isExpense: false
      ),
      Transaction(
        id: '2', title: 'Migros Alışverişi', amount: 1200.0,
        date: now.subtract(const Duration(days: 1)), category: TransactionCategory.food, isExpense: true
      ),
      Transaction(
        id: '3', title: 'Benzin', amount: 1500.0,
        date: now.subtract(const Duration(days: 2)), category: TransactionCategory.transport, isExpense: true
      ),
      Transaction(
        id: '4', title: 'Sinema', amount: 400.0,
        date: now.subtract(const Duration(days: 3)), category: TransactionCategory.entertainment, isExpense: true
      ),
      Transaction(
        id: '5', title: 'Netflix', amount: 200.0,
        date: now.subtract(const Duration(days: 5)), category: TransactionCategory.bills, isExpense: true
      ),
    ];
  }
}

class TransactionsNotifier extends StateNotifier<List<Transaction>> {
  TransactionsNotifier(super.state);

  void addTransaction(Transaction transaction) {
    state = [transaction, ...state];
  }
}
