import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionHistoryTile extends StatelessWidget {
  final WalletTransaction transaction;
  const TransactionHistoryTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Card(
        child: ListTile(
          onTap:
              () => context.push(
                "/wallet/history/${transaction.id}",
                extra: transaction,
              ),
          tileColor: Colors.white,
          leading: CircleAvatar(
            backgroundColor: const Color.fromARGB(37, 164, 164, 164),
            child: Icon(Icons.history, size: 30),
          ),
          title: Text(
            transaction.transactionType.toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            NumberFormat.currency(
              locale: 'en_NG',
              symbol: '₦',
              decimalDigits: 2,
            ).format(transaction.amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          trailing: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                DateFormat.yMMMd().format(transaction.timestamp),
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              // Text(
              //   transaction.status,
              //   style: TextStyle(fontSize: 14, color: Colors.orange),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
