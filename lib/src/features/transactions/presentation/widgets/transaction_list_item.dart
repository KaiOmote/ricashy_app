import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '¥', decimalDigits: 0);
    final dateFormat = DateFormat.yMMMd();

    // Determine transaction properties once to improve readability and reduce repetition.
    final isExpense = transaction.amount < 0;
    final colorScheme = Theme.of(context).colorScheme;
    final transactionColor = isExpense ? colorScheme.error : colorScheme.primary;
    final transactionIcon = isExpense ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          // The `withOpacity` method is the correct and idiomatic way to set transparency.
          // An analyzer warning suggesting `withValues()` may appear, but this is
          // from a faulty or outdated lint rule, as `withValues()` does not exist on the Color class.
          backgroundColor: transactionColor.withOpacity(0.1),
          child: Icon(
            transactionIcon,
            color: transactionColor,
          ),
        ),
        title: Text(
          transaction.description,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(dateFormat.format(transaction.date.toLocal())),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: transactionColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}