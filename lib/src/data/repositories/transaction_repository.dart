import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_filter_provider.dart'; // Added import
import 'package:drift/drift.dart' as drift; // Added import for drift.Value

class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  Future<int> insertTransaction(TransactionsCompanion entry) {
    return _db.into(_db.transactions).insert(entry);
  }

  Future<bool> updateTransaction(TransactionsCompanion entry) {
    return _db.update(_db.transactions).replace(entry);
  }

  Future<int> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Stream<List<Transaction>> getAllTransactions() {
    return _db.select(_db.transactions).watch();
  }

  Stream<List<Transaction>> getFilteredTransactions(TransactionFilterState filter) {
    // The query builder methods `where` and `orderBy` must be chained using the
    // cascade operator (`..`) to ensure all modifications are applied to the
    // same query object before `watch()` is called.
    final query = _db.select(_db.transactions)
      ..where((t) {
        var expression = t.id.isNotNull(); // Start with a true expression

        // Filter by date range
        if (filter.startDate != null) {
          expression = expression & t.date.isBiggerOrEqualValue(filter.startDate!);
        }
        if (filter.endDate != null) {
          final endOfDay = DateTime(filter.endDate!.year, filter.endDate!.month, filter.endDate!.day + 1);
          expression = expression & t.date.isSmallerThanValue(endOfDay);
        }

        // Filter by category
        if (filter.selectedCategoryIds.isNotEmpty) {
          expression = expression & t.categoryId.isIn(filter.selectedCategoryIds);
        }

        // Filter by transaction type
        if (filter.transactionType == TransactionType.income) {
          expression = expression & t.amount.isBiggerOrEqualValue(0.0);
        } else if (filter.transactionType == TransactionType.expense) {
          expression = expression & t.amount.isSmallerThanValue(0.0);
        }

        // Filter by search query
        if (filter.searchQuery.isNotEmpty) {
          expression = expression & t.description.like('%${filter.searchQuery}%');
        }

        return expression;
      })
      ..orderBy([
        (t) => drift.OrderingTerm(expression: t.date, mode: drift.OrderingMode.desc),
        (t) => drift.OrderingTerm(expression: t.description, mode: drift.OrderingMode.asc), // Secondary sort
      ]);

    return query.watch();
  }
}