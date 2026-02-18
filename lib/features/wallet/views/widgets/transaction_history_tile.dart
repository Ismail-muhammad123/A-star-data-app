import 'package:app/features/wallet/data/models/wallet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionHistoryTile extends StatelessWidget {
  final WalletTransaction transaction;
  const TransactionHistoryTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit =
        transaction.transactionType.toLowerCase() == 'credit' ||
        transaction.transactionType.toLowerCase().contains('fund');
    final amountColor = isCredit ? Colors.green[600] : Colors.red[600];
    final amountPrefix = isCredit ? "+" : "-";

    return InkWell(
      onTap:
          () => context.push(
            "/wallet/history/${transaction.id}",
            extra: transaction,
          ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isCredit ? Colors.green : Colors.blueAccent)
                    .withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.add_rounded : Icons.remove_rounded,
                color: isCredit ? Colors.green : Colors.blueAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.transactionType
                        .replaceAll("_", " ")
                        .toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat.yMMMd().add_jm().format(transaction.timestamp),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "$amountPrefix${NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0).format(transaction.amount)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "Success", // Typically successful if in history, or add status field
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
