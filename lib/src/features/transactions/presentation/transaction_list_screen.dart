import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';
import 'package:ricashy_app/src/domain/providers/database_provider.dart';

class TransactionListScreen extends ConsumerWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsyncValue = ref.watch(transactionsStreamProvider);

    return transactionsAsyncValue.when(
      data: (transactions) {
        if (transactions.isEmpty) {
          return const Center(
            child: Text('No transactions yet. Start adding some!'),
          );
        }
        return ListView.builder(
          itemCount: transactions.length,
          itemBuilder: (context, index) {
            final transaction = transactions[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Amount: ${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        color: transaction.amount < 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Date: ${transaction.date.toLocal().toString().split(' ')[0]}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    // TODO: Display category name instead of ID
                    Text(
                      'Category ID: ${transaction.categoryId ?? 'N/A'}',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}