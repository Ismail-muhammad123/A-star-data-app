import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:app/features/wallet/views/widgets/transaction_history_tile.dart';
import 'package:flutter/material.dart';

class TransactionHistoryList extends StatelessWidget {
  final List<WalletTransaction> transactions;
  const TransactionHistoryList({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder:
          (context, index) =>
              TransactionHistoryTile(transaction: transactions[index]),
    );
  }
}
