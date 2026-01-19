import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../data/budget_repository.dart';
import '../domain/budget_models.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BÜTÇE EKRANI
// ═══════════════════════════════════════════════════════════════════════════

class BudgetScreen extends ConsumerWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(budgetStatsProvider);
    final transactions = ref.watch(transactionsProvider);
    final currencyFormat = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 0);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        backgroundColor: AppColors.budgetAccent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ).animate().scale(delay: 500.ms, duration: 300.ms),
      body: CustomScrollView(
        slivers: [
          // AppBar
          SliverAppBar(
            expandedHeight: 80, pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.pop(context)),
            title: Text('Bütçe', style: AppTextStyles.headlineMedium.copyWith(fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),

          // Safe-to-Spend Ring
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _BudgetRingCard(stats: stats, currencyFormat: currencyFormat),
            ),
          ),

          // Pie Chart
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _CategoryPieChart(transactions: transactions),
            ),
          ),

          // Recent Transactions Header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 12),
              child: Text('Son İşlemler', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
            ),
          ),

          // Transactions List
          if (transactions.isEmpty)
             const SliverFillRemaining(child: Center(child: Text('Henüz işlem yok')))
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _TransactionTile(transaction: transactions[i], formatter: currencyFormat).animate(delay: Duration(milliseconds: 50 * i)).fadeIn().slideX(begin: 0.1, end: 0),
                childCount: transactions.length,
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddTransactionSheet(),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET'LAR
// ═══════════════════════════════════════════════════════════════════════════

class _BudgetRingCard extends StatelessWidget {
  final BudgetStats stats;
  final NumberFormat currencyFormat;
  const _BudgetRingCard({required this.stats, required this.currencyFormat});

  @override
  Widget build(BuildContext context) {
    final percentage = stats.spentPercentage;
    final Color statusColor = percentage < 0.5 ? AppColors.success : (percentage < 0.8 ? AppColors.warning : AppColors.error);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(children: [
        SizedBox(
          height: 200, width: 200,
          child: Stack(alignment: Alignment.center, children: [
            // Background Ring
            SizedBox(
              width: 200, height: 200,
              child: CircularProgressIndicator(
                value: 1, strokeWidth: 16,
                valueColor: AlwaysStoppedAnimation(AppColors.surfaceVariant),
              ),
            ),
            // Progress Ring
            SizedBox(
              width: 200, height: 200,
              child: CircularProgressIndicator(
                value: percentage, strokeWidth: 16, strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            // Text Content
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text('Kalan Bütçe', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 4),
              Text(currencyFormat.format(stats.remaining), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: statusColor, letterSpacing: -1)),
              const SizedBox(height: 4),
              Text('/ ${currencyFormat.format(stats.totalLimit)}', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
            ]),
          ]),
        ),
      ]),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}

class _CategoryPieChart extends StatelessWidget {
  final List<Transaction> transactions;
  const _CategoryPieChart({required this.transactions});

  @override
  Widget build(BuildContext context) {
    // Calculate category totals
    final expenseTransactions = transactions.where((t) => t.isExpense).toList();
    final categoryTotals = <TransactionCategory, double>{};
    double totalExpense = 0;

    for (var t in expenseTransactions) {
      if (t.category == TransactionCategory.income) continue;
      categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
      totalExpense += t.amount;
    }

    if (totalExpense == 0) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(24)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Harcama Dağılımı', style: AppTextStyles.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        Row(children: [
          // Chart
          SizedBox(
            height: 140, width: 140,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: categoryTotals.entries.map((entry) {
                  final percentage = (entry.value / totalExpense) * 100;
                  return PieChartSectionData(
                    color: entry.key.color,
                    value: entry.value,
                    title: '${percentage.toInt()}%',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 24),
          // Legend
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: categoryTotals.keys.map((cat) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 12, height: 12, decoration: BoxDecoration(color: cat.color, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(width: 8),
                  Expanded(child: Text(cat.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
                ]),
              )).toList(),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final NumberFormat formatter;
  const _TransactionTile({required this.transaction, required this.formatter});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.surfaceVariant)),
    child: Row(children: [
      Container(
        width: 48, height: 48,
        decoration: BoxDecoration(color: transaction.category.color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
        child: Icon(transaction.category.icon, color: transaction.category.color, size: 24),
      ),
      const SizedBox(width: 16),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(transaction.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 2),
        Text(transaction.category.label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ])),
      Text(
        '${transaction.isExpense ? '-' : '+'}${formatter.format(transaction.amount)}',
        style: TextStyle(
          color: transaction.isExpense ? AppColors.error : AppColors.success,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    ]),
  );
}

class _AddTransactionSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 24),
        Text('Yeni İşlem', style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        Text('Tutar', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
        const TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixText: '₺',
            border: InputBorder.none,
            hintText: '0',
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          decoration: InputDecoration(
            labelText: 'Açıklama',
            filled: true,
            fillColor: AppColors.surfaceVariant,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 24),
        Container(
          height: 50,
          decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: BorderRadius.circular(16)),
          child: const Center(child: Text('Kategori Seçimi (Mock)', style: TextStyle(color: Colors.grey))),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            // Add dummy transaction
            final newTransaction = Transaction(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Yeni Harcama (Manuel)',
              amount: 150.0,
              date: DateTime.now(),
              category: TransactionCategory.shopping,
              isExpense: true,
            );
            
            ref.read(transactionsProvider.notifier).addTransaction(newTransaction);
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Harcama eklendi!')));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.budgetAccent,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: const Text('Ekle', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
      ]),
    );
  }
}
