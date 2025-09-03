import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:drift/drift.dart' as drift;

class TransactionFormState {
  final String description;
  final double amount;
  final DateTime date;
  final int? categoryId;
  final bool isExpense;

  TransactionFormState({
    this.description = '',
    this.amount = 0.0,
    required this.date,
    this.categoryId,
    this.isExpense = true,
  });

  TransactionFormState copyWith({
    String? description,
    double? amount,
    DateTime? date,
    int? categoryId,
    bool? isExpense,
  }) {
    return TransactionFormState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      isExpense: isExpense ?? this.isExpense,
    );
  }
}

class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  TransactionFormNotifier(this.ref) : super(TransactionFormState(date: DateTime.now()));

  final Ref ref;

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
  }

  void setDate(DateTime date) {
    state = state.copyWith(date: date);
  }

  void setCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setIsExpense(bool isExpense) {
    state = state.copyWith(isExpense: isExpense);
  }

  Future<void> submitTransaction() async {
    final transactionRepository = ref.read(transactionRepositoryProvider);

    final newTransaction = TransactionsCompanion(
      description: drift.Value(state.description),
      amount: drift.Value(state.amount * (state.isExpense ? -1 : 1)),
      date: drift.Value(state.date),
      categoryId: drift.Value(state.categoryId),
    );

    await transactionRepository.insertTransaction(newTransaction);
  }

  void resetForm() {
    state = TransactionFormState(date: DateTime.now());
  }
}

final transactionFormNotifierProvider = StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  return TransactionFormNotifier(ref);
});