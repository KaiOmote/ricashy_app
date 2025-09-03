import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/data/repositories/transaction_repository.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_filter_provider.dart'; // Added import

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

    group('getFilteredTransactions', () {
      setUp(() async {
        // Clear existing data
        await database.delete(database.transactions).go();
        await database.delete(database.categories).go();

        // Insert test data
        await database.into(database.categories).insert(CategoriesCompanion.insert(description: 'Food')); // id 1
        await database.into(database.categories).insert(CategoriesCompanion.insert(description: 'Transport')); // id 2

        await repository.insertTransaction(TransactionsCompanion.insert(
          description: 'Groceries',
          amount: -50.0,
          date: DateTime(2023, 10, 15),
          categoryId: Value(1),
        ));
        await repository.insertTransaction(TransactionsCompanion.insert(
          description: 'Bus Fare',
          amount: -5.0,
          date: DateTime(2023, 10, 16),
          categoryId: Value(2),
        ));
        await repository.insertTransaction(TransactionsCompanion.insert(
          description: 'Salary',
          amount: 1000.0,
          date: DateTime(2023, 10, 17),
          categoryId: Value(null), // No category
        ));
        await repository.insertTransaction(TransactionsCompanion.insert(
          description: 'Dinner',
          amount: -30.0,
          date: DateTime(2023, 10, 18),
          categoryId: Value(1),
        ));
      });

      test('filters by date range', () async {
        final filter = TransactionFilterState(
          startDate: DateTime(2023, 10, 16),
          endDate: DateTime(2023, 10, 17),
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 2);
        transactions.sort((a, b) => a.description.compareTo(b.description)); // Sort for consistent comparison
        expect(transactions[0].description, 'Bus Fare');
        expect(transactions[1].description, 'Salary');
      });

      test('filters by category', () async {
        final filter = TransactionFilterState(
          selectedCategoryIds: [1], // Food category
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 2);
        transactions.sort((a, b) => a.description.compareTo(b.description)); // Sort for consistent comparison
        expect(transactions[0].description, 'Dinner'); // Dinner comes before Groceries alphabetically
        expect(transactions[1].description, 'Groceries');
      });

      test('filters by transaction type (income)', () async {
        final filter = TransactionFilterState(
          transactionType: TransactionType.income,
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 1);
        expect(transactions[0].description, 'Salary');
      });

      test('filters by transaction type (expense)', () async {
        final filter = TransactionFilterState(
          transactionType: TransactionType.expense,
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 3);
        transactions.sort((a, b) => a.description.compareTo(b.description)); // Sort for consistent comparison
        expect(transactions[0].description, 'Bus Fare');
        expect(transactions[1].description, 'Dinner');
        expect(transactions[2].description, 'Groceries');
      });

      test('filters by search query', () async {
        final filter = TransactionFilterState(
          searchQuery: 'gr',
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 1);
        expect(transactions[0].description, 'Groceries');
      });

      test('filters by multiple criteria', () async {
        final filter = TransactionFilterState(
          startDate: DateTime(2023, 10, 16),
          endDate: DateTime(2023, 10, 18),
          selectedCategoryIds: [1],
          transactionType: TransactionType.expense,
          searchQuery: 'dinner',
        );
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 1);
        expect(transactions[0].description, 'Dinner');
      });

      test('returns all transactions when no filters are applied', () async {
        final filter = TransactionFilterState(); // Default filter
        final transactions = await repository.getFilteredTransactions(filter).first;
        expect(transactions.length, 4); // All 4 inserted transactions
        transactions.sort((a, b) => a.description.compareTo(b.description)); // Sort for consistent comparison
        expect(transactions[0].description, 'Bus Fare');
        expect(transactions[1].description, 'Dinner');
        expect(transactions[2].description, 'Groceries');
        expect(transactions[3].description, 'Salary');
      });
    });
  });
}