import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferDepositAccountInfoCard extends StatefulWidget {
  final String accountNumber;
  final String bankName;
  final String accountName;
  final double? amount;
  final Color? color;
  const TransferDepositAccountInfoCard({
    super.key,
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    this.amount,
    this.color,
  });

  @override
  State<TransferDepositAccountInfoCard> createState() =>
      _TransferDepositAccountInfoCardState();
}

class _TransferDepositAccountInfoCardState
    extends State<TransferDepositAccountInfoCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(47, 158, 158, 158),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.bankName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Account Name: ${widget.accountName}',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                'Account Number: ${widget.accountNumber}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 18),
                tooltip: 'Copy Account Number',
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.accountNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Account number copied to clipboard'),
                    ),
                  );
                },
              ),
            ],
          ),
          widget.amount == null ? SizedBox() : const Divider(height: 24),
          widget.amount == null
              ? SizedBox()
              : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Amount',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  Text(
                    '₦${widget.amount?.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
        ],
      ),
    );
  }
}
