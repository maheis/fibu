import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';

class BudgetsPage extends StatelessWidget {
  const BudgetsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: controller.budgets.map((budget) {
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
        }).toList(),
      ),
    );
  }
}
