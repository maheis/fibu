import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../app_controller.dart';

class BackupPage extends StatefulWidget {
  const BackupPage({super.key, required this.controller});

  final AppController controller;

  @override
  State<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends State<BackupPage> {
  String? _lastExportPath;
  bool _isExporting = false;

  Future<void> _exportBackup() async {
    setState(() => _isExporting = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportDirectory = Directory(
        p.join(directory.path, 'fibu', 'fibu-exports'),
      );
      await exportDirectory.create(recursive: true);

      final now = DateTime.now();
      final fileName = 'fibu-backup-${_timestamp(now)}.json';
      final file = File(p.join(exportDirectory.path, fileName));
      const encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(_snapshot(now)));

      if (!mounted) return;
      setState(() => _lastExportPath = file.path);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Backup exportiert.')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Map<String, dynamic> _snapshot(DateTime exportedAt) {
    return {
      'app': 'fibu',
      'schemaVersion': 1,
      'exportedAt': exportedAt.toIso8601String(),
      'accounts': widget.controller.accounts
          .map((item) => item.toJson())
          .toList(),
      'budgets': widget.controller.budgets
          .map((item) => item.toJson())
          .toList(),
      'whereCategories': widget.controller.whereCategories
          .map((item) => item.toJson())
          .toList(),
      'whatCategories': widget.controller.whatCategories
          .map((item) => item.toJson())
          .toList(),
      'bookings': widget.controller.bookings
          .map((item) => item.toJson())
          .toList(),
      'recurringBookings': widget.controller.recurringBookings
          .map((item) => item.toJson())
          .toList(),
    };
  }

  String _timestamp(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$year$month$day-$hour$minute$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.archive_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lokales JSON-Backup',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.controller.accounts.length} Konten, ${widget.controller.bookings.length} Buchungen, ${widget.controller.recurringBookings.length} Daueraufträge',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: _isExporting ? null : _exportBackup,
              icon: _isExporting
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.file_download_outlined),
              label: Text(
                _isExporting ? 'Exportiere...' : 'Backup exportieren',
              ),
            ),
            if (_lastExportPath != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SelectableText(_lastExportPath!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
