import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';
import '../pages/booking_editor_page.dart';

class BookingsPage extends StatefulWidget {
  const BookingsPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<BookingsPage> createState() => _BookingsPageState();
}

class _BookingsPageState extends State<BookingsPage> {
  DateTime _selectedMonth = DateTime.now();
  String _search = '';

  List<FibuBooking> get _filteredBookings {
    final filtered = widget.controller.bookingsForMonth(_selectedMonth);
    if (_search.trim().isEmpty) {
      return filtered;
    }
    final needle = _search.toLowerCase();
    return filtered.where((booking) {
      final accountName = widget.controller
          .accountName(booking.accountId)
          .toLowerCase();
      final whereName = widget.controller
          .whereName(booking.whereId)
          .toLowerCase();
      final whatName = widget.controller.whatName(booking.whatId).toLowerCase();
      final comment = booking.comment.toLowerCase();
      return accountName.contains(needle) ||
          whereName.contains(needle) ||
          whatName.contains(needle) ||
          comment.contains(needle);
    }).toList();
  }

  Future<void> _changeMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedMonth = DateTime(picked.year, picked.month, 1));
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filteredBookings;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _changeMonth,
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Monat'),
                    child: Text(
                      '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          BookingEditorPage(controller: widget.controller),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Neu'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Suchen',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) => setState(() => _search = value),
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
                  title: Text(widget.controller.accountName(booking.accountId)),
                  subtitle: Text(
                    '${shortDate(booking.date)} • ${widget.controller.whereName(booking.whereId)} • ${widget.controller.whatName(booking.whatId)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
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
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            if (!mounted) return;
                            Navigator.of(context)
                                .push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingEditorPage(
                                      controller: widget.controller,
                                      booking: booking,
                                    ),
                                  ),
                                )
                                .then((_) {
                                  if (!mounted) return;
                                  setState(() {});
                                });
                            return;
                          }

                          if (value == 'delete') {
                            if (!mounted) return;
                            showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Buchung löschen?'),
                                content: Text(
                                  'Möchtest du die Buchung ${formatMoney(booking.amount)} wirklich löschen?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(false),
                                    child: const Text('Abbrechen'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(true),
                                    child: const Text('Löschen'),
                                  ),
                                ],
                              ),
                            ).then((confirmed) async {
                              if (confirmed != true) return;
                              await widget.controller.deleteBooking(booking.id);
                              if (!mounted) return;
                              setState(() {});
                            });
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Text('Bearbeiten'),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Text('Löschen'),
                          ),
                        ],
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
