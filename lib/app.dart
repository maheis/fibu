import 'package:flutter/material.dart';

import 'app_controller.dart';
import 'pages/bookings_page.dart';
import 'pages/budgets_page.dart';
import 'pages/overview_page.dart';

class FibuApp extends StatelessWidget {
  const FibuApp({super.key, required this.controller});

  final AppController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Fibu',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF2E7D32),
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: const Color(0xFF81C784),
            brightness: Brightness.dark,
          ),
          home: FibuHomePage(controller: controller),
        );
      },
    );
  }
}

class FibuHomePage extends StatefulWidget {
  const FibuHomePage({super.key, required this.controller});

  final AppController controller;

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
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fibu'),
        centerTitle: false,
      ),
      body: pages[_index],
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await widget.controller.addSampleBooking();
          if (!mounted) return;
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo-Buchung angelegt')),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Buchung'),
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
        ],
      ),
    );
  }
}
