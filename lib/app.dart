import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'pages/backup_page.dart';
import 'pages/bookings_page.dart';
import 'pages/budgets_page.dart';
import 'pages/overview_page.dart';
import 'pages/recurring_booking_page.dart';
import 'pages/reports_page.dart';
import 'pages/transfer_page.dart';
import 'ui_settings.dart';

class FibuApp extends StatelessWidget {
  const FibuApp({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  final AppController controller;
  final UiSettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, settingsController]),
      builder: (context, _) {
        final settings = settingsController.settings;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fibu',
          theme: buildUnifiedTheme(settings, Brightness.light),
          darkTheme: buildUnifiedTheme(settings, Brightness.dark),
          themeMode: settings.useLightTheme ? ThemeMode.light : ThemeMode.dark,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(settings.textScaleFactor)),
            child: child ?? const SizedBox.shrink(),
          ),
          home: FibuHomePage(
            controller: controller,
            settingsController: settingsController,
          ),
        );
      },
    );
  }
}

class FibuHomePage extends StatefulWidget {
  const FibuHomePage({
    super.key,
    required this.controller,
    required this.settingsController,
  });

  final AppController controller;
  final UiSettingsController settingsController;

  @override
  State<FibuHomePage> createState() => _FibuHomePageState();
}

class _FibuHomePageState extends State<FibuHomePage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      OverviewPage(controller: widget.controller),
      BookingsPage(controller: widget.controller),
      BudgetsPage(controller: widget.controller),
      ReportsPage(controller: widget.controller),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fibu'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Einstellungen',
            onPressed: () async {
              final result = await Navigator.of(context).push<AppUiSettings>(
                MaterialPageRoute(
                  builder: (_) => UiSettingsPage(
                    initial: widget.settingsController.settings,
                  ),
                ),
              );
              if (result != null) {
                await widget.settingsController.update(result);
              }
            },
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Backup',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => BackupPage(controller: widget.controller),
                ),
              );
            },
            icon: const Icon(Icons.archive_outlined),
          ),
        ],
      ),
      body: pages[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final navigator = Navigator.of(context);
          final messenger = ScaffoldMessenger.of(context);
          final action = await showModalBottomSheet<String>(
            context: context,
            showDragHandle: true,
            builder: (bottomSheetContext) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: const Text('Neue Buchung'),
                        onTap: () =>
                            Navigator.of(bottomSheetContext).pop('booking'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.swap_horiz),
                        title: const Text('Umbuchung'),
                        onTap: () =>
                            Navigator.of(bottomSheetContext).pop('transfer'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.repeat),
                        title: const Text('Dauerauftrag'),
                        onTap: () =>
                            Navigator.of(bottomSheetContext).pop('recurring'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );

          if (!mounted || action == null) return;

          if (action == 'booking') {
            await widget.controller.addSampleBooking();
            if (!mounted) return;
            messenger.showSnackBar(
              const SnackBar(content: Text('Demo-Buchung angelegt')),
            );
            return;
          }

          if (action == 'transfer') {
            if (!mounted) return;
            await navigator.push(
              MaterialPageRoute(
                builder: (_) => TransferPage(controller: widget.controller),
              ),
            );
            return;
          }

          if (!mounted) return;
          await navigator.push(
            MaterialPageRoute(
              builder: (_) =>
                  RecurringBookingPage(controller: widget.controller),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Neu'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Übersicht',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Buchungen',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Budgets',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Auswertung',
          ),
        ],
      ),
    );
  }
}
