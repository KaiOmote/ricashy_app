import 'package:ricashy_app/src/data/local_database/database.dart';

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
}