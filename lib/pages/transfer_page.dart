import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_controller.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  late String _fromAccountId;
  late String _toAccountId;
  late DateTime _selectedDate;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final accounts = widget.controller.accounts;
    _fromAccountId = accounts.isNotEmpty ? accounts.first.id : '';
    _toAccountId = accounts.length > 1 ? accounts[1].id : _fromAccountId;
    _selectedDate = DateTime.now();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _save() async {
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.'));
    if (_fromAccountId.isEmpty ||
        _toAccountId.isEmpty ||
        _fromAccountId == _toAccountId ||
        amount == null ||
        amount == 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte gültige Konten und Betrag eingeben.'),
        ),
      );
      return;
    }

    await widget.controller.transferBetweenAccounts(
      fromAccountId: _fromAccountId,
      toAccountId: _toAccountId,
      date: DateFormat('yyyy-MM-dd').format(_selectedDate),
      amount: amount,
      comment: _commentController.text.trim(),
    );

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.controller.accounts;

    return Scaffold(
      appBar: AppBar(title: const Text('Umbuchung')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _fromAccountId.isEmpty ? null : _fromAccountId,
                decoration: const InputDecoration(labelText: 'Von Konto'),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _fromAccountId = value ?? ''),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _toAccountId.isEmpty ? null : _toAccountId,
                decoration: const InputDecoration(labelText: 'Nach Konto'),
                items: accounts
                    .map(
                      (account) => DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _toAccountId = value ?? ''),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Datum'),
                  child: Text(DateFormat('dd.MM.yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                decoration: const InputDecoration(labelText: 'Kommentar'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Betrag',
                  hintText: 'z. B. 250.00',
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Umbuchung speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
