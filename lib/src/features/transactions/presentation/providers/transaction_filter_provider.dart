import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransactionType { income, expense, all }

class TransactionFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final int? categoryId;
  final TransactionType transactionType;

  TransactionFilterState({
    this.startDate,
    this.endDate,
    this.categoryId,
    this.transactionType = TransactionType.all,
  });

  TransactionFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    int? categoryId,
    TransactionType? transactionType,
  }) {
    return TransactionFilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      categoryId: categoryId ?? this.categoryId,
      transactionType: transactionType ?? this.transactionType,
    );
  }
}

final transactionFilterProvider = StateNotifierProvider<TransactionFilterNotifier, TransactionFilterState>((ref) {
  return TransactionFilterNotifier();
});

class TransactionFilterNotifier extends StateNotifier<TransactionFilterState> {
  TransactionFilterNotifier() : super(TransactionFilterState());

  void setDateRange(DateTime startDate, DateTime endDate) {
    state = state.copyWith(startDate: startDate, endDate: endDate);
  }

  void setCategory(int categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setTransactionType(TransactionType transactionType) {
    state = state.copyWith(transactionType: transactionType);
  }

  void clearFilters() {
    state = TransactionFilterState();
  }
}