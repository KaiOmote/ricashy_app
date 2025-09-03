import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_filter_provider.dart';

void main() {
  group('TransactionFilterNotifier', () {
    test('initial state is correct', () {
      final container = ProviderContainer();
      final filter = container.read(transactionFilterProvider);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.selectedCategoryIds, isEmpty);
      expect(filter.transactionType, TransactionType.all);
      expect(filter.searchQuery, isEmpty);
    });

    test('setStartDate updates the state', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      final date = DateTime(2023, 1, 1);
      notifier.setStartDate(date);
      expect(container.read(transactionFilterProvider).startDate, date);
    });

    test('setEndDate updates the state', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      final date = DateTime(2023, 1, 31);
      notifier.setEndDate(date);
      expect(container.read(transactionFilterProvider).endDate, date);
    });

    test('toggleCategory adds category if not present', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      notifier.toggleCategory(1);
      expect(container.read(transactionFilterProvider).selectedCategoryIds, [1]);
    });

    test('toggleCategory removes category if present', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      notifier.toggleCategory(1);
      notifier.toggleCategory(1);
      expect(container.read(transactionFilterProvider).selectedCategoryIds, isEmpty);
    });

    test('setTransactionType updates the state', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      notifier.setTransactionType(TransactionType.income);
      expect(container.read(transactionFilterProvider).transactionType, TransactionType.income);
    });

    test('setSearchQuery updates the state', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      notifier.setSearchQuery('test query');
      expect(container.read(transactionFilterProvider).searchQuery, 'test query');
    });

    test('resetFilters resets the state to initial values', () {
      final container = ProviderContainer();
      final notifier = container.read(transactionFilterProvider.notifier);
      notifier.setStartDate(DateTime(2023, 1, 1));
      notifier.setEndDate(DateTime(2023, 1, 31));
      notifier.toggleCategory(1);
      notifier.setTransactionType(TransactionType.expense);
      notifier.setSearchQuery('some query');

      notifier.resetFilters();

      final filter = container.read(transactionFilterProvider);
      expect(filter.startDate, isNull);
      expect(filter.endDate, isNull);
      expect(filter.selectedCategoryIds, isEmpty);
      expect(filter.transactionType, TransactionType.all);
      expect(filter.searchQuery, isEmpty);
    });
  });
}
