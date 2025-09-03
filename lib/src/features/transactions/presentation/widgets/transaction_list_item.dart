import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ricashy_app/src/data/local_database/database.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US');
    final dateFormat = DateFormat.yMMMd();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(
            transaction.amount < 0 ? Icons.arrow_downward : Icons.arrow_upward,
          ),
        ),
        title: Text(transaction.description),
        subtitle: Text(dateFormat.format(transaction.date.toLocal())),
        trailing: Text(
          currencyFormat.format(transaction.amount),
          style: TextStyle(
            color: transaction.amount < 0 ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
