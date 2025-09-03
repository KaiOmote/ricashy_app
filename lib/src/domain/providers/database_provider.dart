import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/data/repositories/transaction_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return TransactionRepository(db);
});

final transactionsStreamProvider = StreamProvider<List<Transaction>>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return transactionRepository.getAllTransactions();
});