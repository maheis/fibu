import 'package:flutter/material.dart';

import '../app_controller.dart';
import '../models.dart';

class RecurringBookingPage extends StatefulWidget {
  const RecurringBookingPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<RecurringBookingPage> createState() => _RecurringBookingPageState();
}

class _RecurringBookingPageState extends State<RecurringBookingPage> {
  late String _accountId;
  late String _whatId;
  int _bookingDay = 1;
  String _period = 'M';
  final TextEditingController _amountController = TextEditingController();

  Future<void> _applyDueRecurringBookings() async {
    final created = await widget.controller.applyRecurringBookingsForMonth(
      DateTime.now(),
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created == 1
              ? '1 Dauerbuchung angelegt.'
              : '$created Dauerbuchungen angelegt.',
        ),
      ),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    final accounts = widget.controller.accounts;
    final whatItems = widget.controller.whatCategories;
    _accountId = accounts.isNotEmpty ? accounts.first.id : '';
    _whatId = whatItems.isNotEmpty ? whatItems.first.id : '';
    _bookingDay = DateTime.now().day.clamp(1, 28);
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (_accountId.isEmpty || _whatId.isEmpty || amount == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Konto, Kategorie und Betrag eingeben.'),
        ),
      );
      return;
    }

    await widget.controller.addRecurringBooking(
      accountId: _accountId,
      whatId: _whatId,
      bookingDay: _bookingDay,
      amount: amount,
      period: _period,
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.controller.accounts;
    final whatItems = widget.controller.whatCategories;
    final recurringBookings = widget.controller.recurringBookings;

    return Scaffold(
      appBar: AppBar(title: const Text('Dauerauftrag')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FilledButton.tonalIcon(
                onPressed: recurringBookings.isEmpty
                    ? null
                    : _applyDueRecurringBookings,
                icon: const Icon(Icons.playlist_add_check),
                label: const Text('Fällige für diesen Monat buchen'),
              ),
              const SizedBox(height: 16),
              Text(
                'Gespeicherte Daueraufträge',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (recurringBookings.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Noch keine Daueraufträge angelegt.'),
                  ),
                )
              else
                ...recurringBookings.map((booking) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.repeat),
                      title: Text(widget.controller.whatName(booking.whatId)),
                      subtitle: Text(
                        '${widget.controller.accountName(booking.accountId)} · ${_periodLabel(booking.period)} · Tag ${booking.bookingDay}',
                      ),
                      trailing: Text(
                        formatMoney(booking.amount),
                        style: TextStyle(
                          color: booking.amount >= 0
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              Text(
                'Neuer Dauerauftrag',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _accountId.isEmpty ? null : _accountId,
                decoration: const InputDecoration(labelText: 'Konto'),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _accountId = value ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _whatId.isEmpty ? null : _whatId,
                decoration: const InputDecoration(labelText: 'Was?'),
                items: whatItems
                    .map(
                      (item) => DropdownMenuItem(
                        value: item.id,
                        child: Text(item.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _whatId = value ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _period,
                decoration: const InputDecoration(labelText: 'Periode'),
                items: const [
                  DropdownMenuItem(value: 'M', child: Text('Monatlich')),
                  DropdownMenuItem(value: 'Q', child: Text('Quartal')),
                  DropdownMenuItem(value: 'Y', child: Text('Jährlich')),
                ],
                onChanged: (value) => setState(() => _period = value ?? 'M'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Buchungstag: '),
                  Expanded(
                    child: Slider(
                      min: 1,
                      max: 28,
                      divisions: 27,
                      value: _bookingDay.toDouble(),
                      onChanged: (value) =>
                          setState(() => _bookingDay = value.round()),
                    ),
                  ),
                  Text(_bookingDay.toString()),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Betrag',
                  hintText: 'z. B. -99.90',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.calendar_month),
                label: const Text('Dauerauftrag speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _periodLabel(String period) {
    return switch (period) {
      'Q' => 'Quartal',
      'Y' => 'Jährlich',
      _ => 'Monatlich',
    };
  }
}
