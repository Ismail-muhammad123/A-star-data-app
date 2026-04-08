import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TransferDepositAccountInfoCard extends StatefulWidget {
  final String accountNumber;
  final String bankName;
  final String accountName;
  final double? amount;
  final Color? color;
  final bool compact;
  const TransferDepositAccountInfoCard({
    super.key,
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    this.amount,
    this.color,
    this.compact = false,
  });

  @override
  State<TransferDepositAccountInfoCard> createState() =>
      _TransferDepositAccountInfoCardState();
}

class _TransferDepositAccountInfoCardState
    extends State<TransferDepositAccountInfoCard> {
  @override
  Widget build(BuildContext context) {
    final isCompact = widget.compact;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isCompact ? 14 : 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isCompact ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F2027).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isCompact ? 6 : 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(isCompact ? 10 : 12),
                      ),
                      child: Icon(
                        Icons.account_balance,
                        color: Colors.white,
                        size: isCompact ? 16 : 20,
                      ),
                    ),
                    SizedBox(width: isCompact ? 8 : 12),
                    Expanded(
                      child: Text(
                        widget.bankName,
                        style: TextStyle(
                          fontSize: isCompact ? 14 : 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: isCompact ? 0.6 : 1.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isCompact)
                const Icon(
                  Icons.wifi,
                  color: Colors.white70,
                  size: 28,
                ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.accountNumber.replaceAllMapped(
                    RegExp(r".{4}"),
                    (match) => "${match.group(0)} ",
                  ),
                  style: TextStyle(
                    fontSize: isCompact ? 20 : 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: isCompact ? 1.2 : 2,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: widget.accountNumber));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account number copied to clipboard',
                        style: TextStyle(color: Colors.white),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF203A43),
                    ),
                  );
                },
                icon: Icon(
                  Icons.copy,
                  color: Colors.white70,
                  size: isCompact ? 18 : 20,
                ),
                tooltip: "Copy Account Number",
              ),
            ],
          ),
          SizedBox(height: isCompact ? 12 : 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: _buildInfoItem(
                  "ACCOUNT NAME",
                  widget.accountName.toUpperCase(),
                  compact: isCompact,
                ),
              ),
              SizedBox(width: isCompact ? 8 : 16),
              InkWell(
                onTap: () {
                  final textToCopy =
                      "Account Name: ${widget.accountName}\nAccount Number: ${widget.accountNumber}\nBank Name: ${widget.bankName}";
                  Clipboard.setData(ClipboardData(text: textToCopy));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Account details copied to clipboard',
                        style: TextStyle(color: Colors.white),
                      ),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Color(0xFF203A43),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.copy,
                        size: isCompact ? 12 : 14,
                        color: Colors.white,
                      ),
                      SizedBox(width: isCompact ? 4 : 6),
                      Text(
                        "COPY",
                        style: TextStyle(
                          fontSize: isCompact ? 10 : 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (widget.amount != null) ...[
            SizedBox(height: isCompact ? 12 : 24),
            Container(
              padding: EdgeInsets.all(isCompact ? 10 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isCompact ? 12 : 16),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Expected Amount',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  Text(
                    '₦${widget.amount?.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: isCompact ? 15 : 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    String label,
    String value, {
    bool compact = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: compact ? 9 : 10,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
            letterSpacing: compact ? 1.1 : 1.5,
          ),
        ),
        SizedBox(height: compact ? 2 : 4),
        Text(
          value,
          style: TextStyle(
            fontSize: compact ? 12 : 14,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: compact ? 0.6 : 1,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }
}
