import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final accounts = controller.accounts;

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
          Text(
            'Konten',
            style: Theme.of(context).textTheme.titleLarge,
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
          Text(
            'Budgets',
            style: Theme.of(context).textTheme.titleLarge,
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
            Text(
              title,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
