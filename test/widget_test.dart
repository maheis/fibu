// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:fibu/app.dart';
import 'package:fibu/app_controller.dart';
import 'package:fibu/models.dart';
import 'package:fibu/repository/app_repository.dart';

void main() {
  testWidgets('Fibu app loads the overview page', (WidgetTester tester) async {
    final controller = AppController(_MemoryAppRepository());
    await controller.load();

    await tester.pumpWidget(FibuApp(controller: controller));

    expect(find.text('Fibu'), findsOneWidget);
    expect(find.text('Gesamtguthaben'), findsOneWidget);
  });

  test('transfer creates two opposite bookings', () async {
    final controller = AppController(_MemoryAppRepository());
    await controller.load();

    await controller.transferBetweenAccounts(
      fromAccountId: controller.accounts.first.id,
      toAccountId: controller.accounts[1].id,
      date: '2025-01-15',
      amount: 150.0,
      comment: 'Test-Transfer',
    );

    expect(
      controller.bookings
          .where((b) => b.accountId == controller.accounts.first.id)
          .first
          .amount,
      lessThan(0),
    );
    expect(
      controller.bookings
          .where((b) => b.accountId == controller.accounts[1].id)
          .first
          .amount,
      greaterThan(0),
    );
  });

  test('recurring bookings are persisted', () async {
    final controller = AppController(_MemoryAppRepository());
    await controller.load();

    await controller.addRecurringBooking(
      accountId: controller.accounts.first.id,
      whatId: controller.whatCategories.first.id,
      bookingDay: 15,
      amount: -99.90,
      period: 'M',
    );

    expect(controller.recurringBookings.length, greaterThan(0));
    expect(controller.recurringBookings.first.period, 'M');
  });

  test('due recurring bookings are applied once per month', () async {
    final controller = AppController(_MemoryAppRepository());
    await controller.load();

    await controller.addRecurringBooking(
      accountId: controller.accounts.first.id,
      whatId: controller.whatCategories.first.id,
      bookingDay: 15,
      amount: -25,
      period: 'M',
    );

    final firstRun = await controller.applyRecurringBookingsForMonth(
      DateTime(2026, 2),
    );
    final secondRun = await controller.applyRecurringBookingsForMonth(
      DateTime(2026, 2),
    );

    expect(firstRun, 1);
    expect(secondRun, 0);
    expect(
      controller.bookings.where((booking) => booking.id.contains('recurring_')),
      hasLength(1),
    );
  });
}

class _MemoryAppRepository implements AppRepository {
  final _now = DateTime(2026, 1, 1);
  late List<FibuAccount> _accounts = [
    FibuAccount(id: 'acc_1', name: 'Giro', credit: 1000, createdAt: _now),
    FibuAccount(id: 'acc_2', name: 'Sparen', credit: 2500, createdAt: _now),
  ];
  late List<FibuBudget> _budgets = [
    FibuBudget(id: 'budget_1', name: 'Haushalt', credit: 400, createdAt: _now),
  ];
  List<FibuCategory> _whereCategories = const [
    FibuCategory(id: 'where_1', name: 'Buchung'),
    FibuCategory(id: 'where_2', name: 'Supermarkt'),
  ];
  List<FibuCategory> _whatCategories = const [
    FibuCategory(id: 'what_1', name: 'Umbuchung'),
    FibuCategory(id: 'what_2', name: 'Lebensmittel'),
  ];
  List<FibuBooking> _bookings = const [
    FibuBooking(
      id: 'booking_1',
      accountId: 'acc_1',
      date: '2026-01-01',
      whereId: 'where_2',
      whatId: 'what_2',
      amount: -12.50,
      budgetId: 'budget_1',
      budgetAmount: -12.50,
    ),
  ];
  List<FibuRecurringBooking> _recurringBookings = const [];

  @override
  Future<List<FibuAccount>> loadAccounts() async => _accounts;

  @override
  Future<List<FibuBudget>> loadBudgets() async => _budgets;

  @override
  Future<List<FibuCategory>> loadWhereCategories() async => _whereCategories;

  @override
  Future<List<FibuCategory>> loadWhatCategories() async => _whatCategories;

  @override
  Future<List<FibuBooking>> loadBookings() async => _bookings;

  @override
  Future<List<FibuRecurringBooking>> loadRecurringBookings() async =>
      _recurringBookings;

  @override
  Future<void> saveAccounts(List<FibuAccount> accounts) async {
    _accounts = accounts;
  }

  @override
  Future<void> saveBudgets(List<FibuBudget> budgets) async {
    _budgets = budgets;
  }

  @override
  Future<void> saveWhereCategories(List<FibuCategory> items) async {
    _whereCategories = items;
  }

  @override
  Future<void> saveWhatCategories(List<FibuCategory> items) async {
    _whatCategories = items;
  }

  @override
  Future<void> saveBookings(List<FibuBooking> bookings) async {
    _bookings = bookings;
  }

  @override
  Future<void> saveRecurringBookings(
    List<FibuRecurringBooking> bookings,
  ) async {
    _recurringBookings = bookings;
  }
}
