import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import 'account_budget_editor_page.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final accounts = controller.accounts;
    final month = DateTime.now();
    final monthlyNet = controller.totalForMonth(month);
    final monthlyIncome = controller.totalForMonth(month, incomeOnly: true);
    final monthlyExpense = controller.totalForMonth(month, expenseOnly: true);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SummaryCard(
            title: 'Gesamtguthaben',
            value: formatMoney(controller.totalBalance),
            accent: Colors.green,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SummaryCard(
                  title: 'Monat netto',
                  value: formatMoney(monthlyNet),
                  accent: monthlyNet >= 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SummaryCard(
                  title: 'Einnahmen',
                  value: formatMoney(monthlyIncome),
                  accent: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _SummaryCard(
            title: 'Ausgaben',
            value: formatMoney(monthlyExpense),
            accent: Colors.red,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Konten', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AccountBudgetEditorPage(
                        controller: controller,
                        mode: 'account',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Konto'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...accounts.map((account) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance),
                title: Text(account.name),
                trailing: Text(
                  formatMoney(account.credit),
                  style: TextStyle(
                    color: account.credit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Budgets', style: Theme.of(context).textTheme.titleLarge),
              TextButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AccountBudgetEditorPage(
                        controller: controller,
                        mode: 'budget',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Budget'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...controller.budgets.map((budget) {
            return Card(
              child: ListTile(
                title: Text(budget.name),
                trailing: Text(
                  formatMoney(budget.credit),
                  style: TextStyle(
                    color: budget.credit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.accent,
  });

  final String title;
  final String value;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: accent.withAlpha(28),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
