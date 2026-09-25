import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final years = widget.controller.availableReportYears();
    final year = _selectedYear != null && years.contains(_selectedYear)
        ? _selectedYear!
        : years.first;
    final yearlyNet = widget.controller.totalForYear(year);
    final yearlyIncome = widget.controller.totalForYear(year, incomeOnly: true);
    final yearlyExpense = widget.controller.totalForYear(
      year,
      expenseOnly: true,
    );
    final monthlyTotals = widget.controller.monthlyTotalsForYear(year);
    final categoryTotals = widget.controller.yearlyCategoryTotals(year);
    final maxMonthTotal = monthlyTotals.fold<double>(
      0,
      (max, entry) => entry.value.abs() > max ? entry.value.abs() : max,
    );
    final maxCategoryTotal = categoryTotals.fold<double>(
      0,
      (max, entry) => entry.value.abs() > max ? entry.value.abs() : max,
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Auswertung',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              DropdownButton<int>(
                value: year,
                items: years
                    .map(
                      (item) => DropdownMenuItem<int>(
                        value: item,
                        child: Text(item.toString()),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => _selectedYear = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ReportSummaryCard(
                  title: 'Netto',
                  value: yearlyNet,
                  icon: Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ReportSummaryCard(
                  title: 'Einnahmen',
                  value: yearlyIncome,
                  icon: Icons.trending_up,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ReportSummaryCard(
            title: 'Ausgaben',
            value: yearlyExpense,
            icon: Icons.trending_down,
          ),
          const SizedBox(height: 16),
          Text(
            'Monatsübersicht',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          ...monthlyTotals.map((entry) {
            return _ReportBarTile(
              label: _monthLabel(entry.key),
              value: entry.value,
              maxValue: maxMonthTotal,
            );
          }),
          const SizedBox(height: 16),
          Text(
            'Nach Kategorie',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          if (categoryTotals.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('Noch keine Kategorien in diesem Jahr.'),
              ),
            )
          else
            ...categoryTotals.map((entry) {
              return _ReportBarTile(
                label: entry.key,
                value: entry.value,
                maxValue: maxCategoryTotal,
              );
            }),
        ],
      ),
    );
  }

  String _monthLabel(int month) {
    const labels = <String>[
      'Januar',
      'Februar',
      'März',
      'April',
      'Mai',
      'Juni',
      'Juli',
      'August',
      'September',
      'Oktober',
      'November',
      'Dezember',
    ];
    return labels[month - 1];
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final double value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final color = value >= 0 ? Colors.green : Colors.red;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                formatMoney(value),
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportBarTile extends StatelessWidget {
  const _ReportBarTile({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  final String label;
  final double value;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    final color = value >= 0 ? Colors.green : Colors.red;
    final factor = maxValue == 0
        ? 0.0
        : (value.abs() / maxValue).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  formatMoney(value),
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: factor,
                color: color,
                backgroundColor: color.withAlpha(32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
