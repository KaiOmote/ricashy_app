import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';

/// Represents the state of the transaction form.
class TransactionFormState {
  final String description;
  final double amount;
  final DateTime date;
  final bool isExpense;
  final int? categoryId;

  TransactionFormState({
    this.description = '',
    this.amount = 0.0,
    DateTime? date,
    this.isExpense = true,
    this.categoryId,
  }) : date = date ?? DateTime.now();

  TransactionFormState copyWith({
    String? description,
    double? amount,
    DateTime? date,
    bool? isExpense,
    int? categoryId,
  }) {
    return TransactionFormState(
      description: description ?? this.description,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      isExpense: isExpense ?? this.isExpense,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

/// Manages the state of the transaction form.
class TransactionFormNotifier extends StateNotifier<TransactionFormState> {
  TransactionFormNotifier(this._transactionRepository) : super(TransactionFormState());

  final TransactionRepository _transactionRepository;

  void setDescription(String description) => state = state.copyWith(description: description);

  void setAmount(double amount) => state = state.copyWith(amount: amount);

  void setDate(DateTime date) => state = state.copyWith(date: date);

  void setIsExpense(bool isExpense) => state = state.copyWith(isExpense: isExpense);

  void setCategoryId(int? categoryId) => state = state.copyWith(categoryId: categoryId);

  Future<void> submitTransaction() async {
    final amount = state.isExpense ? -state.amount.abs() : state.amount.abs();
    final transaction = TransactionsCompanion(
      description: drift.Value(state.description),
      amount: drift.Value(amount),
      date: drift.Value(state.date),
      categoryId: drift.Value(state.categoryId),
    );
    await _transactionRepository.insertTransaction(transaction);
  }

  void resetForm() => state = TransactionFormState();
}

/// Provider for the transaction form notifier.
final transactionFormNotifierProvider = StateNotifierProvider<TransactionFormNotifier, TransactionFormState>((ref) {
  final transactionRepository = ref.watch(transactionRepositoryProvider);
  return TransactionFormNotifier(transactionRepository);
});