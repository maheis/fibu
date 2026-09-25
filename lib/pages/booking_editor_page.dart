import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../app_controller.dart';
import '../models.dart';

class BookingEditorPage extends StatefulWidget {
  const BookingEditorPage({super.key, required this.controller, this.booking});

  final AppController controller;
  final FibuBooking? booking;

  @override
  State<BookingEditorPage> createState() => _BookingEditorPageState();
}

class _BookingEditorPageState extends State<BookingEditorPage> {
  late String _accountId;
  late String _whereId;
  late String _whatId;
  String? _budgetId;
  late DateTime _selectedDate;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  bool get _isEditMode => widget.booking != null;

  @override
  void initState() {
    super.initState();
    final accounts = widget.controller.accounts;
    final whereItems = widget.controller.whereCategories;
    final whatItems = widget.controller.whatCategories;
    final budgets = widget.controller.budgets;

    if (widget.booking != null) {
      _accountId = widget.booking!.accountId;
      _whereId = widget.booking!.whereId;
      _whatId = widget.booking!.whatId;
      _budgetId = widget.booking!.budgetId;
      _selectedDate = DateTime.parse(widget.booking!.date);
      _commentController.text = widget.booking!.comment;
      _amountController.text = widget.booking!.amount.toStringAsFixed(2);
      return;
    }

    _accountId = accounts.isNotEmpty ? accounts.first.id : '';
    _whereId = whereItems.isNotEmpty ? whereItems.first.id : '';
    _whatId = whatItems.isNotEmpty ? whatItems.first.id : '';
    _budgetId = budgets.isNotEmpty ? budgets.first.id : null;
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _amountController.dispose();
    super.dispose();
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
    final amountValue = _amountController.text.trim();
    final parsed = double.tryParse(amountValue.replaceAll(',', '.'));

    if (_accountId.isEmpty ||
        _whereId.isEmpty ||
        _whatId.isEmpty ||
        amountValue.isEmpty ||
        parsed == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Konto, Kategorie und gültigen Betrag eingeben.'),
        ),
      );
      return;
    }

    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    if (_isEditMode) {
      final updated = widget.booking!.copyWith(
        accountId: _accountId,
        date: dateString,
        whereId: _whereId,
        whatId: _whatId,
        comment: _commentController.text.trim(),
        amount: parsed,
        budgetId: _budgetId,
        budgetAmount: parsed,
      );
      await widget.controller.updateBooking(updated);
    } else {
      await widget.controller.addBooking(
        accountId: _accountId,
        date: dateString,
        whereId: _whereId,
        whatId: _whatId,
        comment: _commentController.text.trim(),
        amount: parsed,
        budgetId: _budgetId,
        budgetAmount: parsed,
      );
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final accounts = widget.controller.accounts;
    final whereItems = widget.controller.whereCategories;
    final whatItems = widget.controller.whatCategories;
    final budgets = widget.controller.budgets;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Buchung bearbeiten' : 'Neue Buchung'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  onChanged: (value) =>
                      setState(() => _accountId = value ?? ''),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(labelText: 'Datum'),
                          child: Text(
                            DateFormat('dd.MM.yyyy').format(_selectedDate),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _whereId.isEmpty ? null : _whereId,
                  decoration: const InputDecoration(labelText: 'Wo?'),
                  items: whereItems
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _whereId = value ?? ''),
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
                  initialValue: _budgetId,
                  decoration: const InputDecoration(
                    labelText: 'Budget (optional)',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Ohne Budget'),
                    ),
                    ...budgets.map(
                      (budget) => DropdownMenuItem(
                        value: budget.id,
                        child: Text(budget.name),
                      ),
                    ),
                  ],
                  onChanged: (value) => setState(() => _budgetId = value),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(labelText: 'Kommentar'),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Betrag',
                    hintText: 'z. B. 42.50 oder -42.50',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _save,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Speichern'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
