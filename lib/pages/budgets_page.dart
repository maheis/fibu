import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import 'account_budget_editor_page.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
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
                label: const Text('Neu'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Monatsstatus ${month.year}-${month.month.toString().padLeft(2, '0')}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    formatMoney(controller.totalForMonth(month, expenseOnly: true)),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...controller.budgets.map((budget) {
            final used = controller.budgetUsedForMonth(budget.id, month);
            final remaining = controller.budgetRemainingForMonth(budget.id, month);
            return Card(
              child: ListTile(
                title: Text(budget.name),
                subtitle: Text(
                  'Verbraucht: ${formatMoney(used)} • Verbleibend: ${formatMoney(remaining)}',
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatMoney(budget.credit),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      formatMoney(remaining),
                      style: TextStyle(
                        color: remaining >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
