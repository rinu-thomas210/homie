import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/expense_model.dart';
import '../../../data/providers/expense_provider.dart';
import '../../../data/providers/roommate_provider.dart';
import '../../../data/providers/app_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {

  @override
  Widget build(BuildContext context) {
    final roommateProvider = context.watch<RoommateProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();

    // Sync active roommates list with ExpenseProvider
    context.read<ExpenseProvider>().updateRoommates(roommateProvider.roommateIds);

    final isUnlocked = roommateProvider.hasRentedRoom;

    if (!isUnlocked) {
      return _buildLockedState(roommateProvider);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseSheet(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(expenseProvider),
              _buildBalanceCard(expenseProvider),
              const SizedBox(height: 24),
              _buildChart(expenseProvider),
              const SizedBox(height: 24),
              _buildExpensesList(expenseProvider),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ExpenseProvider expenses) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Expenses',
            style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.history_rounded, color: AppColors.textDark, size: 20),
          ),
        ],
      ).animate().fade(duration: 400.ms),
    );
  }

  Widget _buildBalanceCard(ExpenseProvider expenses) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Net Balance', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          expenses.netBalance >= 0
                              ? '+\$${expenses.netBalance.toStringAsFixed(2)}'
                              : '-\$${(-expenses.netBalance).toStringAsFixed(2)}',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expenses.netBalance >= 0 ? 'You are owed money' : 'You owe money',
                          style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_downward_rounded, color: AppColors.accentGreen, size: 16),
                              const SizedBox(width: 4),
                              Text('You\'re owed', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${expenses.totalLent.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.arrow_upward_rounded, color: AppColors.accent, size: 16),
                              const SizedBox(width: 4),
                              Text('You owe', style: GoogleFonts.outfit(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${expenses.totalOwed.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ).animate().fade(duration: 500.ms, delay: 100.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildChart(ExpenseProvider expenses) {
    final categories = expenses.expensesByCategory;
    final total = categories.values.fold(0.0, (a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Spending Breakdown', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 160,
                    child: PieChart(
                      PieChartData(
                        sections: categories.entries.map((e) {
                          final expense = Expense(
                            title: '',
                            type: e.key,
                            amount: e.value,
                            paidById: '',
                            paidByName: '',
                            date: DateTime.now(),
                            splitAmong: [],
                          );
                          return PieChartSectionData(
                            color: expense.color,
                            value: e.value,
                            title: '',
                            radius: 40,
                          );
                        }).toList(),
                        centerSpaceRadius: 48,
                        sectionsSpace: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: categories.entries.map((e) {
                      final expense = Expense(
                        title: '',
                        type: e.key,
                        amount: e.value,
                        paidById: '',
                        paidByName: '',
                        date: DateTime.now(),
                        splitAmong: [],
                      );
                      final pct = total > 0 ? (e.value / total * 100).toInt() : 0;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: expense.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                expense.typeLabel,
                                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                              ),
                            ),
                            Text(
                              '$pct%',
                              style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDark),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fade(duration: 500.ms, delay: 150.ms),
    );
  }

  Widget _buildExpensesList(ExpenseProvider expenses) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Recent Expenses',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark),
          ),
        ),
        const SizedBox(height: 12),
        ...expenses.expenses.asMap().entries.map((entry) {
          final i = entry.key;
          final expense = entry.value;
          final myShare = expense.shareFor('me');
          final iOwe = expense.paidById != 'me' && expense.splitAmong.contains('me');
          final theyOwe = expense.paidById == 'me';

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: expense.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(expense.icon, color: expense.color, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(expense.title, style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textDark)),
                        const SizedBox(height: 2),
                        Text(
                          'Paid by ${expense.paidByName} • ${DateFormat('MMM d').format(expense.date)}',
                          style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textMedium),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${expense.splitAmong.length} people • \$${expense.amount.toStringAsFixed(0)} total',
                          style: GoogleFonts.outfit(fontSize: 11, color: AppColors.textLight),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${myShare.toStringAsFixed(2)}',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: expense.splitAmong.length == 1
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : iOwe
                                  ? AppColors.accent.withValues(alpha: 0.1)
                                  : theyOwe
                                      ? AppColors.accentGreen.withValues(alpha: 0.1)
                                      : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          expense.splitAmong.length == 1
                              ? 'Personal'
                              : iOwe
                                  ? 'You owe'
                                  : theyOwe
                                      ? 'You lent'
                                      : 'Settled',
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: expense.splitAmong.length == 1
                                ? AppColors.primary
                                : iOwe
                                    ? AppColors.accent
                                    : theyOwe
                                        ? AppColors.accentGreen
                                        : AppColors.textLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fade(duration: 400.ms, delay: (60 * i).ms).slideY(begin: 0.05),
          );
        }).toList(),
      ],
    );
  }

  void _showAddExpenseSheet(BuildContext context) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    ExpenseType selectedType = ExpenseType.rent;


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Expense', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: titleController,
                    decoration: InputDecoration(hintText: 'Expense name', prefixIcon: const Icon(Icons.receipt_outlined, color: AppColors.textLight)),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(hintText: 'Amount (\$)', prefixIcon: const Icon(Icons.attach_money_rounded, color: AppColors.textLight)),
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ExpenseType.values.map((type) {
                        final dummy = Expense(
                          title: '',
                          type: type,
                          amount: 0,
                          paidById: '',
                          paidByName: '',
                          date: DateTime.now(),
                          splitAmong: [],
                        );
                        final selected = selectedType == type;
                        return GestureDetector(
                          onTap: () => setSheetState(() => selectedType = type),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? dummy.color : dummy.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(dummy.icon, size: 16, color: selected ? Colors.white : dummy.color),
                                const SizedBox(width: 6),
                                Text(
                                  dummy.typeLabel,
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selected ? Colors.white : dummy.color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text) ?? 0;
                        if (amount > 0 && titleController.text.isNotEmpty) {
                          final roommateProvider = context.read<RoommateProvider>();
                          final roommates = ['me', ...roommateProvider.roommateIds];

                          context.read<ExpenseProvider>().addExpense(
                            Expense(
                              title: titleController.text,
                              type: selectedType,
                              amount: amount,
                              paidById: 'me',
                              paidByName: 'You',
                              date: DateTime.now(),
                              splitAmong: roommates,
                              isEqualSplit: true,
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Add Expense', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLockedState(RoommateProvider roommateProvider) {
    final appProvider = context.read<AppProvider>();
    final hasRented = roommateProvider.hasRentedRoom;
    final hasRoommates = roommateProvider.roommateIds.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 64,
                  color: AppColors.primary,
                ),
              ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
              const SizedBox(height: 24),
              Text(
                'Expense Splitting',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Unlock shared expenses by finding your home and matching with roommates first.',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.textMedium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildChecklistItem(
                      index: 1,
                      title: 'Rent a Property',
                      subtitle: 'Find and secure your shared home listing.',
                      isDone: hasRented,
                      actionLabel: 'Browse Rooms',
                      onAction: () => appProvider.setNavIndex(1),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Divider(color: AppColors.divider, height: 1),
                    ),
                    _buildChecklistItem(
                      index: 2,
                      title: 'Connect with Roommates',
                      subtitle: 'Match and request to become roommates.',
                      isDone: hasRoommates,
                      actionLabel: 'Find Roommates',
                      onAction: () => appProvider.setNavIndex(1),
                    ),
                  ],
                ),
              ).animate().fade(duration: 400.ms, delay: 100.ms).slideY(begin: 0.05),
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem({
    required int index,
    required String title,
    required String subtitle,
    required bool isDone,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone ? AppColors.accentGreen : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : Icons.lock_outline_rounded,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: isDone ? AppColors.textDark : AppColors.textMedium,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.outfit(fontSize: 12, color: AppColors.textLight),
              ),
              if (!isDone) ...[
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: GoogleFonts.outfit(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
