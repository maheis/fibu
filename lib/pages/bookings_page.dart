import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now();
    final entries = controller.bookingsForMonth(month);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Text(
            'Buchungen ${month.year}-${month.month.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          if (entries.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Keine Buchungen in diesem Monat.'),
              ),
            )
          else
            ...entries.map((booking) {
              final positive = booking.amount >= 0;
              return Card(
                child: ListTile(
                  title: Text(controller.accountName(booking.accountId)),
                  subtitle: Text(
                    '${shortDate(booking.date)} • ${controller.whereName(booking.whereId)} • ${controller.whatName(booking.whatId)}',
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatMoney(booking.amount),
                        style: TextStyle(
                          color: positive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (booking.comment.isNotEmpty)
                        Text(
                          booking.comment,
                          style: Theme.of(context).textTheme.labelSmall,
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
