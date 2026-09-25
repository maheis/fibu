import 'package:flutter/foundation.dart';

import 'models.dart';
import 'repository/app_repository.dart';

class AppController extends ChangeNotifier {
  AppController(this._repository);

  final AppRepository _repository;

  List<FibuAccount> accounts = const [];
  List<FibuBudget> budgets = const [];
  List<FibuCategory> whereCategories = const [];
  List<FibuCategory> whatCategories = const [];
  List<FibuBooking> bookings = const [];
  bool isLoaded = false;

  Future<void> load() async {
    accounts = await _repository.loadAccounts();
    budgets = await _repository.loadBudgets();
    whereCategories = await _repository.loadWhereCategories();
    whatCategories = await _repository.loadWhatCategories();
    bookings = await _repository.loadBookings();
    bookings.sort((a, b) => b.date.compareTo(a.date));
    isLoaded = true;
    notifyListeners();
  }

  double get totalBalance => accounts.fold<double>(0, (sum, item) => sum + item.credit);

  List<FibuBooking> bookingsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    return bookings.where((booking) {
      final bookingDate = DateTime.parse(booking.date);
      return !bookingDate.isBefore(start) && !bookingDate.isAfter(end);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  String accountName(String id) {
    final found = accounts.where((item) => item.id == id).firstOrNull;
    return found?.name ?? 'Unbekannt';
  }

  String budgetName(String? id) {
    if (id == null || id.isEmpty) return 'Ohne Budget';
    final found = budgets.where((item) => item.id == id).firstOrNull;
    return found?.name ?? 'Unbekannt';
  }

  String whereName(String id) {
    final found = whereCategories.where((item) => item.id == id).firstOrNull;
    return found?.name ?? 'Unbekannt';
  }

  String whatName(String id) {
    final found = whatCategories.where((item) => item.id == id).firstOrNull;
    return found?.name ?? 'Unbekannt';
  }

  Future<void> addAccount(String name, {String onlineBanking = '', bool isSubAccount = false}) async {
    final nextId = 'acc_${DateTime.now().millisecondsSinceEpoch}';
    final account = FibuAccount(
      id: nextId,
      name: name,
      credit: 0,
      onlineBanking: onlineBanking,
      isSubAccount: isSubAccount,
      createdAt: DateTime.now(),
    );
    accounts = [...accounts, account];
    await _repository.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> addBudget(String name, double credit) async {
    final nextId = 'budget_${DateTime.now().millisecondsSinceEpoch}';
    final budget = FibuBudget(
      id: nextId,
      name: name,
      credit: credit,
      createdAt: DateTime.now(),
    );
    budgets = [...budgets, budget];
    await _repository.saveBudgets(budgets);
    notifyListeners();
  }

  Future<void> addBooking({
    required String accountId,
    required String date,
    required String whereId,
    required String whatId,
    String comment = '',
    required double amount,
    String? budgetId,
    double budgetAmount = 0,
  }) async {
    final booking = FibuBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      accountId: accountId,
      date: date,
      whereId: whereId,
      whatId: whatId,
      comment: comment,
      amount: amount,
      budgetId: budgetId,
      budgetAmount: budgetAmount,
    );

    bookings = [booking, ...bookings];
    await _repository.saveBookings(bookings);
    notifyListeners();
  }

  Future<void> addSampleBooking() async {
    final today = DateTime.now();
    final date = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    await addBooking(
      accountId: accounts.first.id,
      date: date,
      whereId: whereCategories.first.id,
      whatId: whatCategories.first.id,
      comment: 'Demo-Buchung',
      amount: -42.50,
      budgetId: budgets.firstOrNull?.id,
      budgetAmount: -42.50,
    );
  }
}

extension IterableX<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
