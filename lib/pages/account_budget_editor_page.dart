import 'package:flutter/material.dart';

import '../app_controller.dart';

class AccountBudgetEditorPage extends StatefulWidget {
  const AccountBudgetEditorPage({
    super.key,
    required this.controller,
    this.mode = 'account',
  });

  final AppController controller;
  final String mode;

  @override
  State<AccountBudgetEditorPage> createState() =>
      _AccountBudgetEditorPageState();
}

class _AccountBudgetEditorPageState extends State<AccountBudgetEditorPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final value = double.tryParse(_valueController.text.replaceAll(',', '.'));

    if (name.isEmpty || value == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitte Namen und gültigen Betrag eingeben.'),
        ),
      );
      return;
    }

    if (widget.mode == 'account') {
      await widget.controller.addAccount(name, onlineBanking: '');
    } else {
      await widget.controller.addBudget(name, value);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isAccount = widget.mode == 'account';

    return Scaffold(
      appBar: AppBar(
        title: Text(isAccount ? 'Konto anlegen' : 'Budget anlegen'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: isAccount ? 'Kontoname' : 'Budgetname',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _valueController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: isAccount ? 'Startguthaben' : 'Budgetvolumen',
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save_outlined),
                label: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
