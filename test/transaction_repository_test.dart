import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/data/repositories/transaction_repository.dart';

void main() {
  late AppDatabase database;
  late TransactionRepository repository;

  setUp(() {
    database = AppDatabase(executor: NativeDatabase.memory());
    repository = TransactionRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('TransactionRepository', () {
    test('can insert a transaction', () async {
      final initialCount = await database.select(database.transactions).get().then((value) => value.length);

      final newTransaction = TransactionsCompanion.insert(
        description: 'Test Transaction',
        amount: 100.0,
        date: DateTime.now(),
      );
      final id = await repository.insertTransaction(newTransaction);

      expect(id, greaterThan(0));
      final updatedCount = await database.select(database.transactions).get().then((value) => value.length);
      expect(updatedCount, initialCount + 1);
    });

    test('can get all transactions', () async {
      // Insert a few transactions
      await repository.insertTransaction(TransactionsCompanion.insert(
        description: 'Transaction 1',
        amount: 50.0,
        date: DateTime.now(),
      ));
      await repository.insertTransaction(TransactionsCompanion.insert(
        description: 'Transaction 2',
        amount: 75.0,
        date: DateTime.now(),
      ));

      final transactions = await repository.getAllTransactions().first;
      expect(transactions.length, 2);
      expect(transactions[0].description, 'Transaction 1');
      expect(transactions[1].description, 'Transaction 2');
    });

    test('can update a transaction', () async {
      final initialDate = DateTime.now();
      final initialTransaction = TransactionsCompanion.insert(
        description: 'Original Transaction',
        amount: 200.0,
        date: initialDate,
      );
      final id = await repository.insertTransaction(initialTransaction);

      final updatedTransaction = TransactionsCompanion(
        id: Value(id),
        description: Value('Updated Transaction'),
        amount: Value(250.0),
        date: Value(initialDate), // Include the date
      );
      final success = await repository.updateTransaction(updatedTransaction);

      expect(success, isTrue);
      final retrievedTransaction = await (database.select(database.transactions)..where((t) => t.id.equals(id))).getSingle();
      expect(retrievedTransaction.description, 'Updated Transaction');
      expect(retrievedTransaction.amount, 250.0);
    });

    test('can delete a transaction', () async {
      final newTransaction = TransactionsCompanion.insert(
        description: 'Transaction to Delete',
        amount: 300.0,
        date: DateTime.now(),
      );
      final id = await repository.insertTransaction(newTransaction);

      final initialCount = await database.select(database.transactions).get().then((value) => value.length);
      final deletedCount = await repository.deleteTransaction(id);

      expect(deletedCount, 1);
      final updatedCount = await database.select(database.transactions).get().then((value) => value.length);
      expect(updatedCount, initialCount - 1);
    });
  });
}