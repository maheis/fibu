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
  List<FibuRecurringBooking> recurringBookings = const [];
  bool isLoaded = false;

  Future<void> load() async {
    accounts = await _repository.loadAccounts();
    budgets = await _repository.loadBudgets();
    whereCategories = await _repository.loadWhereCategories();
    whatCategories = await _repository.loadWhatCategories();
    bookings = [...await _repository.loadBookings()];
    recurringBookings = await _repository.loadRecurringBookings();
    bookings.sort((a, b) => b.date.compareTo(a.date));
    isLoaded = true;
    notifyListeners();
  }

  double get totalBalance =>
      accounts.fold<double>(0, (sum, item) => sum + item.credit);

  List<FibuBooking> bookingsForMonth(DateTime month) {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 0);

    return bookings.where((booking) {
      final bookingDate = DateTime.parse(booking.date);
      return !bookingDate.isBefore(start) && !bookingDate.isAfter(end);
    }).toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  double totalForMonth(
    DateTime month, {
    bool incomeOnly = false,
    bool expenseOnly = false,
  }) {
    return bookingsForMonth(month).fold<double>(0, (sum, booking) {
      if (incomeOnly && booking.amount < 0) return sum;
      if (expenseOnly && booking.amount > 0) return sum;
      return sum + booking.amount;
    });
  }

  double totalForYear(
    int year, {
    bool incomeOnly = false,
    bool expenseOnly = false,
  }) {
    return bookings
        .where((booking) {
          final date = DateTime.parse(booking.date);
          return date.year == year;
        })
        .fold<double>(0, (sum, booking) {
          if (incomeOnly && booking.amount < 0) return sum;
          if (expenseOnly && booking.amount > 0) return sum;
          return sum + booking.amount;
        });
  }

  List<int> availableReportYears() {
    final years =
        bookings
            .map((booking) => DateTime.parse(booking.date).year)
            .toSet()
            .toList()
          ..sort((a, b) => b.compareTo(a));

    if (years.isEmpty) return [DateTime.now().year];
    return years;
  }

  List<MapEntry<String, double>> yearlyCategoryTotals(int year) {
    final totals = <String, double>{};

    for (final booking in bookings) {
      final date = DateTime.parse(booking.date);
      if (date.year != year) continue;
      final label = whatName(booking.whatId);
      totals[label] = (totals[label] ?? 0) + booking.amount;
    }

    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted;
  }

  List<MapEntry<int, double>> monthlyTotalsForYear(int year) {
    final totals = <int, double>{};

    for (var month = 1; month <= 12; month++) {
      totals[month] = totalForMonth(DateTime(year, month, 1));
    }

    return totals.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  }

  double budgetUsedForMonth(String budgetId, DateTime month) {
    return bookingsForMonth(month).fold<double>(0, (sum, booking) {
      if (booking.budgetId != budgetId) return sum;
      return sum + booking.amount;
    });
  }

  double budgetRemainingForMonth(String budgetId, DateTime month) {
    final budget = budgets.where((item) => item.id == budgetId).firstOrNull;
    if (budget == null) return 0;
    return budget.credit + budgetUsedForMonth(budgetId, month);
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

  Future<void> addAccount(
    String name, {
    String onlineBanking = '',
    bool isSubAccount = false,
  }) async {
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
    final accountIndex = accounts.indexWhere((item) => item.id == accountId);
    if (accountIndex >= 0) {
      final updatedAccount = accounts[accountIndex].copyWith(
        credit: accounts[accountIndex].credit + amount,
      );
      accounts = accounts
          .map((item) => item.id == accountId ? updatedAccount : item)
          .toList();
    }
    await _repository.saveBookings(bookings);
    await _repository.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> updateBooking(FibuBooking booking) async {
    final original = bookings.firstWhereOrNull((item) => item.id == booking.id);
    if (original != null) {
      final accountIndex = accounts.indexWhere(
        (item) => item.id == original.accountId,
      );
      if (accountIndex >= 0) {
        final restoredAccount = accounts[accountIndex].copyWith(
          credit: accounts[accountIndex].credit - original.amount,
        );
        accounts = accounts
            .map(
              (item) => item.id == original.accountId ? restoredAccount : item,
            )
            .toList();
      }
    }

    bookings = bookings
        .map((item) => item.id == booking.id ? booking : item)
        .toList();
    bookings.sort((a, b) => b.date.compareTo(a.date));

    final updatedAccountIndex = accounts.indexWhere(
      (item) => item.id == booking.accountId,
    );
    if (updatedAccountIndex >= 0) {
      final updatedAccount = accounts[updatedAccountIndex].copyWith(
        credit: accounts[updatedAccountIndex].credit + booking.amount,
      );
      accounts = accounts
          .map((item) => item.id == booking.accountId ? updatedAccount : item)
          .toList();
    }
    await _repository.saveBookings(bookings);
    await _repository.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> deleteBooking(String bookingId) async {
    final booking = bookings.firstWhereOrNull((item) => item.id == bookingId);
    if (booking != null) {
      final accountIndex = accounts.indexWhere(
        (item) => item.id == booking.accountId,
      );
      if (accountIndex >= 0) {
        final updatedAccount = accounts[accountIndex].copyWith(
          credit: accounts[accountIndex].credit - booking.amount,
        );
        accounts = accounts
            .map((item) => item.id == booking.accountId ? updatedAccount : item)
            .toList();
      }
    }
    bookings = bookings.where((item) => item.id != bookingId).toList();
    await _repository.saveBookings(bookings);
    await _repository.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> transferBetweenAccounts({
    required String fromAccountId,
    required String toAccountId,
    required String date,
    required double amount,
    String comment = '',
  }) async {
    if (fromAccountId.isEmpty ||
        toAccountId.isEmpty ||
        fromAccountId == toAccountId ||
        amount == 0) {
      return;
    }

    final transferWhere =
        whereCategories.where((item) => item.name == 'Buchung').firstOrNull ??
        (whereCategories.isNotEmpty
            ? whereCategories.first
            : const FibuCategory(id: 'where_transfer', name: 'Buchung'));
    final transferWhat =
        whatCategories.where((item) => item.name == 'Umbuchung').firstOrNull ??
        (whatCategories.isNotEmpty
            ? whatCategories.first
            : const FibuCategory(id: 'what_transfer', name: 'Umbuchung'));

    final transferNote = comment.trim().isEmpty
        ? 'Umbuchung von ${accountName(fromAccountId)} nach ${accountName(toAccountId)}'
        : '${comment.trim()} (Umbuchung von ${accountName(fromAccountId)} nach ${accountName(toAccountId)})';

    final outgoing = FibuBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}_out',
      accountId: fromAccountId,
      date: date,
      whereId: transferWhere.id,
      whatId: transferWhat.id,
      comment: transferNote,
      amount: -amount,
    );

    final incoming = FibuBooking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}_in',
      accountId: toAccountId,
      date: date,
      whereId: transferWhere.id,
      whatId: transferWhat.id,
      comment: transferNote,
      amount: amount,
    );

    bookings = [incoming, outgoing, ...bookings];
    bookings.sort((a, b) => b.date.compareTo(a.date));

    final fromIndex = accounts.indexWhere((item) => item.id == fromAccountId);
    final toIndex = accounts.indexWhere((item) => item.id == toAccountId);
    if (fromIndex >= 0) {
      final updated = accounts[fromIndex].copyWith(
        credit: accounts[fromIndex].credit - amount,
      );
      accounts = accounts
          .map((item) => item.id == fromAccountId ? updated : item)
          .toList();
    }
    if (toIndex >= 0) {
      final updated = accounts[toIndex].copyWith(
        credit: accounts[toIndex].credit + amount,
      );
      accounts = accounts
          .map((item) => item.id == toAccountId ? updated : item)
          .toList();
    }

    await _repository.saveBookings(bookings);
    await _repository.saveAccounts(accounts);
    notifyListeners();
  }

  Future<void> addRecurringBooking({
    required String accountId,
    required String whatId,
    required int bookingDay,
    required double amount,
    required String period,
  }) async {
    final recurring = FibuRecurringBooking(
      id: 'recurring_${DateTime.now().millisecondsSinceEpoch}',
      accountId: accountId,
      whatId: whatId,
      bookingDay: bookingDay,
      amount: amount,
      period: period,
    );

    recurringBookings = [recurring, ...recurringBookings];
    await _repository.saveRecurringBookings(recurringBookings);
    notifyListeners();
  }

  Future<int> applyRecurringBookingsForMonth(DateTime month) async {
    final bookingMonth = DateTime(month.year, month.month, 1);
    final transferWhere =
        whereCategories.where((item) => item.name == 'Buchung').firstOrNull ??
        (whereCategories.isNotEmpty
            ? whereCategories.first
            : const FibuCategory(id: 'where_recurring', name: 'Buchung'));
    final newBookings = <FibuBooking>[];

    for (final recurring in recurringBookings) {
      if (!_isRecurringDue(recurring.period, bookingMonth)) continue;

      final recurringBookingId =
          'booking_${recurring.id}_${bookingMonth.year}_${bookingMonth.month.toString().padLeft(2, '0')}';
      if (bookings.any((booking) => booking.id == recurringBookingId) ||
          newBookings.any((booking) => booking.id == recurringBookingId)) {
        continue;
      }

      final date = DateTime(
        bookingMonth.year,
        bookingMonth.month,
        recurring.bookingDay.clamp(1, 28),
      );
      newBookings.add(
        FibuBooking(
          id: recurringBookingId,
          accountId: recurring.accountId,
          date: _formatDate(date),
          whereId: transferWhere.id,
          whatId: recurring.whatId,
          comment: 'Dauerauftrag ${whatName(recurring.whatId)}',
          amount: recurring.amount,
        ),
      );
    }

    if (newBookings.isEmpty) return 0;

    bookings = [...newBookings, ...bookings]
      ..sort((a, b) => b.date.compareTo(a.date));
    for (final booking in newBookings) {
      final accountIndex = accounts.indexWhere(
        (item) => item.id == booking.accountId,
      );
      if (accountIndex < 0) continue;
      final updatedAccount = accounts[accountIndex].copyWith(
        credit: accounts[accountIndex].credit + booking.amount,
      );
      accounts = accounts
          .map((item) => item.id == booking.accountId ? updatedAccount : item)
          .toList();
    }

    await _repository.saveBookings(bookings);
    await _repository.saveAccounts(accounts);
    notifyListeners();
    return newBookings.length;
  }

  bool _isRecurringDue(String period, DateTime month) {
    return switch (period) {
      'Q' => (month.month - 1) % 3 == 0,
      'Y' => month.month == 1,
      _ => true,
    };
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Future<void> addSampleBooking() async {
    final today = DateTime.now();
    final date =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

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

  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (_) {
      return null;
    }
  }
}
