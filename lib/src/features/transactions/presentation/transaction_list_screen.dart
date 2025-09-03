import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';
import 'package:ricashy_app/src/features/transactions/presentation/widgets/transaction_list_item.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: transactionsAsyncValue.when(
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
    );
  }
}
