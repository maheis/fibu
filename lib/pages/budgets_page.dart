import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import 'account_budget_editor_page.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
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
          ...controller.budgets.map((budget) {
            return Card(
              child: ListTile(
                title: Text(budget.name),
                subtitle: Text('Budget'),
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
