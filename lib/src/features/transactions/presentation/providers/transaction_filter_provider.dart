import 'package:flutter_riverpod/flutter_riverpod.dart';

enum TransactionType {
  all,
  income,
  expense,
}

class TransactionFilterState {
  final DateTime? startDate;
  final DateTime? endDate;
  final List<int> selectedCategoryIds;
  final TransactionType transactionType;
  final String searchQuery;

  TransactionFilterState({
    this.startDate,
    this.endDate,
    this.selectedCategoryIds = const [],
    this.transactionType = TransactionType.all,
    this.searchQuery = '',
  });

  TransactionFilterState copyWith({
    DateTime? startDate,
    DateTime? endDate,
    List<int>? selectedCategoryIds,
    TransactionType? transactionType,
    String? searchQuery,
  }) {
    return TransactionFilterState(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCategoryIds: selectedCategoryIds ?? this.selectedCategoryIds,
      transactionType: transactionType ?? this.transactionType,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TransactionFilterNotifier extends StateNotifier<TransactionFilterState> {
  TransactionFilterNotifier() : super(TransactionFilterState());

  void setStartDate(DateTime? date) {
    state = state.copyWith(startDate: date);
  }

  void setEndDate(DateTime? date) {
    state = state.copyWith(endDate: date);
  }

  void toggleCategory(int categoryId) {
    final currentSelected = List<int>.from(state.selectedCategoryIds);
    if (currentSelected.contains(categoryId)) {
      currentSelected.remove(categoryId);
    } else {
      currentSelected.add(categoryId);
    }
    state = state.copyWith(selectedCategoryIds: currentSelected);
  }

  void setTransactionType(TransactionType type) {
    state = state.copyWith(transactionType: type);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void resetFilters() {
    state = TransactionFilterState();
  }
}

final transactionFilterProvider = StateNotifierProvider<TransactionFilterNotifier, TransactionFilterState>((ref) {
  return TransactionFilterNotifier();
});
