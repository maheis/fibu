import 'package:sembast/sembast.dart';

import '../models.dart';

abstract interface class AppRepository {
  Future<List<FibuAccount>> loadAccounts();
  Future<List<FibuBudget>> loadBudgets();
  Future<List<FibuCategory>> loadWhereCategories();
  Future<List<FibuCategory>> loadWhatCategories();
  Future<List<FibuBooking>> loadBookings();
  Future<List<FibuRecurringBooking>> loadRecurringBookings();

  Future<void> saveAccounts(List<FibuAccount> accounts);
  Future<void> saveBudgets(List<FibuBudget> budgets);
  Future<void> saveWhereCategories(List<FibuCategory> items);
  Future<void> saveWhatCategories(List<FibuCategory> items);
  Future<void> saveBookings(List<FibuBooking> bookings);
  Future<void> saveRecurringBookings(List<FibuRecurringBooking> bookings);
}

class LocalAppRepository implements AppRepository {
  LocalAppRepository(this._database);

  final Database _database;

  final _accountsStore = stringMapStoreFactory.store('accounts');
  final _budgetsStore = stringMapStoreFactory.store('budgets');
  final _whereStore = stringMapStoreFactory.store('booking_where');
  final _whatStore = stringMapStoreFactory.store('booking_what');
  final _bookingsStore = stringMapStoreFactory.store('bookings');
  final _recurringBookingsStore = stringMapStoreFactory.store(
    'recurring_bookings',
  );

  @override
  Future<List<FibuAccount>> loadAccounts() async {
    final values = (await _accountsStore.find(_database))
        .map((entry) => FibuAccount.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultAccounts();
      await saveAccounts(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<List<FibuBudget>> loadBudgets() async {
    final values = (await _budgetsStore.find(_database))
        .map((entry) => FibuBudget.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultBudgets();
      await saveBudgets(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<List<FibuCategory>> loadWhereCategories() async {
    final values = (await _whereStore.find(_database))
        .map((entry) => FibuCategory.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultWhere();
      await saveWhereCategories(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<List<FibuCategory>> loadWhatCategories() async {
    final values = (await _whatStore.find(_database))
        .map((entry) => FibuCategory.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultWhat();
      await saveWhatCategories(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<List<FibuBooking>> loadBookings() async {
    final values = (await _bookingsStore.find(_database))
        .map((entry) => FibuBooking.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultBookings();
      await saveBookings(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<List<FibuRecurringBooking>> loadRecurringBookings() async {
    final values = (await _recurringBookingsStore.find(_database))
        .map((entry) => FibuRecurringBooking.fromJson(entry.value))
        .toList();

    if (values.isEmpty) {
      final seed = _defaultRecurringBookings();
      await saveRecurringBookings(seed);
      return seed;
    }

    return values;
  }

  @override
  Future<void> saveAccounts(List<FibuAccount> accounts) async {
    await _database.transaction((txn) async {
      await _accountsStore.delete(txn);
      for (final account in accounts) {
        await _accountsStore.record(account.id).put(txn, account.toJson());
      }
    });
  }

  @override
  Future<void> saveBudgets(List<FibuBudget> budgets) async {
    await _database.transaction((txn) async {
      await _budgetsStore.delete(txn);
      for (final budget in budgets) {
        await _budgetsStore.record(budget.id).put(txn, budget.toJson());
      }
    });
  }

  @override
  Future<void> saveWhereCategories(List<FibuCategory> items) async {
    await _database.transaction((txn) async {
      await _whereStore.delete(txn);
      for (final item in items) {
        await _whereStore.record(item.id).put(txn, item.toJson());
      }
    });
  }

  @override
  Future<void> saveWhatCategories(List<FibuCategory> items) async {
    await _database.transaction((txn) async {
      await _whatStore.delete(txn);
      for (final item in items) {
        await _whatStore.record(item.id).put(txn, item.toJson());
      }
    });
  }

  @override
  Future<void> saveBookings(List<FibuBooking> bookings) async {
    await _database.transaction((txn) async {
      await _bookingsStore.delete(txn);
      for (final booking in bookings) {
        await _bookingsStore.record(booking.id).put(txn, booking.toJson());
      }
    });
  }

  @override
  Future<void> saveRecurringBookings(
    List<FibuRecurringBooking> bookings,
  ) async {
    await _database.transaction((txn) async {
      await _recurringBookingsStore.delete(txn);
      for (final booking in bookings) {
        await _recurringBookingsStore
            .record(booking.id)
            .put(txn, booking.toJson());
      }
    });
  }

  List<FibuAccount> _defaultAccounts() {
    final now = DateTime.now();
    return [
      FibuAccount(
        id: 'acc_1',
        name: 'Giro',
        credit: 2450.30,
        onlineBanking: 'https://example.com/giro',
        createdAt: now,
      ),
      FibuAccount(
        id: 'acc_2',
        name: 'Sparkasse',
        credit: 8800.90,
        onlineBanking: 'https://example.com/sparkasse',
        createdAt: now,
      ),
      FibuAccount(
        id: 'acc_3',
        name: 'Kreditkarte',
        credit: -260.15,
        onlineBanking: '',
        createdAt: now,
      ),
    ];
  }

  List<FibuBudget> _defaultBudgets() {
    final now = DateTime.now();
    return [
      FibuBudget(id: 'budget_1', name: 'Miete', credit: 1200, createdAt: now),
      FibuBudget(
        id: 'budget_2',
        name: 'Lebensmittel',
        credit: 450,
        createdAt: now,
      ),
      FibuBudget(id: 'budget_3', name: 'Freizeit', credit: 280, createdAt: now),
    ];
  }

  List<FibuCategory> _defaultWhere() => const [
    FibuCategory(id: 'where_1', name: 'Miete'),
    FibuCategory(id: 'where_2', name: 'Supermarkt'),
    FibuCategory(id: 'where_3', name: 'Arbeit'),
    FibuCategory(id: 'where_4', name: 'Versicherung'),
    FibuCategory(id: 'where_5', name: 'Bahn'),
    FibuCategory(id: 'where_6', name: 'Buchung'),
  ];

  List<FibuCategory> _defaultWhat() => const [
    FibuCategory(id: 'what_1', name: 'Einnahmen'),
    FibuCategory(id: 'what_2', name: 'Lebensmittel'),
    FibuCategory(id: 'what_3', name: 'Haushalt'),
    FibuCategory(id: 'what_4', name: 'Mobilität'),
    FibuCategory(id: 'what_5', name: 'Freizeit'),
    FibuCategory(id: 'what_6', name: 'Umbuchung'),
  ];

  List<FibuRecurringBooking> _defaultRecurringBookings() {
    final today = DateTime.now();
    return [
      FibuRecurringBooking(
        id: 'recurring_1',
        accountId: 'acc_1',
        whatId: 'what_3',
        bookingDay: today.day.clamp(1, 28),
        amount: -1200.00,
        period: 'M',
      ),
      FibuRecurringBooking(
        id: 'recurring_2',
        accountId: 'acc_2',
        whatId: 'what_1',
        bookingDay: 25,
        amount: 1800.00,
        period: 'M',
      ),
    ];
  }

  List<FibuBooking> _defaultBookings() {
    final today = DateTime.now();
    final month = DateTime(today.year, today.month, 1);

    return [
      FibuBooking(
        id: 'booking_1',
        accountId: 'acc_1',
        date: month.toIso8601String().substring(0, 10),
        whereId: 'where_2',
        whatId: 'what_2',
        comment: 'Wochenmarkt',
        amount: -84.60,
        budgetId: 'budget_2',
        budgetAmount: -84.60,
      ),
      FibuBooking(
        id: 'booking_2',
        accountId: 'acc_2',
        date: month
            .add(const Duration(days: 3))
            .toIso8601String()
            .substring(0, 10),
        whereId: 'where_3',
        whatId: 'what_1',
        comment: 'Gehalt',
        amount: 2800.00,
        budgetId: null,
        budgetAmount: 0,
      ),
      FibuBooking(
        id: 'booking_3',
        accountId: 'acc_1',
        date: month
            .add(const Duration(days: 6))
            .toIso8601String()
            .substring(0, 10),
        whereId: 'where_1',
        whatId: 'what_3',
        comment: 'Miete',
        amount: -1200.00,
        budgetId: 'budget_1',
        budgetAmount: -1200.00,
      ),
    ];
  }
}
