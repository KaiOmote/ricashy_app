import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/widgets/transaction_list_item.dart';
import 'package:ricashy_app/src/features/transactions/presentation/providers/transaction_filter_provider.dart'; // Added import
import 'package:ricashy_app/src/features/transactions/presentation/providers/category_provider.dart'; // Added import
import 'package:intl/intl.dart'; // Added import for DateFormat

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);
    final filter = ref.watch(transactionFilterProvider);
    final filterNotifier = ref.read(transactionFilterProvider.notifier);
    final categoriesAsyncValue = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    filterNotifier.setSearchQuery(value);
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: filter.startDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          filterNotifier.setStartDate(pickedDate);
                        },
                        child: Text(filter.startDate == null
                            ? 'Start Date'
                            : DateFormat.yMMMd().format(filter.startDate!)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: filter.endDate ?? DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                          );
                          filterNotifier.setEndDate(pickedDate);
                        },
                        child: Text(filter.endDate == null
                            ? 'End Date'
                            : DateFormat.yMMMd().format(filter.endDate!)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        filterNotifier.setStartDate(null);
                        filterNotifier.setEndDate(null);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ChoiceChip(
                      label: const Text('All'),
                      selected: filter.transactionType == TransactionType.all,
                      onSelected: (selected) {
                        if (selected) {
                          filterNotifier.setTransactionType(TransactionType.all);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Income'),
                      selected: filter.transactionType == TransactionType.income,
                      onSelected: (selected) {
                        if (selected) {
                          filterNotifier.setTransactionType(TransactionType.income);
                        }
                      },
                    ),
                    ChoiceChip(
                      label: const Text('Expense'),
                      selected: filter.transactionType == TransactionType.expense,
                      onSelected: (selected) {
                        if (selected) {
                          filterNotifier.setTransactionType(TransactionType.expense);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                categoriesAsyncValue.when(
                  data: (categories) {
                    return Wrap(
                      spacing: 8.0,
                      children: categories.map((category) {
                        final isSelected = filter.selectedCategoryIds.contains(category.id);
                        return ChoiceChip(
                          label: Text(category.description),
                          selected: isSelected,
                          onSelected: (selected) {
                            filterNotifier.toggleCategory(category.id);
                          },
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error loading categories: $error'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    filterNotifier.resetFilters();
                  },
                  child: const Text('Reset Filters'),
                ),
              ],
            ),
          ),
          Expanded(
            child: transactionsAsyncValue.when(
              data: (transactions) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 100,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No transactions yet.',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        Text(
                          'Add a new transaction to get started.',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionListItem(transaction: transaction);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}